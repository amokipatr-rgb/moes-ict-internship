USE moes_inventory_db;

-- ===== DEPARTMENTS =====
INSERT INTO departments (name, floor, head) VALUES
('Records','Floor 1','Sarah Nambi'),
('ICT','Floor 2','ICT Manager'),
('Administration','Floor 3','Peter Mukasa'),
('Internal Audit','Floor 4','John Bosco Ssempijja'),
('Education Standards','Floor 5','Dr. Sarah Mbabazi'),
('Education Planning','Floor 6','Commissioner Planning'),
('Special Needs Education','Floor 7','Dr. Rita Akumu'),
('Sports','Floor 7','Andrew Musoke'),
('Finance & Administration','Floor 8','Adongru Charles'),
('Stores','Floor 1','Kisakye Betty');

-- ===== GOODS RECEIVED =====
INSERT INTO goods_received (id, supplier_name, lpo_number, delivery_date, procurement_dept, has_invoice, has_lpo, has_delivery_note, notes, received_by) VALUES
(1, 'Dell Technologies Uganda Ltd.', 'LPO/MoES/2026/00452', '2026-07-15', 'Procuring Dept', TRUE, TRUE, TRUE, 'First batch of Dell desktops for Education Planning', 'Kisakye Betty'),
(2, 'HP Uganda Limited', 'LPO/MoES/2026/00489', '2026-07-22', 'Procuring Dept', TRUE, TRUE, TRUE, 'HP laptops for senior management', 'Kisakye Betty');

INSERT INTO goods_received_items (id, goods_received_id, description, quantity, category, unit_cost, serial_numbers) VALUES
(1, 1, 'Dell Optiplex 3080 Desktop', 5, 'System Unit', 1850000.00, 'DLSR001,DLSR002,DLSR003,DLSR004,DLSR005'),
(2, 1, 'Dell 22" Monitor', 5, 'Monitor', 420000.00, 'DLM001,DLM002,DLM003,DLM004,DLM005'),
(3, 2, 'HP ProBook 450 G10 Laptop', 3, 'Laptop', 3200000.00, 'HPL001,HPL002,HPL003');

-- ===== STOCK ITEMS (items physically in the store) =====
-- Received from GR (13 items — 10 still in store, 3 later issued via GI#1)
INSERT INTO stock_items (id, item_code, serial_no, category, make_model, description, source, gr_item_id, notes) VALUES
(1, 'MES/HQT/26/STO/0001','DLSR001','System Unit','Dell Optiplex 3080','Desktop PC - received under LPO/MoES/2026/00452','received',1,NULL),
(2, 'MES/HQT/26/STO/0002','DLSR002','System Unit','Dell Optiplex 3080','Desktop PC - received under LPO/MoES/2026/00452','received',1,NULL),
(3, 'MES/HQT/26/STO/0003','DLSR003','System Unit','Dell Optiplex 3080','Desktop PC - received under LPO/MoES/2026/00452','received',1,NULL),
(4, 'MES/HQT/26/STO/0004','DLSR004','System Unit','Dell Optiplex 3080','Desktop PC - received under LPO/MoES/2026/00452','received',1,NULL),
(5, 'MES/HQT/26/STO/0005','DLSR005','System Unit','Dell Optiplex 3080','Desktop PC - received under LPO/MoES/2026/00452','received',1,NULL),
(6, 'MES/HQT/26/STO/0006','DLM001','Monitor','Dell 22" Monitor','22" Monitor - received under LPO/MoES/2026/00452','received',2,NULL),
(7, 'MES/HQT/26/STO/0007','DLM002','Monitor','Dell 22" Monitor','22" Monitor - received under LPO/MoES/2026/00452','received',2,NULL),
(8, 'MES/HQT/26/STO/0008','DLM003','Monitor','Dell 22" Monitor','22" Monitor - received under LPO/MoES/2026/00452','received',2,NULL),
(9, 'MES/HQT/26/STO/0009','DLM004','Monitor','Dell 22" Monitor','22" Monitor - received under LPO/MoES/2026/00452','received',2,NULL),
(10,'MES/HQT/26/STO/0010','DLM005','Monitor','Dell 22" Monitor','22" Monitor - received under LPO/MoES/2026/00452','received',2,NULL),
(11,'MES/HQT/26/STO/0011','HPL001','Laptop','HP ProBook 450 G10','Laptop - received under LPO/MoES/2026/00489','received',3,NULL),
(12,'MES/HQT/26/STO/0012','HPL002','Laptop','HP ProBook 450 G10','Laptop - received under LPO/MoES/2026/00489','received',3,NULL),
(13,'MES/HQT/26/STO/0013','HPL003','Laptop','HP ProBook 450 G10','Laptop - received under LPO/MoES/2026/00489','received',3,NULL);

-- Manual store items (9 items — 4 in store, 5 later issued via GI#2 & GI#3)
INSERT INTO stock_items (id, item_code, serial_no, category, make_model, description, source, notes) VALUES
(14,'MES/HQT/21/STO/0600','CHCRT2P5700','System Unit','Dell Optiplex 3080',NULL,'manual',NULL),
(15,'MES/HQT/21/STO/0601','CHCRT2P5701','System Unit','Dell Optiplex 3080',NULL,'manual',NULL),
(16,'MES/HQT/21/STO/0602','CHCRT2P5702','System Unit','Dell Optiplex 3080',NULL,'manual',NULL),
(17,'MES/HQT/21/STO/0603','MONS2P5703','Monitor','Dell 22" Monitor',NULL,'manual',NULL),
(18,'MES/HQT/21/STO/0604','MONS2P5704','Monitor','Dell 22" Monitor',NULL,'manual',NULL),
(19,'MES/HQT/21/STO/0605','MONS2P5705','Monitor','Dell 22" Monitor',NULL,'manual',NULL),
(20,'MES/HQT/21/STO/0610','PRNHP005','Printer','HP LaserJet Enterprise M507',NULL,'manual',NULL),
(21,'MES/HQT/21/STO/0622','UPSAP009','UPS','APC Back-UPS Pro 1500',NULL,'manual',NULL),
(22,'MES/HQT/23/FSA/LTP/006','LTPHP006','Laptop','HP ProBook 450 G10',NULL,'manual',NULL);

-- ===== ASSETS (items deployed to departments) =====
-- Manual deployed assets (from paper inventory — never went through stock)
INSERT INTO assets (id, asset_tag, serial_no, category, make_model, description, location, room_no, assigned_to, department, status, source, notes) VALUES

-- Floor 1 — Records
(1,'MES/HQT/21/REC/0501','RECCR001','System Unit','Dell Optiplex 3080',NULL,'Floor 1','Rm 1.01','Sarah Nambi','Records','Issued','manual',NULL),
(2,'MES/HQT/21/REC/0502','RECMO001','Monitor','Dell 22" Monitor',NULL,'Floor 1','Rm 1.01','Sarah Nambi','Records','Issued','manual',NULL),
(3,'MES/HQT/21/REC/0503','RECCR002','System Unit','Dell Optiplex 3080',NULL,'Floor 1','Rm 1.02','James Odoch','Records','Issued','manual',NULL),
(4,'MES/HQT/21/REC/0504','RECMO002','Monitor','Dell 22" Monitor',NULL,'Floor 1','Rm 1.02','James Odoch','Records','Issued','manual',NULL),
(5,'MES/HQT/21/REC/0505','RECCR003','System Unit','Dell Optiplex 3080',NULL,'Floor 1','Rm 1.03','Grace Akello','Records','Issued','manual',NULL),
(6,'MES/HQT/21/REC/0506','RECMO003','Monitor','Dell 22" Monitor',NULL,'Floor 1','Rm 1.03','Grace Akello','Records','Issued','manual',NULL),
(7,'MES/HQT/21/REC/0507','RECSC001','Scanner','HP ScanJet Pro 2600',NULL,'Floor 1','Rm 1.01','Sarah Nambi','Records','Issued','manual',NULL),
(8,'MES/HQT/21/REC/0508','RECPR001','Printer','HP LaserJet Pro M404dn',NULL,'Floor 1','Rm 1.01','Sarah Nambi','Records','Issued','manual',NULL),

-- Floor 2 — Server Room (ICT)
(9,'MES/HQT/21/NET/0701','FTGTF001','Router','FortiGate 60F Firewall',NULL,'Floor 2','Server Room','ICT Department','ICT','Issued','manual',NULL),
(10,'MES/HQT/21/NET/0702','CISCO001','Router','Cisco ISR 4321',NULL,'Floor 2','Server Room','ICT Department','ICT','Issued','manual',NULL),
(11,'MES/HQT/21/NET/0703','CISCO002','Network Switch','Cisco Catalyst 2960-X 48-Port',NULL,'Floor 2','Server Room','ICT Department','ICT','Issued','manual',NULL),
(12,'MES/HQT/21/NET/0704','CISCO003','Network Switch','Cisco Catalyst 2960-X 48-Port',NULL,'Floor 2','Server Room','ICT Department','ICT','Issued','manual',NULL),
(13,'MES/HQT/21/NET/0705','CISCO004','Network Switch','Cisco Catalyst 2960-X 24-Port',NULL,'Floor 2','Server Room','ICT Department','ICT','Issued','manual',NULL),
(14,'MES/HQT/21/NET/0706','CISCO005','Network Switch','Cisco Catalyst 2960-X 24-Port',NULL,'Floor 2','Server Room','ICT Department','ICT','Under Repair','manual',NULL),
(15,'MES/HQT/21/NET/0707','UBQM001','Access Point','Ubiquiti U6-LR',NULL,'Floor 2','Server Room','ICT Department','ICT','Issued','manual',NULL),
(16,'MES/HQT/21/SRV/0708','SRVHP001','Server','HP ProLiant DL380 Gen10',NULL,'Floor 2','Server Room','ICT Department','ICT','Issued','manual',NULL),
(17,'MES/HQT/21/SRV/0709','SRVHP002','Server','HP ProLiant DL380 Gen10',NULL,'Floor 2','Server Room','ICT Department','ICT','Issued','manual',NULL),
(18,'MES/HQT/21/SRV/0710','SRVDL001','Server','Dell PowerEdge R740',NULL,'Floor 2','Server Room','ICT Department','ICT','Issued','manual',NULL),
(19,'MES/HQT/21/SRV/0711','SRVDL002','Server','Dell PowerEdge R740',NULL,'Floor 2','Server Room','ICT Department','ICT','Damaged','manual',NULL),
(20,'MES/HQT/21/NET/0712','UPSAP011','UPS','APC Smart-UPS 3000',NULL,'Floor 2','Server Room','ICT Department','ICT','Issued','manual',NULL),
(21,'MES/HQT/21/NET/0713','UPSAP012','UPS','APC Smart-UPS 3000',NULL,'Floor 2','Server Room','ICT Department','ICT','Issued','manual',NULL),
(22,'MES/HQT/21/NET/0714','NASSN001','External HDD','Synology DS920+ NAS',NULL,'Floor 2','Server Room','ICT Department','ICT','Issued','manual',NULL),
(23,'MES/HQT/21/NET/0715','MONSR001','Monitor','Dell 27" Monitor',NULL,'Floor 2','Server Room','ICT Department','ICT','Issued','manual',NULL),

-- Floor 3 — Administration
(24,'MES/HQT/21/ADM/0801','ADMCR001','System Unit','Dell Optiplex 3080',NULL,'Floor 3','Rm 3.01','Peter Mukasa','Administration','Issued','manual',NULL),
(25,'MES/HQT/21/ADM/0802','ADMMO001','Monitor','Dell 22" Monitor',NULL,'Floor 3','Rm 3.01','Peter Mukasa','Administration','Issued','manual',NULL),
(26,'MES/HQT/21/ADM/0803','ADMCR002','System Unit','Dell Optiplex 3080',NULL,'Floor 3','Rm 3.02','Rose Nabatanzi','Administration','Issued','manual',NULL),
(27,'MES/HQT/21/ADM/0804','ADMMO002','Monitor','Dell 22" Monitor',NULL,'Floor 3','Rm 3.02','Rose Nabatanzi','Administration','Issued','manual',NULL),
(28,'MES/HQT/21/ADM/0805','ADMCR003','System Unit','Dell Optiplex 3080',NULL,'Floor 3','Rm 3.03','Henry Kiwanuka','Administration','Issued','manual',NULL),
(29,'MES/HQT/21/ADM/0806','ADMMO003','Monitor','Dell 22" Monitor',NULL,'Floor 3','Rm 3.03','Henry Kiwanuka','Administration','Issued','manual',NULL),
(30,'MES/HQT/21/ADM/0807','ADMLP001','Laptop','HP ProBook 450 G10',NULL,'Floor 3','Rm 3.01','Peter Mukasa','Administration','Issued','manual',NULL),
(31,'MES/HQT/21/ADM/0808','ADMPR001','Printer','HP LaserJet Pro M404dn',NULL,'Floor 3','Rm 3.01','Peter Mukasa','Administration','Issued','manual',NULL),
(32,'MES/HQT/21/ADM/0809','ADMUP001','UPS','APC Back-UPS Pro 1500',NULL,'Floor 3','Rm 3.01','Peter Mukasa','Administration','Issued','manual',NULL),
(33,'MES/HQT/21/ADM/0810','ADMCR004','System Unit','Dell Optiplex 3080',NULL,'Floor 3','Rm 3.04','Mariam Nakato','Administration','Issued','manual',NULL),
(34,'MES/HQT/21/ADM/0811','ADMMO004','Monitor','Dell 22" Monitor',NULL,'Floor 3','Rm 3.04','Mariam Nakato','Administration','Issued','manual',NULL),
(35,'MES/HQT/23/FSA/LTP/010','ADMLP002','Laptop','Dell Latitude 5540',NULL,'Floor 3','Rm 3.02','Rose Nabatanzi','Administration','Damaged','manual',NULL),

-- Floor 4 — Internal Audit
(36,'MES/HQT/21/AUD/0901','AUDCR001','System Unit','Dell Optiplex 3080',NULL,'Floor 4','Rm 4.01','John Bosco Ssempijja','Internal Audit','Issued','manual',NULL),
(37,'MES/HQT/21/AUD/0902','AUDMO001','Monitor','Dell 22" Monitor',NULL,'Floor 4','Rm 4.01','John Bosco Ssempijja','Internal Audit','Issued','manual',NULL),
(38,'MES/HQT/21/AUD/0903','AUDCR002','System Unit','Dell Optiplex 3080',NULL,'Floor 4','Rm 4.02','Agnes Kemigisha','Internal Audit','Issued','manual',NULL),
(39,'MES/HQT/21/AUD/0904','AUDMO002','Monitor','Dell 22" Monitor',NULL,'Floor 4','Rm 4.02','Agnes Kemigisha','Internal Audit','Issued','manual',NULL),
(40,'MES/HQT/21/AUD/0905','AUDCR003','System Unit','Dell Optiplex 3080',NULL,'Floor 4','Rm 4.03','David Okello','Internal Audit','Issued','manual',NULL),
(41,'MES/HQT/21/AUD/0906','AUDMO003','Monitor','Dell 22" Monitor',NULL,'Floor 4','Rm 4.03','David Okello','Internal Audit','Issued','manual',NULL),
(42,'MES/HQT/21/AUD/0907','AUDPR001','Printer','HP LaserJet Pro M404dn',NULL,'Floor 4','Rm 4.01','John Bosco Ssempijja','Internal Audit','Issued','manual',NULL),
(43,'MES/HQT/21/AUD/0908','AUDUP001','UPS','APC Back-UPS Pro 1500',NULL,'Floor 4','Rm 4.01','John Bosco Ssempijja','Internal Audit','Issued','manual',NULL),

-- Floor 5 — Education Standards
(44,'MES/HQT/21/ESQ/1001','ESQCR001','System Unit','Dell Optiplex 3080',NULL,'Floor 5','Rm 5.01','Dr. Sarah Mbabazi','Education Standards','Issued','manual',NULL),
(45,'MES/HQT/21/ESQ/1002','ESQMO001','Monitor','Dell 22" Monitor',NULL,'Floor 5','Rm 5.01','Dr. Sarah Mbabazi','Education Standards','Issued','manual',NULL),
(46,'MES/HQT/21/ESQ/1003','ESQCR002','System Unit','Dell Optiplex 3080',NULL,'Floor 5','Rm 5.02','Robert Twinomujuni','Education Standards','Issued','manual',NULL),
(47,'MES/HQT/21/ESQ/1004','ESQMO002','Monitor','Dell 22" Monitor',NULL,'Floor 5','Rm 5.02','Robert Twinomujuni','Education Standards','Issued','manual',NULL),
(48,'MES/HQT/21/ESQ/1005','ESQCR003','System Unit','Dell Optiplex 3080',NULL,'Floor 5','Rm 5.03','Florence Aol','Quality Assurance','Issued','manual',NULL),
(49,'MES/HQT/21/ESQ/1006','ESQMO003','Monitor','Dell 22" Monitor',NULL,'Floor 5','Rm 5.03','Florence Aol','Quality Assurance','Issued','manual',NULL),
(50,'MES/HQT/21/ESQ/1007','ESQCR004','System Unit','Dell Optiplex 3080',NULL,'Floor 5','Rm 5.04','Patrick Wamala','Quality Assurance','Issued','manual',NULL),
(51,'MES/HQT/21/ESQ/1008','ESQMO004','Monitor','Dell 22" Monitor',NULL,'Floor 5','Rm 5.04','Patrick Wamala','Quality Assurance','Issued','manual',NULL),
(52,'MES/HQT/21/ESQ/1009','ESQPR001','Printer','HP LaserJet Pro M404dn',NULL,'Floor 5','Rm 5.01','Dr. Sarah Mbabazi','Education Standards','Issued','manual',NULL),
(53,'MES/HQT/21/ESQ/1010','ESQUP001','UPS','APC Back-UPS Pro 1500',NULL,'Floor 5','Rm 5.01','Dr. Sarah Mbabazi','Education Standards','Issued','manual',NULL),

-- Floor 6 — Education Planning
(54,'MES/HQT/21/EPPAD/0569','CHCRT2P5669','System Unit','Dell Optiplex 3080',NULL,'Floor 6','Rm 6.11','Richard Ninzee','Education Planning','Issued','manual',NULL),
(55,'MES/HQT/21/EPPAD/0570','CHCRT2P5670','System Unit','Dell Optiplex 3080',NULL,'Floor 6','Rm 6.11','Richard Ninzee','Education Planning','Issued','manual',NULL),
(56,'MES/HQT/21/EPPAD/0571','MONS2P5671','Monitor','Dell 22" Monitor',NULL,'Floor 6','Rm 6.11','Richard Ninzee','Education Planning','Damaged','manual',NULL),
(57,'MES/HQT/21/EPPAD/0572','CHCRT2P5672','System Unit','Dell Optiplex 3080',NULL,'Floor 6','Rm 6.11','Rebecca Akello','Education Planning','Issued','manual',NULL),
(58,'MES/HQT/21/EPPAD/0573','MONS2P5673','Monitor','Dell 22" Monitor',NULL,'Floor 6','Rm 6.11','Rebecca Akello','Education Planning','Issued','manual',NULL),
(59,'MES/HQT/21/EPPAD/0574','CHCRT2P5674','System Unit','Dell Optiplex 3080',NULL,'Floor 6','Rm 6.12','Allan Bas Bagonza','Education Planning','Issued','manual',NULL),
(60,'MES/HQT/21/EPPAD/0575','MONS2P5675','Monitor','Dell 22" Monitor',NULL,'Floor 6','Rm 6.12','Allan Bas Bagonza','Education Planning','Issued','manual',NULL),
(61,'MES/HQT/23/FSA/LTP/001','LTPHP001','Laptop','HP ProBook 450 G10',NULL,'Floor 6','Rm 6.12','Allan Bas Bagonza','Education Planning','Issued','manual',NULL),
(62,'MES/HQT/23/FSA/LTP/002','LTPHP002','Laptop','HP ProBook 450 G10',NULL,'Floor 6','Rm 6.12','Allan Bas Bagonza','Education Planning','Damaged','manual',NULL),
(63,'MES/HQT/21/EPPAD/0576','CHCRT2P5676','System Unit','Dell Optiplex 3080',NULL,'Floor 6','Rm 6.12','Ogwang Ivan','Education Planning','Issued','manual',NULL),
(64,'MES/HQT/21/EPPAD/0577','MONS2P5677','Monitor','Dell 22" Monitor',NULL,'Floor 6','Rm 6.12','Ogwang Ivan','Education Planning','Issued','manual',NULL),
(65,'MES/HQT/23/FSA/LTP/003','LTPHP003','Laptop','HP ProBook 450 G10',NULL,'Floor 6','Rm 6.12','Ogwang Ivan','Education Planning','Issued','manual',NULL),
(66,'MES/HQT/21/EPPAD/0578','CHCRT2P5678','System Unit','Dell Optiplex 3080',NULL,'Floor 6','Rm 6.7','Commissioner Planning','Education Planning','Issued','manual',NULL),
(67,'MES/HQT/21/EPPAD/0579','MONS2P5679','Monitor','Dell 22" Monitor',NULL,'Floor 6','Rm 6.7','Commissioner Planning','Education Planning','Issued','manual',NULL),
(68,'MES/HQT/21/EPPAD/0580','CHCRT2P5680','System Unit','Dell Optiplex 3080',NULL,'Floor 6','Rm 6.7','Secretary','Education Planning','Issued','manual',NULL),
(69,'MES/HQT/21/EPPAD/0581','MONS2P5681','Monitor','Dell 22" Monitor',NULL,'Floor 6','Rm 6.7','Secretary','Education Planning','Issued','manual',NULL),
(70,'MES/HQT/21/EPPAD/0582','CHCRT2P5682','System Unit','Dell Optiplex 3080',NULL,'Floor 6','Rm 6.5','Sanyu Frazoll','Education Planning','Issued','manual',NULL),
(71,'MES/HQT/21/EPPAD/0583','MONS2P5683','Monitor','Dell 22" Monitor',NULL,'Floor 6','Rm 6.5','Sanyu Frazoll','Education Planning','Issued','manual',NULL),
(72,'MES/HQT/21/EPPAD/0584','CHCRT2P5684','System Unit','Dell Optiplex 3080',NULL,'Floor 6','Rm 6.5','Lyndah','Education Planning','Issued','manual',NULL),
(73,'MES/HQT/21/EPPAD/0585','MONS2P5685','Monitor','Dell 22" Monitor',NULL,'Floor 6','Rm 6.5','Lyndah','Education Planning','Issued','manual',NULL),
(74,'MES/HQT/21/EPPAD/0586','CHCRT2P5686','System Unit','Dell Optiplex 3080',NULL,'Floor 6','Rm 6.2','Ssejjuko Milhem','Education Planning','Issued','manual',NULL),
(75,'MES/HQT/21/EPPAD/0587','MONS2P5687','Monitor','Dell 22" Monitor',NULL,'Floor 6','Rm 6.2','Ssejjuko Milhem','Education Planning','Issued','manual',NULL),
(76,'MES/HQT/21/EPPAD/0588','CHCRT2P5688','System Unit','Dell Optiplex 3080',NULL,'Floor 6','Rm 6.2','Atukunda Daniel','Education Planning','Issued','manual',NULL),
(77,'MES/HQT/21/EPPAD/0589','MONS2P5689','Monitor','Dell 22" Monitor',NULL,'Floor 6','Rm 6.2','Atukunda Daniel','Education Planning','Issued','manual',NULL),
(78,'MES/HQT/21/EPPAD/0590','CHCRT2P5690','System Unit','Dell Optiplex 3080',NULL,'Floor 6','Rm 6.2.1','Lugwa M.A','Education Planning','Issued','manual',NULL),
(79,'MES/HQT/21/EPPAD/0591','MONS2P5691','Monitor','Dell 22" Monitor',NULL,'Floor 6','Rm 6.2.1','Lugwa M.A','Education Planning','Issued','manual',NULL),
(80,'MES/HQT/21/EPPAD/0592','CHCRT2P5692','System Unit','Dell Optiplex 3080',NULL,'Floor 6','Rm 6.2.1','Nakwazi Falia','Education Planning','Issued','manual',NULL),
(81,'MES/HQT/21/EPPAD/0593','MONS2P5693','Monitor','Dell 22" Monitor',NULL,'Floor 6','Rm 6.2.1','Nakwazi Falia','Education Planning','Issued','manual',NULL),
(82,'MES/HQT/23/FSA/LTP/007','LTPHP007','Laptop','HP ProBook 450 G10',NULL,'Floor 6','Rm 6.2.1','Nakwazi Falia','Education Planning','Issued','manual',NULL),
(83,'MES/HQT/21/EPPAD/0606','PRNHP001','Printer','HP LaserJet Pro M404dn',NULL,'Floor 6','Rm 6.11','Richard Ninzee','Education Planning','Issued','manual',NULL),
(84,'MES/HQT/21/EPPAD/0607','PRNHP002','Printer','HP LaserJet Pro M404dn',NULL,'Floor 6','Rm 6.12','Allan Bas Bagonza','Education Planning','Issued','manual',NULL),
(85,'MES/HQT/21/EPPAD/0608','PRNHP003','Printer','HP LaserJet Pro M404dn',NULL,'Floor 6','Rm 6.7','Commissioner Planning','Education Planning','Issued','manual',NULL),
(86,'MES/HQT/21/EPPAD/0611','PRNHP006','Printer','HP DeskJet 3772',NULL,'Floor 6','Rm 6.5','Sanyu Frazoll','Education Planning','Damaged','manual',NULL),
(87,'MES/HQT/21/EPPAD/0613','PRNHP008','Printer','HP LaserJet Pro M404dn',NULL,'Floor 6','Rm 6.2','Ssejjuko Milhem','Education Planning','Issued','manual',NULL),
(88,'MES/HQT/21/EPPAD/0614','UPSAP001','UPS','APC Back-UPS Pro 1500',NULL,'Floor 6','Rm 6.11','Richard Ninzee','Education Planning','Issued','manual',NULL),
(89,'MES/HQT/21/EPPAD/0615','UPSAP002','UPS','APC Back-UPS Pro 1500',NULL,'Floor 6','Rm 6.12','Allan Bas Bagonza','Education Planning','Issued','manual',NULL),
(90,'MES/HQT/21/EPPAD/0616','UPSAP003','UPS','APC Back-UPS Pro 1500',NULL,'Floor 6','Rm 6.7','Commissioner Planning','Education Planning','Issued','manual',NULL),
(91,'MES/HQT/21/EPPAD/0618','UPSAP005','UPS','APC Back-UPS Pro 1500',NULL,'Floor 6','Rm 6.5','Sanyu Frazoll','Education Planning','Damaged','manual',NULL),
(92,'MES/HQT/21/EPPAD/0619','UPSAP006','UPS','APC Back-UPS Pro 1500',NULL,'Floor 6','Rm 6.2','Ssejjuko Milhem','Education Planning','Issued','manual',NULL),
(93,'MES/HQT/21/EPPAD/0620','UPSAP007','UPS','APC Back-UPS Pro 1500',NULL,'Floor 6','Rm 6.2.1','Lugwa M.A','Education Planning','Issued','manual',NULL),
(94,'MES/HQT/21/EPPAD/0623','UPSAP010','UPS','APC Back-UPS Pro 1500',NULL,'Floor 6','Rm 6.11','Rebecca Akello','Education Planning','Issued','manual',NULL),
(95,'MES/HQT/21/EPPAD/0624','SCNHP001','Scanner','HP ScanJet Pro 2600',NULL,'Floor 6','Rm 6.7','Commissioner Planning','Education Planning','Issued','manual',NULL),

-- Floor 7 — Special Needs & Sports
(96,'MES/HQT/21/SNE/1101','SNECR001','System Unit','Dell Optiplex 3080',NULL,'Floor 7','Rm 7.01','Dr. Rita Akumu','Special Needs Education','Issued','manual',NULL),
(97,'MES/HQT/21/SNE/1102','SNEMO001','Monitor','Dell 22" Monitor',NULL,'Floor 7','Rm 7.01','Dr. Rita Akumu','Special Needs Education','Issued','manual',NULL),
(98,'MES/HQT/21/SNE/1103','SNECR002','System Unit','Dell Optiplex 3080',NULL,'Floor 7','Rm 7.02','Samson Kigozi','Special Needs Education','Issued','manual',NULL),
(99,'MES/HQT/21/SNE/1104','SNEMO002','Monitor','Dell 22" Monitor',NULL,'Floor 7','Rm 7.02','Samson Kigozi','Special Needs Education','Issued','manual',NULL),
(100,'MES/HQT/21/SNE/1105','SNECR003','System Unit','Dell Optiplex 3080',NULL,'Floor 7','Rm 7.03','Joyce Nabatanzi','Special Needs Education','Issued','manual',NULL),
(101,'MES/HQT/21/SNE/1106','SNEMO003','Monitor','Dell 22" Monitor',NULL,'Floor 7','Rm 7.03','Joyce Nabatanzi','Special Needs Education','Issued','manual',NULL),
(102,'MES/HQT/21/SNE/1111','SNEPR001','Printer','HP LaserJet Pro M404dn',NULL,'Floor 7','Rm 7.01','Dr. Rita Akumu','Special Needs Education','Issued','manual',NULL),
(103,'MES/HQT/21/SNE/1112','SNEUP001','UPS','APC Back-UPS Pro 1500',NULL,'Floor 7','Rm 7.01','Dr. Rita Akumu','Special Needs Education','Issued','manual',NULL),
(104,'MES/HQT/21/SPO/1107','SPOCR001','System Unit','Dell Optiplex 3080',NULL,'Floor 7','Rm 7.04','Andrew Musoke','Sports','Issued','manual',NULL),
(105,'MES/HQT/21/SPO/1108','SPOMO001','Monitor','Dell 22" Monitor',NULL,'Floor 7','Rm 7.04','Andrew Musoke','Sports','Issued','manual',NULL),
(106,'MES/HQT/21/SPO/1109','SPOCR002','System Unit','Dell Optiplex 3080',NULL,'Floor 7','Rm 7.05','Sarah Nakalema','Sports','Issued','manual',NULL),
(107,'MES/HQT/21/SPO/1110','SPOMO002','Monitor','Dell 22" Monitor',NULL,'Floor 7','Rm 7.05','Sarah Nakalema','Sports','Issued','manual',NULL),

-- Floor 8 — Finance & Administration
(108,'MES/HQT/21/FSA/0594','CHCRT2P5694','System Unit','Dell Optiplex 3080',NULL,'Floor 8','Rm 8.15','Adongru Charles','Finance & Administration','Issued','manual',NULL),
(109,'MES/HQT/21/FSA/0595','MONS2P5695','Monitor','Dell 22" Monitor',NULL,'Floor 8','Rm 8.15','Adongru Charles','Finance & Administration','Issued','manual',NULL),
(110,'MES/HQT/21/FSA/0596','CHCRT2P5696','System Unit','Dell Optiplex 3080',NULL,'Floor 8','Rm 8.15','Adongru Charles','Finance & Administration','Issued','manual',NULL),
(111,'MES/HQT/21/FSA/0597','MONS2P5697','Monitor','Dell 22" Monitor',NULL,'Floor 8','Rm 8.15','Adongru Charles','Finance & Administration','Issued','manual',NULL),
(112,'MES/HQT/21/FSA/0598','CHCRT2P5698','System Unit','Dell Optiplex 3080',NULL,'Floor 8','Rm 8.15','Ayebale Sarah','Finance & Administration','Damaged','manual',NULL),
(113,'MES/HQT/21/FSA/0599','MONS2P5699','Monitor','Dell 22" Monitor',NULL,'Floor 8','Rm 8.15','Ayebale Sarah','Finance & Administration','Issued','manual',NULL),
(114,'MES/HQT/21/FSA/0609','PRNHP004','Printer','HP LaserJet Pro M404dn',NULL,'Floor 8','Rm 8.15','Adongru Charles','Finance & Administration','Under Repair','manual',NULL),
(115,'MES/HQT/21/FSA/0612','PRNHP007','Printer','HP LaserJet Pro M404dn',NULL,'Floor 8','Rm 8.15','Ayebale Sarah','Finance & Administration','Issued','manual',NULL),
(116,'MES/HQT/21/FSA/0617','UPSAP004','UPS','APC Back-UPS Pro 1500',NULL,'Floor 8','Rm 8.15','Adongru Charles','Finance & Administration','Issued','manual',NULL),
(117,'MES/HQT/21/FSA/0621','UPSAP008','UPS','APC Back-UPS Pro 1500',NULL,'Floor 8','Rm 8.15','Ayebale Sarah','Finance & Administration','Issued','manual',NULL),
(118,'MES/HQT/23/FSA/LTP/004','LTPDL004','Laptop','Dell Latitude 5540',NULL,'Floor 8','Rm 8.15','Adongru Charles','Finance & Administration','Issued','manual',NULL),
(119,'MES/HQT/23/FSA/LTP/005','LTPDL005','Laptop','Dell Latitude 5540',NULL,'Floor 8','Rm 8.15','Ayebale Sarah','Finance & Administration','Damaged','manual',NULL),
(120,'MES/HQT/21/FSA/0625','SCNHP002','Scanner','HP ScanJet Pro 2600',NULL,'Floor 8','Rm 8.15','Adongru Charles','Finance & Administration','Issued','manual',NULL),

-- Access Points
(121,'MES/HQT/21/WAP/1201','UBQWAP01','Access Point','Ubiquiti U6-LR',NULL,'Floor 1','Corridor','ICT Department','ICT','Issued','manual',NULL),
(122,'MES/HQT/21/WAP/1202','UBQWAP02','Access Point','Ubiquiti U6-LR',NULL,'Floor 3','Corridor','ICT Department','ICT','Issued','manual',NULL),
(123,'MES/HQT/21/WAP/1203','UBQWAP03','Access Point','Ubiquiti U6-LR',NULL,'Floor 6','Corridor','ICT Department','ICT','Issued','manual',NULL),
(124,'MES/HQT/21/WAP/1204','UBQWAP04','Access Point','Ubiquiti U6-LR',NULL,'Floor 8','Corridor','ICT Department','ICT','Issued','manual',NULL);

-- ===== ASSETS CREATED VIA GOODS ISSUED =====
-- GI#1: ICT Department — 3 assets from received stock (stock_item_ids 1, 6, 11)
INSERT INTO assets (id, asset_tag, serial_no, category, make_model, description, location, room_no, assigned_to, department, status, stock_item_id, source, notes) VALUES
(125,'MES/HQT/26/STO/0001','DLSR001','System Unit','Dell Optiplex 3080','Desktop PC - issued to ICT','Floor 2',NULL,'ICT Manager','ICT','Issued',1,'issued','Issued from GR#1 received stock'),
(126,'MES/HQT/26/STO/0006','DLM001','Monitor','Dell 22" Monitor','22" Monitor - issued to ICT','Floor 2',NULL,'ICT Manager','ICT','Issued',6,'issued','Issued from GR#1 received stock'),
(127,'MES/HQT/26/STO/0011','HPL001','Laptop','HP ProBook 450 G10','Laptop - issued to ICT','Floor 2',NULL,'ICT Manager','ICT','Issued',11,'issued','Issued from GR#2 received stock');

-- GI#2: Education Planning — 3 assets from manual store stock (stock_item_ids 14, 15, 17)
INSERT INTO assets (id, asset_tag, serial_no, category, make_model, description, location, room_no, assigned_to, department, status, stock_item_id, source, notes) VALUES
(128,'MES/HQT/21/STO/0600','CHCRT2P5700','System Unit','Dell Optiplex 3080',NULL,'Floor 6',NULL,'Commissioner Planning','Education Planning','Issued',14,'issued','Issued from store spare'),
(129,'MES/HQT/21/STO/0601','CHCRT2P5701','System Unit','Dell Optiplex 3080',NULL,'Floor 6',NULL,'Commissioner Planning','Education Planning','Issued',15,'issued','Issued from store spare'),
(130,'MES/HQT/21/STO/0603','MONS2P5703','Monitor','Dell 22" Monitor',NULL,'Floor 6',NULL,'Commissioner Planning','Education Planning','Issued',17,'issued','Issued from store spare');

-- GI#3: Administration — 2 assets from manual store stock (stock_item_ids 20, 22)
INSERT INTO assets (id, asset_tag, serial_no, category, make_model, description, location, room_no, assigned_to, department, status, stock_item_id, source, notes) VALUES
(131,'MES/HQT/21/STO/0610','PRNHP005','Printer','HP LaserJet Enterprise M507',NULL,'Floor 3',NULL,'Peter Mukasa','Administration','Issued',20,'issued','Issued from store spare'),
(132,'MES/HQT/23/FSA/LTP/006','LTPHP006','Laptop','HP ProBook 450 G10',NULL,'Floor 3',NULL,'Peter Mukasa','Administration','Issued',22,'issued','Issued from store spare');

-- ===== GOODS ISSUED =====
-- GI#1: ICT Department
INSERT INTO goods_issued (id, department, officer_name, officer_title, issue_date, notes, issued_by) VALUES
(1, 'ICT', 'ICT Manager', 'ICT Manager', '2026-07-25', 'New Dell desktops and monitor for ICT office setup', 'Kisakye Betty');

INSERT INTO goods_issued_items (id, goods_issued_id, stock_item_id, asset_id, notes) VALUES
(1, 1, 1, 125, 'Desktop for ICT Manager'),
(2, 1, 6, 126, 'Monitor for ICT Manager'),
(3, 1, 11, 127, 'Laptop for ICT Manager');

-- GI#2: Education Planning
INSERT INTO goods_issued (id, department, officer_name, officer_title, issue_date, notes, issued_by) VALUES
(2, 'Education Planning', 'Commissioner Planning', 'Commissioner', '2026-07-28', 'Spare system units and monitor for Education Planning', 'Kisakye Betty');

INSERT INTO goods_issued_items (id, goods_issued_id, stock_item_id, asset_id, notes) VALUES
(4, 2, 14, 128, 'Spare desktop for Planning'),
(5, 2, 15, 129, 'Spare desktop for Planning'),
(6, 2, 17, 130, 'Spare monitor for Planning');

-- GI#3: Administration
INSERT INTO goods_issued (id, department, officer_name, officer_title, issue_date, notes, issued_by) VALUES
(3, 'Administration', 'Peter Mukasa', 'HOD Administration', '2026-07-29', 'Printer and laptop for Administration office', 'Kisakye Betty');

INSERT INTO goods_issued_items (id, goods_issued_id, stock_item_id, asset_id, notes) VALUES
(7, 3, 20, 131, 'Printer for Admin'),
(8, 3, 22, 132, 'Laptop for Admin');

-- ===== MOVEMENTS =====
-- Stock movements: GR received
INSERT INTO movements (item_type, item_id, movement_type, from_status, to_status, from_location, to_location, from_department, to_department, from_assigned, to_assigned, reference_type, reference_id, notes, changed_by) VALUES
('stock',1,'Received','','In Store','','Stores','','Stores','','Kisakye Betty','goods_received',1,'From: Dell Technologies Uganda Ltd., LPO: LPO/MoES/2026/00452','Kisakye Betty'),
('stock',2,'Received','','In Store','','Stores','','Stores','','Kisakye Betty','goods_received',1,'From: Dell Technologies Uganda Ltd., LPO: LPO/MoES/2026/00452','Kisakye Betty'),
('stock',3,'Received','','In Store','','Stores','','Stores','','Kisakye Betty','goods_received',1,'From: Dell Technologies Uganda Ltd., LPO: LPO/MoES/2026/00452','Kisakye Betty'),
('stock',4,'Received','','In Store','','Stores','','Stores','','Kisakye Betty','goods_received',1,'From: Dell Technologies Uganda Ltd., LPO: LPO/MoES/2026/00452','Kisakye Betty'),
('stock',5,'Received','','In Store','','Stores','','Stores','','Kisakye Betty','goods_received',1,'From: Dell Technologies Uganda Ltd., LPO: LPO/MoES/2026/00452','Kisakye Betty'),
('stock',6,'Received','','In Store','','Stores','','Stores','','Kisakye Betty','goods_received',1,'From: Dell Technologies Uganda Ltd., LPO: LPO/MoES/2026/00452','Kisakye Betty'),
('stock',7,'Received','','In Store','','Stores','','Stores','','Kisakye Betty','goods_received',1,'From: Dell Technologies Uganda Ltd., LPO: LPO/MoES/2026/00452','Kisakye Betty'),
('stock',8,'Received','','In Store','','Stores','','Stores','','Kisakye Betty','goods_received',1,'From: Dell Technologies Uganda Ltd., LPO: LPO/MoES/2026/00452','Kisakye Betty'),
('stock',9,'Received','','In Store','','Stores','','Stores','','Kisakye Betty','goods_received',1,'From: Dell Technologies Uganda Ltd., LPO: LPO/MoES/2026/00452','Kisakye Betty'),
('stock',10,'Received','','In Store','','Stores','','Stores','','Kisakye Betty','goods_received',1,'From: Dell Technologies Uganda Ltd., LPO: LPO/MoES/2026/00452','Kisakye Betty'),
('stock',11,'Received','','In Store','','Stores','','Stores','','Kisakye Betty','goods_received',2,'From: HP Uganda Limited, LPO: LPO/MoES/2026/00489','Kisakye Betty'),
('stock',12,'Received','','In Store','','Stores','','Stores','','Kisakye Betty','goods_received',2,'From: HP Uganda Limited, LPO: LPO/MoES/2026/00489','Kisakye Betty'),
('stock',13,'Received','','In Store','','Stores','','Stores','','Kisakye Betty','goods_received',2,'From: HP Uganda Limited, LPO: LPO/MoES/2026/00489','Kisakye Betty');

-- Asset movements: GI issued (now logged against assets)
INSERT INTO movements (item_type, item_id, movement_type, from_status, to_status, from_location, to_location, from_department, to_department, from_assigned, to_assigned, reference_type, reference_id, notes, changed_by) VALUES
('asset',125,'Issued','In Store','Issued','Stores','Floor 2','Stores','ICT','Kisakye Betty','ICT Manager','goods_issued',1,'Issued to: ICT Manager, ICT','Kisakye Betty'),
('asset',126,'Issued','In Store','Issued','Stores','Floor 2','Stores','ICT','Kisakye Betty','ICT Manager','goods_issued',1,'Issued to: ICT Manager, ICT','Kisakye Betty'),
('asset',127,'Issued','In Store','Issued','Stores','Floor 2','Stores','ICT','Kisakye Betty','ICT Manager','goods_issued',1,'Issued to: ICT Manager, ICT','Kisakye Betty'),
('asset',128,'Issued','In Store','Issued','Stores','Floor 6','Stores','Education Planning','Kisakye Betty','Commissioner Planning','goods_issued',2,'Issued to: Commissioner Planning, Education Planning','Kisakye Betty'),
('asset',129,'Issued','In Store','Issued','Stores','Floor 6','Stores','Education Planning','Kisakye Betty','Commissioner Planning','goods_issued',2,'Issued to: Commissioner Planning, Education Planning','Kisakye Betty'),
('asset',130,'Issued','In Store','Issued','Stores','Floor 6','Stores','Education Planning','Kisakye Betty','Commissioner Planning','goods_issued',2,'Issued to: Commissioner Planning, Education Planning','Kisakye Betty'),
('asset',131,'Issued','In Store','Issued','Stores','Floor 3','Stores','Administration','Kisakye Betty','Peter Mukasa','goods_issued',3,'Issued to: Peter Mukasa, Administration','Kisakye Betty'),
('asset',132,'Issued','In Store','Issued','Stores','Floor 3','Stores','Administration','Kisakye Betty','Peter Mukasa','goods_issued',3,'Issued to: Peter Mukasa, Administration','Kisakye Betty');
