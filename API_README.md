# ETL Pipeline — Technical Reference (API_README)

## Overview

The ETL pipeline (`week4_etl_cleaner_documented.py`) reads a messy CSV of student registrations, normalises all fields, validates records, removes duplicates, and outputs clean structured JSON ready for database ingestion.

- **Domain:** Uganda Ministry of Education (MoES) / EMIS
- **Regions:** Kampala, Gulu, Mbarara (21 schools)
- **Student cap:** 890 per school (enforced)
- **Final result:** 8,314 clean records from 8,339 raw (25 duplicates removed, 0 invalid)

---

## Function Reference

### `normalize_text(text: Optional[str]) -> str`
Normalises general text — strips whitespace, collapses spaces, title-cases (with stop-word exceptions).

| Input | Output |
|-------|--------|
| `"  ST. JOSEPH'S SCHOOL  "` | `"St. Joseph's School"` |
| `"old kampala secondary"` | `"Old Kampala Secondary"` |

### `normalize_name(text: Optional[str]) -> str`
Normalises personal names — strips non-alpha characters except hyphens and apostrophes, then title-cases.

| Input | Output |
|-------|--------|
| `"  john 12 doe!  "` | `"John Doe"` |
| `"o'brien-okello"` | `"O'Brien-Okello"` |

### `normalize_grade(text: Optional[str]) -> str`
Normalises grade to `P.N` or `S.N` format.

| Input | Output |
|-------|--------|
| `"primary 1"` | `"P.1"` |
| `"SENIOR 3"` | `"S.3"` |
| `"s.5"` | `"S.5"` |

### `parse_dob(text: Optional[str]) -> Optional[str]`
Parses date-of-birth from multiple formats to `YYYY-MM-DD`.

| Input | Output |
|-------|--------|
| `"2005-03-15"` | `"2005-03-15"` |
| `"03/15/2005"` | `"2005-15-03"` (day/month heuristic) |
| `"15-03-2005"` | `"2005-03-15"` |
| `""` | `None` |

### `normalize_gender(text: Optional[str]) -> str`
Normalises gender to `M` or `F`.

| Input | Output |
|-------|--------|
| `"Male"` | `"M"` |
| `"female"` | `"F"` |

### `match_school(raw_name: str) -> tuple[str, Optional[str]]`
Matches a raw school name to a known school. Returns `(school_name, region)`.

| Input | Output |
|-------|--------|
| `"kampala high"` | `("Kampala High School", "Kampala")` |
| `"Unknown School"` | `("Unknown School", None)` |

### `run_etl() -> tuple[list[dict], dict]`
Main pipeline orchestrator. Reads `school_registry_raw.csv`, processes all records, writes:
- `school_registry_clean.json` (hierarchical)
- `school_registry_clean.md` (markdown tables)
- `etl_summary.json` (transform statistics)
- `data_integrity_report.json` (validation results)

Returns `(ingest_data, stats)`.

---

## Data Flow

```
CSV (8,339 rows)
    │
    ▼
normalize_text()  normalize_name()  normalize_grade()  parse_dob()  normalize_gender()
    │
    ▼
Validate (drop missing names, default genders)
    │
    ▼
Deduplicate (composite key: first_name + last_name + school)
    │
    ▼
Structure (region → school → students)
    │
    ▼
JSON + Markdown + Integrity Report (8,314 clean, 25 dupes removed)
```

---

## Error Handling

| Scenario | Behaviour |
|----------|-----------|
| Missing CSV file | Prints error, returns empty |
| Unparseable date | Returns `None` (field left null) |
| Missing first/last name | Record removed, counted in `invalid_removed` |
| Unrecognised school name | Original name preserved, region left as-is |
| EOF/encoding errors | Propagates (CSV must be UTF-8) |

---

## Dependencies

- Python 3.10+
- Standard library: `csv`, `json`, `re`, `os`, `collections`
- No third-party packages required

---

## Usage

```bash
python week4_etl_cleaner_documented.py
```

Output files are written to the directory specified in `OUT_DIR`.

---

## Test Coverage

See `test_etl_cleaner.py` for 10+ unit tests covering:
- Text/name/grade/gender normalisation
- Date parsing (6 formats)
- School name matching (exact + partial)
- Duplicate detection
- Region mapping
- Empty/edge-case inputs

---

## Rationale — Why This Document Exists

1. **Separation of concerns.** Pipeline code (`week4_etl_cleaner_documented.py`) focuses on correct logic; the API reference documents the contract without cluttering the source.
2. **Audience.** NITA-U auditors, EMIS administrators, and future interns need a quick-entry guide — they should not have to read 512 lines of Python to understand what the pipeline does.
3. **Onboarding.** A new intern can read this document in 5 minutes and know input requirements, output structure, and error behaviour without running a single command.

### Why pytest over unittest?

- `pytest` requires ~60 % less boilerplate (no `self`, no class inheritance required).
- Failing output is colour-coded and shows local variable values by default.
- `pytest` is the de facto standard in the Python data engineering community — the same ecosystem used by MoES/EMIS data teams.

### Why imperative mood in Git commits ("feat: add", "fix: correct")?

The Conventional Commits specification (widely adopted in open-source and government projects) uses the imperative mood because each commit message completes the sentence *"This commit will..."*. This makes history scannable and generates consistent CHANGELOGs automatically.

### Why Google-style docstrings?

Google-style is chosen over NumPy or reStructuredText because it is the most compact while remaining Sphinx-compatible. In a 512-line pipeline script, NumPy-style would add ~30 % vertical overhead for no additional information — every line counts for readability.
