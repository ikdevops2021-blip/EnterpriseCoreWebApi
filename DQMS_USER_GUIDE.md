# AntiGravity Enterprise DQMS — Comprehensive Screen-by-Screen User Guide

**Product Version:** v1.0.0 Enterprise  
**Backend Architecture:** C# .NET 8 Web API + Dapper ORM + MySQL 8.0 & MS SQL Server  
**Frontend Architecture:** Flutter Cross-Platform Framework (Riverpod + Dio)  
**Design Standard:** Command Center Dark Aesthetic ([UI_UX_DESIGN_SPEC.md](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/UI_UX_DESIGN_SPEC.md))  
**Generated PDF Manual:** [DQMS_Enterprise_User_Guide.pdf](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/DQMS_Enterprise_User_Guide.pdf)

---

## Executive Overview & System Architecture

The **Digital Queue Management System (DQMS)** is an enterprise operational queue automation platform designed for high-traffic environments (Hospitals, Banking Centers, Government Outlets, Telecom Centers). The application is organized into 3 distinct operational stages:

1. **Stage 1 (Admin Masters & Configuration)**: Complete administrative control over tenants, location hierarchy, multi-step process pipelines, SLA TAT targets, system parameters, notifications, and navigation menus.
2. **Stage 2 (Staff & Operator Console)**: High-density, low-click Teller Counter UI engineered for rapid execution using physical keyboard hotkeys (`Space`, `F1`–`F7`).
3. **Stage 3 (Customer Touchpoints & Overhead Displays)**: Touchscreen Ticket Kiosk, Mobile Web QR Ticket Tracker, Appointment Booking Engine, and 4K Overhead TV Display Board.

---

## Table of Contents

- [AntiGravity Enterprise DQMS — Comprehensive Screen-by-Screen User Guide](#antigravity-enterprise-dqms--comprehensive-screen-by-screen-user-guide)
  - [Executive Overview \& System Architecture](#executive-overview--system-architecture)
  - [Table of Contents](#table-of-contents)
  - [1. Authentication \& Core Navigation](#1-authentication--core-navigation)
    - [1.1 Login Screen (`/login`)](#11-login-screen-login)
  - [2. Stage 1: Application Admin Screens](#2-stage-1-application-admin-screens)
    - [2.1 Admin Workspace Shell (`/admin/*`)](#21-admin-workspace-shell-admin)
    - [2.2 Areas \& Zones View (`/admin/areas`)](#22-areas--zones-view-adminareas)
    - [2.3 Processes \& SLAs View (`/admin/processes`)](#23-processes--slas-view-adminprocesses)
    - [2.4 Token Transactions Log View (`/admin/token-transactions`)](#24-token-transactions-log-view-admintoken-transactions)
    - [2.5 Counter \& Window Stations View (`/admin/counters`)](#25-counter--window-stations-view-admincounters)
    - [2.6 Display Templates View (`/admin/display-templates`)](#26-display-templates-view-admindisplay-templates)
    - [2.7 Staff Roles View (`/admin/staff`)](#27-staff-roles-view-adminstaff)
    - [2.8 User Profiles View (`/admin/user-profiles`)](#28-user-profiles-view-adminuser-profiles)
    - [2.9 Tenant Master View (`/admin/tenants`)](#29-tenant-master-view-admintenants)
    - [2.10 Config Categories \& Parameters View (`/admin/config-categories`)](#210-config-categories--parameters-view-adminconfig-categories)
    - [2.11 System Config View (`/admin/system-config`)](#211-system-config-view-adminsystem-config)
    - [2.12 Notification Config View (`/admin/notifications`)](#212-notification-config-view-adminnotifications)
    - [2.13 Email Config View (`/admin/email`)](#213-email-config-view-adminemail)
    - [2.14 Executive Analytics Dashboard (`/admin/analytics` \& `/dashboard`)](#214-executive-analytics-dashboard-adminanalytics--dashboard)
    - [2.15 System Audit Logs View (`/admin/logs`)](#215-system-audit-logs-view-adminlogs)
    - [2.16 Navigation Menu Management View (`/admin/navigation-menu`)](#216-navigation-menu-management-view-adminnavigation-menu)
  - [3. Stage 2: Staff \& Operator Console](#3-stage-2-staff--operator-console)
    - [3.1 Staff Lobby Screen (`/staff/lobby`)](#31-staff-lobby-screen-stafflobby)
    - [3.2 Counter Operator Screen (`/staff/counter`)](#32-counter-operator-screen-staffcounter)
  - [4. Stage 3: Customer Touchpoints \& Overhead Displays](#4-stage-3-customer-touchpoints--overhead-displays)
    - [4.1 Touch Self-Service Kiosk Screen (`/kiosk`)](#41-touch-self-service-kiosk-screen-kiosk)
    - [4.2 Mobile Web Ticket Tracker (`/mobile`)](#42-mobile-web-ticket-tracker-mobile)
    - [4.3 Appointment Booking Screen (`/appointment`)](#43-appointment-booking-screen-appointment)
    - [4.4 Appointments Calendar Screen (`/appointments-calendar`)](#44-appointments-calendar-screen-appointments-calendar)
    - [4.5 Waiting Room 4K Overhead TV Display (`/tv`)](#45-waiting-room-4k-overhead-tv-display-tv)
  - [5. API Endpoint Summary](#5-api-endpoint-summary)

---

## 1. Authentication & Core Navigation

### 1.1 Login Screen (`/login`)
- **Purpose**: Authenticates users and routes them to their designated workspace based on assigned roles (Admin, Staff, or Kiosk).
- **Target Users**: Application Admins, Staff Tellers, Kiosk Operators.
- **Step-by-Step Guide**:
  1. Open the application URL in any modern browser (`http://localhost:8080`).
  2. Select your target **Tenant Organization** from the tenant dropdown list.
  3. Enter your assigned **Username** (e.g. `admin`, `teller_01`).
  4. Enter your **Password**.
  5. Click **Sign In**.
  6. **Automatic Role Redirection**:
     - **Admins** → Redirected to `/admin/areas`.
     - **Staff / Tellers** → Redirected to `/staff/lobby`.
     - **Kiosks** → Redirected to `/kiosk`.

---

## 2. Stage 1: Application Admin Screens

### 2.1 Admin Workspace Shell (`/admin/*`)
- **Purpose**: Provides the side navigation bar, breadcrumb header, tenant switcher, and active route rendering container for administrative management.
- **Step-by-Step Guide**:
  1. Use the collapsible **Sidebar Navigation** on the left to switch between administrative master modules.
  2. Dynamic navigation items load directly from the database table `navigationmenu` (with hardcoded fallback safety).
  3. Click **Logout** at the bottom of the sidebar to terminate the session.

---

### 2.2 Areas & Zones View (`/admin/areas`)
- **Purpose**: Defines physical enterprise zones and location groupings (e.g. *Radiology Zone B*, *Main Banking Hall*).
- **Step-by-Step Guide**:
  1. View existing zones in the high-density datagrid table.
  2. Use the top **Search Bar** to filter zones by Area Code or Name.
  3. Click **+ Add New Area** to open the creation drawer.
  4. Enter **Area Code** (e.g. `AREA_RAD`), **Area Name**, and select **Location ID**.
  5. Toggle **Active Status** (`1: Active`, `0: Deactive`).
  6. Click **Save Area**.

---

### 2.3 Processes & SLAs View (`/admin/processes`)
- **Purpose**: Configures multi-level service pipelines, ticket prefixes, target SLA Turn-Around Times (TAT), communication channel toggles, and daily token limits.
- **Step-by-Step Guide**:
  1. View configured processes with SLA TAT metrics and token prefixes.
  2. Click **+ Create Process** to configure a new service pipeline step.
  3. Fill in process parameters:
     - **Process Code & Name** (e.g. `PROC_REG` — Registration).
     - **Token Prefix** (e.g. `A`, `B`, `C`).
     - **Target SLA TAT (Minutes)** (e.g. `10`).
     - **Communication Toggles**: Enable `SMS`, `WhatsApp`, `Email`, or `Feedback Survey`.
     - **Daily Token Limit Quota (`TokenLimitDaily`)**: Enter max daily tokens allowed (`0` for unlimited).
  4. Click **Save Process**.

---

### 2.4 Token Transactions Log View (`/admin/token-transactions`)
- **Purpose**: Live audit trail and real-time transaction view of all issued tokens across the organization.
- **Step-by-Step Guide**:
  1. Monitor active, waiting, called, and completed tokens in real time.
  2. Filter logs by **Token Number**, **Status Code** (e.g. `Queued`, `Active`, `Hold`, `Canceled`), or **Process ID**.
  3. Click any transaction row to inspect lifecycle timestamps and handling teller details.

---

### 2.5 Counter & Window Stations View (`/admin/counters`)
- **Purpose**: Maps service counters and physical windows to assigned areas and operational status states.
- **Step-by-Step Guide**:
  1. Review existing counters (`C-01`, `C-02`, etc.) and their assigned staff.
  2. Click **+ Add Counter** to register a new window station.
  3. Specify **Counter Number**, **Counter Name**, **Area ID**, and initial **Status** (`Idle`, `Serving`, `Break`).
  4. Click **Save Counter**.

---

### 2.6 Display Templates View (`/admin/display-templates`)
- **Purpose**: Configures overhead waiting room TV display layouts and visual alert styles.
- **Step-by-Step Guide**:
  1. Select template configuration options: `21001` GridView, `21002` Split-Screen Video, or `21003` High-Density List.
  2. Assign visual alert duration (e.g. `30` seconds flash alert for newly called tokens).
  3. Save template mapping to designated waiting room TV devices.

---

### 2.7 Staff Roles View (`/admin/staff`)
- **Purpose**: Manages staff operator accounts, counter station permission assignments, and security roles.
- **Step-by-Step Guide**:
  1. Browse staff accounts and permission levels.
  2. Click **+ Create Staff User** to register a teller or supervisor.
  3. Assign role permissions (`Staff`, `Supervisor`, `Admin`) and map allowed counter stations.
  4. Click **Save User**.

---

### 2.8 User Profiles View (`/admin/user-profiles`)
- **Purpose**: Manages application user account details, passwords, and authentication attributes.
- **Step-by-Step Guide**:
  1. Search for user profiles by username or email.
  2. Reset passwords or update contact details as required.

---

### 2.9 Tenant Master View (`/admin/tenants`)
- **Purpose**: Enterprise multi-tenant management view for configuring organization partitions and domain classifications (Hospitals, Banks, Government Outlets, Telecom).
- **Step-by-Step Guide**:
  1. View active tenant organizations.
  2. Click **+ Add Tenant** to create a new enterprise partition.
  3. Select **Domain Classification** (e.g., `Hospital`, `Banking`, `Government`).
  4. Save tenant record.

---

### 2.10 Config Categories & Parameters View (`/admin/config-categories`)
- **Purpose**: System-wide dynamic parameter and lookup table management (`ConfigCategory` & `ConfigParameters` IDs 18–21). Guarantees zero magic strings or hardcoded constants in system logic.
- **Step-by-Step Guide**:
  1. Select a **Config Category** (e.g., `18: Token Status`, `19: Priority Tier`, `20: Counter Status`, `21: Display Template`).
  2. Add or update lookup parameter codes and display descriptions.
  3. Save parameter entry.

---

### 2.11 System Config View (`/admin/system-config`)
- **Purpose**: Manages system-wide operational parameters, global feature flags, and refresh polling intervals.
- **Step-by-Step Guide**:
  1. Configure system heartbeat polling rates (e.g. `3` seconds for TV displays).
  2. Toggle global communication channels and fallback behavior.

---

### 2.12 Notification Config View (`/admin/notifications`)
- **Purpose**: Configures SMS and WhatsApp gateway provider settings, API keys, and automated messaging templates.
- **Step-by-Step Guide**:
  1. Select provider backend (Twilio, WhatsApp Business API).
  2. Set trigger thresholds (e.g. send alert when customer is `2` tokens away).
  3. Customize message body template string.

---

### 2.13 Email Config View (`/admin/email`)
- **Purpose**: Configures SMTP server parameters and electronic token receipt templates.
- **Step-by-Step Guide**:
  1. Enter **SMTP Host**, **Port**, **Username**, and **Password**.
  2. Enable/disable SSL/TLS.
  3. Test configuration with a test email button.

---

### 2.14 Executive Analytics Dashboard (`/admin/analytics` & `/dashboard`)
- **Purpose**: High-level visual dashboard featuring real-time operational KPIs, SLA TAT variance charts (`fl_chart`), peak-hour token traffic, and counter productivity metrics.
- **Step-by-Step Guide**:
  1. View total tokens issued, active wait times, and SLA compliance percentages.
  2. Analyze interactive trend charts for peak traffic hours.
  3. Filter analytics by Area, Date Range, or Process.

---

### 2.15 System Audit Logs View (`/admin/logs`)
- **Purpose**: Real-time system log stream for inspecting API requests, system exceptions, and security events.
- **Step-by-Step Guide**:
  1. Inspect error trace logs and system activities.
  2. Filter by Log Severity (`Info`, `Warning`, `Error`, `Critical`).

---

### 2.16 Navigation Menu Management View (`/admin/navigation-menu`)
- **Purpose**: Dynamically configures sidebar menu items, display icons, ordering, and required permission claims (`PR_IU_NavigationMenu`).
- **Step-by-Step Guide**:
  1. Drag/re-order or edit sidebar menu items.
  2. Assign required permission strings for access authorization.
  3. Save menu updates to apply dynamically across all admin sessions.

---

## 3. Stage 2: Staff & Operator Console

### 3.1 Staff Lobby Screen (`/staff/lobby`)
- **Purpose**: Pre-operational check-in screen for tellers to select their physical counter station and area before starting their shift.
- **Step-by-Step Guide**:
  1. Log in with staff credentials.
  2. Select your assigned **Area / Zone**.
  3. Select your designated **Counter Station** (e.g. `Counter 01`).
  4. Click **Start Shift / Open Counter**.

---

### 3.2 Counter Operator Screen (`/staff/counter`)
- **Purpose**: High-speed, low-click desktop/web console designed for rapid token handling using physical keyboard hotkeys.
- **Hotkeys & Controls Reference**:

| Hotkey | Action | Resulting Status | Description |
| :--- | :--- | :--- | :--- |
| **`SPACE` / `F1`** | **Call Next** | `18003` Calling | Pulls next token based on priority (`VIP` > `Senior` > `Standard`). |
| **`F2`** | **Recall** | `18003` Calling | Re-triggers visual pulse and audio chime on waiting room TV. |
| **`F3`** | **Serve Active** | `18004` Active | Starts active SLA TAT timer at counter. |
| **`F4`** | **Hold** | `18005` Hold | Places token on hold with operator notes. |
| **`F5`** | **Complete & Call Next** | `18007` Completed | Completes current ticket and immediately auto-calls next token. |
| **`F7`** | **Cancel** | `18006` Canceled | Cancels ticket for no-show. |

- **Step-by-Step Operator Workflow**:
  1. Press **`SPACE`** to call the next customer.
  2. When customer arrives at window, press **`F3`** to begin service.
  3. Upon finishing service, press **`F5`** to complete current customer and automatically call the next customer in line.

---

## 4. Stage 3: Customer Touchpoints & Overhead Displays

### 4.1 Touch Self-Service Kiosk Screen (`/kiosk`)
- **Purpose**: On-site customer ticket issuance touchscreen interface.
- **Step-by-Step Guide**:
  1. Touch target service category on screen (e.g. *Consultation*, *Radiology*, *Billing*).
  2. Select priority tier (*Standard*, *Senior Citizen*, *Disabled*, *VIP*).
  3. (Optional) Enter phone number to receive WhatsApp position updates.
  4. Click **Print Ticket** to generate ticket (`A-001`).

---

### 4.2 Mobile Web Ticket Tracker (`/mobile`)
- **Purpose**: App-less mobile web interface for customers to monitor their live queue position via smartphone.
- **Step-by-Step Guide**:
  1. Customer scans QR code on physical ticket.
  2. View live **Customers Ahead** and **Estimated Wait Time**.
  3. Prominent green alert banner flashes when token is called (*"Proceed to Counter 03"*).

---

### 4.3 Appointment Booking Screen (`/appointment`)
- **Purpose**: Pre-booking engine allowing customers to reserve service slots in advance.
- **Step-by-Step Guide**:
  1. Select service location and department process.
  2. Choose date and available time slot.
  3. Enter customer name, phone, and email details.
  4. Receive booking confirmation with QR code ticket.

---

### 4.4 Appointments Calendar Screen (`/appointments-calendar`)
- **Purpose**: Interactive administrative calendar view for reviewing scheduled customer appointments.
- **Step-by-Step Guide**:
  1. Browse calendar by Day, Week, or Month.
  2. Click any scheduled appointment card to view details or check in customer upon arrival.

---

### 4.5 Waiting Room 4K Overhead TV Display (`/tv`)
- **Purpose**: Waiting room public overhead screen displaying active calls, ticket queue status, audio chimes, and visual alerts.
- **Step-by-Step Guide**:
  1. Mount screen in waiting area and launch `/tv` in full-screen browser mode.
  2. Displays prominent **NOW CALLING** section (`Token A-001 -> COUNTER 03`).
  3. Auto-flashes newly called tokens with visual alert and audio chime.

---

## 5. API Endpoint Summary

| Endpoint Path | Method | Description |
| :--- | :--- | :--- |
| `/api/v1/Auth/login` | `POST` | User authentication & role dispatch |
| `/api/v1/admin/areas` | `GET` / `POST` | Master Area/Zone management |
| `/api/v1/admin/processes` | `GET` / `POST` | Process pipeline & SLA TAT configuration |
| `/api/v1/admin/counters` | `GET` / `POST` | Counter station registry |
| `/api/v1/staff/issue-token` | `POST` | Issues new queue token |
| `/api/v1/staff/call-next` | `POST` | Hotkey trigger to call next waiting token |
| `/api/v1/staff/update-status`| `POST` | Token state transition (`Serve`, `Hold`, `Complete`) |
| `/api/v1/public/display-board`| `GET` | Live TV display feed stream |
| `/api/v1/public/ticket-status`| `GET` | Mobile QR ticket status endpoint |

---
*Manual compiled for AntiGravity Enterprise DQMS Platform.*
