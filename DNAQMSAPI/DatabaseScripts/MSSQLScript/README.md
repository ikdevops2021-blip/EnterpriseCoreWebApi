# MSSQL Database Scripts & Complete Database Table Dictionary

This folder contains the complete table schema creation scripts, stored procedures, and sample data scripts for SQL Server (MSSQL).

---

## 📋 Comprehensive Database Table Dictionary

Below is the complete list of all **36 Database Tables** in the DQMS Enterprise solution, organized by functional domain:

### 🏢 1. Core System & Multi-Tenant Security Domain
| Table Name | Purpose & Business Function |
| :--- | :--- |
| **`Organization`** | Root multi-tenant enterprise company/branch entity (`OrganizationId`). Scopes all child data. |
| **`User`** | Main user identity table storing authentication credentials (`UserCode`, `Email`, `PasswordHash`, `DisplayName`). |
| **`Role`** | Security RBAC role definitions (`SuperAdmin`, `Enterprise Admin`, `CounterOperator`, `Auditor`). |
| **`Permission`** | Granular security permissions catalog (e.g., `areas.read`, `processes.write`, `counters.call`). |
| **`UserOrganization`** | Cross-tenant membership joining users to enterprise organizations. |
| **`UserRole`** | Security mapping assigning RBAC roles to users within specific tenant organizations. |
| **`ApiKey`** | Server-to-server security API keys (`X-Api-Key`) for mobile apps, kiosks, and external integrations. |
| **`UserSession`** | Authentication state management, JWT refresh tokens, and active session revocation control. |
| **`UserDevice`** | Mobile tracker device registration and push notification token mapping (`FCM/APNS`). |

---

### 📍 2. User Profile & Geographical Location Domain
| Table Name | Purpose & Business Function |
| :--- | :--- |
| **`Country`** | Global country master table (250 countries with ISO codes). |
| **`State`** | Global state/province master table (5,308 states with `StateCode`). |
| **`City`** | Global city master table (152,970 cities with IATA `CityCode`). |
| **`UserAddress`** | User address entity records (`AddressLine1`, `City`, `State`, `PostalCode`, `Country`, `AddressType`). |
| **`UserContact`** | User contact entity records (`MobileNumber`, `Relationship`, `IsEmergencyContact`, `IsVerified`). |

---

### 🎯 3. DQMS Queue Management & Administration Domain
| Table Name | Purpose & Business Function |
| :--- | :--- |
| **`Area`** | Physical facility zones/wings (`AZ-01 Main Service Hall`, `AZ-02 Priority Wing`, `AZ-04 VIP Lounge`). |
| **`Process`** | Services & Process Pipelines master table (`ProcessCode`, `ProcessName`, `TargetTATMinutes`, `AllowSubTokens`, `Prefix`). |
| **`ProcessStep`** | Multi-step process workflow pipelines (`StepOrder`, `StepName`, `TargetTATMinutes`). |
| **`ProcessBlackoutDay`** | Selective blackout days and holiday schedules per service. |
| **`Counter`** | Physical counter stations & service desks (`CounterNumber`, `CounterName`, `AreaId`, `CurrentStatus`). |
| **`UserCounterAssignment`** | Maps counter operators to specific counters and services (`UserId`, `CounterId`, `ProcessId`). |
| **`DisplayTemplate`** | Waiting room 4K TV screen display templates (Grid, Split-Screen Video, High-Density List). |
| **`ProcessDisplayMapping`** | Assigns display templates to specific facility areas and service processes. |
| **`NotificationConfig`** | Service threshold lead configs (e.g. notify customer 3 numbers in advance via WhatsApp/SMS). |

---

### 🎫 4. Real-Time Token Operations & Queue Traffic Domain
| Table Name | Purpose & Business Function |
| :--- | :--- |
| **`TokenTransaction`** | Primary token ticket record (`TokenNumber`, `ProcessId`, `CounterId`, `Status`, `IssuedTime`, `CalledTime`, `CompletedTime`). |
| **`TokenAuditHistory`** | Complete audit log of every token status transition (`Issued` ➔ `Called` ➔ `Serving` ➔ `Completed` / `NoShow` / `Transferred`). |
| **`TvDisplaySession`** | Live state management for waiting room TV screens and counter voice announcements. |

---

### ⚙️ 5. Enterprise NexusCore Configuration & System Parameters Domain
| Table Name | Purpose & Business Function |
| :--- | :--- |
| **`ConfigCategory`** | System lookup category headers (`C_TITLE`, `C_GENDER`, `C_ADDRESSTYPE`, `C_NOTIFICATION_EVENT`). |
| **`ConfigParameters`** | Dynamic dropdown options catalog (`ParameterCode`, `ParameterName`, `ParameterColor`, `ParameterIcon`, `ParameterImage`). |
| **`SystemConfigurationKeys`** | Key-value system parameters (e.g., `MaxQueueCapacity`, `SlaWarningThreshold`). |

---

### 📧 6. Notifications, Messaging & Integration Domain
| Table Name | Purpose & Business Function |
| :--- | :--- |
| **`NotificationTemplate`** | Notification templates for WhatsApp, SMS, and Email dispatches. |
| **`UserNotification`** | In-App notification feed displayed in user notification bells. |
| **`EmailSettings`** | SMTP email gateway configurations per organization. |
| **`EmailQueue`** | Asynchronous email dispatch outbox queue. |
| **`EmailSignatures`** | Reusable HTML signature templates for emails. |
| **`NavigationMenu`** | Dynamic plug-and-play side menu items and route permissions. |
| **`AppLogs`** | Application-level NLog database target logging table for audit compliance. |

---

## 🛠️ Execution Sequence

Execute scripts in numerical order:

1. **`01_Organization.sql`**: Root multi-tenant organizational unit.
2. **`02_User.sql`**: Main authenticated identity table.
3. **`03_Role.sql`**: RBAC role definitions.
4. **`04_Permission.sql`**: Extensible list of permissions.
5. **`05_UserOrganization.sql`**: Maps User to Organization.
6. **`06_UserRole.sql`**: Maps User to Role.
7. **`07_ApiKey.sql`**: API access keys tied to users.
8. **`08_UserSession.sql`**: Refresh tokens and session control.
9. **`09_UserDevice.sql`**: Trusted devices for users.
10. **`10_OrganizationStorageConfig.sql`**: Cloud file storage configurations.
11. **`11_OrganizationPaymentProvider.sql`**: Payment gateway credentials.
12. **`12_StoredFile.sql`**: Cloud metadata for uploaded documents.
13. **`13_PaymentTransaction.sql`**: Payment records.
14. **`14_Integration_Tables.sql`**: Integration module configuration & logs.
15. **`16_AppLogs.sql`**: NLog database logging table.
16. **`17_NexusCore_Config.sql`**: Category hierarchy and config parameters.
17. **`22_UserContactAndAddress.sql`**: Location tables and User Contact/Address entities.
18. **`23_WorldLocationSeedData.sql`**: Consolidated 250 Countries, 5,308 States, 152,970 Cities seed.
19. **`29_Notification_Tables.sql`**: Notification templates, in-app feed, and SMS outbox queue.
20. **`31_DQMS_Admin_Masters.sql`**: DQMS Areas, Processes, ProcessSteps, Counters, and Display Templates.
21. **`33_DQMS_Staff_Operations.sql`**: Token transactions and audit history tables.
22. **`34_DQMS_Customer_Display.sql`**: TV sessions and customer notification queues.
23. **`35_NavigationMenu.sql`**: Navigation menu tables and stored procedures.
24. **`36_DQMS_MultiProcess_SampleData.sql`**: Sample data for multi-step processes, sub-tokens, and counter assignments.
