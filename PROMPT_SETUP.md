# Antigravity Workspace Setup & Feature Specification

## Setup Instructions

Please execute the following setup tasks in my project workspace:

1. Create the directory `.agents/skills/flutter_dotnet_agentic` if it does not exist.
2. Clone or update the UI/UX Pro Max repository into `.agents/skills/ui_ux_pro_max` from:
   `https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git`
3. Ensure `pyyaml` is installed for Python by running: `pip install pyyaml`
4. Create the custom Antigravity skill file at `.agents/skills/flutter_dotnet_agentic/SKILL.md` with the following contents:

---
name: flutter-dotnet-agentic
description: Architect cross-platform Flutter applications (Web, Mobile, Linux Desktop) connecting to a .NET Core Web API. Use when generating state management, API service layers, and responsive desktop/mobile UI components.
---

# Flutter + .NET Core Agentic Architecture Skill

## Architectural Guidelines
1. **Backend Integration (.NET Core Web API):**
   - Use `dio` for all HTTP REST and SignalR calls.
   - Strictly map C# JSON responses into type-safe Flutter DTO models.
2. **State Management:**
   - Use `flutter_riverpod` (`AsyncNotifierProvider`) for state management and async data fetching.
3. **Adaptive Cross-Platform Layouts:**
   - Linux Desktop / Web: Use `NavigationRail`, compact layout density, and desktop hover/keyboard shortcuts.
   - Mobile (iOS/Android): Use `NavigationBar` with standard touch padding.
4. **UI/UX Design Engine Integration:**
   - Always invoke `python3 .agents/skills/ui_ux_pro_max/src/ui-ux-pro-max/scripts/search.py "<domain>" --stack flutter` to retrieve styling, theme color tokens, and accessibility rules before building presentation components.

---

5. Create a file named `FEATURES.md` in the root of the project with the following complete feature specification:

# DQMS (Digital Queue Management System) - Feature Specification & Staging Roadmap

## 🎯 Phased Persona-Based Development Roadmap

To ensure targeted, user-centric delivery, development is organized into 3 distinct persona stages:

```
┌───────────────────────────────────────────────────────────────────────────────────────────┐
│ STAGE 1: APPLICATION ADMIN PERSPECTIVE (Master Setup, Pipeline Configs & Analytics)      │
├───────────────────────────────────────────────────────────────────────────────────────────┤
│ STAGE 2: STAFF & TELLER PERSPECTIVE (High-Speed, Low-Friction, Hotkey Counter Station)     │
├───────────────────────────────────────────────────────────────────────────────────────────┤
│ STAGE 3: END CUSTOMER PERSPECTIVE (App-Less Mobile PWA, Kiosk, Display TVs & Voice TTS)    │
└───────────────────────────────────────────────────────────────────────────────────────────┘
```

### Stage 1: Application Admin Perspective (Setup, Masters & Configurations)
* **Goal:** Complete admin control over tenant organization, location hierarchy, multi-step process pipelines, display template mappings, staff role assignments, notification lead thresholds, and executive analytics.
* **Scope:** Admin Web Panel, Master APIs, Database DDL Schemas, Stored Procedures, and Reporting Engine.

### Stage 2: Staff & Operator Perspective (High-Speed Counter Station)
* **Goal:** High-density, keyboard-driven desktop/web counter UI designed for minimal clicks and rapid teller execution (`Space`, `F1-F5` hotkeys).
* **Scope:** Counter Station UI, Contextual Token Panel, Instant Transfer/Hold, SignalR Teller Events, and Simulator Mode.

### Stage 3: End Customer Perspective (World-Class Customer Experience)
* **Goal:** Stress-free, transparent customer journey across touch points.
* **Scope:** Touch Self-Service Kiosk, App-Less Mobile PWA (QR scan), Pre-Booking Engine, Waiting Room Display TVs with Multilingual Text-to-Speech (TTS), and WhatsApp CSAT feedback.

---

### 1.1 Multi-Tenant Isolation
* **Tenant-Level Partitioning:** Complete logical separation of data, settings, and workflows per organization.
* **Domain Adaptability:** Flexible domain classification supporting Hospitals, Passports, Banks, Restaurants & Food Courts, Government entities, Retail, and Service Centers.
* **Location Hierarchy:** Each Tenant can create and manage multiple physical branches/centers/dining areas.

### 1.2 Cross-Platform Ecosystem
* **Web First:** Responsive web panel for administrative tasks, tenant setup, and public views.
* **Mobile App:** Touch-optimized UI for customer remote token tracking and mobile check-ins.
* **Desktop App (Linux & Windows):** High-density, keyboard-driven UI for counters/tellers with low-latency responsiveness.
* **API Engine:** Centralized REST & WebSocket/SignalR backend powered by .NET Core.

### 1.3 Area & Zone Management
* **Hierarchical Layout:** Supports Tenant -> Location -> Area/Zone -> Counter/Room.
* **Proximity & Load-Balanced Routing:** Tokens are automatically directed to the nearest or least-congested Area offering the target Process.
* **Area-Isolated Display Screens:** TV displays in waiting zones can be filtered by `AreaId` to show only relevant local counter calls.

---

## 2. Dynamic N-Level Process & Workflow Engine

### 2.1 Multi-Level Pipeline Configuration
* **Sequential Process Workflows:** Ability to define multi-step customer journeys (N-level deep pipelines).
* **Branching & Forwarding:** Support for forwarding tokens from Step N to Step N+1 without requiring customer re-registration.
* **Sub-Token Generation:** Automated generation of sub-tokens or sub-tickets when a process triggers an intermediate step (e.g., Doctor Visit -> Billing -> Lab Collection).

### 2.2 Turnaround Time (TAT) Management
* **Target TAT Settings:** Define operational TAT thresholds per process step and overall journey.
* **Real-Time TAT Variance:** Calculation of actual vs. expected processing duration at each counter.
* **Bottleneck Detection:** Visual alerts on dashboards when tokens exceed target TAT thresholds.

---

## 3. Token Lifecycle & Status State Machine

### 3.1 Status Transitions
Tokens transition through explicit lifecycle states:
* `0: Queued` — Entered queue / system waitlist.
* `1: Waiting` — In designated waiting zone for a specific counter line.
* `2: Calling` — Flashing on display audio/visual channels.
* `3: Active` — Service actively being delivered at counter.
* `4: Hold` — Paused (e.g., awaiting lab reports or missing documentation).
* `5: Canceled` — Abandoned or voided ticket.
* `6: Completed` — Successfully finished current step.
* `7: Forwarded` — Handed off to the next step pipeline.

### 3.2 VIP & Priority Management
* **Priority Classification:** Priority tiers for Standard, Senior Citizen, Emergency, and VIP.
* **Priority Queue Interleaving:** Automated queue re-ordering to serve VIP or Emergency tokens ahead of standard queues while preventing standard token starvation.

### 3.3 Contextual Comments & Audit Trails
* **Process Comments:** Ability for tellers/operators to append notes and internal comments to a token at any step.
* **Historical Audit Log:** Comprehensive time-stamped log tracking every state change, duration, counter assignment, and serving staff member.

### 3.4 WhatsApp & Multi-Channel Customer Alerts
* **Prior-to-Calling WhatsApp Notifications:** Automated WhatsApp message sent to the customer when their token reaches a configurable threshold before calling (e.g., "You are 3rd in line, please proceed towards Counter Zone B").
* **Configurable Pre-Alert Thresholds:** Tenant/Location configurable parameters for notification lead time (e.g., Notify N position(s) ahead or N minute(s) estimated wait time).
* **Multi-Gateway Fallback:** Support for SMS and Mobile Push notifications as fallback channels if WhatsApp delivery fails or is un-configured.

---

## 4. Multi-Interface User Experience (UX)

### 4.1 Self-Service Kiosk
* **Touch-Optimized Display:** Interactive service selector for on-site token issuance.
* **Direct Printing & QR Tracking:** Option for physical paper tickets or digital QR scanning for mobile updates.

### 4.2 Counter / Teller Station
* **Hotkey Navigation:** Rapid execution of Call, Next, Hold, Forward, and Complete actions via keyboard shortcuts.
* **Customer Context Display:** View token priority, duration counter, previous process history, and added comments.

### 4.3 Dynamic Waiting Area Display Templates
* **Customizable Multi-Template Engine:** Create, save, and configure display templates (Grid View, Split-Screen Video/Token View, High-Density List, Audio-Visual Banner).
* **Process-to-Template Mapping:** Option to map specific display templates directly to individual Processes or Steps.
* **Fallback Resolution Logic:** Checks for an explicit Process-to-Template mapping first; if no mapping exists, it automatically falls back to the Tenant's Default Display Template (`IsDefault = true`).

---

## 5. Tenant Analytics & Operations Dashboard

### 5.1 Real-Time Queue Metrics
* **Live Counter Status:** Active vs. idle counter status monitoring.
* **Current Queue Density:** Live volume of tokens across Queued, Active, and Hold states.

### 5.2 TAT & Efficiency Analytics (Operational Formulas)

* **Actual Step TAT Calculation:**
  $$\text{Actual Step TAT} = \text{ExitTime} - \text{EntryTime}$$

* **TAT Variance Percentage:**
  $$\text{TAT Variance (\%)} = \left( \frac{\text{Actual Step TAT} - \text{Target Step TAT}}{\text{Target Step TAT}} \right) \times 100$$
  *(Positive variance indicates SLA breach/bottleneck; negative indicates ahead of schedule).*

* **Process Efficiency Score:**
  $$\text{Process Efficiency Score} = \left( \frac{\text{Tokens Completed Within Target TAT}}{\text{Total Tokens Processed}} \right) \times 100$$

* **Visual Analytics & Heatmaps:**
  * **Process Step Heatmap:** Graphical display highlighting steps experiencing service bottlenecks based on TAT Variance.
  * **Throughput Metrics:** Tokens processed per hour grouped by counter, staff member, and process type.
  * **Cancellation & Abandonment Rates:** Tracking drop-off rates across multi-step journeys.

---

## 6. Online Appointment & Time-Slot Booking Engine

### 6.1 Process-Specific Time-Slot Configuration
* **Process & Location Slot Scheduling:** Define available booking windows per Location and Process (e.g., Passport Renewal available 09:00 AM - 04:00 PM in 15-minute slots).
* **Selective Service Blackout Days:** Ability to block/disable online appointments for a **specific process/service on specific days of the week** (e.g., Disable online booking for *Passport VIP Renewal* on Fridays, or block *Dental Diagnostics* on Weekends) while walk-in kiosk tokens remain active.
* **Date-Range Blackout Windows:** Configure date-range blackout windows per service (e.g., Block online booking for *Tax Audit Process* during annual audit week).
* **Slot Capacity & Overbooking Limits:** Configurable max token capacity per time slot (e.g., Max 5 appointment tokens per 15-minute window) to prevent counter congestion.
* **Non-Working Days & Holiday Calendar:** Define tenant/location holidays, custom non-working hours, and blackout windows.

### 6.2 Pre-Booking & QR Check-In
* **Web & Mobile Customer Widget:** Public self-service booking portal for pre-booking time slots with instant SMS/WhatsApp confirmation and digital QR Pass.
* **Auto Check-In & Priority Interleaving:** On arrival, customer scans QR pass at Kiosk or mobile geofence check-in, converting the appointment into an active queue token with elevated `Appointment` priority.
* **No-Show & Slot Release Handling:** Automated cancellation and release of slots if customer fails to check in within `N` minutes of their appointment start time.

---

## 7. Global Localization & Multi-Lingual Engine (i18n & L10n)

### 7.1 Multi-Lingual Interface & Audio Displays
* **Multi-Language UI (RTL & LTR):** Full support for Right-To-Left (Arabic, Hebrew) and Left-To-Right (English, Spanish, French, Hindi) languages across Kiosks, Counter Stations, and Waiting TV Displays.
* **Multilingual Audio Voice Announcements (TTS):** Automated Text-To-Speech audio announcements in local languages (e.g. Sequential audio call: *"Ticket A-102 to Counter 4"* in Arabic followed by English).
* **Location-Based Timezone & Currency:** Multi-region date/time formatting according to branch timezone (`UTC+4`, `UTC+5:30`).

---

## 8. Hardware Integration & IoT Protocols

### 8.1 Thermal Printers & Physical Call Controllers
* **ESC/POS Thermal Printing:** Native driver-less printing over Network/USB for thermal ticket printers (Epson, Star Micronics).
* **Hardware Keypad Support:** USB/IP physical keypad hardware support for tellers who prefer physical buttons over software UI.
* **Digital Signage Media Overlay:** Split-screen display engine showing promotional videos/live streams alongside real-time token call grids.

---

## 9. Real-Time Customer Experience (CSAT/NPS) & Feedback

### 9.1 Counter & Post-Service Feedback
* **Counter Feedback Terminals:** Integration with 4-button physical hardware or touch tablets at teller counters for instant customer rating (1-5 Stars / Smileys).
* **Post-Service WhatsApp CSAT Surveys:** Automated WhatsApp/SMS survey link sent upon token completion.
* **Teller Service Score Correlation:** Staff performance reports correlating CSAT ratings directly with Teller TAT and token volume.

---

## 10. Multi-Location SLA Escalation & Command Center

### 10.1 Automated SLA Escalation Manager
* **Multi-Tier Threshold Alerts:** Trigger automatic SMS/Email/Slack alerts to Branch Managers when queue wait time exceeds target thresholds.
* **Dynamic Counter Re-Allocation:** System suggests or automatically re-assigns idle tellers from low-volume processes to bottlenecked processes.
* **HQ Command Center View:** Centralized global executive dashboard mapping real-time operational metrics across all international branches on a live map.

---

## 11. Enterprise Security, SSO & Compliance

### 11.1 Enterprise Auth & PII Masking
* **Single Sign-On (SSO):** SAML 2.0 / OpenID Connect / Azure AD / Okta integration for corporate staff authentication.
* **Role-Based Access Control (RBAC):** Fine-grained permission system (HQ Admin, Branch Manager, Receptionist, Teller, Display Screen Only).
* **GDPR/HIPAA PII Masking:** Masking customer PII names and phone numbers on public waiting room displays.

---

## 12. SaaS Commercial Billing & Subscription Metering

### 12.1 Multi-Tenant Monetization
* **Flexible Licensing Models:** Per-Counter, Per-Location, or Per-Token usage metering billing models.
* **White-Labeling & Custom Domains:** Custom domain names (`queue.tenant.com`), logo uploads, and custom CSS color themes per tenant.

---

## 13. Comprehensive Enterprise Analytics & Reporting Suite

### 13.1 Operational & Staff Performance Reports
* **Teller Performance Summary:** Total tokens served, average service duration, idle time, hold counts, and transfer stats.
* **Counter Utilization Report:** Active vs. idle hours per counter with peak window analysis.
* **Staff Attendance & Audit Log:** Login/logout timestamps, break durations, and active serving time audit trails.

### 13.2 Customer Journey & Flow Reports
* **End-to-End Journey Audit:** Full multi-step process trace for a token with timestamps at every handoff.
* **Service Category Popularity:** Token volume breakdown by process, service category, or department.
* **Abandonment & No-Show Report:** Log of canceled, expired, or abandoned tokens across wait zones.

### 13.3 SLA & Executive HQ Reports
* **SLA Breach & TAT Variance Report:** Log of tokens exceeding target TAT categorized by root cause and branch.
* **HQ Multi-Branch Benchmark:** Comparative benchmark report ranking branches by average wait time and customer volume.
* **Automated PDF/Excel Distribution:** Scheduled email distribution engine sending daily/weekly PDF and XLSX reports to operations managers.

---

## 14. Third-Party Integration & Open API Platform

### 14.1 Webhook Notification Engine
* **Event-Driven Webhook Subscriptions:** Configure real-time HTTP Webhook subscriptions for external applications triggered by queue state transitions:
  * `token.created` — Fired when a customer takes a token (Syncs customer into CRM / HIS / POS).
  * `token.called` — Fired when a token is called at a counter (Triggers external display TV, pager, or staff alert).
  * `token.completed` — Fired when service/order completes (Syncs billing, kitchen status, and duration data).
  * `token.canceled` — Fired when a token is canceled/abandoned.
* **Webhook Retry & HMAC Signing:** Built-in exponential backoff retry mechanism (up to 5 retries) and HMAC-SHA256 signature headers (`X-DQMS-Signature`) for payload security.

### 14.2 RESTful Open API & Developer Portal
* **Developer API Gateway:** Public REST APIs for third-party systems to remotely issue tokens, query queue status, update customer info, and retrieve TAT analytics.
* **Granular Scoped API Keys:** Issue API Keys (`x-api-key`) with restricted permissions (e.g. `read:queues`, `write:tokens`, `read:reports`).
* **Rate Limiting & Throttling:** Built-in API rate limiting per IP / API Key to prevent API abuse.

### 14.3 Out-of-the-Box Industry Connectors
* **Restaurant & Food Court POS Integration:** Connectors for Point-of-Sale (POS) and Kitchen Display Systems (KDS) (e.g., Toast, Square, Lightspeed, Clover, Oracle MICROS) to auto-generate queue tokens upon order placement and flash order numbers when kitchen marks food ready.
* **Healthcare HIS / EMR Connectors:** Ready adapters for HL7 FHIR standards (Epic, Cerner, Meditech) to fetch patient appointments and link medical record IDs (MRN).
* **Core Banking Systems (CBS):** Connectors for Temenos, Finacle, and Oracle Flexcube to route VIP bank customers based on account balance tiers.
* **CRM & Helpdesk Integrations:** Native webhooks for Salesforce, HubSpot, Microsoft Dynamics 365, and Zendesk.

---

## 15. Offline Edge Resilience & Hybrid Sync Engine

### 15.1 Edge Node Autonomy (Zero Internet Disruption)
* **Local Branch Edge Server:** Support for running a lightweight local Edge Service at each physical location (branch/hospital/airport).
* **Offline Operation Continuity:** If internet or cloud connectivity drops, local Kiosks, Counter Stations, and Waiting TV Displays continue operating 100% offline without service interruption.
* **Automated Bidirectional Conflict-Free Sync:** When connection is restored, the Edge Node automatically syncs offline tokens, state transitions, and audit logs back to the central Cloud SaaS database with automated timestamp conflict resolution.

---

## 16. AI-Powered Smart Capacity & Dynamic Queue Balancing

### 16.1 AI Predictive Analytics & Dynamic Re-Allocation
* **AI Demand Surge Forecasting:** Machine learning model analyzing historical trends, day-of-week, weather, and time patterns to predict queue volume spikes 2 hours in advance.
* **Automated Counter Balancing:** Dynamic recommendation engine that alerts branch managers or automatically re-allocates idle counters from low-traffic services to high-demand bottlenecked queues.
* **Machine-Learned Estimated Wait Time (EWT):** Real-time EWT algorithm that continuously adjusts expected wait times based on teller processing speeds, complex process ratios, and current queue depth.

---

## 17. Zero-Download App-Less Virtual Queueing (Mobile PWA)

### 17.1 Camera QR Instant Access
* **No-App-Required Virtual Ticket:** Customer scans entrance QR code with standard smartphone camera, immediately opening a lightweight Web App (PWA) in browser without app store download.
* **Live Virtual Queue Tracker:** Displays real-time position countdown (*"3 people ahead of you"*), estimated wait time, and counter assignment.
* **Browser Push & Vibration Alerts:** Native web notifications and phone vibration alerts notifying customer when their turn approaches, allowing freedom to roam nearby shops/cafes.

---

## 18. Digital Signage Campaign & Emergency Broadcast Engine

### 18.1 Promotional Media Scheduling & Emergency Overrides
* **Scheduled Ad Campaigns:** Upload promotional video banners, image carousels, and news ticker announcements scheduled by time of day alongside token call grids.
* **One-Click HQ Emergency Broadcast:** Centralized emergency override engine allowing HQ operators to immediately broadcast emergency evacuation, safety alerts, or audio announcements across all connected branch TV displays globally.

---

## 19. Multi-Region Compliance, Data Residency & Security

### 19.1 Global Data Sovereignty & Encryption
* **Multi-Region Data Residency:** Multi-tenant deployment options supporting in-country data storage (e.g. AWS/Azure UAE North, EU Frankfurt, US East, Saudi Arabia Riyadh) to satisfy local data sovereignty regulations (GDPR, NESA, PDPL, SAMA).
* **Field-Level Encryption at Rest (AES-256):** Encrypted customer PII (Phone, Name, National ID) using tenant-isolated KMS encryption keys.
* **GDPR Right-To-Be-Forgotten:** Automated customer PII anonymization and configurable data retention purge schedules.

---

6. Once all setup tasks are executed and `FEATURES.md` is saved, please review the requirements and run a test query using the UI/UX script for Flutter, then present a sample adaptive display/dashboard component connecting a Flutter Riverpod provider to a .NET Core Web API endpoint (`/api/v1/dqms/dashboard`).
