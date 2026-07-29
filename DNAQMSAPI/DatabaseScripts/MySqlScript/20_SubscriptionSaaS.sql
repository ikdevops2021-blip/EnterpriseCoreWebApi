CREATE TABLE `SubscriptionPlans` (
    `PlanId` INT PRIMARY KEY AUTO_INCREMENT,
    `PlanName` VARCHAR(150) NOT NULL,
    `Price` DECIMAL(18,2) NOT NULL,
    `BillingCycleMonths` INT NOT NULL,
    `IsActive` TINYINT(1) DEFAULT 1,
    `CreatedDate` DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE `PlanFeatures` (
    `FeatureId` INT PRIMARY KEY AUTO_INCREMENT,
    `PlanId` INT NOT NULL,
    `FeatureKey` VARCHAR(150) NOT NULL,
    `FeatureValue` VARCHAR(150) NOT NULL, 
    FOREIGN KEY (`PlanId`) REFERENCES `SubscriptionPlans`(`PlanId`)
);

CREATE TABLE `TenantSubscriptions` (
    `SubscriptionId` CHAR(36) PRIMARY KEY,
    `TenantId` CHAR(36) NOT NULL,
    `PlanId` INT NOT NULL,
    `Status` SMALLINT NOT NULL,
    `StartDate` DATETIME NOT NULL,
    `ExpiryDate` DATETIME NOT NULL,
    `TrialEndDate` DATETIME NULL,
    `AutoRenew` TINYINT(1) DEFAULT 1,
    `GracePeriodEnd` DATETIME NULL,
    `CreatedDate` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `ModifiedDate` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`PlanId`) REFERENCES `SubscriptionPlans`(`PlanId`)
);
CREATE INDEX `IX_TenantSubscriptions_Tenant` ON `TenantSubscriptions`(`TenantId`);

CREATE TABLE `UsageTracking` (
    `UsageId` CHAR(36) PRIMARY KEY,
    `TenantId` CHAR(36) NOT NULL,
    `FeatureKey` VARCHAR(150) NOT NULL,
    `UsageCount` BIGINT DEFAULT 0,
    `PeriodStart` DATETIME NOT NULL,
    `PeriodEnd` DATETIME NOT NULL
);
CREATE INDEX `IX_UsageTracking_Tenant_Feature` ON `UsageTracking`(`TenantId`, `FeatureKey`);

CREATE TABLE `PaymentTransactions` (
    `TransactionId` CHAR(36) PRIMARY KEY,
    `SubscriptionId` CHAR(36) NOT NULL,
    `Amount` DECIMAL(18,2) NOT NULL,
    `Currency` VARCHAR(10) DEFAULT 'USD',
    `PaymentProvider` VARCHAR(100) NOT NULL,
    `ProviderTransactionId` VARCHAR(200),
    `Status` VARCHAR(50) NOT NULL,
    `CreatedDate` DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE `BillingHistory` (
    `BillingId` CHAR(36) PRIMARY KEY,
    `SubscriptionId` CHAR(36) NOT NULL,
    `BillingStart` DATETIME NOT NULL,
    `BillingEnd` DATETIME NOT NULL,
    `Amount` DECIMAL(18,2) NOT NULL,
    `InvoiceNumber` VARCHAR(100),
    `Paid` TINYINT(1) DEFAULT 0,
    `CreatedDate` DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Seed basic plans
INSERT INTO `SubscriptionPlans` (`PlanName`, `Price`, `BillingCycleMonths`) VALUES 
('Free Plan', 0.00, 1),
('Pro Plan', 49.99, 1),
('Enterprise Plan', 199.99, 1);

INSERT INTO `PlanFeatures` (`PlanId`, `FeatureKey`, `FeatureValue`) VALUES 
(1, 'MaxUsers', '5'),
(2, 'MaxUsers', '50'),
(3, 'MaxUsers', '999999');
