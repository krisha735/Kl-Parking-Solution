# Kl-Parking-Solution
Database System Assignment

# 🚗 KLParkEasyASM: AI-Driven Parking Management System

**KLParkEasyASM** is a robust relational database solution designed to manage modern, high-tech parking facilities.  
It integrates traditional parking management with **IoT sensor monitoring**, **AI-driven dynamic pricing**, and a **comprehensive loyalty rewards system** for commuters and corporate clients.

---

## 🌟 Key Features

- **IoT Integration**  
  Real-time tracking of parking spot status (Operational, Needs Calibration, Offline).

- **AI-Powered Pricing**  
  Dedicated tables for AI model outputs and dynamic pricing rules based on peak hours and demand.

- **Client Loyalty System**  
  Automated point redemption, referral bonuses, and multi-tier loyalty levels (Bronze, Silver, Gold).

- **Personnel Management**  
  Tracks zone managers, technicians, and attendants linked to specific parking zones and maintenance tasks.

- **Green Initiatives**  
  Specialized tracking for EV-Charger spots and “Green Driver” status for electric vehicle users.

---

## 📊 Database Schema & Table Overview

The database consists of **11 interconnected tables**, designed with strong referential integrity and meaningful constraints.

### Table Overview

| Category | Tables |
|--------|--------|
| **User & Loyalty** | `Client`, `ClientContact`, `ReferralBonus`, `PointRedemption` |
| **Assets** | `Vehicle`, `ParkingSpot` |
| **Operations** | `Personnel`, `ParkingSession`, `Maintenance` |
| **AI & Pricing** | `DynamicPricingRule`, `AIModelOutput` |

---

## 🛠️ Tech Stack

- **Language:** SQL (Structured Query Language)
- **Database Engine:** MySQL / MariaDB
- **Tools:** MySQL Workbench
---
