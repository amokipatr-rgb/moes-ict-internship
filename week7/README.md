# Ministry ICT Inventory Manager (Stock vs Assets)

Full-stack capstone application built in Week 7 of the MoES internship. It replaces the
paper-based ICT asset tracking process (handwritten servicing forms) with a digital system
that separates **store stock** from **deployed assets** and keeps a complete audit trail.

## Key Design

- **Stock vs Assets model**
  - `stock_items` — equipment physically held in Stores (`source` = `received` | `manual`).
  - `assets` — equipment deployed to offices (`source` = `issued` | `manual`), linked back to
    the originating stock item via `stock_item_id`.
- **Goods Received (GR)** workflow — creates stock items and a `Received` movement.
- **Goods Issued (GI)** workflow — reduces available stock and automatically creates a new
  asset for the recipient department.
- **Movements audit trail** — polymorphic `movements` table (`item_type` = `stock` | `asset`)
  recording `Received`, `Issued`, `Returned`, `Transferred`, `Damaged`, `Repaired`,
  `Disposed`, `Adjusted` events with timestamps and actors.
- **REST API (~17 endpoints)** using `PATH_INFO` routing and prepared statements throughout
  (SQL-injection safe). Suppliers are recorded as a plain text field on the GR form.

## Requirements

- XAMPP (Apache + MySQL + PHP) — no other server software
- MySQL `root` user with no password (MoES dev setup)

## Setup

1. Start Apache and MySQL from the XAMPP Control Panel.
2. In phpMyAdmin, import `db/schema.sql` then `db/seed.sql` (creates `moes_inventory_db`
   with 10 departments, 22 stock items, 132 assets, 2 GR / 3 GI documents and 21 movements).
3. Copy this `week7/` folder to `C:\xampp\htdocs\`:
   - e.g. copy as `C:\xampp\htdocs\week_seven_task\` to match the API base URL in
     `client/index.html` (line ~577, `const API = 'http://localhost/week_seven_task/api/server.php'`),
     or update that constant to match your folder name.
4. Open `http://localhost/week_seven_task/client/index.html` in a browser.

## API Endpoints (base: `api/server.php`)

| Route | Methods | Purpose |
|-------|---------|---------|
| `/stats` | GET | Dashboard statistics (assets, stock, today's activity) |
| `/stock`, `/stock/{id}` | GET/POST/DELETE | Manage store stock items |
| `/stock/available` | GET | Available stock (excludes issued items) |
| `/assets`, `/asset/{id}` | GET/POST/PUT/DELETE | Manage deployed assets |
| `/goods_received`, `/goods_received_item/{id}` | GET/POST/DELETE | Goods Received workflow |
| `/goods_issued`, `/goods_issued_item/{id}`, `/goods_issued_del/{id}` | GET/POST/DELETE | Goods Issued workflow |
| `/return_assets` | POST | Return issued assets to stock |
| `/movements/{id}`, `/all_movements` | GET | Movement audit trail |
| `/departments` | GET/POST | Department list |
| `/export` | GET | CSV export |
| `/import` | POST | CSV import (upsert) |
| `/report` | GET | PDF report (FPDF) |

## Features

- Dashboard with stat cards (Assets, In Store, Damaged, Movements, Today's Issued) and a
  "Today's Activity" bar for Received / Issued / Returned / Damaged.
- Sortable, searchable, filterable asset/stock tables with modal CRUD forms.
- CSV export/import for Excel interoperability and PDF report generation via FPDF.
