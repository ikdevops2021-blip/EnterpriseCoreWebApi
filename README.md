# Enterprise Core .NET 8 Web API Template

An enterprise-ready, production-grade **.NET 8 Web API Core Template** built with **Clean Architecture**, **Dapper DB Factory**, **Dual Database Support (MySQL & MS SQL Server)**, **JWT & API Key Authentication**, and modular microservices architecture.

---

## 📌 Features & Key Capabilities

- **Clean Architecture & Hexagonal Layers**: Decoupled `Domain`, `Application`, `Infrastructure`, `Storage`, and `Presentation` layers.
- **Dual Database Support (MySQL & MS SQL)**: Pre-configured database scripts and stored procedures for both MySQL and MS SQL Server.
- **Dapper DB Factory (`IDapperDBFactory`)**: High-performance data access layer abstraction supporting multiple simultaneous connection strings and transactions.
- **SeederApp CLI Tool**: Built-in migration and database initializer tool that handles new DB creation, table schema migrations, stored procedure deployment, and initial seed data.
- **Multi-Authentication Support**: Dual-mode security with JWT Bearer tokens and customizable API Keys (`x-api-key`).
- **Cross-Platform & Docker Ready**: Containerized execution with `Dockerfile` and `docker-compose.yml`.
- **Pre-packaged Modules**:
  - **Auth & Access Control**: Users, Roles, Permissions, User Devices, User Sessions.
  - **NexusCore Config Engine**: Environment settings and custom sequence ID generators.
  - **Storage & Audit System**: File storage integration and auditing.
  - **Email & Notification Gateway**: Multi-channel queued notification system.
  - **Subscription & SaaS Billing**: Enterprise tax engine, subscription plans, and invoice tracking.

---

## ⚡ Dapper DB Factory (`IDapperDBFactory`)

The template includes a generic, high-performance **Dapper DB Factory** ([DapperDBFactory.cs](file:///e:/MySourceCodes/AntiGravity_Projects/WebAPIs/antigravity-enterprise/AntiGravity.Enterprise.Shared.Core/Data/DapperDBFactory.cs)) located in `AntiGravity.Enterprise.Shared.Core`. 

It acts as a unified abstraction layer over `IDbConnection` and `Dapper`, eliminating boilerplate code while providing seamless connection pooling, dynamic provider switching, and transaction management across multiple connection targets simultaneously.

### Supported Databases & Providers:
| Database Type | Configuration Key (`Type`) | Underpinning ADO.NET Client | Usage / Target Scenario |
| :--- | :--- | :--- | :--- |
| **Microsoft SQL Server** | `"SqlServer"` | `Microsoft.Data.SqlClient` | Enterprise RDBMS (T-SQL, Stored Procs, Transactions) |
| **MySQL / MariaDB** | `"MySql"` | `MySql.Data.MySqlClient` | Open-Source RDBMS (MySQL Dialect, Stored Procs) |
| **Oracle Database** | `"Oracle"` | `Oracle.ManagedDataAccess.Client` | Enterprise Oracle RDBMS |
| **SQLite** | `"SQLite"` | `Microsoft.Data.Sqlite` | Embedded / Local File Database & Lightweight Testing |
| **MongoDB / DocumentDB**| `"MongoDb"` | `MongoDB.Driver` | NoSQL Document Store (Mapped via DB Wrapper) |

### Key DB Factory Features:
1. **Dynamic Provider Switching**: Simply change `"Type": "MySql"` or `"Type": "SqlServer"` in `appsettings.json` without modifying any repository or service code.
2. **Multi-Connection Support**: Manage multiple database connections simultaneously by passing named connection targets to `_dbFactory.GetConnection("SecondaryConnection")`.
3. **Transaction Management**: Built-in Unit-of-Work support via `BeginTransaction()`, `CommitTransaction()`, and `RollbackTransaction()`.
4. **Stored Procedure & Grid Reader Helpers**: Direct support for multi-result grid readers (`QueryMultipleAsync`) and execution helpers (`ExecuteAsync`, `QueryAsync`).

---

## 🗄️ Database Architecture & Pre-Packaged Objects

The template includes a comprehensive database schema designed for enterprise systems, fully implemented for both **MySQL** and **MS SQL Server**.

### 1. Complete List of Database Tables by Feature Module
| Module | Table Name | Short Details & Purpose |
| :--- | :--- | :--- |
| **Auth & Security** | `Organization` | Multitenant organization metadata, tenant code, active status, and custom settings. |
| | `User` | User profiles, email, password hash, salt, activation status, and metadata. |
| | `Role` | System & enterprise roles (`SuperAdmin`, `Admin`, `User`, `Manager`). |
| | `Permission` | Fine-grained application permission definitions. |
| | `UserOrganization` | Many-to-many relationship mapping users to organizations. |
| | `UserRole` | Role assignments per user. |
| | `ApiKey` | Hashed API Keys for system-to-system integrations with expiration rules. |
| | `UserSession` | Active user JWT sessions and login history tracking. |
| | `UserDevice` | Registered mobile/desktop user devices for push notifications. |
| | `UserContactAndAddress` | User contacts, phone numbers, and physical mailing addresses. |
| **NexusCore Config Engine** | `ConfigCategory` | Top-level configuration categories (e.g. System, Security, Storage, Email). |
| | `ConfigParameters` | Category-specific dynamic lookup parameters and options. |
| | `SystemConfigurationKeys` | System-wide dynamic key-value settings with data types and lock controls. |
| | `NexusCore_Config` | Legacy/Core key-value environment settings and configurations. |
| | `NexusCore_ID_Generator` | Custom sequence pattern generators for auto-generating formatted IDs. |
| **Location & Geography** | `Country` | World countries master list with ISO codes and dial codes. |
| | `State` | States/provinces linked to countries. |
| | `City` | Cities linked to states and countries. |
| **Integrations & Third-Party APIs** | `APIIntegrations` | Third-party REST/SOAP API providers, credentials, auth types, and OAuth tokens. |
| | `ApiEndpoints` | Action endpoints, relative paths, HTTP methods, and sample payloads. |
| | `APIAuditLogs` | Request/response audit logs, HTTP status codes, execution durations, and errors. |
| | `ThirdPartyApiConfig` | Legacy third-party integration endpoint configurations. |
| | `IntegrationLogs` | Execution and failure logs for third-party API invocations. |
| **Notifications & Email** | `Notification` | System notifications log with delivery statuses. |
| | `NotificationTemplate` | Email and SMS dynamic notification templates with placeholder tokens. |
| | `UserNotification` | User-level notification log tracking read/unread status. |
| | `SmsQueue` | Queue table for pending outbound SMS dispatches. |
| | `EmailSettings` | SMTP server configurations, ports, credentials, and SSL settings. |
| | `EmailQueue` | Asynchronous outbound email dispatch queue. |
| | `EmailSignatures` | HTML signature templates per organization/user. |
| **Storage System** | `OrganizationStorageConfig` | Per-tenant storage provider settings (Local Disk, AWS S3, Azure Blob). |
| | `StoredFile` | File metadata, storage paths, mime types, and file sizes. |
| | `FileAuditLogs` | Audit history of file uploads, downloads, and deletions. |
| **Payment & Billing System** | `CurrencyMaster` | Currency master list (USD, EUR, INR, etc.) with symbols and exchange rules. |
| | `PaymentProviders` | Master gateway list (Stripe, PayPal, Razorpay, UPI). |
| | `OrganizationPaymentProviders` | Tenant-specific payment gateway credentials and public/private keys. |
| | `BranchPaymentProviders` | Branch/location specific payment gateway configurations. |
| | `ProviderPaymentMethods` | Allowed payment methods per provider (Credit Card, NetBanking, UPI). |
| | `PaymentTransaction` / `PaymentTransactions` | Financial payment transaction ledger and tracking. |
| | `PaymentStatusHistory` | Transaction state transition history (Pending -> Success/Failed). |
| | `WebhookLogs` | Raw webhook payloads and processing logs from payment gateways. |
| | `SubscriptionSaaS` | SaaS subscription plans, tiers, features, and billing cycles. |
| **Logging & Diagnostics** | `AppLogs` | Application logging table for audit trails and diagnostics. |

---

### 2. Comprehensive Stored Procedures Reference
| Module | Stored Procedure Name | Short Details & Functionality |
| :--- | :--- | :--- |
| **Auth & User** | `sp_User_Authenticate` | Validates email/username and returns user authentication payload. |
| | `sp_User_GetPermissions` | Fetches consolidated permissions for a specific user and role set. |
| | `sp_User_Create` / `sp_User_Update` | Manages user registration, profile updates, and status changes. |
| | `sp_ApiKey_Validate` | Validates active `x-api-key` headers against hashed database records. |
| | `PR_S_UserAddresses` / `PR_IU_UserAddresses` | Search and Insert/Update operations for user physical addresses. |
| | `PR_S_UserContacts` / `PR_IU_UserContacts` | Search and Insert/Update operations for user phone/email contacts. |
| **NexusCore & Configuration** | `PR_S_ConfigCategory` / `PR_IU_ConfigCategory` | Search, insert, and update operations for `ConfigCategory`. |
| | `PR_S_ConfigParameters` / `PR_IU_ConfigParameters` | Search, insert, and update operations for `ConfigParameters`. |
| | `sp_GetConfigCategories` / `sp_GetConfigCategoryById` / `sp_GetConfigCategoryByCode` | Helper procedures for reading configuration categories. |
| | `sp_GetConfigParametersByCategory` / `sp_GetConfigParametersByCategoryCode` | Helper procedures for fetching configuration parameter lists. |
| | `PR_S_SystemConfigurationKeys` / `PR_IU_SystemConfigurationKeys` | Search and manage dynamic system configuration key-values. |
| | `sp_GetSystemConfigurations` / `sp_GetSystemConfigurationByKey` | Fetch system configurations with caching options. |
| | `sp_UpdateSystemConfiguration` | Updates system configuration values with validation. |
| | `sp_NexusCore_Config_Get` | Retrieves cached system settings by key. |
| | `sp_NexusCore_GenerateID` | Generates next sequence number based on specified format rules. |
| **Integrations** | `pr_GetThirdPartyApiConfig` | Retrieves third-party integration endpoint configurations and OAuth credentials. |
| | `pr_InsertIntegrationLog` | Logs API request/response execution details into `IntegrationLogs`. |
| | `pr_UpdateOAuthTokens` | Updates OAuth access/refresh tokens and expiration timestamps. |
| **Notifications** | `PR_S_NotificationTemplate` / `PR_IU_NotificationTemplate` | Search and manage email/SMS notification templates. |
| | `PR_S_UserNotification` / `PR_IU_UserNotification` | Search and insert/update user notification logs. |
| | `PR_S_UnreadNotificationCount` | Counts unread notifications for a specific user. |
| | `PR_U_MarkAllNotificationsRead` | Marks all unread user notifications as read. |
| **Location & Geography** | `PR_S_Country` / `PR_IU_Country` | Search and manage countries master list. |
| | `PR_S_State` / `PR_IU_State` | Search and manage state/province records. |
| | `PR_S_City` / `PR_IU_City` | Search and manage city records. |
| **File Storage** | `pr_GetOrganizationStorageConfig` | Retrieves tenant-specific storage credentials and provider configuration. |
| | `pr_GetStoredFileMetadata` | Reads file metadata by File ID or GUID. |
| | `pr_InsertStoredFileMetadata` | Saves new file record and metadata. |
| | `pr_MarkStoredFileAsDeleted` | Soft-deletes a stored file record. |
| | `pr_InsertFileAuditLog` | Audit logs file access operations (Upload, Download, Delete). |

---

### 3. Database Views Reference
| View Name | Short Details & Purpose |
| :--- | :--- |
| `vw_ConfigCategoryParameters` | Joins `ConfigCategory` and `ConfigParameters` into a single view for quick lookup of category parameter hierarchies. |
| `vw_EmailQueue_Pending` | Aggregates un-sent emails ready for immediate background dispatching. |
| `vw_UserActivePermissions` | Flattens user, role, and direct permission mappings into a single view for fast security authorization lookup. |
| `View_DailyMailHealthReport` | Generates daily email sending health, success rates, and failure metrics. |

---

### 4. Migration & Seed Scripts Summary (`DatabaseScripts/`)
| Script File | Purpose & Contents |
| :--- | :--- |
| `01_Organization.sql` to `10_...` | DDL Schema Table Creation for Core Entities. |
| `12_Core_StoredProcs.sql` | Primary Auth, Organization, and System Stored Procedures. |
| `17_NexusCore_Config.sql` | Core Nexus configuration schema setup. |
| `21_NexusCore_SeedData.sql` | Initial System Seed Data (Default Roles, Permissions, Configs). |
| `23_WorldLocationSeedData.sql` | Standardized World Countries, States, and Cities seed dataset. |
| `99_DummyData.sql` | Sample test records for quick developer verification (Skipped unless `--dummy` flag used). |



---

## 🚀 Quick Start Guide

### Prerequisites
- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [MySQL 8.0+](https://dev.mysql.com/downloads/) OR [Microsoft SQL Server 2019+](https://www.microsoft.com/en-us/sql-server/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) *(Optional)*

---

### Step 1: Clone the Template Repository

```bash
git clone https://github.com/ikdevops2021-blip/EnterpriseCoreWebApi.git
cd EnterpriseCoreWebApi
```

---

### Step 2: Database Setup & Migration (`SeederApp`)

Before launching the Web API, initialize your target database using the included `SeederApp` migration tool.

1. Configure your target database connection in `DNAQMSAPI/appsettings.json` or `SeederApp/appsettings.json`:

#### For MySQL:
```json
"DatabaseSettings": {
  "DefaultConnectionName": "MySqlConnection",
  "Databases": [
    {
      "Name": "MySqlConnection",
      "Type": "MySql",
      "ConnectionString": "Server=localhost;Port=3306;Database=enterprise_core_db;Uid=root;Pwd=yourpassword;"
    }
  ]
}
```

#### For MS SQL Server:
```json
"DatabaseSettings": {
  "DefaultConnectionName": "SqlServerConnection",
  "Databases": [
    {
      "Name": "SqlServerConnection",
      "Type": "SqlServer",
      "ConnectionString": "Server=localhost;Database=EnterpriseCoreDB;Trusted_Connection=True;TrustServerCertificate=True;"
    }
  ]
}
```

2. Run the `SeederApp` CLI tool to create the database (if missing), execute DDL scripts, deploy stored procedures, and seed initial data:

```bash
dotnet run --project SeederApp
```

---

### Step 3: Run the Web API

Launch the Web API solution using the .NET CLI or Visual Studio:

```bash
dotnet run --project DNAQMSAPI/DNAQMSAPI.API
```

Once running, access Swagger UI in your browser:
- **Swagger Documentation**: `http://localhost:5026/swagger` (or `https://localhost:7093/swagger`)

---

## 🏗️ Solution Folder Architecture

```
EnterpriseCoreWebApi/
├── AntiGravity.Enterprise.Shared.Core/  # Cross-cutting core (DapperDBFactory, Middlewares, Auth)
├── DNAQMSAPI/                           # Primary Web API Project Solution
│   ├── DNAQMSAPI.API/                   # Controllers, Middleware, API Startup
│   ├── DNAQMSAPI.Application/           # Use Cases, DTOs, Application Contracts
│   ├── DNAQMSAPI.Domain/                # Entities, Domain Enums, Interfaces
│   ├── DNAQMSAPI.Infrastructure/         # Dapper Repositories, DB Services
│   ├── DNAQMSAPI.Storage/               # File Storage Providers
│   └── DatabaseScripts/                 # DDL, Stored Procs & Seed Data
│       ├── MSSQLScript/                 # MS SQL T-SQL Migration Scripts
│       └── MySqlScript/                 # MySQL Dialect Migration Scripts
├── DataAccess/                          # Standardized Dapper Factory Interfaces
├── SeederApp/                           # CLI Tool for DB Creation & Seeding
├── Dockerfile                           # Production Docker Image Build
├── docker-compose.yml                   # Multi-container orchestration (API + DB)
└── README.md                            # Template Documentation
```

---

## 🔧 How to Use This Core Template

You can use this core template in two primary ways:

---

### Strategy 1: Using `.NET Custom CLI Template` (`dotnet new`) — Recommended for New Projects

Install this repository as a reusable template on your development machine. The .NET CLI automatically renames all solution files, projects, namespaces, and directory structures to match your new project name.

#### 1. Install the Template:
```bash
# Install directly from GitHub
dotnet new install https://github.com/ikdevops2021-blip/EnterpriseCoreWebApi.git

# Or install locally from your cloned directory
dotnet new install ./
```

#### 2. Generate a New API Microservice:
```bash
# Create a new project with your company/service namespace (e.g., MyCompany.PaymentAPI)
dotnet new enterprise-api -n MyCompany.PaymentAPI

# Navigate into your new project
cd MyCompany.PaymentAPI
```

#### 3. Manage Installed Templates:
```bash
# Check installed template list
dotnet new list

# Uninstall template if needed
dotnet new uninstall EnterpriseCoreWebApi
```

---

### Strategy 2: Direct Git Repository Workflow — For Framework Contributors & Custom Forks

If you want to customize the core starter architecture, add new base modules, or maintain a company-wide base template:

#### 1. Clone the Git Repository:
```bash
git clone https://github.com/ikdevops2021-blip/EnterpriseCoreWebApi.git MyCustomEnterpriseAPI
cd MyCustomEnterpriseAPI
```

#### 2. Configure Database & Launch:
1. Update `DNAQMSAPI/appsettings.json` with your MySQL or MS SQL Server connection string.
2. Run `dotnet run --project SeederApp` to create and migrate your database.
3. Run `dotnet run --project DNAQMSAPI/DNAQMSAPI.API` to launch your API!

---

## 🧪 Testing & Verification Scripts

The repository includes pre-built PowerShell test runners for local integration testing:
- **`init-localdb.ps1`**: Initializes local DB setup.
- **`run-qa-tests-http.ps1`**: Executes endpoint HTTP integration tests.
- **`seed_and_test_integration.ps1`**: One-step seed and verification test.

---

## 📜 License & Contribution

Distributed under the Enterprise Core License. Maintained by `ikdevops2021-blip`.
