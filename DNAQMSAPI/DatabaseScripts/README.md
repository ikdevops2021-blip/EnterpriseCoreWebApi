# 🗄️ Enterprise Core Database Migration Guide

This directory contains the pre-packaged DDL schemas, Stored Procedures, and Seed Data scripts for both **MySQL** and **Microsoft SQL Server**.

---

## 📂 Directory Organization

```
DNAQMSAPI/DatabaseScripts/
├── MySqlScript/             # MySQL 8.0+ Dialect Scripts
│   ├── 01_Organization.sql
│   ├── 02_User.sql
│   ├── 12_Core_StoredProcs.sql
│   ├── 21_NexusCore_SeedData.sql
│   ├── 23_WorldLocationSeedData.sql
│   └── 99_DummyData.sql     # Optional testing records
│
└── MSSQLScript/             # Microsoft SQL Server 2019+ (T-SQL) Scripts
    ├── 01_Organization.sql
    ├── 02_User.sql
    ├── 12_Core_StoredProcs.sql
    ├── 21_NexusCore_SeedData.sql
    ├── 23_WorldLocationSeedData.sql
    └── 99_DummyData.sql     # Optional testing records
```

---

## 🚀 Running Migrations via `SeederApp` CLI Tool

The solution includes a built-in cross-platform migration engine located at `/SeederApp`. 

### Key Capabilities:
1. **Auto-Database Creation**: Checks if the target database exists. If missing, it executes `CREATE DATABASE` automatically before starting migrations.
2. **Existing Database Migration**: Idempotently runs DDL, Stored Procedures, and Seed files against existing databases.
3. **Sequential Execution**: Sorts and applies scripts numerically (`01_`, `02_`, `12_`, `21_`, etc.).

---

### Command Execution Examples

#### 1. Execute MySQL Migration (Default Settings from `appsettings.json`)
```bash
dotnet run --project SeederApp
```

#### 2. Execute MS SQL Server Migration
```bash
dotnet run --project SeederApp -- --provider SqlServer --connection "Server=localhost;Database=EnterpriseCoreDB;Trusted_Connection=True;TrustServerCertificate=True;"
```

#### 3. Include Optional Test/Dummy Data (`--dummy` flag)
```bash
dotnet run --project SeederApp -- --provider MySql --dummy
```

---

## 📝 Script Naming Rules for Developers

When contributing new database migration scripts to this repository, follow these conventions:

1. **Prefix Numbers**:
   - `01_` to `10_`: Core DDL Schema Tables (Organizations, Users, Roles, ApiKeys)
   - `11_` to `20_`: Module Extensions & Stored Procedures
   - `21_` to `30_`: System Seed Data (Default Roles, Core Configs, World Locations)
   - `99_`: Optional Dummy/Test Data (Skipped unless `--dummy` flag is provided)
2. **Provider Separation**:
   - Maintain equivalent T-SQL scripts in `MSSQLScript/` and MySQL dialect scripts in `MySqlScript/`.
