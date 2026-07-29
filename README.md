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

### 1. Database Tables by Feature Module
| Module | Table Name | Short Details & Purpose |
| :--- | :--- | :--- |
| **Auth & Security** | `Organization` | Multitenant organization metadata, code, status, and system settings. |
| | `User` | User profiles, emails, password hashes, security salts, and profile data. |
| | `Role` | Enterprise roles (`SuperAdmin`, `Admin`, `User`, `Manager`). |
| | `Permission` | Fine-grained application permission definitions. |
| | `UserOrganization` | Many-to-many relationship mapping users to organizations. |
| | `UserRole` | Role assignments per user. |
| | `ApiKey` | Hashed API Keys for system-to-system integrations with expiration rules. |
| | `UserSession` | Active user JWT sessions and login history tracking. |
| | `UserDevice` | Registered mobile/desktop user devices for push notifications. |
| | `UserContactAndAddress` | User contacts, phone numbers, and physical mailing addresses. |
| **NexusCore Engine** | `NexusCore_Config` | System-wide dynamic key-value environment settings and configurations. |
| | `NexusCore_ID_Generator` | Custom sequence pattern generators for auto-generating formatted IDs. |
| **Notifications & Email** | `Notification` | System notifications log with delivery statuses. |
| | `EmailSettings` | SMTP and third-party provider configurations. |
| | `EmailQueue` | Asynchronous outbound email dispatch queue. |
| | `EmailSignatures` | HTML signature templates per organization/user. |
| **Storage System** | `StoredFile` | File metadata, storage paths, mime types, and file sizes. |
| | `FileAuditLogs` | Audit history of file uploads, downloads, and deletions. |
| **Integrations & Billing** | `ThirdPartyApiConfig` | Integrations config for third-party REST/SOAP APIs. |
| | `OrganizationPaymentProvider` | Multi-gateway payment config (Stripe, PayPal, UPI). |
| | `PaymentTransaction` | Financial payment transactions ledger. |
| | `SubscriptionSaaS` | SaaS subscription plans, tiers, and billing cycles. |
| | `AppLogs` | Application logging table for audit trails and diagnostics. |

---

### 2. Primary Stored Procedures
| Module | Stored Procedure Name | Short Details & Functionality |
| :--- | :--- | :--- |
| **Auth & User** | `sp_User_Authenticate` | Validates email/username and returns user authentication info. |
| | `sp_User_GetPermissions` | Fetches consolidated permissions for a specific user and role set. |
| | `sp_User_Create` / `sp_User_Update` | Manages user registration, details, and profile modifications. |
| | `sp_ApiKey_Validate` | Validates active `x-api-key` headers against hashed records. |
| **NexusCore** | `sp_NexusCore_Config_Get` | Retrieves cached system settings by key. |
| | `sp_NexusCore_GenerateID` | Generates next sequence number based on specified format rules. |
| **Location & Profile** | `sp_Location_GetCountries` | Fetches world location hierarchy (Countries, States, Cities). |
| | `sp_UserProfile_GetFull` | Retrieves combined user profile, roles, address, and org details. |
| **Storage & Email** | `sp_FileStorage_SaveFile` | Saves file metadata record and returns generated file GUID. |
| | `sp_EmailQueue_Enqueue` | Inserts outbound email into dispatch queue for background processors. |

---

### 3. Database Views
| View Name | Short Details & Purpose |
| :--- | :--- |
| `vw_EmailQueue_Pending` | Aggregates un-sent emails ready for immediate background dispatching. |
| `vw_UserActivePermissions` | Flattens user, role, and direct permission mappings into a single view for fast security authorization lookup. |

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

## 🔧 How to Use as a Template for New Projects

### Option A: Direct Clone (Manual Re-naming)
1. Clone this repository into your new project directory.
2. Rename namespaces from `AntiGravity.Enterprise` / `DNAQMSAPI` to your project name (e.g. `MyCompany.NewService`).
3. Update connection strings in `appsettings.json`.

### Option B: `.net custom template` (`dotnet new`)
You can install this repository locally as a reusable template:

```bash
# Install the template locally
dotnet new install ./

# Scaffolding a new microservice project
dotnet new enterprise-api -n MyCompany.PaymentService
```

---

## 🧪 Testing & Verification Scripts

The repository includes pre-built PowerShell test runners for local integration testing:
- **`init-localdb.ps1`**: Initializes local DB setup.
- **`run-qa-tests-http.ps1`**: Executes endpoint HTTP integration tests.
- **`seed_and_test_integration.ps1`**: One-step seed and verification test.

---

## 📜 License & Contribution

Distributed under the Enterprise Core License. Maintained by `ikdevops2021-blip`.
