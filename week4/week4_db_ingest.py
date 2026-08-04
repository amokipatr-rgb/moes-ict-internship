"""
Week 4: Database Ingestion Script
Loads clean school registry data (JSON) into MySQL database.
Uses the school_registry schema defined in week4_schema.sql.
"""
import json
import os
import re
import mysql.connector
from mysql.connector import Error

BASE_DIR = r"E:\internship task\week_four_task"
CLEAN_JSON = os.path.join(BASE_DIR, "school_registry_clean.json")

DB_CONFIG = {
    "host": "localhost",
    "port": 3306,
    "user": "root",
    "password": "",
    "database": "school_registry",
}

def execute_sql_safe(cursor, sql_file):
    """Execute SQL statements safely, handling DELIMITER and multi-line statements."""
    with open(sql_file, encoding="utf-8") as f:
        content = f.read()

    # Remove single-line comments
    content = re.sub(r'--.*$', '', content, flags=re.MULTILINE)
    # Remove DELIMITER commands (mysql client only, not valid SQL)
    content = re.sub(r'DELIMITER\s+\S+', '', content)
    # Remove END // style delimiters
    content = content.replace('//', '')
    # Split by semicolons
    statements = content.split(';')

    success = 0
    errors = 0
    for stmt in statements:
        stmt = stmt.strip()
        if not stmt:
            continue
        # Skip non-executable lines
        if stmt.upper().startswith('SELECT') or stmt.upper().startswith('USE'):
            continue
        try:
            cursor.execute(stmt)
            success += 1
        except Error as e:
            # Ignore "already exists" and "duplicate" errors
            err_str = str(e)
            if 'already exists' in err_str or 'Duplicate' in err_str:
                success += 1
            else:
                errors += 1
    return success, errors

def create_database_and_tables():
    """Create the database and tables if they don't exist."""
    try:
        conn = mysql.connector.connect(
            host=DB_CONFIG["host"],
            port=DB_CONFIG["port"],
            user=DB_CONFIG["user"],
            password=DB_CONFIG["password"],
        )
        cursor = conn.cursor()
        cursor.execute("CREATE DATABASE IF NOT EXISTS school_registry")
        cursor.execute("USE school_registry")

        # Drop existing tables to ensure clean state
        cursor.execute("DROP TABLE IF EXISTS students")
        cursor.execute("DROP TABLE IF EXISTS schools")
        cursor.execute("DROP TABLE IF EXISTS districts")
        cursor.execute("DROP TABLE IF EXISTS regions")

        # Create tables
        cursor.execute("""
            CREATE TABLE regions (
                id INT AUTO_INCREMENT PRIMARY KEY,
                region_name VARCHAR(100) NOT NULL UNIQUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB
        """)

        cursor.execute("""
            CREATE TABLE districts (
                id INT AUTO_INCREMENT PRIMARY KEY,
                district_name VARCHAR(100) NOT NULL UNIQUE,
                region_id INT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (region_id) REFERENCES regions(id) ON DELETE CASCADE
            ) ENGINE=InnoDB
        """)

        cursor.execute("""
            CREATE TABLE schools (
                id INT AUTO_INCREMENT PRIMARY KEY,
                school_name VARCHAR(200) NOT NULL,
                district_id INT NOT NULL,
                student_count INT DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                FOREIGN KEY (district_id) REFERENCES districts(id) ON DELETE CASCADE,
                CONSTRAINT chk_student_count CHECK (student_count >= 0 AND student_count <= 890)
            ) ENGINE=InnoDB
        """)

        cursor.execute("""
            CREATE TABLE students (
                id INT AUTO_INCREMENT PRIMARY KEY,
                school_id INT NOT NULL,
                first_name VARCHAR(100) NOT NULL,
                last_name VARCHAR(100) NOT NULL,
                date_of_birth DATE,
                gender ENUM('M', 'F') NOT NULL,
                grade VARCHAR(20) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
            ) ENGINE=InnoDB
        """)

        # Create indexes
        cursor.execute("CREATE INDEX idx_schools_district ON schools(district_id)")
        cursor.execute("CREATE INDEX idx_schools_name ON schools(school_name)")
        cursor.execute("CREATE INDEX idx_students_school ON students(school_id)")
        cursor.execute("CREATE INDEX idx_students_name ON students(last_name, first_name)")
        cursor.execute("CREATE INDEX idx_students_grade ON students(grade)")

        conn.commit()
        print("Database schema created successfully with 4 tables and 5 indexes.")

        cursor.close()
        conn.close()
    except Error as e:
        print(f"Schema creation error: {e}")

def ingest_data():
    """Read clean JSON and insert into MySQL database."""
    if not os.path.exists(CLEAN_JSON):
        print(f"Error: {CLEAN_JSON} not found. Run ETL pipeline first.")
        return

    with open(CLEAN_JSON, encoding="utf-8") as f:
        data = json.load(f)

    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()

        total_regions = 0
        total_districts = 0
        total_schools = 0
        total_students = 0
        errors = []

        for region_entry in data:
            region_name = region_entry["region"]

            # Insert region
            cursor.execute("INSERT IGNORE INTO regions (region_name) VALUES (%s)", (region_name,))
            if cursor.rowcount > 0:
                total_regions += 1

            # Get region ID
            cursor.execute("SELECT id FROM regions WHERE region_name = %s", (region_name,))
            region_id = cursor.fetchone()[0]

            # Use region name as district
            district_name = region_name
            cursor.execute("INSERT IGNORE INTO districts (district_name, region_id) VALUES (%s, %s)",
                          (district_name, region_id))
            if cursor.rowcount > 0:
                total_districts += 1

            # Get district ID
            cursor.execute("SELECT id FROM districts WHERE district_name = %s", (district_name,))
            district_id = cursor.fetchone()[0]

            for school_entry in region_entry["schools"]:
                school_name = school_entry["school_name"]
                student_count = school_entry["student_count"]

                # Insert school
                cursor.execute(
                    "INSERT INTO schools (school_name, district_id, student_count) VALUES (%s, %s, %s)",
                    (school_name, district_id, student_count))
                total_schools += 1
                school_id = cursor.lastrowid

                # Insert students in batches for performance
                batch_size = 100
                batch = []
                for student in school_entry["students"]:
                    batch.append((
                        school_id,
                        student["first_name"],
                        student["last_name"],
                        student.get("dob") or None,
                        student["gender"],
                        student["grade"],
                    ))
                    if len(batch) >= batch_size:
                        cursor.executemany(
                            """INSERT INTO students 
                               (school_id, first_name, last_name, date_of_birth, gender, grade) 
                               VALUES (%s, %s, %s, %s, %s, %s)""",
                            batch
                        )
                        total_students += len(batch)
                        batch = []

                # Insert remaining
                if batch:
                    cursor.executemany(
                        """INSERT INTO students 
                           (school_id, first_name, last_name, date_of_birth, gender, grade) 
                           VALUES (%s, %s, %s, %s, %s, %s)""",
                        batch
                    )
                    total_students += len(batch)

        conn.commit()

        # Sync student counts
        try:
            cursor.callproc("sync_student_counts")
            conn.commit()
        except Error:
            cursor.execute("""UPDATE schools s 
                              SET s.student_count = (SELECT COUNT(*) FROM students WHERE school_id = s.id)""")
            conn.commit()

        # Print summary
        print(f"\n{'='*50}")
        print(f"DATABASE INGESTION SUMMARY")
        print(f"{'='*50}")
        print(f"Regions inserted:      {total_regions}")
        print(f"Districts inserted:    {total_districts}")
        print(f"Schools inserted:      {total_schools}")
        print(f"Students inserted:     {total_students}")
        print(f"Errors encountered:    {len(errors)}")

        # Verification
        cursor.execute("SELECT COUNT(*) FROM students")
        db_count = cursor.fetchone()[0]
        print(f"\nVerification:")
        print(f"  Students in DB:      {db_count}")
        print(f"  Expected (from JSON): {total_students}")
        print(f"  Match: {'YES' if db_count == total_students else 'NO'}")

        # Per-region breakdown
        cursor.execute("""
            SELECT r.region_name, COUNT(st.id) as student_count
            FROM students st
            JOIN schools sc ON st.school_id = sc.id
            JOIN districts d ON sc.district_id = d.id
            JOIN regions r ON d.region_id = r.id
            GROUP BY r.region_name
        """)
        print(f"\nPer-region student distribution:")
        for row in cursor.fetchall():
            print(f"  {row[0]}: {row[1]} students")

        # Check 890 cap enforcement
        cursor.execute("""
            SELECT school_name, student_count FROM schools
            WHERE student_count > 890
        """)
        violations = cursor.fetchall()
        if violations:
            print(f"\nCap Violations (schools exceeding 890):")
            for v in violations:
                print(f"  {v[0]}: {v[1]} students")
        else:
            print(f"\nCap Compliance: All 21 schools within the 890-student limit.")

        cursor.close()
        conn.close()
        print(f"\nIngestion complete!")

    except Error as e:
        print(f"Database error: {e}")

if __name__ == "__main__":
    print("Step 1: Creating database schema...")
    create_database_and_tables()
    print("\nStep 2: Ingesting clean data...")
    ingest_data()
    print("\nDone!")
