# AntiGravity Enterprise DQMS — Complete Platform User Guide

**Product Version:** v1.0.0 Enterprise  
**Backend Architecture:** C# .NET 8 Web API + Dapper ORM + MySQL 8.0 & MS SQL Server  
**Frontend Architecture:** Flutter Cross-Platform Framework (Riverpod + Dio)  
**Design Standard:** Command Center UI/UX Design System ([UI_UX_DESIGN_SPEC.md](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/UI_UX_DESIGN_SPEC.md))  
**Generated PDF Manual:** [DQMS_Enterprise_User_Guide.pdf](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/DQMS_Enterprise_User_Guide.pdf)

---

## Executive Overview

The **Digital Queue Management System (DQMS)** is an enterprise operational queue automation platform designed for high-traffic environments (Hospitals, Banking Centers, Government Service Centers, Telecom Outlets). The application spans 3 operational stages:

1. **Stage 1 (Admin Masters)**: System setup for Areas, Processes, Counters, and Display Templates.
2. **Stage 2 (Staff Operations)**: High-speed, low-click Counter Operator Console powered by physical keyboard hotkeys (`Space / F1` to `F7`).
3. **Stage 3 (Customer & Display)**: 4K Overhead TV Display Board, Touchscreen Ticket Kiosk, and Mobile Web QR Ticket Tracker.

---

## 1. Stage 1: Application Admin Masters Guide

### Access & Navigation
Open the Web App at `http://localhost:8080` and ensure **Admin Master Configuration** is selected.

### Master Modules

#### A. Areas & Zones Master
- **Purpose**: Defines physical enterprise zones (e.g. `Radiology Zone B`, `Main Registration Lobby`).
- **Fields**: Area Code, Area Name, Location ID, Description, Active Status (`e_ActiveSearchStatus.Active`).
- **Database Procedures**: `PR_S_Area`, `PR_IU_Area`.

#### B. Process Pipelines & SLA TAT Master
- **Purpose**: Configures service workflows and target SLA turn-around times.
- **Fields**: Process Code, Process Name, Token Prefix (`A`, `B`, `C`), Target TAT (Minutes), Allow Sub-Tokens.
- **Database Procedures**: `PR_S_Process`, `PR_IU_Process`.

#### C. Counter & Window Stations Master
- **Purpose**: Maps service windows to staff operators and areas.
- **Fields**: Counter Number (`C-01`), Counter Name, Current Status (`20001` Idle, `20002` Serving, `20003` Break).
- **Database Procedures**: `PR_S_Counter`, `PR_IU_Counter`.

#### D. Display Templates Master
- **Purpose**: Configures waiting room TV overhead display layouts.
- **Fields**: Template Name, Template Type (`21001` GridView, `21002` Split-Screen Video, `21003` High-Density List).
- **Database Procedures**: `PR_S_DisplayTemplate`, `PR_IU_DisplayTemplate`.

---

## 2. Stage 2: Staff Counter Operator Console & Keyboard Hotkey Guide

### Access & Navigation
Click **Stage 2 Operator** from the top command header bar or navigate directly to `CounterOperatorScreen`.

### Low-Friction Keyboard Hotkey Reference

| Hotkey | Action | Target Token Status | Behavior & Operational Rules |
| :--- | :--- | :--- | :--- |
| **`SPACE` / `F1`** | **Call Next** | `18003` Calling | Pulls highest priority waiting customer (`VIP`, `Emergency`, `Senior Citizen`, `Standard`). |
| **`F2`** | **Recall** | `18003` Calling | Re-triggers audio chime and TV display visual pulse alert for current customer. |
| **`F3`** | **Serve Active** | `18004` Active | Marks customer active at counter and starts SLA TAT timer. |
| **`F4`** | **Hold** | `18005` Hold | Places token on hold with operator reason notes. |
| **`F5`** | **Complete & Call Next** | `18007` Completed | Completes current ticket and immediately auto-calls next waiting customer. |
| **`F7`** | **Cancel** | `18006` Canceled | Cancels ticket for no-show or customer departure. |

### Priority Queueing Engine
Tokens are automatically sorted in the queue using `PriorityTier DESC, IssuedTime ASC`:
1. `19005` **VIP / Emergency**
2. `19003` **Person with Disability**
3. `19002` **Senior Citizen**
4. `19001` **Standard Walk-in**

---

## 3. Stage 3: Customer Displays, Kiosk & Mobile Web Tracking Guide

### A. 4K Overhead TV Display Board (`WaitingRoomDisplayScreen`)
- **Access**: Click **Stage 3 TV Display** in top header bar.
- **Features**:
  - Displays large **NOW CALLING** cards (`A-001 -> COUNTER 03`).
  - 30-second green/red visual pulse alert (`FlashAlert = 1`) on newly called tokens.
  - Audio announcement chime indicator.
  - Live 3-second auto-refresh poll.

### B. Self-Service Ticket Kiosk (`KioskTicketScreen`)
- **Access**: Click **Stage 3 Kiosk** in top header bar.
- **Features**:
  - Touchscreen service department cards (`Consultation`, `Radiology`, `Pharmacy`, `Registration`).
  - Category selector (`Standard`, `Senior Citizen`, `Disabled`, `VIP`).
  - Customer phone number input for WhatsApp updates.
  - Thermal ticket printer integration.

### C. Customer Mobile Web Ticket Tracker (`CustomerMobileStatusScreen`)
- **Access**: Click **Stage 3 Mobile Tracker** in top header bar.
- **Features**:
  - Customer scans QR code on physical ticket to view live position on smartphone.
  - Displays live **Customers Ahead** (`2 ahead of you`) and **Estimated Wait Time** (`~15 mins`).
  - Prominent green banner alert when token is called ("Proceed to Counter 03").

---

## 4. REST API Endpoint Reference

| Method | Endpoint Path | Description | Access Level |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/v1/admin/areas` | Get areas list | Anonymous / Auth |
| `POST` | `/api/v1/admin/area` | Save area record | Anonymous / Auth |
| `GET` | `/api/v1/admin/processes` | Get process list | Anonymous / Auth |
| `POST` | `/api/v1/admin/process` | Save process record | Anonymous / Auth |
| `GET` | `/api/v1/admin/counters` | Get counters list | Anonymous / Auth |
| `POST` | `/api/v1/admin/counter` | Save counter record | Anonymous / Auth |
| `POST` | `/api/v1/staff/issue-token` | Issue new ticket | Anonymous / Staff |
| `POST` | `/api/v1/staff/call-next` | Call next token | Anonymous / Staff |
| `POST` | `/api/v1/staff/update-status` | Update token state | Anonymous / Staff |
| `GET` | `/api/v1/public/display-board` | TV Display Board Stream | Public |
| `GET` | `/api/v1/public/ticket-status/{id}`| Mobile Ticket Tracker | Public |

---

## 5. PDF User Guide Download
A print-ready PDF User Guide has been compiled and saved to the project root:
- File Location: [DQMS_Enterprise_User_Guide.pdf](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/DQMS_Enterprise_User_Guide.pdf)
