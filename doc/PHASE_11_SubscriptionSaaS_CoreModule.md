# PHASE 11 – Subscription SaaS Core Module

> ✅ **STATUS: COMPLETED**

## Reusable Multi-Tenant Subscription & Billing Engine

---

# 📌 Overview

The Subscription SaaS Core Module is designed as a **standalone, reusable business engine**.

It can be plugged into:

- Existing SaaS applications
- New startup products
- Enterprise platforms
- Government service systems
- API-based products
- Microservice ecosystems

This module is:

- Multi-tenant ready
- Plan-based
- Usage metered
- Payment-ready
- Feature-toggle controlled
- Clean Architecture compliant
- Vendor-neutral

It has ZERO dependency on your Email or Integration modules.

---

# 🎯 Core Objectives

- Separate revenue logic from product logic
- Enable subscription lifecycle management
- Support recurring billing
- Provide usage metering
- Enforce feature access by plan
- Allow easy integration into any project

---

# 🏗 Recommended Project Structure (Separate Solution)

```
SubscriptionSaaS.Core/
 ├── API/
 ├── Application/
 │     ├── Interfaces/
 │     ├── DTOs/
 │     ├── Services/
 │
 ├── Domain/
 │     ├── Entities/
 │     ├── Enums/
 │
 ├── Infrastructure/
 │     ├── Payment/
 │     ├── Persistence/
 │
 └── Shared/
       └── DBScript/
```

This project should be deployed independently and consumed via:

- REST API
- NuGet package
- Internal service reference
- gRPC
- Microservice

---

# 🧠 Core Concepts

## 1️⃣ Subscription Plans

Defines pricing tiers.

Examples:
- Free
- Starter
- Pro
- Enterprise

Each plan controls:
- Feature access
- Usage limits
- Billing frequency

---

## 2️⃣ Tenant Subscription

Represents which tenant (Center) is subscribed to which plan.

Tracks:
- StartDate
- ExpiryDate
- Status
- Trial info
- Auto renewal

---

## 3️⃣ Feature Control

Feature-based gating:

Example:
- CanSendEmail
- CanUseAPIIntegration
- MaxUsers
- MaxApiCalls
- MaxStorageMB

---

## 4️⃣ Usage Metering

Tracks:

- API Calls
- Email sent
- SMS sent
- Storage used
- Active users

---

## 5️⃣ Billing Lifecycle

Handles:

- Subscription activation
- Payment success
- Payment failure
- Grace period
- Suspension
- Cancellation
- Upgrade/Downgrade

---

# 🔐 Subscription Status Enum

```csharp
public enum SubscriptionStatus : short
{
    Trial = 0,
    Active = 1,
    GracePeriod = 2,
    Suspended = 3,
    Cancelled = 4,
    Expired = 5
}
```

---

# 🧩 Feature Enforcement Strategy

Middleware approach:

1. Identify tenant
2. Fetch active subscription
3. Validate:
   - Status
   - Expiry
   - Usage limit
   - Feature enabled
4. Allow or reject request

---

# 🗄 DATABASE DESIGN

All scripts below can be executed directly.

---

## 001_SubscriptionPlans.sql

```sql
CREATE TABLE SubscriptionPlans (
    PlanId INT PRIMARY KEY IDENTITY(1,1),
    PlanName NVARCHAR(150) NOT NULL,
    Price DECIMAL(18,2) NOT NULL,
    BillingCycleMonths INT NOT NULL, -- 1 = Monthly, 12 = Yearly
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);
```

---

## 002_PlanFeatures.sql

```sql
CREATE TABLE PlanFeatures (
    FeatureId INT PRIMARY KEY IDENTITY(1,1),
    PlanId INT NOT NULL,
    FeatureKey NVARCHAR(150) NOT NULL,
    FeatureValue NVARCHAR(150) NOT NULL, 
    -- Example:
    -- FeatureKey = 'MaxEmailPerMonth'
    -- FeatureValue = '5000'

    FOREIGN KEY (PlanId) REFERENCES SubscriptionPlans(PlanId)
);
```

---

## 003_TenantSubscriptions.sql

```sql
CREATE TABLE TenantSubscriptions (
    SubscriptionId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    PlanId INT NOT NULL,
    Status SMALLINT NOT NULL,
    StartDate DATETIME NOT NULL,
    ExpiryDate DATETIME NOT NULL,
    TrialEndDate DATETIME NULL,
    AutoRenew BIT DEFAULT 1,
    GracePeriodEnd DATETIME NULL,

    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE(),

    FOREIGN KEY (PlanId) REFERENCES SubscriptionPlans(PlanId)
);

CREATE INDEX IX_TenantSubscriptions_Tenant 
ON TenantSubscriptions(TenantId);
```

---

## 004_UsageTracking.sql

```sql
CREATE TABLE UsageTracking (
    UsageId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    TenantId UNIQUEIDENTIFIER NOT NULL,
    FeatureKey NVARCHAR(150) NOT NULL,
    UsageCount BIGINT DEFAULT 0,
    PeriodStart DATETIME NOT NULL,
    PeriodEnd DATETIME NOT NULL
);

CREATE INDEX IX_UsageTracking_Tenant_Feature
ON UsageTracking(TenantId, FeatureKey);
```

---

## 005_PaymentTransactions.sql

```sql
CREATE TABLE PaymentTransactions (
    TransactionId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    SubscriptionId UNIQUEIDENTIFIER NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    Currency NVARCHAR(10) DEFAULT 'USD',
    PaymentProvider NVARCHAR(100) NOT NULL,
    ProviderTransactionId NVARCHAR(200),
    Status NVARCHAR(50) NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);
```

---

## 006_BillingHistory.sql

```sql
CREATE TABLE BillingHistory (
    BillingId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    SubscriptionId UNIQUEIDENTIFIER NOT NULL,
    BillingStart DATETIME NOT NULL,
    BillingEnd DATETIME NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    InvoiceNumber NVARCHAR(100),
    Paid BIT DEFAULT 0,
    CreatedDate DATETIME DEFAULT GETDATE()
);
```

---

# 📊 Usage Example

Example Feature Values:

| FeatureKey | FeatureValue |
|------------|-------------|
| MaxEmailPerMonth | 10000 |
| MaxApiCallsPerMonth | 50000 |
| MaxUsers | 50 |
| StorageMB | 10240 |

---

# 🔄 Subscription Lifecycle Flow

1. User selects plan
2. Payment successful
3. Subscription created
4. Status = Active
5. Usage tracked
6. Renewal triggered before expiry
7. On payment failure → GracePeriod
8. If not resolved → Suspended

---

# 🚀 Deployment Strategy

1. Deploy DB
2. Seed plans
3. Integrate into main project
4. Add middleware enforcement
5. Integrate payment provider
6. Enable usage metering

---

# 🏁 Completion Checklist

- [ ] DB deployed
- [ ] Plans seeded
- [ ] Middleware added
- [ ] Usage tracker integrated
- [ ] Payment gateway connected
- [ ] Renewal worker implemented
- [ ] Grace period logic tested

---

# 🔥 Business Impact

This transforms your ecosystem into:

- Revenue-driven SaaS
- Multi-product compatible platform
- Feature-controlled architecture
- Scalable subscription engine
- Enterprise-ready billing system

---

# 🧠 Design Philosophy

- Separation of concerns
- Reusable business module
- Plan-driven access control
- Vendor-neutral payment design
- Scalable usage metering

---

# ✅ Final Result

You now have a fully reusable:

Subscription SaaS Core Module

That can power:

- Current project
- Future products
- External client systems
- Government SaaS deployments
- API monetization models

---
# 📝 Implementation Notes
- Implemented UsageMeteringService leveraging feature gates ([FeatureGate]) and direct native usage counting via Dapper.
