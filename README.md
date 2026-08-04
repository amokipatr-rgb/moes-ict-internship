# MoES ICT Internship — Code Deliverables

Field Attachment at the **Ministry of Education and Sports (MoES)**, ICT Department
**(Library & E-Learning)**, Kampala, Uganda.

**Student:** Ogwal Richard · **Reg No:** 23/U/16574/PS · **Programme:** BSc Software Engineering
**University:** Makerere University, College of Computing and Information Sciences (COCIS)
**Period:** June 2026 – August 2026

This repository contains the **source-code deliverables** produced during the internship,
so that the academic supervisor can review the practical work directly on GitHub. Weekly
logbooks, progress reports, and the final internship report are kept as local documents
and are intentionally **not** committed here.

## Repository Structure

| Folder | Focus Area | Key Files |
|--------|-----------|-----------|
| `week3/` | XAMPP client–server development | `api/server.php`, `client/index.html` (form → MySQL via `fetch()`) |
| `week4/` | Relational DB design & ETL pipeline | `week4_schema.sql`, `week4_etl_cleaner.py`, `week4_db_ingest.py` |
| `week5/` | Git version control & testing | `etl_cleaner.py`, `test_etl_cleaner.py`, `API_README.md` (42 passing tests) |
| `week6/` | Network mapping & hardware audit | `generate_topology.py`, `network_hardware_audit.md`, `physical_cable_trace.md` |
| `week7/` | Capstone: Ministry ICT Inventory Manager | Stock vs Assets model, GR/GI workflows, movements audit — see `week7/README.md` |

## Highlights

- **ETL Pipeline:** 8,339 messy school-registry records cleaned to 8,314 with zero data loss
  (`week4`, `week5`).
- **Network topology:** digital diagram of the MoES network — 2 buildings, 13 devices, 5 VLANs
  (`week6`).
- **Inventory Manager:** full-stack PHP/MySQL/HTML app separating *store stock* from
  *deployed assets*, with Goods Received / Goods Issued workflows and a polymorphic
  movements audit trail (`week7`).

## Getting Started

See `week7/README.md` for how to run the capstone application on XAMPP. Each week folder
contains the relevant source; data files and screenshots are excluded from version control.
