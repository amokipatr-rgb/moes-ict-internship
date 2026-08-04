# Network Hardware Audit — Ministry of ICT & National Guidance

## IP Addressing Scheme

| VLAN | Purpose | Subnet | Gateway | DHCP Range |
|------|---------|--------|---------|------------|
| 10 | Management | 10.10.10.0/24 | 10.10.10.1 | Static |
| 20 | Staff (AR, REC) | 192.168.20.0/24 | 192.168.20.1 | 192.168.20.50–200 |
| 30 | Servers | 192.168.30.0/24 | 192.168.30.1 | Static |
| 40 | Guest WiFi | 192.168.40.0/24 | 192.168.40.1 | 192.168.40.10–254 |
| 50 | COCIS Block A | 192.168.50.0/24 | 192.168.50.1 | 192.168.50.10–100 |

---

## Hardware Inventory

### Firewall

| Field | Value |
|-------|-------|
| **Model** | FortiGate 60F |
| **Role** | Edge firewall — NAT, IPS, SSL VPN, traffic shaping |
| **IP** | WAN: DHCP from ISP | LAN: 10.10.10.254 |
| **Location** | Main Building Floor 2 — Server Room |
| **Firmware** | FortiOS v7.4.1 |
| **Uplink** | 50 Mbps fibre from MTN Uganda |
| **Connected To** | Core Router (Cisco ISR 4321) — Port1 |

### Core Router

| Field | Value |
|-------|-------|
| **Model** | Cisco ISR 4321 |
| **Role** | Inter-VLAN routing, BGP to ISP, QoS |
| **IP** | 10.10.10.1 |
| **Location** | Main Building Floor 2 — Server Room |
| **IOS** | IOS-XE 17.6 |
| **Connected To** | FortiGate 60F (Gi0/0/0), MDF Switch (Gi0/0/1) |

### MDF Switch (Main Distribution Frame)

| Field | Value |
|-------|-------|
| **Model** | Cisco Catalyst 2960-X 48-Port |
| **Role** | Distribution layer — VLAN trunking, inter-floor routing |
| **IP** | 10.10.10.2 |
| **Location** | Main Building Floor 2 — Server Room |
| **IOS** | IOS 15.2 |
| **Connected To** | Core Router, all floor switches, server rack, IDF patch panel |
| **PoE Budget** | 370W |

### Floor 1 Switch (REC Department)

| Field | Value |
|-------|-------|
| **Model** | Cisco Catalyst 2960-L 24-Port |
| **Role** | Access layer — Floor 1 staff connectivity |
| **IP** | 10.10.10.4 |
| **Location** | Main Building Floor 1 — Comms Closet |
| **Connected To** | MDF Switch (CAT6, 40m) |
| **PoE Budget** | 195W |
| **Connected Devices** | 2× staff PCs, 1× AP-02 |

### Floor 3 Switch (AR Department)

| Field | Value |
|-------|-------|
| **Model** | Cisco Catalyst 2960-L 24-Port |
| **Role** | Access layer — Floor 3 staff connectivity |
| **IP** | 10.10.10.3 |
| **Location** | Main Building Floor 3 — Comms Closet |
| **Connected To** | MDF Switch (CAT6, 70m) |
| **PoE Budget** | 195W |
| **Connected Devices** | 3× staff PCs, 1× AP-01 |

### COCIS Block A Switch

| Field | Value |
|-------|-------|
| **Model** | Cisco Catalyst 2960-L 24-Port |
| **Role** | Access layer — COCIS building connectivity |
| **IP** | 10.10.10.5 |
| **Location** | COCIS Block A — Network Cabinet |
| **Connected To** | MDF Switch (Single-mode fibre, 350m) |
| **PoE Budget** | 195W |
| **Connected Devices** | 1× staff PC, 1× AP-03 |

### Wireless Access Points

| AP ID | Model | Location | SSID | IP | Channel |
|-------|-------|----------|------|----|---------|
| AP-01 | Ubiquiti U6-LR | Main Bldg Floor 3 | MoES-Staff | 192.168.20.101 | Ch 6 (2.4G), Ch 36 (5G) |
| AP-02 | Ubiquiti U6-LR | Main Bldg Floor 1 | MoES-Staff | 192.168.20.102 | Ch 11 (2.4G), Ch 149 (5G) |
| AP-03 | Ubiquiti U6-LR | COCIS Block A | MoES-Guest | 192.168.40.101 | Ch 1 (2.4G), Ch 44 (5G) |

### Servers

| Server | Purpose | IP | OS | Specs |
|--------|---------|----|----|-------|
| DHCP Server | IP lease management, scope options | 192.168.30.10 | Windows Server 2022 | 4 vCPU, 8 GB RAM |
| DNS Server | Internal DNS resolution, AD integration | 192.168.30.11 | Windows Server 2022 | 4 vCPU, 8 GB RAM |
| File Server (NAS) | Staff shared drives, backups | 192.168.30.12 | Synology DSM 7 | 4×4 TB RAID 5 |
| PRTG/Grafana | Network monitoring, bandwidth graphs | 192.168.30.100 | Ubuntu 22.04 LTS | 2 vCPU, 4 GB RAM |
