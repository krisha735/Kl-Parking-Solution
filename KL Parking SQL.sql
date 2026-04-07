DROP DATABASE IF EXISTS klparkeasyasm;
CREATE DATABASE klparkeasyasm;
USE klparkeasyasm;

# *****************
# 1. CREATING TABLES  
# *****************

#TABLE 1:Client
CREATE TABLE Client (
ClientID VARCHAR(20) PRIMARY KEY,
FullName VARCHAR(100) NOT NULL,
BusnRelType VARCHAR(30) NOT NULL CHECK (BusnRelType IN ('Individual Commuter','Corporate Fleet Account')),
PrefPayMethod VARCHAR(30) NOT NULL CHECK (PrefPayMethod IN ('Credit Card','E-Wallet','Blockchain Token')),
ParkPointsBal INT DEFAULT 0,
LoyaltyTier VARCHAR(10) DEFAULT 'Bronze' CHECK (LoyaltyTier IN ('Bronze','Silver','Gold')),
BrandAffiliation VARCHAR(10) DEFAULT 'Tourist' CHECK (BrandAffiliation IN ('Pro','Tourist','Both')),
GreenDriverStat BOOLEAN DEFAULT FALSE,
RefSource VARCHAR(50) NOT NULL
);

#TABLE 2:ClientContact - Solving the multivalue client primary contact attirbute.
CREATE TABLE ClientContact (
ContactID INT PRIMARY KEY AUTO_INCREMENT,
ClientID VARCHAR(20) NOT NULL,
ContactType VARCHAR(20) NOT NULL CHECK (ContactType IN ('Email','Phone')),
ContactValue VARCHAR(100) NOT NULL, 
IsPrimary BOOLEAN DEFAULT FALSE, 
FOREIGN KEY (ClientID) REFERENCES Client(ClientID)
);

#TABLE 3: ReferralBonus 
CREATE TABLE ReferralBonus (
BonusID VARCHAR(20) PRIMARY KEY,
ReferrerClientID VARCHAR(20) NOT NULL,
ReferredClientID VARCHAR(20) NOT NULL,
ReferralDate DATE NOT NULL,
ReferrerClientSource VARCHAR(50) NOT NULL,
ReferredClientBrand VARCHAR(50),
ReferredClientZone VARCHAR(50),
FOREIGN KEY (ReferrerClientID) REFERENCES Client(ClientID),
FOREIGN KEY (ReferredClientID) REFERENCES Client(ClientID)
);
 
#TABLE 4: PointRedemption
CREATE TABLE PointRedemption (
PRedemptId VARCHAR(20) PRIMARY KEY,
ClientID VARCHAR(20) NOT NULL,
RedemptionDate DATE NOT NULL,
PointsRedeemed INT NOT NULL,
FOREIGN KEY (ClientID) REFERENCES Client(ClientID)
);

#TABLE 5:Vehicle
CREATE TABLE Vehicle (
LicensePlateNumber VARCHAR(20) PRIMARY KEY,
ClientID VARCHAR(20) NOT NULL,
VehicleType VARCHAR(20) NOT NULL CHECK (VehicleType IN ('Sedan','SUV','Motorbike','Van')),
IsEV BOOLEAN DEFAULT FALSE,
FOREIGN KEY (ClientID) REFERENCES Client(ClientID)
);

# TABLE 6: Personnel
CREATE TABLE Personnel (
PersonnelID VARCHAR(20) PRIMARY KEY,
Name VARCHAR(100) NOT NULL,
Role VARCHAR(50),
AsgnLocation VARCHAR(50)
);

#TABLE 7: ParkingSpot
CREATE TABLE ParkingSpot (
ParkSpotID VARCHAR(20) PRIMARY KEY,
SiteTier VARCHAR(20) NOT NULL CHECK (SiteTier IN ('Tier 1', 'Tier 2', 'Tier 3')),
SpaceType VARCHAR(20) NOT NULL CHECK (SpaceType IN ('Standard','Premium-Covered','EV-Charger','Motorbike')),
OpSensorStat VARCHAR(30) NOT NULL CHECK (OpSensorStat IN ('Operational','Needs Calibration','Offline')),
LastInspectDT DATETIME,
LastMaintDate DATE,
StdHourlyRate DECIMAL(7,2) NOT NULL,
LocationZone VARCHAR(50) NOT NULL,
DemandRating INT CHECK (DemandRating BETWEEN 1 AND 5),
ZoneManager VARCHAR(20),
AttendantID VARCHAR(20),
FOREIGN KEY (ZoneManager) REFERENCES Personnel(PersonnelID),
FOREIGN KEY (AttendantID) REFERENCES Personnel(PersonnelID)
);

#TABLE 8: ParkingSession
CREATE TABLE ParkingSession (
ParkSessionID VARCHAR(20) PRIMARY KEY,
ClientID VARCHAR(20) NOT NULL,
LicensePlateNumber VARCHAR(20) NOT NULL,
ParkSpotID VARCHAR(20) NOT NULL,
StartTime DATETIME NOT NULL,
EndTime DATETIME,
DurationHours DECIMAL(4,2),
DiscPerc DECIMAL(5,2),
BaseCharge DECIMAL(8,2),
FinalCharge DECIMAL(8,2),
LPRFailCount INT DEFAULT 0,
FOREIGN KEY (ClientID) REFERENCES Client(ClientID),
FOREIGN KEY (LicensePlateNumber) REFERENCES Vehicle(LicensePlateNumber),
FOREIGN KEY (ParkSpotID) REFERENCES ParkingSpot(ParkSpotID)
);

# TABLE 9: Maintenance
CREATE TABLE Maintenance (
MaintenanceID VARCHAR(20) PRIMARY KEY,
ParkSpotID VARCHAR(20) NOT NULL,
TechnicianID VARCHAR(20) NOT NULL,
WorkDescription TEXT,
MaintenanceAction VARCHAR(50),
MaintenanceDate DATE NOT NULL,
FOREIGN KEY (ParkSpotID) REFERENCES ParkingSpot(ParkSpotID),
FOREIGN KEY (TechnicianID) REFERENCES Personnel(PersonnelID)
);

# TABLE 10: DynamicPricingRule
CREATE TABLE DynamicPricingRule (
DPriceRuleID VARCHAR(20) PRIMARY KEY,
ParkSpotID VARCHAR(20) NOT NULL,
ZoneAffected VARCHAR(50) NOT NULL,
SpCTypAffect VARCHAR(20) NOT NULL CHECK (SpCTypAffect IN ('Standard','Premium-Covered','EV-Charger','Motorbike')),
SurchargePer DECIMAL(5,2),
PeakHour VARCHAR(20),
EffectiveStartDate DATE,
FOREIGN KEY (ParkSpotID) REFERENCES ParkingSpot(ParkSpotID)
);

# TABLE 11: AIModelOutput
CREATE TABLE AIModelOutput (
OutputID VARCHAR(20) PRIMARY KEY,
DPriceRuleID VARCHAR(20) NOT NULL,
GeneratedDT DATETIME NOT NULL,
PredDemScore DECIMAL(4,2),
OptPriceIndex DECIMAL(5,2),
FOREIGN KEY (DPriceRuleID) REFERENCES DynamicPricingRule(DPriceRuleID)
);

#TABLE 12: RevenueProjection
CREATE TABLE RevenueProjection (
RevenueID VARCHAR(20) PRIMARY KEY,
ClientID VARCHAR(20),
ParkSessionID VARCHAR(20),
SrcTyp VARCHAR(30) NOT NULL CHECK (SrcTyp IN ('ParkingSession','CorporateFleet','PointRedemption','Penalty')),
GrossAmnt DECIMAL(10,2) NOT NULL,
DymcSrchg DECIMAL(6,2) DEFAULT 0,
LylDisc DECIMAL(6,2) DEFAULT 0,
TaxSst DECIMAL(6,2) DEFAULT 0,
RecrdedDT DATETIME NOT NULL,
FOREIGN KEY (ClientID) REFERENCES Client(ClientID),
FOREIGN KEY (ParkSessionID) REFERENCES ParkingSession(ParkSessionID)
);

#Table 13: AirQualityRouting
CREATE TABLE AirQualityRouting (
AqiID VARCHAR(20) PRIMARY KEY,
ParkSpotID VARCHAR(20) NOT NULL,
AQIValue INT NOT NULL CHECK (AQIValue BETWEEN 0 AND 500),
PollutantType VARCHAR(50),
RecordedDateTime DATETIME NOT NULL,
FOREIGN KEY (ParkSpotID) REFERENCES ParkingSpot(ParkSpotID)
);

#Table 14:MaintenanceAlert
CREATE TABLE MaintenanceAlert (
AlertID VARCHAR(20) PRIMARY KEY,
ParkSpotID VARCHAR(20) NOT NULL,
TechnicianID VARCHAR(20),
PrdctFailProblty DECIMAL(5,2) NOT NULL,
AlertDT DATETIME NOT NULL,
ActionRqrd VARCHAR(100),
FOREIGN KEY (ParkSpotID) REFERENCES ParkingSpot(ParkSpotID),
FOREIGN KEY (TechnicianID) REFERENCES Personnel(PersonnelID)
);


# ********************************
# 2. INSERTING VALUES INTO TABLES    
# ********************************

#INSERT VALUE TO CLIENT TABLE
INSERT INTO Client (ClientID, FullName, BusnRelType, PrefPayMethod, ParkPointsBal, LoyaltyTier, BrandAffiliation, GreenDriverStat, RefSource) VALUES
('C001','Alif Hakimi B. Mazlan','Corporate Fleet Account','Credit Card',1500,'Gold','Pro',TRUE,'Google Ad'),
('C002','Serena Foong','Individual Commuter','E-Wallet',350,'Silver','Both',FALSE,'Social Media'),
('C003','Tech Solutions Bhd','Corporate Fleet Account','Blockchain Token',5000,'Gold','Pro',FALSE,'Word of Mouth'),
('C004','Hariharan Nandakumar','Individual Commuter','Credit Card', 10,'Bronze','Tourist',FALSE,'Billboard'),
('C005','Haiko International Group','Corporate Fleet Account','Credit Card', 800,'Silver','Pro', TRUE,'Referral'),
('C006','Kim Jing Kong','Individual Commuter','Blockchain Token', 6000,'Gold','Pro', TRUE,'Google Ad'),
('C007','Mark Lee','Individual Commuter','E-Wallet', 120,'Bronze','Tourist', FALSE,'Social Media'),
('C008','Lee Star Transport Corpration.','Corporate Fleet Account','E-Wallet', 2500,'Silver','Both', TRUE,'Word of Mouth'),
('C009','Bannerman Menon','Individual Commuter','Blockchain Token', 7500,'Gold','Tourist', FALSE,'Referral'),
('C010','Lara Raj','Individual Commuter','Credit Card', 50,'Bronze','Tourist',FALSE,'Billboard'),
('C011','Jenny Kim Hong','Individual Commuter','Blockchain Token', 9000,'Gold','Pro', TRUE,'Referral'),
('C012','Theodore Hong','Individual Commuter','Blockchain Token', 150,'Bronze','Tourist', FALSE,'Google Ad'),
('C013','Plato Sdn Bhd','Corporate Fleet Account','Credit Card', 1200,'Silver','Pro', FALSE,'Referral'),
('C014','James Dylan Noah','Individual Commuter','Blockchain Token', 8000,'Gold','Pro', FALSE,'Social Media'),
('C015','Sime Darby Bhd','Corporate Fleet Account','Blockchain Token', 5500,'Gold','Pro', TRUE,'Referral'),
('C016','Genting Group','Corporate Fleet Account','Credit Card', 300,'Bronze','Tourist', FALSE,'Direct Sales'),
('C017','Hafiz Malik','Individual Commuter','E-Wallet', 1000,'Silver','Pro', FALSE,'Social Media'),
('C018','Eco Green Transport','Corporate Fleet Account','E-Wallet', 4500,'Gold','Both', TRUE,'Referral'),
('C019','Jessica Lee','Individual Commuter','Credit Card', 50,'Bronze','Tourist',FALSE,'Billboard'),
('C020','Megamind Corporation','Corporate Fleet Account','Credit Card', 200,'Bronze','Pro', FALSE,'Direct Sales'),
('C021','Ahmad Zakian','Individual Commuter','Blockchain Token', 3500,'Silver','Pro', TRUE,'Google Ad'),
('C022','Kim Hock Corporation','Corporate Fleet Account','E-Wallet', 7000,'Gold','Pro', TRUE,'Word of Mouth'),
('C023','Gopal Naidu','Individual Commuter','Credit Card', 100,'Bronze','Tourist',FALSE,'Referral'),
('C024','Rapid Glow Group','Corporate Fleet Account','Credit Card', 1800,'Silver','Both', FALSE,'Direct Sales'),
('C025','Nadia Wong','Individual Commuter','E-Wallet', 400,'Bronze','Pro', TRUE,'Billboard');

#INSERT VALUE TO ClientContact TABLE
INSERT INTO ClientContact (ClientID, ContactType, ContactValue, IsPrimary) VALUES
('C001','Email','alif.mazlan@corp.my',TRUE),
('C001','Phone','+60-12-345-6789',FALSE),
('C002','Email','serena_foong@gmail.com', FALSE),
('C002','Phone','+60-16-987-6543', TRUE),
('C003','Email','contact@techsolutions.bhd', TRUE),
('C003','Phone','+60-13-001-1001', FALSE),
('C004','Email','hariharan.n42@gmail.com', FALSE),
('C004','Phone','+60-17-223-4567', TRUE),
('C005','Email','fleet.mgmt@haiko.com', TRUE),
('C005','Phone','+60-13-005-5005', FALSE),
('C006','Email','kim.j.kong@outlook.com', FALSE),
('C006','Phone','+60-11-876-5432', TRUE),
('C007','Email','mark32lee@outlook.com', TRUE),
('C007','Phone','+60-14-123-4567', FALSE),
('C008','Email','leestar.transport@corp.com', FALSE),
('C008','Phone','+60-13-008-8008', TRUE),
('C009','Email','bannerman.m@gmail.com', TRUE),
('C009','Phone','+60-19-654-3210', FALSE),
('C010','Email','lara.raj@outlook.com', FALSE),
('C010','Phone','+60-18-555-4444', TRUE),
('C011','Email','jenny.kh@yahoo.com', TRUE),
('C011','Phone','+60-12-998-8776', FALSE),
('C012','Email','theodore.h@gmail.com', FALSE),
('C012','Phone','+60-16-777-6666', TRUE),
('C013','Email','admin@plato.sdn.bhd', TRUE),
('C013','Phone','+60-11-013-3013', FALSE),
('C014','Email','james.d.n@gmail.com', FALSE),
('C014','Phone','+60-17-112-2334', TRUE),
('C015','Email','fleet@simedarby.com', TRUE),
('C015','Phone','+60-13-015-5015', FALSE),
('C016','Email','transport@genting.com', FALSE),
('C016','Phone','+60-11-016-6016', TRUE),
('C017','Email','hafiz.malik@gmail.com', TRUE),
('C017','Phone','+60-12-445-6789', FALSE),
('C018','Email','contact@ecogreen.com', FALSE),
('C018','Phone','+60-12-018-8018', TRUE),
('C019','Email','jessica.lee@gmail.com', TRUE),
('C019','Phone','+60-16-123-9876', FALSE),
('C020','Email','MGmind@corp.my', FALSE),
('C020','Phone','+60-11-020-0020', TRUE),
('C021','Email','ahmad.zakian@gmail.com', TRUE),
('C021','Phone','+60-17-900-1122', FALSE),
('C022','Email','admin@kimhock.com', FALSE),
('C022','Phone','+60-17-022-2022', TRUE),
('C023','Email','gopal.naidu@outlook.com', TRUE),
('C023','Phone','+60-17-334-5678', FALSE),
('C024','Email','rapidGlow@corp.com', FALSE),
('C024','Phone','+60-12-024-4024', TRUE),
('C025','Email','nadia.wong@outlook.com', TRUE),
('C025','Phone','+60-12-556-7788', FALSE);

#Insert value into ReferralBonus
INSERT INTO ReferralBonus (BonusID, ReferrerClientID, ReferredClientID, ReferralDate, ReferrerClientSource, ReferredClientBrand, ReferredClientZone) VALUES
('RB001','C005','C013','2025-10-01','Corporate Event','Pro','Bukit Bintang'),
('RB002','C011','C014','2025-11-05','Social Media','Pro','The Gardens Mall'),
('RB003','C001','C008','2025-12-01','Email Campaign','Both','KL Sentral'),
('RB004','C005','C015','2025-12-03','Corporate Event','Pro','Jalan Ampang'),
('RB005','C009','C010','2025-12-05','Social Media','Tourist','Cyberjaya'),
('RB006','C017','C021','2025-11-20','Social Media','Pro','Jalan Ampang'),
('RB007','C002','C018','2025-10-15','Corporate Event','Tourist','KL Sentral'),
('RB008','C006','C020','2025-11-10','Email Campaign','Both','Cyberjaya'),
('RB009','C012','C023','2025-12-08','Corporate Event','Pro','Bukit Bintang'),
('RB010','C004','C025','2025-12-12','Social Media','Tourist','Jalan Ampang');

#Insert value into PointRedemption
INSERT INTO PointRedemption (PRedemptId, ClientID, RedemptionDate, PointsRedeemed) VALUES
('PR001','C001','2025-10-02',200),
('PR002','C002','2025-10-05',150),
('PR003','C003','2025-10-10',90),
('PR004','C004','2025-10-15',60),
('PR005','C005','2025-11-01',100),
('PR006','C006','2025-11-08',200),
('PR007','C007','2025-11-20',80),
('PR008','C008','2025-12-01',150),
('PR009','C009','2025-12-05',100),
('PR010','C010','2025-12-10',25);

#Insert value into Vehicle
INSERT INTO Vehicle (LicensePlateNumber, ClientID, VehicleType, IsEV) VALUES
('WBN2364','C001','Sedan', FALSE),
('BKL3678','C002','SUV', TRUE),
('JPN9032','C003','Van', FALSE),
('PKR3486','C004','Motorbike', FALSE),
('WXY7830','C005','Sedan', TRUE),
('MEL1952','C006','SUV', FALSE),
('JHE3944','C007','Motorbike', FALSE),
('MBU6318','C008','Van', TRUE),
('JVD4896','C009','Sedan', FALSE),
('JWJ4637','C010','SUV', TRUE);

#Insert value into Personnel
INSERT INTO Personnel (PersonnelID, Name, Role, AsgnLocation) VALUES
('P001','Ahmad Raizan','Zone Manager','KL Sentral'), 
('P002','Siti Nur Maya','Technician','Bukit Bintang'),
('P003','Rajesh Kumar','Technician','KL Sentral'),
('P004','Lim Wei Han','Zone Manager','Cyberjaya'),
('P005','Noraini Hassan','Attendant','The Gardens Mall'),
('P006','Daniel Wong','Technician','Cyberjaya'),
('P007','Farah Nadia','Zone Manager','Jalan Ampang'),
('P008','Mohd Hafiz','Attendant','Jalan Ampang'),
('P009','Tan Jia Hui','Technician','The Gardens Mall'),
('P010','Mei Xuan Ling','Zone Manager','Bukit Bintang');

#Insert value into ParkingSpot
INSERT INTO ParkingSpot (ParkSpotID, SiteTier, SpaceType, OpSensorStat, LastInspectDT, LastMaintDate, StdHourlyRate, LocationZone, DemandRating, ZoneManager, AttendantID) VALUES
('PS001','Tier 1','EV-Charger','Operational','2025-11-01 09:00:00','2025-11-02',8.00,'KL Sentral',5,'P001', NULL),
('PS002','Tier 2','Standard','Needs Calibration','2025-11-03 10:30:00','2025-11-04',5.00,'Bukit Bintang',3,'P010', NULL),
('PS003','Tier 1','Premium-Covered','Offline','2025-11-05 11:15:00','2025-11-06',9.00,'Cyberjaya',4,'P004', NULL),
('PS004','Tier 2','Standard','Operational','2025-11-07 08:45:00','2025-11-08',6.00,'KL Sentral',2,'P001', NULL),
('PS005','Tier 1','EV-Charger','Needs Calibration','2025-11-09 14:20:00','2025-11-10',7.50,'The Gardens Mall',4,'P004', 'P005'),
('PS006','Tier 2','Standard','Offline','2025-11-11 15:00:00','2025-11-12',5.50,'Jalan Ampang',3,'P007', 'P008'),
('PS007','Tier 1','EV-Charger','Operational','2025-11-13 09:40:00','2025-11-14',8.20,'KL Sentral',5,'P001', NULL),
('PS008','Tier 2','Premium-Covered','Needs Calibration','2025-11-15 10:10:00','2025-11-16',6.30,'Bukit Bintang',2,'P010', NULL),
('PS009','Tier 3','Motorbike','Operational','2025-11-19 16:00:00','2025-11-20',3.50,'The Gardens Mall',3,'P004', 'P005'),
('PS010','Tier 3','Motorbike','Operational','2025-11-21 09:00:00','2025-11-22',3.00,'KL Sentral',2,'P001', NULL);

#Insert value into ParkingSession
INSERT INTO ParkingSession (ParkSessionID, ClientID, LicensePlateNumber, ParkSpotID, StartTime, EndTime, DurationHours, DiscPerc, BaseCharge, FinalCharge, LPRFailCount) VALUES
('PSE001','C001','WBN2364','PS001','2025-12-01 08:00:00','2025-12-01 10:00:00',2.00,10.00,10.00,9.00,0),
('PSE002','C001','WBN2364','PS002','2025-12-02 09:00:00','2025-12-02 11:00:00',2.00,0.00,7.00,7.00,0),
('PSE003','C001','WBN2364','PS003','2025-12-03 07:30:00','2025-12-03 09:00:00',1.50,5.00,9.00,8.55,0),
('PSE004','C001','WBN2364','PS004','2025-12-04 10:00:00','2025-12-04 12:00:00',2.00,0.00,8.00,8.00,1),
('PSE005','C002','BKL3678','PS002','2025-12-01 09:00:00','2025-12-01 11:30:00',2.50,0.00,8.75,8.75,1),
('PSE006','C002','BKL3678','PS005','2025-12-02 14:00:00','2025-12-02 16:00:00',2.00,15.00,11.00,9.35,0),
('PSE007','C002','BKL3678','PS006','2025-12-03 08:30:00','2025-12-03 10:00:00',1.50,0.00,4.50,4.50,0),
('PSE008','C002','BKL3678','PS007','2025-12-04 18:00:00','2025-12-04 20:00:00',2.00,20.00,13.00,10.40,1),
('PSE009','C003','JPN9032','PS003','2025-12-02 07:30:00','2025-12-02 09:00:00',1.50,5.00,9.00,8.55,0),
('PSE010','C003','JPN9032','PS008','2025-12-03 12:00:00','2025-12-03 14:00:00',2.00,0.00,6.40,6.40,0),
('PSE011','C003','JPN9032','PS009','2025-12-04 09:00:00','2025-12-04 11:00:00',2.00,10.00,10.40,9.36,0),
('PSE012','C003','JPN9032','PS010','2025-12-05 15:00:00','2025-12-05 17:00:00',2.00,0.00,6.00,6.00,1),
('PSE013','C004','PKR3486','PS004','2025-12-02 10:00:00','2025-12-02 12:00:00',2.00,0.00,8.00,8.00,0),
('PSE014','C004','PKR3486','PS001','2025-12-03 08:00:00','2025-12-03 09:00:00',1.00,0.00,5.00,5.00,0),
('PSE015','C004','PKR3486','PS005','2025-12-04 11:00:00','2025-12-04 12:30:00',1.50,10.00,8.25,7.43,0),
('PSE016','C004','PKR3486','PS006','2025-12-05 13:00:00','2025-12-05 14:30:00',1.50,0.00,4.50,4.50,0),
('PSE017','C005','WXY7830','PS005','2025-12-03 08:15:00','2025-12-03 09:45:00',1.50,15.00,8.25,7.01,0),
('PSE018','C005','WXY7830','PS007','2025-12-04 09:00:00','2025-12-04 11:00:00',2.00,20.00,13.00,10.40,0),
('PSE019','C005','WXY7830','PS008','2025-12-05 14:00:00','2025-12-05 15:30:00',1.50,0.00,4.80,4.80,0),
('PSE020','C005','WXY7830','PS009','2025-12-06 08:30:00','2025-12-06 10:00:00',1.50,10.00,7.80,7.02,0),
('PSE021','C006','MEL1952','PS006','2025-12-03 11:00:00','2025-12-03 13:30:00',2.50,0.00,7.50,7.50,2),
('PSE022','C006','MEL1952','PS002','2025-12-04 08:00:00','2025-12-04 09:30:00',1.50,0.00,5.25,5.25,0),
('PSE023','C006','MEL1952','PS003','2025-12-05 07:30:00','2025-12-05 09:00:00',1.50,5.00,9.00,8.55,0),
('PSE024','C006','MEL1952','PS010','2025-12-06 12:00:00','2025-12-06 14:00:00',2.00,0.00,6.00,6.00,1),
('PSE025','C007','JHE3944','PS007','2025-12-04 09:00:00','2025-12-04 11:00:00',2.00,20.00,13.00,10.40,0),
('PSE026','C007','JHE3944','PS008','2025-12-05 14:00:00','2025-12-05 15:30:00',1.50,0.00,4.80,4.80,0),
('PSE027','C007','JHE3944','PS009','2025-12-06 08:30:00','2025-12-06 10:00:00',1.50,10.00,7.80,7.02,0),
('PSE028','C007','JHE3944','PS001','2025-12-07 12:00:00','2025-12-07 14:00:00',2.00,0.00,10.00,10.00,0),
('PSE029','C008','MBU6318','PS008','2025-12-04 14:00:00','2025-12-04 15:30:00',1.50,0.00,4.80,4.80,0),
('PSE030','C008','MBU6318','PS002','2025-12-05 09:00:00','2025-12-05 11:00:00',2.00,0.00,7.00,7.00,0),
('PSE031','C008','MBU6318','PS005','2025-12-06 08:15:00','2025-12-06 09:45:00',1.50,15.00,8.25,7.01,0),
('PSE032','C008','MBU6318','PS009','2025-12-07 13:00:00','2025-12-07 15:00:00',2.00,0.00,10.40,10.40,0),
('PSE033','C008','MBU6318','PS010','2025-12-08 16:00:00','2025-12-08 18:00:00',2.00,5.00,6.00,5.70,1),
('PSE034','C008','MBU6318','PS001','2025-12-09 08:00:00','2025-12-09 09:30:00',1.50,0.00,7.50,7.50,1),
('PSE035','C009','JVD4896','PS002','2025-12-10 09:00:00','2025-12-10 11:00:00',2.00,0.00,7.00,7.00,0),
('PSE036','C009','JVD4896','PS004','2025-12-11 10:00:00','2025-12-11 12:00:00',2.00,10.00,8.00,7.20,0),
('PSE037','C009','JVD4896','PS006','2025-12-12 08:30:00','2025-12-12 10:00:00',1.50,0.00,4.50,4.50,0),
('PSE038','C009','JVD4896','PS008','2025-12-13 14:00:00','2025-12-13 15:30:00',1.50,0.00,4.80,4.80,0),
('PSE039','C010','JWJ4637','PS009','2025-12-14 08:30:00','2025-12-14 10:30:00',2.00,10.00,10.40,9.36,0),
('PSE040','C010','JWJ4637','PS003','2025-12-15 12:00:00','2025-12-15 14:00:00',2.00,0.00,9.00,9.00,1);

#Insert value into Maintenance
INSERT INTO Maintenance (MaintenanceID, ParkSpotID, TechnicianID, WorkDescription, MaintenanceAction, MaintenanceDate) VALUES
('M001','PS001','P003','Sensor Calibration','Inspection','2025-11-02'),
('M002','PS002','P002','Parking line repaint','Upgrade','2025-11-04'),
('M003','PS003','P006','EV charger firmware update','Upgrade','2025-11-06'),
('M004','PS004','P003','Barrier gate lubrication','Routine','2025-11-08'),
('M005','PS005','P009','Camera replacement','Repair','2025-11-10'),
('M006','PS006','P006','Sensor battery change','Routine','2025-11-12'),
('M007','PS007','P003','EV charger connector swap','Repair','2025-11-14'),
('M008','PS008','P002','Surface crack sealing','Repair','2025-11-16'),
('M009','PS009','P006','Lighting system check','Inspection','2025-11-18'),
('M010','PS010','P009','Barrier arm fixing','Repair','2025-11-20');

#Insert value into DynamicPricingRule
INSERT INTO DynamicPricingRule 
(DPriceRuleID, ParkSpotID, ZoneAffected, SpCTypAffect, SurchargePer, PeakHour, EffectiveStartDate) VALUES
('DR001','PS001','KL Sentral','EV-Charger',1.25,'07:00-09:00','2025-11-01'),
('DR002','PS002','Bukit Bintang','Standard',1.50,'17:00-19:00','2025-11-01'),
('DR003','PS003','Cyberjaya','Premium-Covered',1.10,'12:00-14:00','2025-11-02'),
('DR004','PS006','Jalan Ampang','Standard',1.30,'13:00-15:00','2025-11-08'),
('DR005','PS005','The Gardens Mall','EV-Charger',1.20,'08:00-10:00','2025-11-04'),
('DR006','PS008','Bukit Bintang','Premium-Covered',1.40,'16:00-18:00','2025-11-05'),
('DR007','PS007','KL Sentral','EV-Charger',2.00,'19:00-21:00','2025-11-06'),
('DR008','PS004','KL Sentral','Standard',1.05,'06:00-08:00','2025-11-07'),
('DR009','PS006','Jalan Ampang','Standard',1.75,'18:00-20:00','2025-11-03'),
('DR010','PS009','The Gardens Mall','Motorbike',1.60,'20:00-22:00','2025-11-09');

#Insert value into AIModelOutput
INSERT INTO AIModelOutput (OutputID, DPriceRuleID, GeneratedDT, PredDemScore, OptPriceIndex)  VALUES
('AM001','DR001','2025-12-01 07:15:00',4.8,1.65),
('AM002','DR002','2025-12-01 17:30:00',5.0,2.10),
('AM003','DR003','2025-12-02 12:45:00',3.2,1.05),
('AM004','DR004','2025-12-03 18:10:00',4.5,2.35),
('AM005','DR005','2025-12-04 08:30:00',3.9,1.30),
('AM006','DR006','2025-12-05 16:45:00',4.2,1.95),
('AM007','DR007','2025-12-06 19:20:00',5.0,2.50),
('AM008','DR008','2025-12-07 06:50:00',2.8,1.10),
('AM009','DR009','2025-12-08 13:30:00',3.5,1.40),
('AM010','DR010','2025-12-09 20:15:00',4.7,2.20);

#Insert value into RevenueProjection
INSERT INTO RevenueProjection (RevenueID, ClientID, ParkSessionID, SrcTyp, GrossAmnt, DymcSrchg, LylDisc, TaxSst, RecrdedDT) VALUES
('RP001','C001','PSE001','ParkingSession',9.00,1.00,0.50,0.54,'2025-12-01 10:15:00'),
('RP002','C002','PSE006','ParkingSession',9.35,0.75,0.00,0.56,'2025-12-02 16:15:00'),
('RP003','C003','PSE009','ParkingSession',8.55,0.50,0.25,0.51,'2025-12-02 09:15:00'),
('RP004','C001','PSE002','CorporateFleet',7.00,0.70,0.00,0.42,'2025-12-02 11:15:00'),
('RP005','C003','PSE010','CorporateFleet',6.40,0.60,0.00,0.38,'2025-12-03 14:15:00'),
('RP006','C001','PSE003','PointRedemption',20.00,0.00,0.00,0.00,'2025-10-02 12:00:00'),
('RP007','C002','PSE005','PointRedemption',15.00,0.00,0.00,0.00,'2025-10-05 12:00:00'),
('RP008','C001','PSE004','Penalty',5.00,0.00,0.00,0.30,'2025-12-04 12:15:00'),
('RP009','C002','PSE008','Penalty',5.00,0.00,0.00,0.30,'2025-12-04 20:15:00'),
('RP010','C010','PSE040','Penalty',5.00,0.00,0.00,0.30,'2025-12-15 14:15:00');

#Insert value into AirQualityRouting
INSERT INTO AirQualityRouting (AqiID, ParkSpotID, AQIValue, PollutantType, RecordedDateTime) VALUES
('AQ001','PS001',120,'PM2.5','2025-12-01 08:00:00'),
('AQ002','PS002',95,'NO2','2025-12-01 09:00:00'),
('AQ003','PS003',180,'PM10','2025-12-01 10:00:00'),
('AQ004','PS004',85,'O3','2025-12-02 08:30:00'),
('AQ005','PS005',70,'PM2.5','2025-12-02 09:15:00'),
('AQ006','PS006',150,'SO2','2025-12-02 10:00:00'),
('AQ007','PS007',110,'PM2.5','2025-12-03 11:00:00'),
('AQ008','PS008',200,'PM10','2025-12-03 12:00:00'),
('AQ009','PS009',90,'NO2','2025-12-04 08:45:00'),
('AQ010','PS010',65,'O3','2025-12-04 09:30:00');

#Insert value into MaintenanceAlert 
INSERT INTO MaintenanceAlert (AlertID, ParkSpotID, TechnicianID, PrdctFailProblty, AlertDT, ActionRqrd) VALUES
('MA001','PS002','P002',0.85,'2025-12-01 07:30:00','Calibrate sensor before peak hours'),
('MA002','PS003','P006',0.90,'2025-12-01 08:00:00','Restart premium covered bay system'),
('MA003','PS005','P009',0.75,'2025-12-02 09:00:00','Replace EV charger connector'),
('MA004','PS006','P006',0.88,'2025-12-02 10:15:00','Check offline sensor battery'),
('MA005','PS008','P002',0.80,'2025-12-03 11:00:00','Recalibrate premium covered bay sensor'),
('MA006','PS009','P009',0.70,'2025-12-03 12:30:00','Inspect motorbike bay lighting'),
('MA007','PS001','P003',0.65,'2025-12-04 08:45:00','Routine EV charger firmware check'),
('MA008','PS004','P003',0.60,'2025-12-04 09:15:00','Lubricate barrier gate'),
('MA009','PS007','P003',0.78,'2025-12-05 07:50:00','Check EV charger connector wear'),
('MA010','PS010','P009',0.72,'2025-12-05 08:30:00','Replace motorbike bay barrier arm');

#TASK C : SQL Report
#1.Write an SQL query to list the name and vehicle identifier of all clients designated as 'Corporate' who have an electric vehicle registered and are affiliated with the 'KLParkEasy Pro' brand.
SELECT
	C.FullName,
	V.LicensePlateNumber
FROM
	Client C
JOIN
	Vehicle V ON C.ClientID=V.ClientID
WHERE
	C.BusnRelType='Corporate Fleet Account'
	AND V.IsEV=TRUE
AND C.BrandAffiliation IN ('Pro', 'Both');


#2.Write an SQL query to calculate the Total BaseCharge revenue generated from all parking transactions that occurred in the 'Bukit Bintang' zone.
SELECT
	SUM(PSess.BaseCharge) AS TotalBaseCharge_BukitBintang
FROM
	ParkingSession PSess
JOIN
ParkingSpot PSpot ON PSess.ParkSpotID=PSpot.ParkSpotID
WHERE
	PSpot.LocationZone='Bukit Bintang';


#3.Write an SQL query to list the spot identifier, its LocationZone, and its last service date for all parking spaces where the sensor status is reported as 'Offline'.
SELECT
	ParkSpotID,
LocationZone,
LastMaintDate
FROM
	ParkingSpot
WHERE
	OpSensorStat='Offline';

#4.Calculate the FinalCharge for a Gold Tier client who parked a vehicle for 3.0 hours in a lot with a Standard Hourly Rate of 5.00 (RM) during a Peak Hour where a 20% surcharge was applied (Gold Tier discount must be factored in after the surcharge is applied)
SELECT
	(3.0*5.00)AS BaseCharge,
	(3.0*5.00*(1+0.20))AS ChargeAfterSurcharge,
	(3.0*5.00*(1+0.20)*(1-0.05))AS FinalCharge_Scenario
FROM
	DUAL;


#5.Provide a report showing the total count of parking transactions that experienced one or more license plate reading failures, segmented by LocationZone.
SELECT
PSpot.LocationZone,
COUNT(PSess.ParkSessionID) AS LPRFail_Count
FROM
ParkingSession PSess
JOIN
ParkingSpot PSpot ON PSess.ParkSpotID=PSpot.ParkSpotID
WHERE
PSess.LPRFailCount>=1
GROUP BY
PSpot.LocationZone
ORDER BY
LPRFail_Count DESC;

#6.Write an SQL query to identify the 10 clients with the highest total ParkPoints Balance whose PreferredPaymentMethod is 'Blockchain Token', and list their Loyalty Tier and Brand Affiliation.
SELECT
FullName,
ParkPointsBal,
LoyaltyTier,
BrandAffiliation
FROM
Client
WHERE
PrefPayMethod='Blockchain Token'
ORDER BY
ParkPointsBal DESC
LIMIT 10;


#TASK D
#1. Report on customer that brings the most referals in each business relationship type and loyalty tier.
SELECT c.BusnRelType, c.LoyaltyTier, COUNT(rb.ReferredClientID) AS Total_Referals
From Client c
JOIN ReferralBonus rb  ON c.ClientID = rb.ReferrerClientID
GROUP BY c.BusnRelType, c.LoyaltyTier
ORDER BY Total_Referals DESC;

#2. Report on total revenue contribution  in each loyalty tier and location zone.
SELECT c.LoyaltyTier, ps.LocationZone, SUM(pse.FinalCharge) as Total_Revenue
FROM Client c
JOIN ParkingSession pse ON c.ClientID = pse.ClientID
JOIN ParkingSpot ps ON pse.ParkSpotID = ps.ParkSpotID
GROUP BY  c.LoyaltyTier, ps.LocationZone 
ORDER BY Total_Revenue DESC;

#3. Report on Total number of Maintenance in each location zone, space type and ithe sensor operational status.
SELECT ps.LocationZone, ps.SpaceType,ps.OpSensorStat, COUNT(m.MaintenanceID) AS TotalMaintenance, MAX(m.MaintenanceDate) AS LastMaintenance, ps.LastInspectDT
FROM ParkingSpot ps
JOIN Maintenance m ON ps.ParkSpotID = m.ParkSpotID
GROUP BY ps.LocationZone, ps.SpaceType, ps.OpSensorStat, ps.LastInspectDT;

#4. Report on Alert of Unhealthy Air Quality in Location Zone with Client Details and Contact Information to send alert.
SELECT c.FullName,c.LoyaltyTier, cc.ContactType,cc.ContactValue AS PrimaryContact, ps.LocationZone, aqr.AQIValue, aqr.RecordedDateTime
FROM Client c
JOIN ParkingSession pse ON c.ClientID = pse.ClientID
JOIN ParkingSpot ps ON pse.ParkSpotID = ps.ParkSpotID
JOIN AirQualityRouting aqr ON ps.ParkSpotID = aqr.ParkSpotID
JOIN ClientContact cc ON c.ClientID = cc.ClientID
WHERE aqr.AQIValue > 150 AND cc.IsPrimary = TRUE
ORDER BY aqr.RecordedDateTime DESC;

#5. Report on Parking Session Failures by Zone and Space type
SELECT ps.LocationZone, ps.SpaceType,SUM(pse.LPRFailCount) AS TotalLPRFailures,AVG(pse.LPRFailCount) AS AvgFailuresPerSession
FROM ParkingSession pse
JOIN Client c ON pse.ClientID = c.ClientID
JOIN ParkingSpot ps ON pse.ParkSpotID = ps.ParkSpotID
GROUP BY ps.LocationZone, ps.SpaceType
HAVING SUM(pse.LPRFailCount) > 0
ORDER BY TotalLPRFailures DESC;