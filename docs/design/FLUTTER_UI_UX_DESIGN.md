# DQMS Enterprise — Flutter UI/UX Design Specification & Architecture Foundation

**Project:** `dqms_frontend` (Digital Queue Management System — Cross-Platform Flutter App)  
**Target Platforms:** Web-First (PWA/WASM), Desktop (Windows/Linux), Mobile (Android/iOS)  
**Design Standard:** Command Center UI/UX Design System (Per [UI_UX_DESIGN_SPEC.md](../../UI_UX_DESIGN_SPEC.md))  

---

## 1. Executive Summary & Design Vision

The **DQMS Enterprise Frontend** is an operational command center UI designed to streamline queue operations, ticket management, waiting room overhead displays, and self-service kiosks.

### Core Philosophy
* **Precision. Clarity. Speed. Trust. Control.**
* **Refined Dark Operational Aesthetic**: Deep slate canvases (`#090D11`), structured dark surfaces (`#12171F`), crisp border contrasts (`#222B36`), and vibrant semantic accents.
* **Low Visual Noise & Zero Clutter**: Information hierarchy takes precedence over decorative gradients or glassmorphism. Visual density is compact yet comfortable.
* **100% Shared Code Architecture**: Single Flutter codebase adapting responsively to Desktop/Web widescreen displays, touch kiosks, and mobile screens.

---

## 2. Design System & Token Foundation (`lib/core/theme/`)

The design system establishes global constants and design tokens used across all screens.

```
lib/core/theme/
├── app_colors.dart        # Surface, text, status & brand palette
├── app_typography.dart    # GoogleFonts Inter hierarchy
├── app_decorations.dart   # Border radius, shadows, container styles
└── app_theme.dart         # Flutter ThemeData configuration
```

### Color Palette Specification (`AppColors`)

| Token Category | Token Name | Hex Code | Purpose / Usage |
| :--- | :--- | :--- | :--- |
| **Canvas** | `bgCanvas` | `#090D11` | Main screen background |
| **Surfaces** | `bgSurface` | `#12171F` | Panel, card, and sidebar background |
| **Surfaces (Hover)** | `bgSurfaceHover` | `#1A212B` | Hover & interactive state |
| **Header** | `bgHeader` | `#0E131A` | Top command navigation bar |
| **Borders** | `borderSubtle` | `#222B36` | Subtle dividers and card borders |
| **Borders (Focus)** | `borderFocus` | `#2F81F7` | Active input & keyboard focus state |
| **Brand Primary** | `brandPrimary` | `#2F81F7` | Primary buttons, active tabs, links |
| **Status Active** | `statusActive` | `#238636` | Active tokens, online counters, live sync |
| **Status Deactive** | `statusDeactive` | `#DA3633` | Canceled tokens, offline counters, errors |
| **Status Warning** | `statusWarning` | `#D29922` | SLA warning, estimated wait times |
| **Status Special** | `statusSpecial` | `#8957E5` | Priority tiers, process prefixes, VIP |
| **Typography** | `textMain` | `#F0F6FC` | Primary headings & high-emphasis text |
| **Typography** | `textMuted` | `#8B949E` | Subtitles, table labels, secondary info |
| **Typography** | `textSubtle` | `#6E7681` | Metadata, helper text, disabled states |

---

## 3. Reusable Core Component Architecture (`lib/core/widgets/`)

To eliminate code duplication and maintain visual consistency, all UI components are organized into atomic reusable widgets:

```
lib/core/widgets/
├── dqms_data_table.dart     # Standardized master data tables with hover & header rows
├── dqms_status_badge.dart   # Standardized status pills for tokens, counters & active states
├── dqms_kpi_card.dart       # Operational summary metric cards
├── dqms_button.dart         # Primary, Secondary, Destructive & Icon-only button styles
├── dqms_text_field.dart     # Form inputs with clean label & focus indicators
├── dqms_header.dart         # Top command navigation bar with breadcrumbs & quick actions
└── dqms_sidebar_nav.dart    # Collapsible / adaptive navigation sidebar
```

---

## 4. Declarative Routing & Application Shell (`lib/core/router/`)

Routing is governed by `go_router` in `lib/core/router/app_router.dart`, replacing imperative `Navigator.push()` calls.

### Route Map

| Path | Screen View | Access / Persona | Description |
| :--- | :--- | :--- | :--- |
| `/admin` | `AdminPanelScreen` | Admin / Manager | Master Configuration Command Center |
| `/admin/areas` | `AreaMasterTableView` | Admin | Areas & Zones Directory |
| `/admin/processes` | `ProcessMasterTableView` | Admin | Process Pipelines & SLA Targets |
| `/admin/counters` | `CounterStationView` | Admin | Service Windows & Station Config |
| `/admin/templates` | `DisplayTemplateView` | Admin | Waiting Room TV Templates |
| `/operator` | `CounterOperatorScreen` | Counter Staff | High-Speed Keyboard Operator Station |
| `/display` | `WaitingRoomDisplayScreen` | Public TV | 4K Overhead Waiting Room Calling Board |
| `/kiosk` | `KioskTicketScreen` | Customer | Self-Service Touchscreen Ticket Kiosk |
| `/ticket/:id` | `CustomerMobileStatusScreen` | Customer | Mobile Web Live Ticket Status Tracker |

---

## 5. Screen & View Specifications

### A. Admin Command Center (`/admin`)
* **Layout**: Top command bar + left navigation sidebar (Desktop) or bottom bar (Mobile) + central workspace stack.
* **KPI Metrics Bar**: Live indicators for Total Areas, Active Zones, Process Pipelines, and Operational SLA.
* **Data Tables**: High-density structured list views with subtle row separation, clean hover highlights, and modal creation dialogs.

### B. Counter Operator Station (`/operator`)
* **Focus**: High-speed queue processing with physical keyboard hotkey support (`SPACE`, `F1-F7`).
* **Active Token Workspace (Left 65%)**: Large display of current serving token number, customer name, priority tier badge, and operator action toolbar.
* **Waiting Queue Side Panel (Right 35%)**: Real-time list of waiting customers sorted by priority tier.

### C. Waiting Room TV Display Board (`/display`)
* **Focus**: High-visibility 4K overhead display board.
* **Live Calling Grid**: Prominent cards showing calling tokens, counter numbers, and visual flash alerts (`flashAlert`).
* **Header & Ticker**: Live time, audio announcement indicator, and rolling customer guidance ticker.

### D. Touchscreen Ticket Kiosk (`/kiosk`)
* **Focus**: Low-friction self-service ticket issuance.
* **Touch Targets**: Large service department selection cards (minimum 48px touch targets), priority category choice chips, and high-visibility print button.

### E. Mobile Ticket Status Tracker (`/ticket/:id`)
* **Focus**: Customer mobile browser status tracking.
* **Card Display**: Prominent queue token number, department name, estimated wait time, customers ahead, and live counter call alerts.

---

## 6. Adaptive Breakpoint Rules

Layouts adapt according to screen width breakpoints:

| Device Category | Breakpoint Width | Navigation Strategy | Layout Structure |
| :--- | :--- | :--- | :--- |
| **Mobile** | `< 600px` | Bottom Navigation Bar / Drawer | Single column layout, full-width cards |
| **Tablet** | `600px - 1024px` | Compact Icon Sidebar | 2-column grid layout |
| **Desktop / Widescreen** | `> 1024px` | Full Enterprise Sidebar | Multi-column command layout, split workspaces |

---

## 7. Preservation & Safety Rules

During UI/UX refactoring and design system rollout:

1. **State Management**: All Riverpod providers (`admin_providers.dart`, `staff_providers.dart`, `customer_providers.dart`, `dio_provider.dart`) MUST remain intact.
2. **Database Models & Enums**: `dqms_enums.dart` and `models/*.dart` MUST NOT be altered.
3. **Hotkey Logic**: `KeyboardListener` binding on `CounterOperatorScreen` MUST be preserved.
4. **Backend Contracts**: API endpoints (`/api/v1/admin/*`, `/api/v1/staff/*`, `/api/v1/public/*`) MUST remain 100% aligned with the .NET Core Web API.
