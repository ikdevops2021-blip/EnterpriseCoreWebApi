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
