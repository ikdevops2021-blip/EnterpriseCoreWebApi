-- =============================================
-- Phase 5: UPI & QR Code Extension
-- =============================================

-- 1. Extend PaymentTransactions Table
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[PaymentTransactions]') AND name = 'UpiIntentUri')
BEGIN
    ALTER TABLE [dbo].[PaymentTransactions] ADD 
        UpiIntentUri NVARCHAR(1000) NULL,
        QrContent NVARCHAR(MAX) NULL,
        QrImage NVARCHAR(MAX) NULL,
        ExpiryTime DATETIME NULL;
END
GO

-- 2. Create ProviderPaymentMethods capabilities mapping table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProviderPaymentMethods]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[ProviderPaymentMethods](
        [Id] [int] IDENTITY(1,1) NOT NULL,
        [PaymentProviderId] [int] NOT NULL,
        [PaymentMethod] [nvarchar](50) NOT NULL,
        [IsActive] [bit] NOT NULL DEFAULT(1),
        CONSTRAINT [PK_ProviderPaymentMethods] PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [FK_ProviderPaymentMethods_Providers] FOREIGN KEY([PaymentProviderId]) REFERENCES [dbo].[OrganizationPaymentProvider] ([Id])
    )
END
GO

-- 3. Seed capabilities (Assumes Razorpay=1, Stripe=2 from earlier)
-- Razorpay (1)
IF NOT EXISTS(SELECT 1 FROM [dbo].[ProviderPaymentMethods] WHERE PaymentProviderId = 1 AND PaymentMethod = 'UPI')
BEGIN
    INSERT INTO [dbo].[ProviderPaymentMethods] (PaymentProviderId, PaymentMethod, IsActive) VALUES 
    (1, 'UPI', 1),
    (1, 'QRCode', 1),
    (1, 'CreditCard', 1),
    (1, 'DebitCard', 1),
    (1, 'NetBanking', 1),
    (1, 'Wallet', 1)
END

-- Stripe (2)
IF NOT EXISTS(SELECT 1 FROM [dbo].[ProviderPaymentMethods] WHERE PaymentProviderId = 2 AND PaymentMethod = 'CreditCard')
BEGIN
    INSERT INTO [dbo].[ProviderPaymentMethods] (PaymentProviderId, PaymentMethod, IsActive) VALUES 
    (2, 'CreditCard', 1),
    (2, 'Wallet', 1)
END
GO

-- 4. Update Stored Procedure for CreatePaymentTransaction
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
    @UpiIntentUri NVARCHAR(1000) = NULL,
    @QrContent NVARCHAR(MAX) = NULL,
    @QrImage NVARCHAR(MAX) = NULL,
    @ExpiryTime DATETIME = NULL,
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
            IdempotencyKey, CreatedBy, UpiIntentUri, QrContent, QrImage, ExpiryTime
        ) VALUES (
            @Guid, @OrganizationId, @BranchId, @PaymentProviderId, @ExternalTransactionId, 
            @Amount, @CurrencyId, @Status, @PaymentMethod, @CustomerId, @Description, 
            @IdempotencyKey, @CreatedBy, @UpiIntentUri, @QrContent, @QrImage, @ExpiryTime
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
