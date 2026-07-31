# DQMS Enterprise Flutter Frontend

A modern, high-performance, cross-platform **Flutter Web & Desktop Application** built with **Riverpod State Management**, **Dio HTTP Client**, and **Master-Detail Responsive UI System** connecting to the **DQMS .NET 8 Core Web API**.

---

## 🚀 Architectural Key Features

### 1. Unified Admin Workspace & Domain Management
- **Areas & Zones**: Hierarchical tenant location, area, and zone management.
- **Process Pipelines**: Multi-step process workflow configurations.
- **Counter Stations**: Counter station registration, teller mappings, and status state machine.
- **Display Templates**: Audio-visual waiting room display template mapping.
- **Staff & Roles**: Enterprise RBAC role assignments.
- **User Profiles**: Profile search, edit, and status management.
- **Tenant / Organization Master**: Enterprise tenant configuration.
- **Config Categories & Parameters**: Dynamic configuration parameter management.
- **System Config Keys**: Real-time system configuration key-value management.
- **Notification Channels**: Multi-channel notification rules (WhatsApp, SMS, Email).
- **Email Gateway Setup**: SMTP gateway setup and test email dispatch.
- **Analytics Hub**: Operational queue metrics, TAT variance, and efficiency heatmaps.
- **Application & Audit Logs**: Real-time log inspector with level badges, stack trace diagnostics, and date filters.

---

### 2. Client Application Logging Utility ([ClientLogger](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/dqms_frontend/lib/core/logging/client_logger.dart))
Centralized client-side logger dispatches errors, warnings, info, and debug events directly to the `.NET Core Web API` (`POST /api/v1/Logs`).

```dart
// Log Info
await ClientLogger.logInfo(dio, 'User updated category parameter');

// Log Error with Exception & StackTrace
await ClientLogger.logError(
  dio,
  'Failed to fetch system configurations',
  error: exception,
  stackTrace: stackTrace,
);
```

---

### 3. Application & Audit Logs Inspection Screen ([app_logs_view.dart](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/dqms_frontend/lib/features/admin/widgets/app_logs_view.dart))
- **Default Recent Logs View**: Loads recent logs ordered by timestamp (`Logged DESC`).
- **Optional Date Filter**: Interactive Date Picker (`YYYY-MM-DD`). Leaving it blank displays recent logs across all dates.
- **Log Level Filter**: Filter by `ALL`, `ERROR / FATAL`, `WARN`, `INFO`, `DEBUG / TRACE`.
- **Detail Inspector Panel**: Inspect full Exception stack traces, Verbose Thread Info, Machine Name, and URL route.

---

### 4. Two-Tier Caching Architecture
- **Backend Caching**: `.NET Core` `IMemoryCache` in `ConfigurationService.cs` (10-minute sliding expiration).
- **Frontend Caching**: Riverpod `systemConfigCacheProvider` and `categoryParametersCacheProvider` in `config_cache_provider.dart`.
- **Master Sync**: Top header button in Admin Workspace to invalidate and refresh cache on demand.

---

### 5. Running the Flutter App

#### Run Web App (Chrome):
```bash
flutter run -d chrome --web-port 8080
```

#### Run Unit & Widget Tests:
```bash
flutter test
```

#### Run Static Analysis:
```bash
flutter analyze
```
