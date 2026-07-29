-- =============================================
-- DUMMY DATA SEEDING FOR PAYMENT FRAMEWORK (MySQL)
-- =============================================

-- 1. Ensure basic providers exist
INSERT IGNORE INTO PaymentProviders (Guid, Name, Code, CreatedBy) VALUES 
(UUID(), 'Razorpay', 'RAZORPAY', 'System'),
(UUID(), 'Stripe', 'STRIPE', 'System');

-- We use variables to avoid hardcoded IDs
SET @RazorpayId = (SELECT Id FROM PaymentProviders WHERE Code = 'RAZORPAY' LIMIT 1);
SET @StripeId = (SELECT Id FROM PaymentProviders WHERE Code = 'STRIPE' LIMIT 1);
SET @OrgId = 1;
SET @BranchId = 1;

-- 2. Link Providers to Organization (Assuming OrganizationId = 1)
INSERT INTO OrganizationPaymentProviders (Guid, OrganizationId, PaymentProviderId, Priority, CreatedBy)
SELECT UUID(), @OrgId, @RazorpayId, 1, 'System'
WHERE NOT EXISTS (SELECT 1 FROM OrganizationPaymentProviders WHERE OrganizationId = @OrgId AND PaymentProviderId = @RazorpayId);

INSERT INTO OrganizationPaymentProviders (Guid, OrganizationId, PaymentProviderId, Priority, CreatedBy)
SELECT UUID(), @OrgId, @StripeId, 2, 'System'
WHERE NOT EXISTS (SELECT 1 FROM OrganizationPaymentProviders WHERE OrganizationId = @OrgId AND PaymentProviderId = @StripeId);

SET @OrgRazorpayId = (SELECT Id FROM OrganizationPaymentProviders WHERE OrganizationId = @OrgId AND PaymentProviderId = @RazorpayId LIMIT 1);
SET @OrgStripeId = (SELECT Id FROM OrganizationPaymentProviders WHERE OrganizationId = @OrgId AND PaymentProviderId = @StripeId LIMIT 1);

-- 3. Link Organization Providers to a Branch (Assuming BranchId = 1)
INSERT INTO BranchPaymentProviders (Guid, BranchId, OrganizationPaymentProviderId, CreatedBy)
SELECT UUID(), @BranchId, @OrgRazorpayId, 'System'
WHERE NOT EXISTS (SELECT 1 FROM BranchPaymentProviders WHERE BranchId = @BranchId AND OrganizationPaymentProviderId = @OrgRazorpayId);

INSERT INTO BranchPaymentProviders (Guid, BranchId, OrganizationPaymentProviderId, CreatedBy)
SELECT UUID(), @BranchId, @OrgStripeId, 'System'
WHERE NOT EXISTS (SELECT 1 FROM BranchPaymentProviders WHERE BranchId = @BranchId AND OrganizationPaymentProviderId = @OrgStripeId);

-- 4. Seed Dummy Transactions into the legacy 'paymenttransactions' table
INSERT INTO paymenttransactions (
    TransactionId, SubscriptionId, Amount, Currency, PaymentProvider, ProviderTransactionId, Status
) VALUES (
    UUID(), UUID(), 500.00, 'INR', 'RAZORPAY', 'pay_mock_success_001', 'Completed'
);

INSERT INTO paymenttransactions (
    TransactionId, SubscriptionId, Amount, Currency, PaymentProvider, ProviderTransactionId, Status
) VALUES (
    UUID(), UUID(), 150.00, 'USD', 'STRIPE', 'pi_mock_pending_002', 'Pending'
);
