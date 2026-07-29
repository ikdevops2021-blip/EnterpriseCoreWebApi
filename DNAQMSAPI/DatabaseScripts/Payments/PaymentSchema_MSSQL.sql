-- MS SQL Server Database Script for Payment Framework
-- Tables, Views, Stored Procedures

-- =============================================
-- TABLES
-- =============================================

-- 1. CurrencyMaster
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CurrencyMaster]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[CurrencyMaster](
    [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Guid] [uniqueidentifier] NOT NULL DEFAULT NEWID() UNIQUE,
    [Code] [nvarchar](3) NOT NULL UNIQUE,
    [Name] [nvarchar](100) NOT NULL,
    [Symbol] [nvarchar](10) NOT NULL,
    [CreatedOn] [datetime2](7) NOT NULL DEFAULT GETUTCDATE(),
    [CreatedBy] [nvarchar](100) NOT NULL,
    [ModifiedOn] [datetime2](7) NULL,
    [ModifiedBy] [nvarchar](100) NULL,
    [IsDeleted] [bit] NOT NULL DEFAULT 0,
    [RowVersion] [rowversion] NOT NULL
)
END
GO

-- 2. PaymentProviders
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PaymentProviders]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PaymentProviders](
    [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Guid] [uniqueidentifier] NOT NULL DEFAULT NEWID() UNIQUE,
    [Name] [nvarchar](100) NOT NULL,
    [Code] [nvarchar](50) NOT NULL UNIQUE,
    [IsActive] [bit] NOT NULL DEFAULT 1,
    [CreatedOn] [datetime2](7) NOT NULL DEFAULT GETUTCDATE(),
    [CreatedBy] [nvarchar](100) NOT NULL,
    [ModifiedOn] [datetime2](7) NULL,
    [ModifiedBy] [nvarchar](100) NULL,
    [IsDeleted] [bit] NOT NULL DEFAULT 0,
    [RowVersion] [rowversion] NOT NULL
)
END
GO

-- 3. PaymentTransactions
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PaymentTransactions]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PaymentTransactions](
    [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Guid] [uniqueidentifier] NOT NULL DEFAULT NEWID() UNIQUE,
    [OrganizationId] [int] NOT NULL,
    [BranchId] [int] NOT NULL,
    [PaymentProviderId] [int] NOT NULL,
    [ExternalTransactionId] [nvarchar](255) NULL,
    [Amount] [decimal](18, 4) NOT NULL,
    [CurrencyId] [int] NOT NULL,
    [Status] [nvarchar](50) NOT NULL,
    [PaymentMethod] [nvarchar](50) NOT NULL,
    [CustomerId] [nvarchar](255) NULL,
    [Description] [nvarchar](max) NULL,
    [IdempotencyKey] [nvarchar](255) NULL,
    [CreatedOn] [datetime2](7) NOT NULL DEFAULT GETUTCDATE(),
    [CreatedBy] [nvarchar](100) NOT NULL,
    [ModifiedOn] [datetime2](7) NULL,
    [ModifiedBy] [nvarchar](100) NULL,
    [IsDeleted] [bit] NOT NULL DEFAULT 0,
    [RowVersion] [rowversion] NOT NULL,
    CONSTRAINT [FK_PaymentTransactions_PaymentProviders] FOREIGN KEY([PaymentProviderId]) REFERENCES [dbo].[PaymentProviders] ([Id]),
    CONSTRAINT [FK_PaymentTransactions_CurrencyMaster] FOREIGN KEY([CurrencyId]) REFERENCES [dbo].[CurrencyMaster] ([Id])
)
END
GO

-- 4. PaymentStatusHistory
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PaymentStatusHistory]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[PaymentStatusHistory](
    [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Guid] [uniqueidentifier] NOT NULL DEFAULT NEWID() UNIQUE,
    [PaymentTransactionId] [int] NOT NULL,
    [OldStatus] [nvarchar](50) NULL,
    [NewStatus] [nvarchar](50) NOT NULL,
    [Reason] [nvarchar](255) NULL,
    [CreatedOn] [datetime2](7) NOT NULL DEFAULT GETUTCDATE(),
    [CreatedBy] [nvarchar](100) NOT NULL,
    CONSTRAINT [FK_PaymentStatusHistory_PaymentTransactions] FOREIGN KEY([PaymentTransactionId]) REFERENCES [dbo].[PaymentTransactions] ([Id])
)
END
GO

-- 5. WebhookLogs
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WebhookLogs]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[WebhookLogs](
    [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [Guid] [uniqueidentifier] NOT NULL DEFAULT NEWID() UNIQUE,
    [PaymentProviderId] [int] NOT NULL,
    [EventId] [nvarchar](255) NULL,
    [EventType] [nvarchar](100) NOT NULL,
    [Payload] [nvarchar](max) NOT NULL,
    [IsProcessed] [bit] NOT NULL DEFAULT 0,
    [CreatedOn] [datetime2](7) NOT NULL DEFAULT GETUTCDATE(),
    [CreatedBy] [nvarchar](100) NOT NULL
)
END
GO

-- =============================================
-- DUMMY DATA SEEDING
-- =============================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[CurrencyMaster] WHERE Code = 'USD')
BEGIN
    INSERT INTO [dbo].[CurrencyMaster] (Code, Name, Symbol, CreatedBy) VALUES ('USD', 'US Dollar', '$', 'System')
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[CurrencyMaster] WHERE Code = 'INR')
BEGIN
    INSERT INTO [dbo].[CurrencyMaster] (Code, Name, Symbol, CreatedBy) VALUES ('INR', 'Indian Rupee', '₹', 'System')
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[PaymentProviders] WHERE Code = 'RAZORPAY')
BEGIN
    INSERT INTO [dbo].[PaymentProviders] (Name, Code, CreatedBy) VALUES ('Razorpay', 'RAZORPAY', 'System')
END
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[PaymentProviders] WHERE Code = 'STRIPE')
BEGIN
    INSERT INTO [dbo].[PaymentProviders] (Name, Code, CreatedBy) VALUES ('Stripe', 'STRIPE', 'System')
END
GO

-- =============================================
-- VIEWS
-- =============================================

CREATE OR ALTER VIEW [dbo].[vw_PaymentDashboardStats] AS
SELECT 
    OrganizationId,
    BranchId,
    Status,
    COUNT(Id) AS TotalCount,
    SUM(Amount) AS TotalAmount
FROM [dbo].[PaymentTransactions]
WHERE IsDeleted = 0
GROUP BY OrganizationId, BranchId, Status;
GO

-- =============================================
-- STORED PROCEDURES
-- =============================================

CREATE OR ALTER PROCEDURE [dbo].[pr_CreatePaymentTransaction]
    @Guid UNIQUEIDENTIFIER,
    @OrganizationId INT,
    @BranchId INT,
    @PaymentProviderId INT,
    @ExternalTransactionId NVARCHAR(255),
    @Amount DECIMAL(18, 4),
    @CurrencyId INT,
    @Status NVARCHAR(50),
    @PaymentMethod NVARCHAR(50),
    @CustomerId NVARCHAR(255),
    @Description NVARCHAR(MAX),
    @IdempotencyKey NVARCHAR(255),
    @CreatedBy NVARCHAR(100),
    @NewId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check Idempotency
        IF @IdempotencyKey IS NOT NULL AND EXISTS (SELECT 1 FROM [dbo].[PaymentTransactions] WHERE IdempotencyKey = @IdempotencyKey)
        BEGIN
            SELECT @NewId = Id FROM [dbo].[PaymentTransactions] WHERE IdempotencyKey = @IdempotencyKey;
            COMMIT TRANSACTION;
            RETURN 0;
        END

        INSERT INTO [dbo].[PaymentTransactions] (
            Guid, OrganizationId, BranchId, PaymentProviderId, ExternalTransactionId, 
            Amount, CurrencyId, Status, PaymentMethod, CustomerId, Description, 
            IdempotencyKey, CreatedBy
        ) VALUES (
            @Guid, @OrganizationId, @BranchId, @PaymentProviderId, @ExternalTransactionId, 
            @Amount, @CurrencyId, @Status, @PaymentMethod, @CustomerId, @Description, 
            @IdempotencyKey, @CreatedBy
        );
        
        SET @NewId = SCOPE_IDENTITY();
        
        INSERT INTO [dbo].[PaymentStatusHistory] (PaymentTransactionId, OldStatus, NewStatus, CreatedBy)
        VALUES (@NewId, NULL, @Status, @CreatedBy);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE [dbo].[pr_UpdatePaymentStatus]
    @TransactionId INT,
    @NewStatus NVARCHAR(50),
    @Reason NVARCHAR(255),
    @ModifiedBy NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @OldStatus NVARCHAR(50);
        SELECT @OldStatus = Status FROM [dbo].[PaymentTransactions] WHERE Id = @TransactionId AND IsDeleted = 0;
        
        IF @OldStatus IS NULL
        BEGIN
            RAISERROR ('Transaction not found.', 16, 1);
            RETURN;
        END

        IF @OldStatus <> @NewStatus
        BEGIN
            UPDATE [dbo].[PaymentTransactions]
            SET Status = @NewStatus, ModifiedOn = GETUTCDATE(), ModifiedBy = @ModifiedBy
            WHERE Id = @TransactionId;
            
            INSERT INTO [dbo].[PaymentStatusHistory] (PaymentTransactionId, OldStatus, NewStatus, Reason, CreatedBy)
            VALUES (@TransactionId, @OldStatus, @NewStatus, @Reason, @ModifiedBy);
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE [dbo].[pr_LogWebhookEvent]
    @PaymentProviderId INT,
    @EventId NVARCHAR(255),
    @EventType NVARCHAR(100),
    @Payload NVARCHAR(MAX),
    @CreatedBy NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Avoid logging duplicate events from providers
    IF @EventId IS NOT NULL AND EXISTS (SELECT 1 FROM [dbo].[WebhookLogs] WHERE EventId = @EventId AND PaymentProviderId = @PaymentProviderId)
    BEGIN
        RETURN 0;
    END

    INSERT INTO [dbo].[WebhookLogs] (PaymentProviderId, EventId, EventType, Payload, CreatedBy)
    VALUES (@PaymentProviderId, @EventId, @EventType, @Payload, @CreatedBy);
END
GO

-- =============================================
-- FUNCTIONS
-- =============================================

-- Scalar Function Example
CREATE OR ALTER FUNCTION [dbo].[fn_GetPaymentStatusName]
(
    @Status NVARCHAR(50)
)
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @Result NVARCHAR(100);
    SET @Result = UPPER(@Status);
    RETURN @Result;
END
GO

-- Table-Valued Function Example
CREATE OR ALTER FUNCTION [dbo].[fn_GetRecentTransactions]
(
    @OrganizationId INT,
    @Days INT
)
RETURNS TABLE
AS
RETURN 
(
    SELECT Id, Guid, Amount, Status, CreatedOn
    FROM [dbo].[PaymentTransactions]
    WHERE OrganizationId = @OrganizationId 
      AND CreatedOn >= DATEADD(day, -@Days, GETUTCDATE())
      AND IsDeleted = 0
);
GO
