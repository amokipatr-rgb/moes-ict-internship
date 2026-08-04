# MoES ICT Inventory Manager — Requirements Document

## 1. Elicitation Summary
- **Date:** July 2026
- **Stakeholders:** Stores Team (Kisakye Betty), ICT Department (Mr. Obua, Mr. Joseph), Commissioner E-Library & E-Learning (Dr. Patrick E. Muinda)
- **Method:** Informal interviews, observation of existing paper-based inventory process, review of handwritten MoES HQ IT Equipment Servicing forms

## 2. Background
The Ministry of Education and Sports currently tracks ICT assets using handwritten servicing forms stored across multiple departments (Education Planning, Finance & Administration, Stores). There is no central digital register. Asset lookup requires physical file retrieval. The Stores team identified a need for a simple digital tool to record, search, and report on all ICT equipment.

## 3. Functional Requirements

### F1 — Asset CRUD
| ID | Requirement | Priority |
|----|-------------|----------|
| F1.1 | User shall add a new asset with fields: asset tag, serial number, category, make/model, location, room, assigned person, department, status, notes | High |
| F1.2 | User shall view all assets in a sortable table | High |
| F1.3 | User shall edit any existing asset | High |
| F1.4 | User shall delete an asset | Medium |

### F2 — Search and Filter
| ID | Requirement | Priority |
|----|-------------|----------|
| F2.1 | User shall search assets by asset tag, serial number, or assigned person name | High |
| F2.2 | User shall filter assets by category, location, and status | High |
| F2.3 | Filtered results shall display in real-time as selections change | Medium |

### F3 — Dashboard & Reporting
| ID | Requirement | Priority |
|----|-------------|----------|
| F3.1 | Dashboard shall show total asset count, number needing attention, category count, location count | High |
| F3.2 | Dashboard shall show breakdowns by category, location, status, and department with counts | High |
| F3.3 | Data shall be exportable to CSV for external reporting | Medium |

### F4 — Bulk Import
| ID | Requirement | Priority |
|----|-------------|----------|
| F4.1 | User shall upload a CSV file to bulk-import or update assets | Medium |
| F4.2 | System shall handle duplicate asset tags via upsert (update if exists) | Medium |

## 4. Non-Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| N1 | System shall run on existing XAMPP stack (Apache + MySQL + PHP) — no new server software | High |
| N2 | Interface shall be accessible from any desktop browser on the MoES LAN | High |
| N3 | Response time for listing/searching assets shall be under 2 seconds | Medium |
| N4 | System shall handle at least 5,000 asset records | Medium |

## 5. Data Fields (from Stores team feedback)

| Field | Type | Example | Required |
|-------|------|---------|----------|
| Asset Tag | Text | MES/HQT/21/EPPAD/0569 | Yes |
| Serial Number | Text | CHCRT2P5669 | No |
| Category | Dropdown | System Unit, Monitor, Laptop, Printer, UPS | Yes |
| Make/Model | Text | Dell Optiplex 3080, HP LaserJet Pro M404dn | No |
| Location | Dropdown | Floor 1–Floor 8, COCIS Block A | Yes |
| Room Number | Text | Rm 6.11, Rm 8.15 | No |
| Assigned To | Text | Richard Ninzee, Kisakye Betty | No |
| Department | Text | Education Planning, Finance & Administration | No |
| Status | Dropdown | Operational, Under Repair, Damaged, Disposed | Default: Operational |
| Notes | Text | "Faulty battery", "Damaged screen" | No |

## 6. Constraints
- Must use existing XAMPP installation (no Docker, no additional servers)
- Must be deployable at `C:\xampp\htdocs\week_seven_task\`
- Must work with MySQL via `root` (no password) as per existing MoES dev setup
- No external API dependencies or CDN (all CSS/JS inline for offline use)

## 7. Acceptance Criteria
1. Stores team can add a new asset via the web form in under 2 minutes
2. All MoES assets from the handwritten forms are loaded via seed SQL (133 assets across 8 floors)
3. Dashboard correctly shows total count, category breakdowns, and needs-attention count
4. CSV export produces a valid file openable in Excel
5. CSV import successfully loads a test batch of 10 assets
6. Search by "Kisakye" returns all assets assigned to Kisakye Betty
