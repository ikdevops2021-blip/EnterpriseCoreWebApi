-- =============================================
-- CREATE MISSING PAYMENT FRAMEWORK TABLES IN MYSQL
-- =============================================

-- 1. Create ProviderPaymentMethods (from Phase 5 extension)
CREATE TABLE IF NOT EXISTS ProviderPaymentMethods (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    PaymentProviderId INT NOT NULL,
    PaymentMethod VARCHAR(50) NOT NULL,
    IsActive BOOLEAN NOT NULL DEFAULT 1,
    FOREIGN KEY(PaymentProviderId) REFERENCES PaymentProviders(Id)
);

-- 2. Create PaymentStatusHistory
CREATE TABLE IF NOT EXISTS PaymentStatusHistory (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Guid CHAR(36) NOT NULL UNIQUE,
    PaymentTransactionId CHAR(36) NOT NULL, 
    OldStatus VARCHAR(50) NULL,
    NewStatus VARCHAR(50) NOT NULL,
    Reason VARCHAR(255) NULL,
    CreatedOn DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CreatedBy VARCHAR(100) NOT NULL,
    FOREIGN KEY(PaymentTransactionId) REFERENCES paymenttransactions(TransactionId)
);

-- 3. Create WebhookLogs
CREATE TABLE IF NOT EXISTS WebhookLogs (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Guid CHAR(36) NOT NULL UNIQUE,
    PaymentProviderId INT NOT NULL,
    EventId VARCHAR(255) NULL,
    EventType VARCHAR(100) NOT NULL,
    Payload TEXT NOT NULL,
    IsProcessed BOOLEAN NOT NULL DEFAULT 0,
    CreatedOn DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CreatedBy VARCHAR(100) NOT NULL,
    FOREIGN KEY(PaymentProviderId) REFERENCES PaymentProviders(Id)
);

-- =============================================
-- SEED DUMMY DATA FOR THE MISSING TABLES
-- =============================================

SET @RazorpayId = (SELECT Id FROM PaymentProviders WHERE Code = 'RAZORPAY' LIMIT 1);
SET @StripeId = (SELECT Id FROM PaymentProviders WHERE Code = 'STRIPE' LIMIT 1);

-- Seed capabilities into ProviderPaymentMethods
INSERT INTO ProviderPaymentMethods (PaymentProviderId, PaymentMethod, IsActive)
SELECT @RazorpayId, 'UPI', 1 WHERE @RazorpayId IS NOT NULL
ON DUPLICATE KEY UPDATE IsActive = 1;

INSERT INTO ProviderPaymentMethods (PaymentProviderId, PaymentMethod, IsActive)
SELECT @RazorpayId, 'QRCode', 1 WHERE @RazorpayId IS NOT NULL
ON DUPLICATE KEY UPDATE IsActive = 1;

INSERT INTO ProviderPaymentMethods (PaymentProviderId, PaymentMethod, IsActive)
SELECT @RazorpayId, 'CreditCard', 1 WHERE @RazorpayId IS NOT NULL
ON DUPLICATE KEY UPDATE IsActive = 1;

INSERT INTO ProviderPaymentMethods (PaymentProviderId, PaymentMethod, IsActive)
SELECT @StripeId, 'CreditCard', 1 WHERE @StripeId IS NOT NULL
ON DUPLICATE KEY UPDATE IsActive = 1;

-- Seed dummy webhook log
INSERT INTO WebhookLogs (Guid, PaymentProviderId, EventId, EventType, Payload, IsProcessed, CreatedBy)
SELECT UUID(), @RazorpayId, 'evt_dummy_001', 'payment.captured', '{"mock": "data"}', 1, 'System'
WHERE @RazorpayId IS NOT NULL;

-- Seed dummy status history
SET @TxId = (SELECT TransactionId FROM paymenttransactions WHERE PaymentProvider = 'RAZORPAY' LIMIT 1);

INSERT INTO PaymentStatusHistory (Guid, PaymentTransactionId, OldStatus, NewStatus, Reason, CreatedBy)
SELECT UUID(), @TxId, 'Pending', 'Completed', 'User completed UPI payment', 'System'
WHERE @TxId IS NOT NULL;
