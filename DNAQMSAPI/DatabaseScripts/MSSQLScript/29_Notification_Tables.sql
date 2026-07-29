-- ===================================================================================
-- DNAQMS API - NOTIFICATION & MESSAGING TABLES (MS SQL Server)
-- File Path: DNAQMSAPI/DatabaseScripts/MSSQLScript/29_Notification_Tables.sql
-- ===================================================================================

USE [dnaqms];
GO

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. NotificationTemplate: Center/Organization-specific or Global templates
-- ─────────────────────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[NotificationTemplate]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[NotificationTemplate] (
        [Id]                INT IDENTITY(1,1) PRIMARY KEY,
        [OrganizationId]    INT NULL,                           -- NULL = Global System Default Template, else Center/Organization Specific
        [EventId]           INT NOT NULL,                       -- Foreign Key to ConfigParameters Category 17 (C_NOTIFICATION_EVENT)
        [EventCode]         NVARCHAR(100) NOT NULL,             -- e.g. PAYMENT_RECEIVED, INTERNAL_ANNOUNCEMENT, SYSTEM_ALERT
        [CategoryId]        INT NOT NULL,                       -- Category ID
        [SubjectTemplate]   NVARCHAR(255) NOT NULL,
        [BodyTemplate]      NVARCHAR(MAX) NOT NULL,
        [SendInApp]         BIT NOT NULL DEFAULT 1,
        [SendEmail]         BIT NOT NULL DEFAULT 1,
        [SendSMS]           BIT NOT NULL DEFAULT 0,
        [IsActive]          BIT NOT NULL DEFAULT 1,
        [CreatedBy]         INT NOT NULL,
        [CreatedDate]       DATETIME NOT NULL DEFAULT GETDATE(),
        [ModifiedBy]        INT NOT NULL DEFAULT 0,
        [ModifiedDate]      DATETIME NOT NULL DEFAULT GETDATE(),
        [IsDeleted]         BIT NULL DEFAULT 0,
        [DeletedBy]         INT NULL,
        [DeletedDate]       DATETIME NULL,

        CONSTRAINT [FK_NotificationTemplate_Organization]
            FOREIGN KEY ([OrganizationId]) REFERENCES [dbo].[Organization]([Id]),

        CONSTRAINT [FK_NotificationTemplate_Event]
            FOREIGN KEY ([EventId]) REFERENCES [dbo].[ConfigParameters]([ParameterID])
    );

    CREATE NONCLUSTERED INDEX [IX_NotificationTemplate_Lookup]
        ON [dbo].[NotificationTemplate] ([OrganizationId], [EventId], [EventCode], [IsDeleted]);
END
GO

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. UserNotification: In-App Notification Bell Feed
-- ─────────────────────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserNotification]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[UserNotification] (
        [Id]                BIGINT IDENTITY(1,1) PRIMARY KEY,
        [OrganizationId]    INT NOT NULL,
        [UserId]            INT NOT NULL,
        [EventId]           INT NULL,                           -- Foreign Key to ConfigParameters Category 17 (C_NOTIFICATION_EVENT)
        [EventCode]         NVARCHAR(100) NOT NULL,
        [CategoryId]        INT NOT NULL,
        [Title]             NVARCHAR(255) NOT NULL,
        [Message]           NVARCHAR(MAX) NOT NULL,
        [ActionUrl]         NVARCHAR(500) NULL,                 -- e.g., /payments/invoices/1002
        [IsRead]            BIT NOT NULL DEFAULT 0,
        [ReadDate]          DATETIME NULL,
        [CreatedBy]         INT NOT NULL,
        [CreatedDate]       DATETIME NOT NULL DEFAULT GETDATE(),
        [ModifiedBy]        INT NOT NULL DEFAULT 0,
        [ModifiedDate]      DATETIME NOT NULL DEFAULT GETDATE(),
        [IsDeleted]         BIT NULL DEFAULT 0,
        [DeletedBy]         INT NULL,
        [DeletedDate]       DATETIME NULL,

        CONSTRAINT [FK_UserNotification_Organization]
            FOREIGN KEY ([OrganizationId]) REFERENCES [dbo].[Organization]([Id]),

        CONSTRAINT [FK_UserNotification_User]
            FOREIGN KEY ([UserId]) REFERENCES [dbo].[User]([Id]),

        CONSTRAINT [FK_UserNotification_Event]
            FOREIGN KEY ([EventId]) REFERENCES [dbo].[ConfigParameters]([ParameterID])
    );

    CREATE NONCLUSTERED INDEX [IX_UserNotification_UserFeed]
        ON [dbo].[UserNotification] ([UserId], [IsRead], [IsDeleted], [CreatedDate]);
END
GO

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. SmsQueue: Outgoing SMS Dispatch Queue
-- ─────────────────────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SmsQueue]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[SmsQueue] (
        [QueueId]               NVARCHAR(36) PRIMARY KEY,
        [OrganizationId]        INT NOT NULL,
        [RecipientPhoneNumber] NVARCHAR(30) NOT NULL,
        [Message]               NVARCHAR(1000) NOT NULL,
        [Status]                INT NOT NULL DEFAULT 0,          -- 0: Pending, 1: Sent, 2: Failed
        [RetryCount]            INT NOT NULL DEFAULT 0,
        [MaxRetryCount]         INT NOT NULL DEFAULT 3,
        [ErrorMessage]          NVARCHAR(500) NULL,
        [CreatedBy]             INT NOT NULL,
        [CreatedDate]           DATETIME NOT NULL DEFAULT GETDATE(),
        [ModifiedBy]            INT NOT NULL DEFAULT 0,
        [ModifiedDate]          DATETIME NOT NULL DEFAULT GETDATE(),
        [IsDeleted]             BIT NULL DEFAULT 0,
        [DeletedBy]             INT NULL,
        [DeletedDate]           DATETIME NULL,

        CONSTRAINT [FK_SmsQueue_Organization]
            FOREIGN KEY ([OrganizationId]) REFERENCES [dbo].[Organization]([Id])
    );
END
GO

-- Starter Seed Data
IF NOT EXISTS (SELECT 1 FROM [dbo].[NotificationTemplate] WHERE [EventCode] = N'PAYMENT_RECEIVED' AND [OrganizationId] IS NULL)
BEGIN
    INSERT INTO [dbo].[NotificationTemplate] 
    (OrganizationId, EventId, EventCode, CategoryId, SubjectTemplate, BodyTemplate, SendInApp, SendEmail, SendSMS, IsActive, CreatedBy, CreatedDate)
    VALUES
    (NULL, 17001, N'PAYMENT_RECEIVED', 2001, N'Payment Received: {InvoiceNo}', N'Hello {UserName}, your payment of {Currency} {Amount} for {CenterName} has been received successfully.', 1, 1, 0, 1, 0, GETDATE()),
    (NULL, 17002, N'INTERNAL_ANNOUNCEMENT', 2001, N'Important Intimation: {Title}', N'Dear {UserName}, {Message}. Intimation from {CenterName}.', 1, 1, 0, 1, 0, GETDATE()),
    (NULL, 17003, N'SYSTEM_ALERT', 2001, N'Security Intimation', N'Hello {UserName}, a security event occurred on your account at {CenterName}.', 1, 1, 1, 1, 0, GETDATE());
END
GO
