-- =============================================
-- DUMMY DATA SEEDING FOR PAYMENT FRAMEWORK (MSSQL)
-- =============================================

-- Ensure we are using the right DB context (Change this if needed)
-- USE [YourDatabaseName];
-- GO

-- 1. Ensure basic providers exist
IF NOT EXISTS (SELECT 1 FROM [dbo].[PaymentProviders] WHERE Code = 'RAZORPAY')
    INSERT INTO [dbo].[PaymentProviders] (Name, Code, CreatedBy) VALUES ('Razorpay', 'RAZORPAY', 'System');
IF NOT EXISTS (SELECT 1 FROM [dbo].[PaymentProviders] WHERE Code = 'STRIPE')
    INSERT INTO [dbo].[PaymentProviders] (Name, Code, CreatedBy) VALUES ('Stripe', 'STRIPE', 'System');

-- 2. Link Providers to Organization (Assuming OrganizationId = 1)
DECLARE @OrgId INT = 1;
DECLARE @RazorpayId INT = (SELECT Id FROM [dbo].[PaymentProviders] WHERE Code = 'RAZORPAY');
DECLARE @StripeId INT = (SELECT Id FROM [dbo].[PaymentProviders] WHERE Code = 'STRIPE');

IF NOT EXISTS (SELECT 1 FROM [dbo].[OrganizationPaymentProviders] WHERE OrganizationId = @OrgId AND PaymentProviderId = @RazorpayId)
BEGIN
    INSERT INTO [dbo].[OrganizationPaymentProviders] (OrganizationId, PaymentProviderId, Priority, CreatedBy)
    VALUES (@OrgId, @RazorpayId, 1, 'System');
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[OrganizationPaymentProviders] WHERE OrganizationId = @OrgId AND PaymentProviderId = @StripeId)
BEGIN
    INSERT INTO [dbo].[OrganizationPaymentProviders] (OrganizationId, PaymentProviderId, Priority, CreatedBy)
    VALUES (@OrgId, @StripeId, 2, 'System');
END

-- 3. Link Organization Providers to a Branch (Assuming BranchId = 1)
DECLARE @BranchId INT = 1;
DECLARE @OrgRazorpayId INT = (SELECT Id FROM [dbo].[OrganizationPaymentProviders] WHERE OrganizationId = @OrgId AND PaymentProviderId = @RazorpayId);
DECLARE @OrgStripeId INT = (SELECT Id FROM [dbo].[OrganizationPaymentProviders] WHERE OrganizationId = @OrgId AND PaymentProviderId = @StripeId);

IF NOT EXISTS (SELECT 1 FROM [dbo].[BranchPaymentProviders] WHERE BranchId = @BranchId AND OrganizationPaymentProviderId = @OrgRazorpayId)
BEGIN
    INSERT INTO [dbo].[BranchPaymentProviders] (BranchId, OrganizationPaymentProviderId, CreatedBy)
    VALUES (@BranchId, @OrgRazorpayId, 'System');
END

IF NOT EXISTS (SELECT 1 FROM [dbo].[BranchPaymentProviders] WHERE BranchId = @BranchId AND OrganizationPaymentProviderId = @OrgStripeId)
BEGIN
    INSERT INTO [dbo].[BranchPaymentProviders] (BranchId, OrganizationPaymentProviderId, CreatedBy)
    VALUES (@BranchId, @OrgStripeId, 'System');
END

-- 4. Seed Dummy Transactions
DECLARE @UsdId INT = (SELECT Id FROM [dbo].[CurrencyMaster] WHERE Code = 'USD');
DECLARE @InrId INT = (SELECT Id FROM [dbo].[CurrencyMaster] WHERE Code = 'INR');

-- Transaction 1: Successful Razorpay UPI Payment
INSERT INTO [dbo].[PaymentTransactions] (
    OrganizationId, BranchId, PaymentProviderId, ExternalTransactionId, Amount, CurrencyId, 
    Status, PaymentMethod, CustomerId, Description, IdempotencyKey, CreatedBy, UpiIntentUri
) VALUES (
    1, 1, @RazorpayId, 'pay_mock_success_001', 500.00, @InrId, 
    'Completed', 'UPI', 'cust_101', 'Monthly Subscription', NEWID(), 'System', 'upi://pay?pa=mock@rzp&pn=Test&am=500'
);

-- Transaction 2: Pending Stripe Card Payment
INSERT INTO [dbo].[PaymentTransactions] (
    OrganizationId, BranchId, PaymentProviderId, ExternalTransactionId, Amount, CurrencyId, 
    Status, PaymentMethod, CustomerId, Description, IdempotencyKey, CreatedBy
) VALUES (
    1, 1, @StripeId, 'pi_mock_pending_002', 150.00, @UsdId, 
    'Pending', 'CreditCard', 'cust_102', 'Product Purchase', NEWID(), 'System'
);

-- Transaction 3: Failed Razorpay QR Code Payment
INSERT INTO [dbo].[PaymentTransactions] (
    OrganizationId, BranchId, PaymentProviderId, ExternalTransactionId, Amount, CurrencyId, 
    Status, PaymentMethod, CustomerId, Description, IdempotencyKey, CreatedBy, QrContent
) VALUES (
    1, 1, @RazorpayId, 'pay_mock_failed_003', 1200.00, @InrId, 
    'Failed', 'QRCode', 'cust_103', 'Annual License Fee', NEWID(), 'System', 'upi://pay?pa=mock@rzp&pn=Test&am=1200'
);
GO
