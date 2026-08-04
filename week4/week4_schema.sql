-- =====================================================
-- Week 4: Relational Database Schema for School Registry
-- Ministry of Education and Sports - ICT Department
-- =====================================================

-- Create database
CREATE DATABASE IF NOT EXISTS school_registry;
USE school_registry;

-- =====================================================
-- 1. REGIONS TABLE (Lookup)
-- =====================================================
CREATE TABLE IF NOT EXISTS regions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    region_name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =====================================================
-- 2. DISTRICTS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS districts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    district_name VARCHAR(100) NOT NULL UNIQUE,
    region_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (region_id) REFERENCES regions(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================
-- 3. SCHOOLS TABLE
-- Student count constrained to max 890
-- =====================================================
CREATE TABLE IF NOT EXISTS schools (
    id INT AUTO_INCREMENT PRIMARY KEY,
    school_name VARCHAR(200) NOT NULL,
    district_id INT NOT NULL,
    student_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (district_id) REFERENCES districts(id) ON DELETE CASCADE,
    CONSTRAINT chk_student_count CHECK (student_count >= 0 AND student_count <= 890)
) ENGINE=InnoDB;

-- =====================================================
-- 4. STUDENTS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS students (
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
) ENGINE=InnoDB;

-- =====================================================
-- 5. INDEXES for performance
-- =====================================================
CREATE INDEX idx_schools_district ON schools(district_id);
CREATE INDEX idx_schools_name ON schools(school_name);
CREATE INDEX idx_students_school ON students(school_id);
CREATE INDEX idx_students_name ON students(last_name, first_name);
CREATE INDEX idx_students_grade ON students(grade);

-- =====================================================
-- 6. STRUCTURAL MAINTENANCE SCRIPTS
-- =====================================================

-- 6a. Update student_count in schools (sync after inserts)
-- Run periodically to keep school student_count accurate
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS sync_student_counts()
BEGIN
    UPDATE schools s
    SET s.student_count = (
        SELECT COUNT(*) FROM students WHERE school_id = s.id
    );
END //
DELIMITER ;

-- 6b. Find orphaned records
-- Students without a valid school
SELECT 'Orphaned Students Check' as '';
SELECT COUNT(*) AS orphan_count FROM students WHERE school_id NOT IN (SELECT id FROM schools);

-- 6c. View table relationships
SELECT 
    TABLE_NAME, 
    COLUMN_NAME, 
    CONSTRAINT_NAME, 
    REFERENCED_TABLE_NAME, 
    REFERENCED_COLUMN_NAME 
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
WHERE TABLE_SCHEMA = 'school_registry' 
    AND REFERENCED_TABLE_NAME IS NOT NULL;

-- =====================================================
-- 7. DUPLICATE CLEANUP SCRIPTS
-- =====================================================

-- 7a. Find duplicate students (same name + same school)
SELECT 
    s.school_name,
    st.first_name,
    st.last_name,
    COUNT(*) AS duplicate_count,
    GROUP_CONCAT(st.id ORDER BY st.id) AS student_ids
FROM students st
JOIN schools s ON st.school_id = s.id
GROUP BY st.school_id, st.first_name, st.last_name
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- 7b. Remove duplicates keeping the earliest entry (lowest ID)
DELETE st1 FROM students st1
INNER JOIN students st2
WHERE 
    st1.id > st2.id 
    AND st1.school_id = st2.school_id 
    AND st1.first_name = st2.first_name 
    AND st1.last_name = st2.last_name;

-- 7c. Find schools exceeding 890 student limit
SELECT 
    s.school_name,
    s.student_count AS recorded_count,
    COUNT(st.id) AS actual_count
FROM schools s
LEFT JOIN students st ON s.id = st.school_id
GROUP BY s.id, s.school_name, s.student_count
HAVING COUNT(st.id) > 890;

-- =====================================================
-- 8. FOREIGN KEY RELATIONSHIP MAP
-- =====================================================
-- regions 1---* districts
-- districts 1---* schools
-- schools 1---* students
--
-- regions: stores Kampala, Gulu, Mbarara
-- districts: specific districts within regions
-- schools: individual schools with enrollment cap (<= 890)
-- students: individual student records tied to a school

-- =====================================================
-- 9. DATA QUALITY CHECKS
-- =====================================================

-- 9a. Students with missing or invalid data
SELECT 'Data Quality Issues' AS '';
SELECT * FROM students
WHERE 
    first_name IS NULL OR first_name = ''
    OR last_name IS NULL OR last_name = ''
    OR gender NOT IN ('M', 'F')
    OR grade IS NULL OR grade = ''
LIMIT 20;

-- 9b. Gender distribution
SELECT gender, COUNT(*) AS count FROM students GROUP BY gender;

-- 9c. Grade distribution
SELECT grade, COUNT(*) AS count FROM students GROUP BY grade ORDER BY grade;
