# PHASE 12 – Enterprise Tax Engine Core Module

> ✅ **STATUS: COMPLETED**

## Configurable Multi-Country Tax Calculation Engine

---

# 📌 Overview

A standalone, reusable, configuration-driven tax engine.

Supports:

- Multi-country tax rules
- Country & state rate configuration
- Compound tax calculation
- Inclusive & exclusive tax
- SaaS multi-tenant support
- Zero hardcoded tax logic
- Schema-stable design

---

# 🎯 Core Objectives

- Eliminate hardcoded tax logic
- Enable master-table driven tax configuration
- Support compound tax rules
- Allow adding new tax types without schema changes
- Integrate with Subscription Billing

---

# 🏗 Project Structure

TaxEngine.Core/
 ├── API/
 ├── Application/
 │     ├── Interfaces/
 │     ├── Services/
 │     ├── DTOs/
 ├── Domain/
 │     ├── Entities/
 │     ├── Enums/
 ├── Infrastructure/
 │     ├── Persistence/
 └── Shared/DBScript/

---

# 🧠 Design Principles

## No Hardcoded Tax Logic
All tax calculation must be configuration-driven.

## TaxTypes Master Table Driven
Add new tax via DB insert only.

## Country & State Configurable Rates
Support country/state-level tax setup.

## Compound Tax Support
Support cascading tax calculation order.

## No Schema Modification for New Tax
Future tax types require no DB change.

---

# 🔐 Enums

```csharp
public enum TaxCalculationType : short
{
    Percentage = 1,
    Fixed = 2
}

public enum TaxApplicationType : short
{
    Exclusive = 1,
    Inclusive = 2
}

# 🗄 Database Design

## Table: TaxTypes

```sql
CREATE TABLE TaxTypes (
    TaxTypeId INT PRIMARY KEY IDENTITY(1,1),
    TaxName NVARCHAR(150) NOT NULL,
    CalculationType SMALLINT NOT NULL,
    ApplicationType SMALLINT NOT NULL,
    IsCompound BIT DEFAULT 0,
    
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedBy] INT NOT NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedBy] INT NULL,
    [ModifiedDate] DATETIME NULL,
    [IsDeleted] BIT NULL DEFAULT 0,
    [DeletedBy] INT NULL,
    [DeletedDate] DATETIME NULL
);
```

## Table: TaxRates

```sql
CREATE TABLE TaxRates (
    TaxRateId INT PRIMARY KEY IDENTITY(1,1),
    TaxTypeId INT NOT NULL,
    CountryCode NVARCHAR(2) NOT NULL,
    StateCode NVARCHAR(50) NULL,
    Rate DECIMAL(5,2) NOT NULL,
    EffectiveDate DATE NOT NULL,
    
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedBy] INT NOT NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedBy] INT NULL,
    [ModifiedDate] DATETIME NULL,
    [IsDeleted] BIT NULL DEFAULT 0,
    [DeletedBy] INT NULL,
    [DeletedDate] DATETIME NULL
);
```

## Table: TaxRules

```sql
CREATE TABLE TaxRules (
    TaxRuleId INT PRIMARY KEY IDENTITY(1,1),
    TaxTypeId INT NOT NULL,
    RuleName NVARCHAR(255) NOT NULL,
    Priority INT NOT NULL,
    Condition NVARCHAR(MAX) NULL,
    
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedBy] INT NOT NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedBy] INT NULL,
    [ModifiedDate] DATETIME NULL,
    [IsDeleted] BIT NULL DEFAULT 0,
    [DeletedBy] INT NULL,
    [DeletedDate] DATETIME NULL
);
```

## Table: InvoiceTaxBreakdown

```sql
CREATE TABLE InvoiceTaxBreakdown (
    InvoiceTaxBreakdownId INT PRIMARY KEY IDENTITY(1,1),
    InvoiceId UNIQUEIDENTIFIER NOT NULL,
    TaxTypeId INT NOT NULL,
    TaxName NVARCHAR(150) NOT NULL,
    Rate DECIMAL(5,2) NOT NULL,
    TaxAmount DECIMAL(18,2) NOT NULL,
    BaseAmount DECIMAL(18,2) NOT NULL,
    
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedBy] INT NOT NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedBy] INT NULL,
    [ModifiedDate] DATETIME NULL,
    [IsDeleted] BIT NULL DEFAULT 0,
    [DeletedBy] INT NULL,
    [DeletedDate] DATETIME NULL
);
```

After completion:
Ask:
"Proceed to PHASE 13 – Subscription & Tax Engine Integration?"

---
# 📝 Implementation Notes
- Developed TaxService executing boundary-isolated tax lookups mapping rules directly from DB.
