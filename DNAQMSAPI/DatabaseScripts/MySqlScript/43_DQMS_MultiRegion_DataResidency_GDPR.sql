-- ============================================================================================
-- DQMS STAGE 4: MULTI-REGION DATA RESIDENCY, SHARDING & GDPR COMPLIANCE ENGINE (MySQL)
-- Script Number: 43_DQMS_MultiRegion_DataResidency_GDPR.sql
-- Description: Geographic residency sharding, field-level AES-256 encryption columns,
--              Article 17 Right-To-Be-Forgotten cryptographic erasure, automated retention purge,
--              sovereign audit logging, and NavigationMenu seeding.
-- ============================================================================================

-- 1. OrganizationDataResidency Table
CREATE TABLE IF NOT EXISTS `OrganizationDataResidency` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `OrganizationId` INT NOT NULL,
    `DataRegion` VARCHAR(50) NOT NULL,
    `Jurisdiction` VARCHAR(50) NOT NULL,
    `KmsKeyArn` VARCHAR(250) NULL,
    `DataRetentionDays` INT NOT NULL DEFAULT 90,
    `AutoAnonymizeOnComplete` TINYINT(1) NOT NULL DEFAULT 0,
    `EnableBlindIndexing` TINYINT(1) NOT NULL DEFAULT 1,
    `AllowCrossBorderDiagnostics` TINYINT(1) NOT NULL DEFAULT 0,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `UQ_OrgResidency_OrgId` (`OrganizationId`),
    INDEX `IX_OrgDataResidency_Region` (`DataRegion`, `Jurisdiction`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. GdprAuditLog Table
CREATE TABLE IF NOT EXISTS `GdprAuditLog` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `OrganizationId` INT NOT NULL,
    `ActionType` VARCHAR(100) NOT NULL,
    `RecordsAffected` INT NOT NULL DEFAULT 0,
    `RequestedByUserId` INT NOT NULL DEFAULT 1,
    `AuditReason` VARCHAR(250) NULL,
    `ExecutionTime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `IX_GdprAuditLog_Org_Time` (`OrganizationId`, `ExecutionTime` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Alter TokenTransaction with Encryption & Blind Index Columns (Safe Procedure)
DELIMITER $$
DROP PROCEDURE IF EXISTS `SP_AddTokenTransactionEncryptionColumns`$$
CREATE PROCEDURE `SP_AddTokenTransactionEncryptionColumns`()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
          AND TABLE_NAME = 'TokenTransaction' 
          AND COLUMN_NAME = 'EncryptedCustomerName'
    ) THEN
        ALTER TABLE `TokenTransaction` 
            ADD COLUMN `EncryptedCustomerName` LONGBLOB NULL,
            ADD COLUMN `EncryptedCustomerPhone` LONGBLOB NULL,
            ADD COLUMN `EncryptedNotes` LONGBLOB NULL,
            ADD COLUMN `PhoneBlindIndex` VARCHAR(64) NULL,
            ADD COLUMN `NationalIdBlindIndex` VARCHAR(64) NULL,
            ADD COLUMN `EncryptionKeyVersion` INT NOT NULL DEFAULT 1,
            ADD COLUMN `IsAnonymized` TINYINT(1) NOT NULL DEFAULT 0,
            ADD COLUMN `AnonymizedDate` DATETIME NULL;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.STATISTICS 
        WHERE TABLE_SCHEMA = DATABASE() 
          AND TABLE_NAME = 'TokenTransaction' 
          AND INDEX_NAME = 'IX_TokenTransaction_PhoneBlindIndex'
    ) THEN
        ALTER TABLE `TokenTransaction` 
            ADD INDEX `IX_TokenTransaction_PhoneBlindIndex` (`OrganizationId`, `PhoneBlindIndex`);
    END IF;
END$$
DELIMITER ;

CALL `SP_AddTokenTransactionEncryptionColumns`();
DROP PROCEDURE IF EXISTS `SP_AddTokenTransactionEncryptionColumns`;

-- ============================================================================
-- STORED PROCEDURE: UPSERT ORGANIZATION DATA RESIDENCY (MySQL)
-- ============================================================================
DELIMITER $$
DROP PROCEDURE IF EXISTS `PR_IU_OrganizationDataResidency`$$
CREATE PROCEDURE `PR_IU_OrganizationDataResidency`(
    IN `p_OrganizationId` INT,
    IN `p_DataRegion` VARCHAR(50),
    IN `p_Jurisdiction` VARCHAR(50),
    IN `p_KmsKeyArn` VARCHAR(250),
    IN `p_DataRetentionDays` INT,
    IN `p_AutoAnonymizeOnComplete` TINYINT(1),
    IN `p_EnableBlindIndexing` TINYINT(1),
    IN `p_AllowCrossBorderDiagnostics` TINYINT(1),
    OUT `p_ResidencyId` INT
)
BEGIN
    IF `p_DataRetentionDays` IS NULL OR `p_DataRetentionDays` <= 0 THEN
        SET `p_DataRetentionDays` = 90;
    END IF;

    INSERT INTO `OrganizationDataResidency` (
        `OrganizationId`, `DataRegion`, `Jurisdiction`, `KmsKeyArn`,
        `DataRetentionDays`, `AutoAnonymizeOnComplete`, `EnableBlindIndexing`,
        `AllowCrossBorderDiagnostics`, `CreatedDate`, `ModifiedDate`
    ) VALUES (
        `p_OrganizationId`, `p_DataRegion`, `p_Jurisdiction`, `p_KmsKeyArn`,
        `p_DataRetentionDays`, `p_AutoAnonymizeOnComplete`, `p_EnableBlindIndexing`,
        `p_AllowCrossBorderDiagnostics`, NOW(), NOW()
    )
    ON DUPLICATE KEY UPDATE
        `DataRegion` = `p_DataRegion`,
        `Jurisdiction` = `p_Jurisdiction`,
        `KmsKeyArn` = `p_KmsKeyArn`,
        `DataRetentionDays` = `p_DataRetentionDays`,
        `AutoAnonymizeOnComplete` = `p_AutoAnonymizeOnComplete`,
        `EnableBlindIndexing` = `p_EnableBlindIndexing`,
        `AllowCrossBorderDiagnostics` = `p_AllowCrossBorderDiagnostics`,
        `ModifiedDate` = NOW();

    SELECT `Id` INTO `p_ResidencyId`
    FROM `OrganizationDataResidency`
    WHERE `OrganizationId` = `p_OrganizationId`
    LIMIT 1;
END$$
DELIMITER ;

-- ============================================================================
-- STORED PROCEDURE: GET ORGANIZATION DATA RESIDENCY (MySQL)
-- ============================================================================
DELIMITER $$
DROP PROCEDURE IF EXISTS `PR_S_OrganizationDataResidency`$$
CREATE PROCEDURE `PR_S_OrganizationDataResidency`(
    IN `p_OrganizationId` INT
)
BEGIN
    IF `p_OrganizationId` IS NOT NULL AND `p_OrganizationId` > 0 THEN
        SELECT 
            `Id`,
            `OrganizationId`,
            `DataRegion`,
            `Jurisdiction`,
            `KmsKeyArn`,
            `DataRetentionDays`,
            `AutoAnonymizeOnComplete`,
            `EnableBlindIndexing`,
            `AllowCrossBorderDiagnostics`,
            `CreatedDate`,
            `ModifiedDate`
        FROM `OrganizationDataResidency`
        WHERE `OrganizationId` = `p_OrganizationId`;
    ELSE
        SELECT 
            `Id`,
            `OrganizationId`,
            `DataRegion`,
            `Jurisdiction`,
            `KmsKeyArn`,
            `DataRetentionDays`,
            `AutoAnonymizeOnComplete`,
            `EnableBlindIndexing`,
            `AllowCrossBorderDiagnostics`,
            `CreatedDate`,
            `ModifiedDate`
        FROM `OrganizationDataResidency`
        ORDER BY `OrganizationId` ASC;
    END IF;
END$$
DELIMITER ;

-- ============================================================================
-- STORED PROCEDURE: GDPR ARTICLE 17 RIGHT-TO-BE-FORGOTTEN (MySQL)
-- ============================================================================
DELIMITER $$
DROP PROCEDURE IF EXISTS `PR_IU_GdprRightToBeForgotten`$$
CREATE PROCEDURE `PR_IU_GdprRightToBeForgotten`(
    IN `p_OrganizationId` INT,
    IN `p_PhoneBlindIndex` VARCHAR(64),
    IN `p_RequestedByUserId` INT,
    IN `p_AuditReason` VARCHAR(250),
    OUT `p_AffectedRecordsCount` INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- 1. Anonymize PII in TokenTransaction
    UPDATE `TokenTransaction`
    SET `CustomerName` = '[ANONYMIZED-GDPR-ART17]',
        `CustomerPhone` = '[ANONYMIZED]',
        `Notes` = NULL,
        `EncryptedCustomerName` = NULL,
        `EncryptedCustomerPhone` = NULL,
        `EncryptedNotes` = NULL,
        `PhoneBlindIndex` = NULL,
        `NationalIdBlindIndex` = NULL,
        `IsAnonymized` = 1,
        `AnonymizedDate` = NOW(),
        `ModifiedBy` = IFNULL(`p_RequestedByUserId`, 1),
        `ModifiedDate` = NOW()
    WHERE `OrganizationId` = `p_OrganizationId`
      AND `PhoneBlindIndex` = `p_PhoneBlindIndex`
      AND `IsAnonymized` = 0;

    SET `p_AffectedRecordsCount` = ROW_COUNT();

    -- 2. Scrub pending notification queue
    DELETE FROM `CustomerNotificationQueue`
    WHERE `OrganizationId` = `p_OrganizationId`
      AND (`RecipientPhone` = `p_PhoneBlindIndex` OR `Notes` LIKE CONCAT('%', `p_PhoneBlindIndex`, '%'));

    -- 3. Audit log entry
    INSERT INTO `GdprAuditLog` (
        `OrganizationId`, `ActionType`, `RecordsAffected`,
        `RequestedByUserId`, `AuditReason`, `ExecutionTime`
    ) VALUES (
        `p_OrganizationId`, 'Article17_RightToBeForgotten', `p_AffectedRecordsCount`,
        IFNULL(`p_RequestedByUserId`, 1), IFNULL(`p_AuditReason`, 'GDPR Article 17 Erasure'), NOW()
    );

    COMMIT;
END$$
DELIMITER ;

-- ============================================================================
-- STORED PROCEDURE: PURGE EXPIRED DATA RETENTION (MySQL Chunked Batch)
-- ============================================================================
DELIMITER $$
DROP PROCEDURE IF EXISTS `PR_IU_PurgeExpiredDataRetention`$$
CREATE PROCEDURE `PR_IU_PurgeExpiredDataRetention`(
    IN `p_OrganizationId` INT,
    OUT `p_PurgedCount` INT
)
BEGIN
    DECLARE v_RetentionDays INT DEFAULT 90;
    DECLARE v_BatchRows INT DEFAULT 1;
    DECLARE v_TotalPurged INT DEFAULT 0;

    SELECT `DataRetentionDays` INTO v_RetentionDays
    FROM `OrganizationDataResidency`
    WHERE `OrganizationId` = `p_OrganizationId`
    LIMIT 1;

    IF v_RetentionDays IS NULL OR v_RetentionDays <= 0 THEN
        SET v_RetentionDays = 90;
    END IF;

    SET `p_PurgedCount` = 0;

    WHILE v_BatchRows > 0 DO
        START TRANSACTION;
        UPDATE `TokenTransaction`
        SET `CustomerName` = '[PURGED-RETENTION-POLICY]',
            `CustomerPhone` = '[PURGED]',
            `Notes` = NULL,
            `EncryptedCustomerName` = NULL,
            `EncryptedCustomerPhone` = NULL,
            `EncryptedNotes` = NULL,
            `PhoneBlindIndex` = NULL,
            `NationalIdBlindIndex` = NULL,
            `IsAnonymized` = 1,
            `AnonymizedDate` = NOW()
        WHERE `OrganizationId` = `p_OrganizationId`
          AND `CreatedDate` < DATE_SUB(NOW(), INTERVAL v_RetentionDays DAY)
          AND `TokenStatus` IN (18005, 18006, 18007)
          AND `IsAnonymized` = 0
        LIMIT 1000;

        SET v_BatchRows = ROW_COUNT();
        SET v_TotalPurged = v_TotalPurged + v_BatchRows;
        COMMIT;
    END WHILE;

    SET `p_PurgedCount` = v_TotalPurged;

    IF `p_PurgedCount` > 0 THEN
        INSERT INTO `GdprAuditLog` (
            `OrganizationId`, `ActionType`, `RecordsAffected`,
            `RequestedByUserId`, `AuditReason`, `ExecutionTime`
        ) VALUES (
            `p_OrganizationId`, 'Retention_Purge', `p_PurgedCount`,
            1, CONCAT('Automated purge of records older than ', v_RetentionDays, ' days'), NOW()
        );
    END IF;
END$$
DELIMITER ;

-- ============================================================================
-- STORED PROCEDURE: GET GDPR AUDIT LOGS (MySQL)
-- ============================================================================
DELIMITER $$
DROP PROCEDURE IF EXISTS `PR_S_GdprAuditLogs`$$
CREATE PROCEDURE `PR_S_GdprAuditLogs`(
    IN `p_OrganizationId` INT,
    IN `p_PageSize` INT,
    IN `p_PageIndex` INT
)
BEGIN
    DECLARE v_Offset INT;
    IF `p_PageSize` IS NULL OR `p_PageSize` <= 0 THEN
        SET `p_PageSize` = 50;
    END IF;
    IF `p_PageIndex` IS NULL OR `p_PageIndex` <= 0 THEN
        SET `p_PageIndex` = 1;
    END IF;
    SET v_Offset = (`p_PageIndex` - 1) * `p_PageSize`;

    SELECT 
        `Id`,
        `OrganizationId`,
        `ActionType`,
        `RecordsAffected`,
        `RequestedByUserId`,
        `AuditReason`,
        `ExecutionTime`
    FROM `GdprAuditLog`
    WHERE `OrganizationId` = `p_OrganizationId`
    ORDER BY `ExecutionTime` DESC
    LIMIT `p_PageSize` OFFSET v_Offset;
END$$
DELIMITER ;

-- ============================================================================
-- SEED NAVIGATION MENU FOR DATA RESIDENCY & PRIVACY (MySQL)
-- ============================================================================
INSERT INTO `NavigationMenu` (
    `ParentId`, `Title`, `RouteUrl`, `IconName`, `DisplayOrder`,
    `RequiredPermission`, `IsActive`, `CreatedBy`, `CreatedDate`, `ModifiedBy`, `ModifiedDate`, `IsDeleted`
)
SELECT 
    (SELECT `Id` FROM `NavigationMenu` WHERE `RouteUrl` = '/admin' OR `Title` LIKE '%Admin%' ORDER BY `Id` ASC LIMIT 1),
    'Data Residency & GDPR', '/admin/data-residency', 'security_rounded', 20,
    'Privacy.Manage', 1, 1, NOW(), 1, NOW(), 0
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `NavigationMenu` WHERE `RouteUrl` = '/admin/data-residency'
);
