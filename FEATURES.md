# DQMS (Digital Queue Management System) - Feature Specification

## 1. Core Platform & Architectural Features

### 1.1 Multi-Tenant Isolation
* **Tenant-Level Partitioning:** Complete logical separation of data, settings, and workflows per organization.
* **Domain Adaptability:** Flexible domain classification supporting Hospitals, Passports, Banks, Government entities, and Service Centers.
* **Location Hierarchy:** Each Tenant can create and manage multiple physical branches/centers.

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

### 5.2 TAT & Efficiency Analytics
* **Process Step Heatmap:** Graphical display highlighting steps experiencing service bottlenecks.
* **Throughput Metrics:** Tokens processed per hour grouped by counter, staff member, and process type.
* **Cancellation & Abandonment Rates:** Tracking drop-off rates across multi-step journeys.
