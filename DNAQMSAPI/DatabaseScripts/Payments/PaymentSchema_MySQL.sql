-- MySQL Database Script for Payment Framework

-- 1. CurrencyMaster
CREATE TABLE IF NOT EXISTS CurrencyMaster (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Guid CHAR(36) NOT NULL UNIQUE,
    Code VARCHAR(3) NOT NULL UNIQUE,
    Name VARCHAR(100) NOT NULL,
    Symbol VARCHAR(10) NOT NULL,
    CreatedOn DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CreatedBy VARCHAR(100) NOT NULL,
    ModifiedOn DATETIME NULL,
    ModifiedBy VARCHAR(100) NULL,
    IsDeleted BOOLEAN NOT NULL DEFAULT 0,
    RowVersion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. PaymentProviders
CREATE TABLE IF NOT EXISTS PaymentProviders (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Guid CHAR(36) NOT NULL UNIQUE,
    Name VARCHAR(100) NOT NULL,
    Code VARCHAR(50) NOT NULL UNIQUE,
    IsActive BOOLEAN NOT NULL DEFAULT 1,
    CreatedOn DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CreatedBy VARCHAR(100) NOT NULL,
    ModifiedOn DATETIME NULL,
    ModifiedBy VARCHAR(100) NULL,
    IsDeleted BOOLEAN NOT NULL DEFAULT 0,
    RowVersion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 3. OrganizationPaymentProviders
CREATE TABLE IF NOT EXISTS OrganizationPaymentProviders (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Guid CHAR(36) NOT NULL UNIQUE,
    OrganizationId INT NOT NULL,
    PaymentProviderId INT NOT NULL,
    Priority INT NOT NULL DEFAULT 1,
    IsActive BOOLEAN NOT NULL DEFAULT 1,
    CreatedOn DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CreatedBy VARCHAR(100) NOT NULL,
    ModifiedOn DATETIME NULL,
    ModifiedBy VARCHAR(100) NULL,
    IsDeleted BOOLEAN NOT NULL DEFAULT 0,
    RowVersion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (PaymentProviderId) REFERENCES PaymentProviders(Id)
);

-- 4. BranchPaymentProviders
CREATE TABLE IF NOT EXISTS BranchPaymentProviders (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Guid CHAR(36) NOT NULL UNIQUE,
    BranchId INT NOT NULL,
    OrganizationPaymentProviderId INT NOT NULL,
    IsActive BOOLEAN NOT NULL DEFAULT 1,
    CreatedOn DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CreatedBy VARCHAR(100) NOT NULL,
    ModifiedOn DATETIME NULL,
    ModifiedBy VARCHAR(100) NULL,
    IsDeleted BOOLEAN NOT NULL DEFAULT 0,
    RowVersion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (OrganizationPaymentProviderId) REFERENCES OrganizationPaymentProviders(Id)
);

-- 5. PaymentTransactions
CREATE TABLE IF NOT EXISTS PaymentTransactions (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Guid CHAR(36) NOT NULL UNIQUE,
    OrganizationId INT NOT NULL,
    BranchId INT NOT NULL,
    PaymentProviderId INT NOT NULL,
    ExternalTransactionId VARCHAR(255) NULL,
    Amount DECIMAL(18, 4) NOT NULL,
    CurrencyId INT NOT NULL,
    Status VARCHAR(50) NOT NULL,
    PaymentMethod VARCHAR(50) NOT NULL,
    CustomerId VARCHAR(255) NULL,
    Description TEXT NULL,
    IdempotencyKey VARCHAR(255) NULL,
    CreatedOn DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CreatedBy VARCHAR(100) NOT NULL,
    ModifiedOn DATETIME NULL,
    ModifiedBy VARCHAR(100) NULL,
    IsDeleted BOOLEAN NOT NULL DEFAULT 0,
    RowVersion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (PaymentProviderId) REFERENCES PaymentProviders(Id),
    FOREIGN KEY (CurrencyId) REFERENCES CurrencyMaster(Id)
);

-- DUMMY DATA SEEDING
INSERT INTO CurrencyMaster (Guid, Code, Name, Symbol, CreatedBy) VALUES
(UUID(), 'USD', 'US Dollar', '$', 'System'),
(UUID(), 'INR', 'Indian Rupee', '₹', 'System'),
(UUID(), 'EUR', 'Euro', '€', 'System')
ON DUPLICATE KEY UPDATE Code = Code;

INSERT INTO PaymentProviders (Guid, Name, Code, CreatedBy) VALUES
(UUID(), 'Razorpay', 'RAZORPAY', 'System'),
(UUID(), 'Stripe', 'STRIPE', 'System'),
(UUID(), 'PayPal', 'PAYPAL', 'System')
ON DUPLICATE KEY UPDATE Code = Code;
