# Physical Cable Tracing Log — Ministry of ICT & National Guidance

Trace Date: Week 6 of Internship
Tracer: Intern (under supervision of Mr. Regan)
Building: Main Building (3 floors) + COCIS Block A

---

## Cable Route #1: Internet Demarc → Server Room (Floor 2)

| Segment | From | To | Cable Type | Length | Notes |
|---------|------|----|------------|--------|-------|
| 1 | External demarc (roof) | Building entrance conduit | Single-mode OS2 | 15m | MTN fibre termination |
| 2 | Building entrance | Floor 2 Server Room riser | Single-mode OS2 | 25m | Runs through vertical cable tray |
| 3 | Server Room patch panel | FortiGate 60F WAN port | CAT6A UTP | 2m | Patch cord |
| 4 | FortiGate LAN port | Core Cisco ISR 4321 Gi0/0/0 | CAT6A UTP | 1m | Cross-connect |

**Path:** Roof → East wall conduit → Floor 2 riser → Server Room Rack A (top)

---

## Cable Route #2: MDF Switch → Floor 3 AR Department

| Segment | From | To | Cable Type | Length | Notes |
|---------|------|----|------------|--------|-------|
| 1 | MDF Switch Gi0/1 (Port 1) | Floor 2 → Floor 3 vertical riser | CAT6 UTP | 5m | Cable tray through riser |
| 2 | Floor 3 riser | Floor 3 comms closet | CAT6 UTP | 65m | Stapled to cable tray every 30cm |
| 3 | Floor 3 comms closet patch panel | Floor 3 Switch port 1 | CAT6 patch cord | 1m | |
| 4 | Floor 3 Switch port 2 | Office #101 (AR - Dr. Mukasa) wall jack | CAT6 UTP | 12m | Underfloor conduit |
| 5 | Floor 3 Switch port 3 | Office #102 (AR - Mr. Okello) wall jack | CAT6 UTP | 14m | Underfloor conduit |
| 6 | Floor 3 Switch port 4 | Office #999 (Sys Admin) wall jack | CAT6 UTP | 8m | Underfloor conduit |
| 7 | Floor 3 Switch PoE port 24 | AP-01 ceiling mount | CAT6 UTP | 6m | Ceiling tray, PoE powered |

**Total distance:** ~111m
**Path:** Server Room → Vertical riser (NE corner) → Floor 3 cable tray → Comms closet → Offices

---

## Cable Route #3: MDF Switch → Floor 1 REC Department

| Segment | From | To | Cable Type | Length | Notes |
|---------|------|----|------------|--------|-------|
| 1 | MDF Switch Gi0/2 (Port 2) | Floor 2 → Floor 1 vertical riser | CAT6 UTP | 5m | Cable tray downward |
| 2 | Floor 1 riser | Floor 1 comms closet | CAT6 UTP | 35m | |
| 3 | Floor 1 comms closet patch panel | Floor 1 Switch port 1 | CAT6 patch cord | 1m | |
| 4 | Floor 1 Switch port 2 | Office #202 (REC - Mr. Ssempijja) wall jack | CAT6 UTP | 10m | Underfloor conduit |
| 5 | Floor 1 Switch port 3 | Office #201 (REC - Ms. Nambi) wall jack | CAT6 UTP | 8m | Underfloor conduit |
| 6 | Floor 1 Switch PoE port 24 | AP-02 ceiling mount | CAT6 UTP | 5m | Ceiling tray |

**Total distance:** ~64m
**Path:** Server Room → Vertical riser (NE corner) → Floor 1 cable tray → Comms closet → Offices

---

## Cable Route #4: MDF Switch → COCIS Block A (Inter-building)

| Segment | From | To | Cable Type | Length | Notes |
|---------|------|----|------------|--------|-------|
| 1 | MDF Switch Gi0/3 (SFP) | Server Room → underground conduit | Single-mode OS2 | 5m | Fibre SFP module |
| 2 | Underground conduit | COCIS Block A entry point | Single-mode OS2 | 330m | Buried 60cm depth in PVC duct |
| 3 | COCIS entry point | COCIS network cabinet | Single-mode OS2 | 15m | Interior wall conduit |
| 4 | COCIS cabinet patch panel | COCIS Switch SFP port | CAT6A patch cord | 1m | Fibre-to-copper media converter built into SFP |
| 5 | COCIS Switch port 2 | Office #301 (GC - Ms. Nakato) wall jack | CAT6 UTP | 7m | Surface-mounted trunking |
| 6 | COCIS Switch PoE port 24 | AP-03 ceiling mount | CAT6 UTP | 4m | Ceiling tray |

**Total distance:** ~362m
**Path:** Server Room → Underground duct (runs parallel to parking lot) → COCIS Block A → Network cabinet → Office #301

---

## Cable Route #5: Patch Panel (IDF) — Server Connections

| From (MDF Switch Port) | To | Cable Type | Length |
|------------------------|----|------------|--------|
| Port 11 | DHCP Server NIC 1 | CAT6A patch | 1.5m |
| Port 12 | DNS Server NIC 1 | CAT6A patch | 1.5m |
| Port 13 | File Server (NAS) NIC 1 | CAT6A patch | 2m |
| Port 14 | PRTG/Grafana Monitor NIC 1 | CAT6A patch | 1m |
| Port 21 | IDF Patch Panel (48-port) | CAT6 patch | 3m |
| Port 22 | IDF Patch Panel (48-port) | CAT6 patch | 3m |

---

## Cable Summary

| Cable Type | Total Length Used | Quantity |
|------------|-------------------|----------|
| Single-mode OS2 (inter-building) | 390m | 1× 350m + 1× 40m |
| CAT6 UTP (horizontal) | ~200m | 10 runs |
| CAT6A UTP (server rack) | ~12m | 6 patch cords |
| CAT6 patch cords | ~15m | 12 patch cords |

## Testing Notes

- All CAT6 runs tested with Fluke DSX-600 CableAnalyzer
- All runs passed at Category 6 (250 MHz) — NEXT and PSNEXT within spec
- Fibre optic tested with OTDR — loss at 0.35 dB/km at 1310 nm
- No cable exceeds 90m horizontal limit per TIA/EIA-568-B standard
