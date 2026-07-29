---
name: flutter-dotnet-agentic
description: Architect cross-platform Flutter applications (Web, Mobile, Linux Desktop) connecting to a .NET Core Web API. Use when generating state management, API service layers, and responsive desktop/mobile UI components.
---

# Flutter + .NET Core Agentic Architecture Skill

## Architectural Guidelines
1. Backend Integration (.NET Core Web API):
   - Use `dio` for all HTTP REST and SignalR calls.
   - Strictly map C# JSON responses into type-safe Flutter DTO models.
2. State Management:
   - Use `flutter_riverpod` (`AsyncNotifierProvider`) for state management and async data fetching.
3. Adaptive Cross-Platform Layouts:
   - Linux Desktop / Web: Use `NavigationRail`, compact layout density, and desktop hover/keyboard shortcuts.
   - Mobile (iOS/Android): Use `NavigationBar` with standard touch padding.
4. UI/UX Design Engine Integration:
   - Always invoke `python3 .agents/skills/ui_ux_pro_max/src/ui-ux-pro-max/scripts/search.py "<domain>" --stack flutter` to retrieve styling, theme color tokens, and accessibility rules before building presentation components.
