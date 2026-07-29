-- ===================================================================================
-- DNAQMS API - NOTIFICATION & MESSAGING TABLES (MySQL)
-- File Path: DNAQMSAPI/DatabaseScripts/MySqlScript/29_Notification_Tables.sql
-- ===================================================================================

USE `dnaqms`;

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. NotificationTemplate: Center/Organization-specific or Global templates
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `NotificationTemplate` (
    `Id`                INT AUTO_INCREMENT PRIMARY KEY,
    `OrganizationId`    INT NULL,                               -- NULL = Global System Default Template, else Center/Organization Specific
    `EventId`           INT NOT NULL,                           -- Foreign Key to ConfigParameters Category 17 (C_NOTIFICATION_EVENT)
    `EventCode`         VARCHAR(100) NOT NULL,                  -- e.g. PAYMENT_RECEIVED, INTERNAL_ANNOUNCEMENT, SYSTEM_ALERT
    `CategoryId`        INT NOT NULL,                           -- ConfigParameters Category for Notification Types
    `SubjectTemplate`   VARCHAR(255) NOT NULL,
    `BodyTemplate`      TEXT NOT NULL,
    `SendInApp`         TINYINT(1) NOT NULL DEFAULT 1,
    `SendEmail`         TINYINT(1) NOT NULL DEFAULT 1,
    `SendSMS`           TINYINT(1) NOT NULL DEFAULT 0,
    `IsActive`          TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy`         INT NOT NULL,
    `CreatedDate`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy`        INT NOT NULL DEFAULT 0,
    `ModifiedDate`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted`         TINYINT(1) NULL DEFAULT 0,
    `DeletedBy`         INT NULL,
    `DeletedDate`       DATETIME NULL,

    CONSTRAINT `FK_NotificationTemplate_Organization`
        FOREIGN KEY (`OrganizationId`) REFERENCES `Organization`(`Id`),

    CONSTRAINT `FK_NotificationTemplate_Event`
        FOREIGN KEY (`EventId`) REFERENCES `ConfigParameters`(`ParameterID`),

    INDEX `IX_NotificationTemplate_Lookup` (`OrganizationId`, `EventId`, `EventCode`, `IsDeleted`)
);

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. UserNotification: In-App Notification Bell Feed
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `UserNotification` (
    `Id`                BIGINT AUTO_INCREMENT PRIMARY KEY,
    `OrganizationId`    INT NOT NULL,
    `UserId`            INT NOT NULL,
    `EventId`           INT NULL,                               -- Foreign Key to ConfigParameters Category 17 (C_NOTIFICATION_EVENT)
    `EventCode`         VARCHAR(100) NOT NULL,
    `CategoryId`        INT NOT NULL,
    `Title`             VARCHAR(255) NOT NULL,
    `Message`           TEXT NOT NULL,
    `ActionUrl`         VARCHAR(500) NULL,                      -- e.g., /payments/invoices/1002
    `IsRead`            TINYINT(1) NOT NULL DEFAULT 0,
    `ReadDate`          DATETIME NULL,
    `CreatedBy`         INT NOT NULL,
    `CreatedDate`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy`        INT NOT NULL DEFAULT 0,
    `ModifiedDate`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted`         TINYINT(1) NULL DEFAULT 0,
    `DeletedBy`         INT NULL,
    `DeletedDate`       DATETIME NULL,

    CONSTRAINT `FK_UserNotification_Organization`
        FOREIGN KEY (`OrganizationId`) REFERENCES `Organization`(`Id`),

    CONSTRAINT `FK_UserNotification_User`
        FOREIGN KEY (`UserId`) REFERENCES `User`(`Id`),

    CONSTRAINT `FK_UserNotification_Event`
        FOREIGN KEY (`EventId`) REFERENCES `ConfigParameters`(`ParameterID`),

    INDEX `IX_UserNotification_UserFeed` (`UserId`, `IsRead`, `IsDeleted`, `CreatedDate`)
);

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. SmsQueue: Outgoing SMS Dispatch Queue
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `SmsQueue` (
    `QueueId`               VARCHAR(36) PRIMARY KEY,
    `OrganizationId`        INT NOT NULL,
    `RecipientPhoneNumber` VARCHAR(30) NOT NULL,
    `Message`               VARCHAR(1000) NOT NULL,
    `Status`                INT NOT NULL DEFAULT 0,              -- 0: Pending, 1: Sent, 2: Failed
    `RetryCount`            INT NOT NULL DEFAULT 0,
    `MaxRetryCount`         INT NOT NULL DEFAULT 3,
    `ErrorMessage`          VARCHAR(500) NULL,
    `CreatedBy`             INT NOT NULL,
    `CreatedDate`           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy`            INT NOT NULL DEFAULT 0,
    `ModifiedDate`          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted`             TINYINT(1) NULL DEFAULT 0,
    `DeletedBy`             INT NULL,
    `DeletedDate`           DATETIME NULL,

    CONSTRAINT `FK_SmsQueue_Organization`
        FOREIGN KEY (`OrganizationId`) REFERENCES `Organization`(`Id`)
);

-- Initial Starter Seed Templates (Global System Defaults with ConfigParameters EventId references)
INSERT INTO `NotificationTemplate` 
(OrganizationId, EventId, EventCode, CategoryId, SubjectTemplate, BodyTemplate, SendInApp, SendEmail, SendSMS, IsActive, CreatedBy, CreatedDate)
VALUES
(NULL, 17001, 'PAYMENT_RECEIVED', 2001, 'Payment Received: {InvoiceNo}', 'Hello {UserName}, your payment of {Currency} {Amount} for {CenterName} has been received successfully.', 1, 1, 0, 1, 0, CURRENT_TIMESTAMP),
(NULL, 17002, 'INTERNAL_ANNOUNCEMENT', 2001, 'Important Intimation: {Title}', 'Dear {UserName}, {Message}. Intimation from {CenterName}.', 1, 1, 0, 1, 0, CURRENT_TIMESTAMP),
(NULL, 17003, 'SYSTEM_ALERT', 2001, 'Security Intimation', 'Hello {UserName}, a security event occurred on your account at {CenterName}.', 1, 1, 1, 1, 0, CURRENT_TIMESTAMP)
ON DUPLICATE KEY UPDATE `ModifiedDate` = CURRENT_TIMESTAMP;
