# PHASE 9 – Generic Email Gateway
## High-Performance Stateless Transport Engine

---

# 📌 Overview

The GenericEmailGateway is designed as a high-performance, stateless, protocol-agnostic Transport Engine.

It serves as the final bridge between the application layer and external mail servers.

This module:

- Uses MailKit (industry standard .NET mail library)
- Is fully stateless
- Is thread-safe
- Supports parallel execution
- Has zero dependency on database or logging frameworks
- Returns tuple-based results instead of throwing unhandled exceptions
- Is production-ready for enterprise SaaS workloads

This module integrates cleanly with the existing Clean Architecture project.

---

# 🏗 Clean Architecture Placement

| Layer | Responsibility |
|-------|---------------|
| API | Controller exposure |
| Application | DTOs + Interfaces |
| Domain | Enums |
| Infrastructure | EmailGateway implementation |
| Shared | DB Scripts |

Dependency flow remains intact.

Infrastructure depends only on Application abstractions.

---

# 📁 Folder Structure

```
src/
 ├── Application/
 │     └── Email/
 │            ├── DTOs/
 │            │      ├── EmailRequest.cs
 │            │      ├── MailServerConfig.cs
 │            │      └── EmailAttachment.cs
 │            └── Interfaces/
 │                   └── IGenericEmailGateway.cs
 │
 ├── Domain/
 │     └── Email/
 │            └── EmailStatus.cs
 │
 ├── Infrastructure/
 │     └── Email/
 │            └── GenericEmailGateway.cs
 │
 └── Shared/
       └── DBScript/
              └── Email/
                     ├── 001_EmailSettings.sql
                     ├── 002_EmailQueue.sql
                     ├── 003_EmailSignatures.sql
                     ├── 004_EmailIndexes.sql
                     └── 005_EmailViews.sql
```

---

# 🎯 Core Capabilities

## 1️⃣ Protocol Support

- SMTP (TLS 1.2 / 1.3)
- IMAP
- POP3
- Optional SSL Certificate Revocation bypass

---

## 2️⃣ Advanced Sending Features

- Multiple To / CC / BCC
- Dual MIME (HTML + Plain Text)
- Unlimited Attachments (byte[] support)
- Friendly Sender Name
- High-volume parallel safe

---

## 3️⃣ Smart Receiving

- Fetch Last N emails
- HTML body extraction
- Plain text fallback
- Self-contained connection lifecycle
- No persistent connection

---

## 4️⃣ Enterprise Engineering

- Stateless static utility
- Parallel safe
- Tuple-based error reporting:
  `(bool Success, string Error)`
- Zero dependency on DB or logger
- MailKit-based modern implementation

---

# 🔐 Security Features

- TLS support
- Optional SSL revocation bypass
- No credentials stored in memory long-term
- Password encryption recommended at DB level
- OAuth2-ready extension model

---

# 📦 EmailRequest DTO

```csharp
public class EmailRequest
{
    public List<string> To { get; set; }
    public List<string> Cc { get; set; }
    public List<string> Bcc { get; set; }
    public string Subject { get; set; }
    public string HtmlBody { get; set; }
    public string TextBody { get; set; }
    public List<EmailAttachment> Attachments { get; set; }
}
```

---

# 📡 MailServerConfig DTO

```csharp
public class MailServerConfig
{
    public string SmtpHost { get; set; }
    public int SmtpPort { get; set; }
    public string SmtpUser { get; set; }
    public string SmtpPass { get; set; }
    public bool EnableSSL { get; set; }
    public bool BypassCertificateValidation { get; set; }
    public string SenderDescription { get; set; }
}
```

---

# 🧠 EmailStatus Enum

```csharp
public enum EmailStatus : short
{
    Pending = 0,
    Sent = 1,
    Failed = 2
}
```

---

# 🔁 Email Queue Processing Flow

1. Insert into EmailQueue
2. Background Worker fetches:
   - Status = 0
   - Ordered by Priority DESC
   - Then CreateDate ASC
3. Send via GenericEmailGateway
4. Update:
   - Status
   - ErrorDescription
   - RetryCount
5. Log failures

---

# 🗄 Database Design

## EmailSettings

Purpose:
Stores SMTP configuration per Center.

Key Features:
- Active flag toggle
- Soft delete
- Audit tracking

---

## EmailSignatures

Purpose:
Stores reusable HTML templates.

Supports:
- Logo URL
- Dynamic placeholders
- Branding per center

---

## EmailQueue

Purpose:
High-performance mail dispatch queue.

Key Design Choices:
- SMALLINT for Status
- UNIQUEIDENTIFIER for QueueId
- Filtered index for Pending only
- RetryCount for resilience
- ErrorDescription for troubleshooting

---

# 📊 View_DailyMailHealthReport

Provides:

- Daily success rate
- Total processed
- Last error message
- Per-center statistics

Useful for:
- Monitoring dashboard
- SLA compliance
- Admin reporting

---

# 🏭 Enterprise Enhancements (Recommended)

- Add OAuth2 support for Office 365
- Add EmailAudit table
- Add RateLimiter control
- Add Redis-based throttle tracking
- Add Background Worker batching
- Add Circuit breaker

---

# 🧩 DI Registration

```csharp
builder.Services.AddScoped<IGenericEmailGateway, GenericEmailGateway>();
```

---

# 🏁 Completion Checklist

- [ ] DB scripts executed
- [ ] DTOs created
- [ ] Enum added
- [ ] Gateway implemented
- [ ] Background worker created
- [ ] Encryption applied to passwords
- [ ] Monitoring dashboard connected

---

# 🚀 Business Impact

After PHASE 8:

- Your system supports enterprise email infrastructure
- Parallel safe sending
- High-volume transactional mail
- Fully auditable mail system
- Ready for compliance environments
- Extendable to OAuth2 modern auth

---

# 🧠 Architectural Philosophy

- Stateless transport layer
- Clean separation of concerns
- Infrastructure isolation
- Failure-tolerant processing
- Database-driven configuration
- Vendor-neutral mail system

---

# ✅ Result

Your SaaS platform now includes:

- Enterprise-grade Email Gateway
- Full queue-based mail dispatch
- Health reporting
- Clean Architecture compliance
- Future-proof extensibility

---

# 🗄 Database Scripts (Email Module)

> The following scripts must be executed before enabling the Email Background Worker.
> Physical files are stored under: `/Shared/DBScript/Email/`

---

## 001_EmailSettings.sql

```sql
-- NOTE: SmtpPass should be encrypted using application-level encryption

CREATE TABLE EmailSettings (
    SettingId INT PRIMARY KEY IDENTITY(1,1),
    CenterId INT NOT NULL,
    SmtpHost NVARCHAR(255) NOT NULL,
    SmtpPort INT NOT NULL,
    SmtpUser NVARCHAR(255) NOT NULL,
    SmtpPass NVARCHAR(MAX) NOT NULL,
    SenderDescription NVARCHAR(255) NULL,
    EnableSSL BIT DEFAULT 1,
    BypassCertificateValidation BIT DEFAULT 0,
    Active BIT DEFAULT 0,

    CreatedBy INT NOT NULL,
    CreateDate DATETIME DEFAULT GETDATE(),
    ModifiedBy INT NOT NULL,
    ModifyDate DATETIME DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0,
    DeletedBy INT NULL,
    DeletedDate DATETIME NULL
);

CREATE INDEX IX_EmailSettings_Center_Active 
ON EmailSettings(CenterId, Active) 
WHERE IsDeleted = 0;
```

---

## 002_EmailQueue.sql

```sql
CREATE TABLE EmailQueue (
    QueueId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    CenterId INT NOT NULL,
    RecipientTo NVARCHAR(MAX) NOT NULL,
    RecipientCc NVARCHAR(MAX) NULL,
    RecipientBcc NVARCHAR(MAX) NULL,
    Subject NVARCHAR(500) NULL,
    Body NVARCHAR(MAX) NULL,
    IsHtml BIT DEFAULT 1,
    Status SMALLINT DEFAULT 0, -- 0:Pending, 1:Sent, 2:Failed
    ErrorDescription NVARCHAR(MAX) NULL,
    Priority INT DEFAULT 0,
    RetryCount INT DEFAULT 0,
    MaxRetryCount INT DEFAULT 3,

    CreatedBy INT NOT NULL,
    CreateDate DATETIME DEFAULT GETDATE(),
    ModifiedBy INT NOT NULL,
    ModifyDate DATETIME DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0,
    DeletedBy INT NULL,
    DeletedDate DATETIME NULL
);

CREATE INDEX IX_EmailQueue_Status_Priority 
ON EmailQueue(Status, Priority DESC, CreateDate ASC) 
WHERE IsDeleted = 0 AND Status = 0;
```

---

## 003_EmailSignatures.sql

```sql
CREATE TABLE EmailSignatures (
    SignatureId INT PRIMARY KEY IDENTITY(1,1),
    CenterId INT NOT NULL,
    LogoUrl NVARCHAR(MAX) NULL,
    LogoLink NVARCHAR(MAX) NULL,
    TemplateHtml NVARCHAR(MAX) NOT NULL,

    CreatedBy INT NOT NULL,
    CreateDate DATETIME DEFAULT GETDATE(),
    ModifiedBy INT NOT NULL,
    ModifyDate DATETIME DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0,
    DeletedBy INT NULL,
    DeletedDate DATETIME NULL
);
```

---

## 004_EmailViews.sql

```sql
CREATE VIEW View_DailyMailHealthReport AS
WITH MailStats AS (
    SELECT 
        CenterId,
        CAST(CreateDate AS DATE) AS ReportDate,
        COUNT(QueueId) AS TotalProcessed,
        SUM(CASE WHEN Status = 1 THEN 1 ELSE 0 END) AS TotalSuccess,
        SUM(CASE WHEN Status = 2 THEN 1 ELSE 0 END) AS TotalFailed,
        SUM(CASE WHEN Status = 0 THEN 1 ELSE 0 END) AS TotalPending
    FROM EmailQueue
    WHERE IsDeleted = 0
    GROUP BY CenterId, CAST(CreateDate AS DATE)
)
SELECT 
    s.*,
    CASE 
        WHEN s.TotalProcessed > 0 
        THEN CAST((CAST(s.TotalSuccess AS FLOAT) / s.TotalProcessed) * 100 AS DECIMAL(5,2)) 
        ELSE 0 
    END AS SuccessRatePercentage,
    (SELECT TOP 1 ErrorDescription FROM EmailQueue 
     WHERE CenterId = s.CenterId 
       AND Status = 2 
       AND CAST(CreateDate AS DATE) = s.ReportDate
     ORDER BY CreateDate DESC) AS LastErrorMessage
FROM MailStats s;
```

---

# 📊 Column Logic Summary

| Column | Purpose |
|--------|----------|
| Active | Toggle mail config without deletion |
| Status | SMALLINT for performance |
| ErrorDescription | Stores tuple error message |
| RetryCount | Background worker retry logic |
| Priority | High-priority emails processed first |

---

# 🏁 Deployment Order

1. Run EmailSettings script
2. Run EmailQueue script
3. Run EmailSignatures script
4. Run View script
5. Deploy API
6. Enable Background Worker
7. Activate EmailSettings per center

---

# ✅ Post Deployment Checklist

- [ ] Encrypt SmtpPass before production
- [ ] Add background worker
- [ ] Configure retry policy
- [ ] Configure health dashboard
- [ ] Test with SMTP sandbox

After completion display:

"Enterprise Multi-Tenant SaaS Platform Generated Successfully."