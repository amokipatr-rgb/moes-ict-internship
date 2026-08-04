"""
Week 6: Ministry Network Topology Diagram Generator
Generates a comprehensive digital network topology using the diagrams library.

Buildings:  Main Building (3 floors) + COCIS Block A
Offices:    AR (Floor 3), REC (Floor 1), GC (COCIS A), Server Room (Floor 2)
Equipment:  Firewall, Core Router, Floor Switches, APs, Servers
"""
from diagrams import Diagram, Edge
from diagrams.generic.network import Router, Firewall, Switch
from diagrams.onprem.network import Internet, CiscoSwitchL2
from diagrams.onprem.client import Client, Users
from diagrams.onprem.monitoring import Grafana
from diagrams.aws.compute import EC2Instance
from diagrams.aws.network import CloudFront
import os

OUT_DIR = r"E:\internship task\week_six_task"
DIAGRAM_PATH = os.path.join(OUT_DIR, "moes_network_topology")

with Diagram(
    "MoES ICT Ministry — Network Topology Diagram",
    filename=DIAGRAM_PATH,
    direction="TB",
    outformat="png",
    show=False,
):
    # ── INTERNET EDGE ──
    internet = Internet("Internet")
    cloud = CloudFront("ISP (MTN/Uganda Telecom)")

    internet >> Edge(color="red", label="50 Mbps Dedicated") >> cloud

    # ── FIREWALL & CORE ──
    firewall = Firewall("FortiGate 60F\n(NAT / IPS / VPN)")
    core_router = Router("Cisco ISR 4321\nCore Router\n10.10.10.1")

    cloud >> Edge(color="orange", label="WAN") >> firewall
    firewall >> Edge(color="blue", label="DMZ / LAN") >> core_router

    # ── MAIN BUILDING FLOOR 2 — SERVER ROOM (MDF) ──
    mdf_switch = CiscoSwitchL2("Cisco Catalyst 2960-X\nMDF Switch\nVLAN Trunk\n10.10.10.2")

    core_router >> Edge(color="blue", label="1 Gbps Fiber") >> mdf_switch

    dhcp_server = EC2Instance("DHCP Server\nWindows Server 2022\n192.168.30.10")
    dns_server = EC2Instance("DNS Server\nWindows Server 2022\n192.168.30.11")
    file_server = EC2Instance("File Server\nNAS Synology\n192.168.30.12")
    monitoring = Grafana("PRTG / Grafana\nNetwork Monitor\n192.168.30.100")

    mdf_switch >> Edge(color="green", label="GigE") >> [dhcp_server, dns_server, file_server, monitoring]

    # ── MAIN BUILDING FLOOR 3 — AR DEPARTMENT ──
    floor3_switch = CiscoSwitchL2("Floor 3 Switch\nCisco Catalyst 2960-L\nVLAN 20 - Staff\n10.10.10.3")
    floor3_ap = Router("AP-01\nUbiquiti U6-LR\nSSID: MoES-Staff\n192.168.20.101")

    mdf_switch >> Edge(label="CAT6 UTP\n70m") >> floor3_switch
    floor3_switch >> Edge(label="PoE+") >> floor3_ap

    ar1 = Client("Officer #101\nDr. Sarah Mukasa\nAR - Floor 3\n192.168.20.10")
    ar2 = Client("Officer #102\nMr. James Okello\nAR - Floor 3\n192.168.20.11")
    sysadmin = Client("Sys Admin #999\nSystem Administrator\nAR - Floor 3\n192.168.20.99")

    floor3_switch >> [ar1, ar2, sysadmin]
    floor3_ap >> Edge(label="WiFi 6", style="dashed") >> [ar1, ar2, sysadmin]

    # ── MAIN BUILDING FLOOR 1 — REC DEPARTMENT ──
    floor1_switch = CiscoSwitchL2("Floor 1 Switch\nCisco Catalyst 2960-L\nVLAN 20 - Staff\n10.10.10.4")
    floor1_ap = Router("AP-02\nUbiquiti U6-LR\nSSID: MoES-Staff\n192.168.20.102")

    mdf_switch >> Edge(label="CAT6 UTP\n40m") >> floor1_switch
    floor1_switch >> Edge(label="PoE+") >> floor1_ap

    rec1 = Client("Officer #202\nMr. Peter Ssempijja\nREC - Floor 1\n192.168.20.20")
    rec2 = Client("Officer #201\nMs. Grace Nambi\nREC - Floor 1\n192.168.20.21")

    floor1_switch >> [rec1, rec2]
    floor1_ap >> Edge(label="WiFi 6", style="dashed") >> [rec1, rec2]

    # ── COCIS BLOCK A — GC DEPARTMENT ──
    cocis_switch = CiscoSwitchL2("COCIS Switch\nCisco Catalyst 2960-L\nVLAN 50 - COCIS\n10.10.10.5")
    cocis_ap = Router("AP-03\nUbiquiti U6-LR\nSSID: MoES-Guest\n192.168.40.101")

    mdf_switch >> Edge(label="Single-mode Fiber\n350m (Inter-building)", color="purple") >> cocis_switch
    cocis_switch >> Edge(label="PoE+") >> cocis_ap

    gc1 = Client("Officer #301\nMs. Alice Nakato\nGC - COCIS A\n192.168.50.10")

    cocis_switch >> gc1
    cocis_ap >> Edge(label="WiFi 6", style="dashed") >> gc1

    # ── MAIN BUILDING FLOOR 2 — IDF (PATCH PANEL) ──
    idf_patch = Switch("Patch Panel\n48-port CAT6\nFloor 2 IDF")
    mdf_switch >> Edge(label="Patch Cords", style="dotted") >> idf_patch

print(f"Topology diagram saved to {DIAGRAM_PATH}.png")
