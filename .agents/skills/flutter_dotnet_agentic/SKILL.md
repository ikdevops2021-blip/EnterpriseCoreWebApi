---
name: flutter-dotnet-agentic
description: Architect cross-platform Flutter applications (Web, Mobile, Linux Desktop) connecting to a .NET Core Web API. Use when generating state management, API service layers, and responsive desktop/mobile UI components.
---

# Flutter + .NET Core Agentic Architecture Skill

## Core Objective & Architectural Principles

The primary architectural goal of the **DNAQMS Enterprise Frontend Application** is to build a **single, 100% shared Flutter codebase** supporting multi-platform deployment (Web-First, Android, iOS, Windows, Linux) where any feature can be added, updated, or modified without risk of regression.

---

## 🏛️ Architectural Blueprint: Feature-Sliced Package Isolation & Clean Architecture

Every feature package enforces strict 3-tier Clean Architecture layering:

```
┌─────────────────────────────────────────────────────────┐
│                 CORE SHELL / APP ROUTER                 │
│          (GoRouter Declarative Route Registry)          │
└───────────┬─────────────────────────────────┬───────────┘
            │                                 │
┌───────────▼─────────────────┐     ┌─────────▼─────────────────┐
│   FEATURE: ADMIN MASTERS    │     ┌   FEATURE: OPERATOR / STAFF │
│ (Areas, Processes, Counters)│     │   (Counter Hotkeys & Queue) │
└───────────┬─────────────────┘     └─────────┬─────────────────┘
            │                                 │
            └────────────────┬────────────────┘
                             ▼
┌─────────────────────────────────────────────────────────┐
│                 CORE CONTRACTS & SHARED                 │
│  (Theme Tokens, Dio HTTP Client, Models, DTOs & Enums)  │
└─────────────────────────────────────────────────────────┘
```

### Layering Rules:
1. **Domain & Core Enums Layer (100% Pure Dart)**:
   - All enums must follow the mandatory `e_` prefix standard (e.g. `e_TokenStatus`, `e_PriorityTier`, `e_CounterStatus`).
   - Strongly-typed DTO models (`AreaDto`, `ProcessDto`, `TokenTransactionDto`) with factory JSON serialization.
2. **Data & Network Layer**:
   - `dioProvider` (`Dio` client with `baseUrl: http://localhost:5026`, timeouts, and logging interceptors).
3. **Presentation & State Management Layer**:
   - `flutter_riverpod` (`AsyncNotifierProvider`) for asynchronous notifier state management.
   - Adaptive UI Widgets reacting to screen width breakpoints (`Mobile <600px`, `Tablet 600-1024px`, `Desktop/Web >1024px`).

---

## ⚙️ Backend (.NET Core Web API) Integration Rules

1. **HTTP Client Standard**:
   - Consume endpoints via `Dio` using `ref.read(dioProvider)`.
   - Handle response payloads gracefully checking for `data` or `Data` keys.
2. **DTO & Enums Mapping**:
   - Map C# backend integer enums strictly into Dart `e_` prefixed enums.
3. **No Direct Backend Modifications during UI/UX Phases**:
   - UI refactoring must NEVER alter database schemas, API payload structures, or backend controller logic.

---

## 🎨 UI/UX Design Engine Integration

Before building or refactoring presentation components:
1. Refer to **`UI_UX_DESIGN_SPEC.md`** and **`docs/design/FLUTTER_UI_UX_DESIGN.md`**.
2. Run the UI/UX Pro Max search command:
   ```bash
   python .agents/skills/ui_ux_pro_max/src/ui-ux-pro-max/scripts/search.py "<query>" --stack flutter
   ```
3. Use the centralized design system tokens in `lib/core/theme/` (`AppColors`, `AppTypography`, `AppDecorations`, `AppTheme`) rather than hardcoding hex colors or inline text styles.

---

## 🔄 100% Code Sharing & Cross-Platform Adaptive Guidelines

1. **Layout Adaptability**:
   - **Desktop / Web (`>1024px`)**: Use sidebars, desktop hotkey listeners (`KeyboardListener`), high-density data tables, and compact spacing.
   - **Mobile (`<600px`)**: Use bottom navigation, full-width touch cards (minimum 48px touch targets), and swipeable views.
2. **Web-First & Deep Linking**:
   - Use `go_router` for declarative URL state management and deep-linking support on Web.
