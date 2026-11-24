-- ============================================================================================
-- DQMS STAGE 4: OFFLINE EDGE RESILIENCE & HYBRID SYNC ENGINE (MySQL 8.0)
-- Script Number: 41_DQMS_Offline_Edge_Hybrid_Sync.sql
-- Description: Alters TokenTransaction, creates EdgeNodeRegistration and EdgeSyncAuditLog tables,
--              stored procedures (PR_IU_EdgeNodeRegistration, PR_S_EdgeNodes,
--              PR_IU_ProcessEdgeSyncBatch), and seeds NavigationMenu for '/admin/edge-nodes'.
-- ============================================================================================

USE `dnaqms`;

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;

-- ============================================================================
-- 1. Alter TokenTransaction with Edge Sync Columns
-- ============================================================================
SET @col_exists = (
    SELECT COUNT(*) FROM information_schema.columns 
    WHERE table_schema = DATABASE() AND table_name = 'TokenTransaction' AND column_name = 'ClientTokenGuid'
);
SET @sql = IF(@col_exists = 0, 'ALTER TABLE `TokenTransaction` ADD COLUMN `ClientTokenGuid` VARCHAR(64) NULL;', 'SELECT 1;');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = (
    SELECT COUNT(*) FROM information_schema.columns 
    WHERE table_schema = DATABASE() AND table_name = 'TokenTransaction' AND column_name = 'IsOfflineGenerated'
);
SET @sql = IF(@col_exists = 0, 'ALTER TABLE `TokenTransaction` ADD COLUMN `IsOfflineGenerated` TINYINT(1) NOT NULL DEFAULT 0;', 'SELECT 1;');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = (
    SELECT COUNT(*) FROM information_schema.columns 
    WHERE table_schema = DATABASE() AND table_name = 'TokenTransaction' AND column_name = 'EdgeNodeId'
);
SET @sql = IF(@col_exists = 0, 'ALTER TABLE `TokenTransaction` ADD COLUMN `EdgeNodeId` VARCHAR(64) NULL;', 'SELECT 1;');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = (
    SELECT COUNT(*) FROM information_schema.columns 
    WHERE table_schema = DATABASE() AND table_name = 'TokenTransaction' AND column_name = 'SyncedAt'
);
SET @sql = IF(@col_exists = 0, 'ALTER TABLE `TokenTransaction` ADD COLUMN `SyncedAt` DATETIME NULL;', 'SELECT 1;');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Unique index on ClientTokenGuid
SET @idx_exists = (
    SELECT COUNT(*) FROM information_schema.statistics 
    WHERE table_schema = DATABASE() AND table_name = 'TokenTransaction' AND index_name = 'UX_TokenTransaction_ClientTokenGuid'
);
SET @sql = IF(@idx_exists = 0, 'ALTER TABLE `TokenTransaction` ADD UNIQUE INDEX `UX_TokenTransaction_ClientTokenGuid` (`ClientTokenGuid`);', 'SELECT 1;');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================================
-- 2. Table: EdgeNodeRegistration
-- ============================================================================
CREATE TABLE IF NOT EXISTS `EdgeNodeRegistration` (
    `Id`                  INT AUTO_INCREMENT PRIMARY KEY,
    `NodeId`              VARCHAR(64) NOT NULL UNIQUE,
    `NodeName`            VARCHAR(128) NOT NULL,
    `OrganizationId`      INT NOT NULL,
    `LocationId`          INT NOT NULL,
    `MacAddress`          VARCHAR(64) NULL,
    `IpAddress`           VARCHAR(64) NULL,
    `SecretKeyHash`       VARCHAR(256) NOT NULL,
    `SoftwareVersion`     VARCHAR(32) NULL DEFAULT '1.0.0',
    `IsActive`            TINYINT(1) NOT NULL DEFAULT 1,
    `LastHeartbeatAt`     DATETIME NULL,
    `LastSyncAt`          DATETIME NULL,
    `PendingJournalCount` INT NOT NULL DEFAULT 0,
    `CreatedBy`           INT NOT NULL DEFAULT 0,
    `CreatedDate`         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy`          INT NOT NULL DEFAULT 0,
    `ModifiedDate`        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `IX_EdgeNode_OrgLocation` (`OrganizationId`, `LocationId`, `IsActive`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- 3. Table: EdgeSyncAuditLog
-- ============================================================================
CREATE TABLE IF NOT EXISTS `EdgeSyncAuditLog` (
    `Id`                BIGINT AUTO_INCREMENT PRIMARY KEY,
    `BatchId`           VARCHAR(64) NOT NULL,
    `NodeId`            VARCHAR(64) NOT NULL,
    `OrganizationId`    INT NOT NULL,
    `LocationId`        INT NOT NULL,
    `RecordsCount`      INT NOT NULL,
    `ConflictsResolved` INT NOT NULL DEFAULT 0,
    `DurationMs`        INT NOT NULL DEFAULT 0,
    `Status`            VARCHAR(32) NOT NULL,
    `ErrorMessage`      TEXT NULL,
    `CreatedDate`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `IX_EdgeSyncAudit_BatchNode` (`NodeId`, `BatchId`, `CreatedDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- 4. Stored Procedure: PR_IU_EdgeNodeRegistration
-- ============================================================================
DROP PROCEDURE IF EXISTS `PR_IU_EdgeNodeRegistration`;
DELIMITER $$

CREATE PROCEDURE `PR_IU_EdgeNodeRegistration`(
    IN p_Id INT,
    IN p_NodeId VARCHAR(64),
    IN p_NodeName VARCHAR(128),
    IN p_OrganizationId INT,
    IN p_LocationId INT,
    IN p_MacAddress VARCHAR(64),
    IN p_IpAddress VARCHAR(64),
    IN p_SecretKeyHash VARCHAR(256),
    IN p_SoftwareVersion VARCHAR(32),
    IN p_IsActive TINYINT(1),
    IN p_UserId INT
)
BEGIN
    DECLARE v_ExistingId INT DEFAULT 0;

    SELECT `Id` INTO v_ExistingId
    FROM `EdgeNodeRegistration`
    WHERE `Id` = p_Id OR `NodeId` = p_NodeId
    LIMIT 1;

    IF v_ExistingId = 0 THEN
        INSERT INTO `EdgeNodeRegistration` (
            `NodeId`, `NodeName`, `OrganizationId`, `LocationId`,
            `MacAddress`, `IpAddress`, `SecretKeyHash`, `SoftwareVersion`,
            `IsActive`, `CreatedBy`, `CreatedDate`, `ModifiedBy`, `ModifiedDate`
        ) VALUES (
            p_NodeId, p_NodeName, p_OrganizationId, p_LocationId,
            p_MacAddress, p_IpAddress, p_SecretKeyHash, IFNULL(p_SoftwareVersion, '1.0.0'),
            IFNULL(p_IsActive, 1), p_UserId, UTC_TIMESTAMP(), p_UserId, UTC_TIMESTAMP()
        );
        SELECT LAST_INSERT_ID() AS `NewId`;
    ELSE
        UPDATE `EdgeNodeRegistration`
        SET `NodeName` = p_NodeName,
            `OrganizationId` = p_OrganizationId,
            `LocationId` = p_LocationId,
            `MacAddress` = IFNULL(p_MacAddress, `MacAddress`),
            `IpAddress` = IFNULL(p_IpAddress, `IpAddress`),
            `SecretKeyHash` = CASE WHEN LENGTH(p_SecretKeyHash) > 0 THEN p_SecretKeyHash ELSE `SecretKeyHash` END,
            `SoftwareVersion` = IFNULL(p_SoftwareVersion, `SoftwareVersion`),
            `IsActive` = IFNULL(p_IsActive, `IsActive`),
            `ModifiedBy` = p_UserId,
            `ModifiedDate` = UTC_TIMESTAMP()
        WHERE `Id` = v_ExistingId;

        SELECT v_ExistingId AS `NewId`;
    END IF;
END$$
DELIMITER ;

-- ============================================================================
-- 5. Stored Procedure: PR_S_EdgeNodes
-- ============================================================================
DROP PROCEDURE IF EXISTS `PR_S_EdgeNodes`;
DELIMITER $$

CREATE PROCEDURE `PR_S_EdgeNodes`(
    IN p_OrganizationId INT,
    IN p_LocationId INT,
    IN p_NodeId VARCHAR(64)
)
BEGIN
    SELECT 
        `Id`,
        `NodeId`,
        `NodeName`,
        `OrganizationId`,
        `LocationId`,
        `MacAddress`,
        `IpAddress`,
        `SoftwareVersion`,
        `IsActive`,
        `LastHeartbeatAt`,
        `LastSyncAt`,
        `PendingJournalCount`,
        `CreatedDate`,
        `ModifiedDate`
    FROM `EdgeNodeRegistration`
    WHERE (p_OrganizationId = -1 OR `OrganizationId` = p_OrganizationId)
      AND (p_LocationId = -1 OR `LocationId` = p_LocationId)
      AND (p_NodeId IS NULL OR `NodeId` = p_NodeId)
    ORDER BY `LastHeartbeatAt` DESC, `NodeName` ASC;
END$$
DELIMITER ;

-- ============================================================================
-- 6. Stored Procedure: PR_IU_ProcessEdgeSyncBatch
-- ============================================================================
DROP PROCEDURE IF EXISTS `PR_IU_ProcessEdgeSyncBatch`;
DELIMITER $$

CREATE PROCEDURE `PR_IU_ProcessEdgeSyncBatch`(
    IN p_BatchId VARCHAR(64),
    IN p_NodeId VARCHAR(64),
    IN p_OrganizationId INT,
    IN p_LocationId INT,
    IN p_PayloadJson LONGTEXT,
    IN p_UserId INT
)
BEGIN
    DECLARE v_StartTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP(3);
    DECLARE v_RecordsIngested INT DEFAULT 0;
    DECLARE v_ConflictsResolved INT DEFAULT 0;
    DECLARE v_DurationMs INT DEFAULT 0;

    -- Process JSON array using MySQL 8.0 JSON_TABLE
    IF JSON_VALID(p_PayloadJson) THEN
        -- 1. Insert new tokens with UUIDv7 ClientTokenGuid
        INSERT INTO `TokenTransaction` (
            `OrganizationId`, `LocationId`, `AreaId`, `ProcessId`, `CounterId`,
            `TokenNumber`, `PriorityTier`, `TokenStatus`, `QueuePosition`,
            `CreatedDate`, `CalledTime`, `CompletedTime`, `CustomerName`, `CustomerPhone`,
            `ClientTokenGuid`, `IsOfflineGenerated`, `EdgeNodeId`, `SyncedAt`
        )
        SELECT 
            p_OrganizationId,
            p_LocationId,
            1,
            jt.ProcessId,
            jt.CounterId,
            jt.TokenNumber,
            IFNULL(jt.PriorityTier, 19001),
            jt.TokenStatus,
            1,
            jt.CreatedDate,
            jt.CalledTime,
            jt.CompletedTime,
            jt.CustomerName,
            jt.CustomerPhone,
            jt.ClientTokenGuid,
            1,
            p_NodeId,
            UTC_TIMESTAMP()
        FROM JSON_TABLE(
            p_PayloadJson,
            '$[*]' COLUMNS (
                ClientTokenGuid VARCHAR(64) PATH '$.clientTokenGuid',
                TokenNumber VARCHAR(32) PATH '$.tokenNumber',
                ProcessId INT PATH '$.processId',
                CounterId INT PATH '$.counterId',
                PriorityTier INT PATH '$.priorityTier',
                TokenStatus INT PATH '$.tokenStatus',
                CreatedDate DATETIME PATH '$.createdDate',
                CalledTime DATETIME PATH '$.calledTime',
                CompletedTime DATETIME PATH '$.completedTime',
                CustomerName VARCHAR(100) PATH '$.customerName',
                CustomerPhone VARCHAR(50) PATH '$.customerPhone'
            )
        ) AS jt
        WHERE NOT EXISTS (
            SELECT 1 FROM `TokenTransaction` t WHERE t.`ClientTokenGuid` = jt.ClientTokenGuid
        );

        SET v_RecordsIngested = ROW_COUNT();

        -- 2. State Dominance for existing tokens: Completed(18007) > Active(18004) > Calling(18003)
        UPDATE `TokenTransaction` t
        JOIN JSON_TABLE(
            p_PayloadJson,
            '$[*]' COLUMNS (
                ClientTokenGuid VARCHAR(64) PATH '$.clientTokenGuid',
                CounterId INT PATH '$.counterId',
                TokenStatus INT PATH '$.tokenStatus',
                CalledTime DATETIME PATH '$.calledTime',
                CompletedTime DATETIME PATH '$.completedTime'
            )
        ) AS jt ON t.`ClientTokenGuid` = jt.ClientTokenGuid
        SET 
            t.`TokenStatus` = CASE 
                WHEN jt.TokenStatus = 18007 THEN 18007
                WHEN jt.TokenStatus = 18004 AND t.`TokenStatus` NOT IN (18007) THEN 18004
                WHEN jt.TokenStatus = 18003 AND t.`TokenStatus` NOT IN (18004, 18007) THEN 18003
                ELSE t.`TokenStatus` 
            END,
            t.`CounterId` = IFNULL(jt.CounterId, t.`CounterId`),
            t.`CalledTime` = IFNULL(jt.CalledTime, t.`CalledTime`),
            t.`CompletedTime` = IFNULL(jt.CompletedTime, t.`CompletedTime`),
            t.`SyncedAt` = UTC_TIMESTAMP()
        WHERE t.`TokenStatus` <> jt.TokenStatus;

        SET v_ConflictsResolved = ROW_COUNT();
    END IF;

    -- Audit Log Entry
    SET v_DurationMs = TIMESTAMPDIFF(MICROSECOND, v_StartTime, CURRENT_TIMESTAMP(3)) / 1000;

    INSERT INTO `EdgeSyncAuditLog` (
        `BatchId`, `NodeId`, `OrganizationId`, `LocationId`,
        `RecordsCount`, `ConflictsResolved`, `DurationMs`, `Status`
    ) VALUES (
        p_BatchId, p_NodeId, p_OrganizationId, p_LocationId,
        v_RecordsIngested, v_ConflictsResolved, v_DurationMs, 'Success'
    );

    UPDATE `EdgeNodeRegistration`
    SET `LastSyncAt` = UTC_TIMESTAMP(),
        `LastHeartbeatAt` = UTC_TIMESTAMP(),
        `PendingJournalCount` = 0
    WHERE `NodeId` = p_NodeId;

    SELECT 
        p_BatchId AS `BatchId`,
        v_RecordsIngested AS `RecordsIngested`,
        v_ConflictsResolved AS `ConflictsResolved`,
        v_DurationMs AS `DurationMs`,
        'Success' AS `Status`;
END$$
DELIMITER ;

-- ============================================================================
-- 7. Seed NavigationMenu entry for /admin/edge-nodes
-- ============================================================================
INSERT INTO `NavigationMenu` (
    `ParentId`, `Title`, `IconName`, `RoutePath`, `SortOrder`,
    `IsActive`, `RequiredPermission`, `CreatedBy`, `CreatedDate`
)
SELECT 0, 'Edge Appliances & Sync', 'hub_rounded', '/admin/edge-nodes', 16, 1, 'Admin.EdgeSync', 1, UTC_TIMESTAMP()
WHERE NOT EXISTS (
    SELECT 1 FROM `NavigationMenu` WHERE `RoutePath` = '/admin/edge-nodes'
);
