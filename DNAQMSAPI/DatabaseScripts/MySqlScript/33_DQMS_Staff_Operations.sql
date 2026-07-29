-- ============================================================================================
-- DQMS STAGE 2: STAFF OPERATIONS & TOKEN QUEUE MANAGEMENT (MySQL)
-- Script Number: 33_DQMS_Staff_Operations.sql
-- Description: Token transaction tables, audit logs, and high-performance PR_IU_* / PR_S_* 
--              Stored Procedures for operator counter stations.
-- ============================================================================================

-- 1. Token Transaction Table
CREATE TABLE IF NOT EXISTS `TokenTransaction` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `TokenNumber` VARCHAR(20) NOT NULL,
    `OrganizationId` INT NOT NULL,
    `LocationId` INT NOT NULL,
    `AreaId` INT NOT NULL,
    `ProcessId` INT NOT NULL,
    `CounterId` INT NULL,
    `UserId` INT NULL,
    `PriorityTier` INT NOT NULL DEFAULT 19001 COMMENT '19001: Standard, 19002: Senior, 19003: Disabled, 19004: Emergency, 19005: VIP',
    `TokenStatus` INT NOT NULL DEFAULT 18001 COMMENT '18001: Queued, 18002: Waiting, 18003: Calling, 18004: Active, 18005: Hold, 18006: Canceled, 18007: Completed, 18008: Forwarded',
    `QueuePosition` INT NOT NULL DEFAULT 1,
    `CustomerName` VARCHAR(100) NULL,
    `CustomerPhone` VARCHAR(20) NULL,
    `Notes` VARCHAR(250) NULL,
    `IssuedTime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `CalledTime` DATETIME NULL,
    `ServedTime` DATETIME NULL,
    `CompletedTime` DATETIME NULL,
    `CreatedBy` INT NOT NULL,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy` INT NOT NULL,
    `ModifiedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted` TINYINT(1) NULL DEFAULT 0,
    `DeletedBy` INT NULL,
    `DeletedDate` DATETIME NULL,
    INDEX `IX_Token_QueueLookup` (`OrganizationId`, `LocationId`, `ProcessId`, `TokenStatus`),
    INDEX `IX_Token_CounterLookup` (`CounterId`, `TokenStatus`),
    INDEX `IX_Token_Priority` (`PriorityTier`, `IssuedTime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Token Audit & State History Table
CREATE TABLE IF NOT EXISTS `TokenAuditLog` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `TokenId` INT NOT NULL,
    `PreviousStatus` INT NOT NULL,
    `NewStatus` INT NOT NULL,
    `ActionByUserId` INT NOT NULL,
    `ActionTime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ActionReason` VARCHAR(250) NULL,
    INDEX `IX_Audit_Token` (`TokenId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DELIMITER //

-- ============================================================================
-- STORED PROCEDURE: ISSUE NEW TOKEN (Kiosk / Reception)
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_IU_IssueToken //
CREATE PROCEDURE PR_IU_IssueToken (
    IN p_OrganizationId INT,
    IN p_LocationId     INT,
    IN p_AreaId         INT,
    IN p_ProcessId      INT,
    IN p_PriorityTier   INT,
    IN p_CustomerName   VARCHAR(100),
    IN p_CustomerPhone  VARCHAR(20),
    IN p_UID            INT
)
proc_body: BEGIN
    DECLARE v_prefix VARCHAR(5) DEFAULT 'A';
    DECLARE v_nextSeq INT DEFAULT 1;
    DECLARE v_tokenNum VARCHAR(20);

    -- Get Process Prefix
    SELECT Prefix INTO v_prefix FROM Process WHERE Id = p_ProcessId AND IsDeleted = 0 LIMIT 1;
    IF v_prefix IS NULL THEN SET v_prefix = 'A'; END IF;

    -- Calculate today's next sequence for process
    SELECT COALESCE(MAX(CAST(SUBSTRING_INDEX(TokenNumber, '-', -1) AS UNSIGNED)), 0) + 1 INTO v_nextSeq
    FROM TokenTransaction
    WHERE ProcessId = p_ProcessId 
      AND DATE(IssuedTime) = CURRENT_DATE();

    SET v_tokenNum = CONCAT(v_prefix, '-', LPAD(v_nextSeq, 3, '0'));

    -- Insert Token
    INSERT INTO TokenTransaction (
        TokenNumber, OrganizationId, LocationId, AreaId, ProcessId, PriorityTier, TokenStatus,
        CustomerName, CustomerPhone, IssuedTime, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
    ) VALUES (
        v_tokenNum, p_OrganizationId, p_LocationId, p_AreaId, p_ProcessId, COALESCE(p_PriorityTier, 19001), 18001,
        TRIM(p_CustomerName), TRIM(p_CustomerPhone), CURRENT_TIMESTAMP, p_UID, CURRENT_TIMESTAMP, p_UID, CURRENT_TIMESTAMP, 0
    );

    SELECT LAST_INSERT_ID() AS ID, 0 AS ErrNo, 1 AS RowsCount, 'Token issued successfully' AS ErrMsg, v_tokenNum AS TokenNumber;
END //

-- ============================================================================
-- STORED PROCEDURE: CALL NEXT TOKEN (Counter Operator)
-- High-priority tokens (VIP, Emergency, Senior) called first
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_IU_CallNextToken //
CREATE PROCEDURE PR_IU_CallNextToken (
    IN p_OrganizationId INT,
    IN p_LocationId     INT,
    IN p_CounterId      INT,
    IN p_ProcessId      INT,
    IN p_UserId         INT
)
proc_body: BEGIN
    DECLARE v_tokenId INT DEFAULT 0;
    DECLARE v_tokenNum VARCHAR(20) DEFAULT '';

    -- Find next waiting token ordered by PriorityTier DESC, IssuedTime ASC
    SELECT Id, TokenNumber INTO v_tokenId, v_tokenNum
    FROM TokenTransaction
    WHERE OrganizationId = p_OrganizationId 
      AND LocationId = p_LocationId
      AND ProcessId = p_ProcessId
      AND TokenStatus IN (18001, 18002) -- Queued or Waiting
      AND IsDeleted = 0
    ORDER BY PriorityTier DESC, IssuedTime ASC
    LIMIT 1;

    IF v_tokenId > 0 THEN
        UPDATE TokenTransaction
        SET TokenStatus  = 18003, -- Calling
            CounterId    = p_CounterId,
            UserId       = p_UserId,
            CalledTime   = CURRENT_TIMESTAMP,
            ModifiedBy   = p_UserId,
            ModifiedDate = CURRENT_TIMESTAMP
        WHERE Id = v_tokenId;

        -- Audit log entry
        INSERT INTO TokenAuditLog (TokenId, PreviousStatus, NewStatus, ActionByUserId, ActionTime, ActionReason)
        VALUES (v_tokenId, 18001, 18003, p_UserId, CURRENT_TIMESTAMP, 'Token called by counter operator');

        SELECT v_tokenId AS ID, 0 AS ErrNo, 1 AS RowsCount, 'Next token called' AS ErrMsg, v_tokenNum AS TokenNumber;
    ELSE
        SELECT 0 AS ID, 100 AS ErrNo, 0 AS RowsCount, 'No tokens currently waiting in queue' AS ErrMsg, '' AS TokenNumber;
    END IF;
END //

-- ============================================================================
-- STORED PROCEDURE: UPDATE TOKEN STATUS (Active, Hold, Complete, Cancel, Forward)
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_IU_UpdateTokenStatus //
CREATE PROCEDURE PR_IU_UpdateTokenStatus (
    IN p_TokenId     INT,
    IN p_NewStatus   INT, -- 18004: Active, 18005: Hold, 18006: Canceled, 18007: Completed, 18008: Forwarded
    IN p_Reason      VARCHAR(250),
    IN p_UserId      INT
)
proc_body: BEGIN
    DECLARE v_oldStatus INT DEFAULT 18001;

    SELECT TokenStatus INTO v_oldStatus FROM TokenTransaction WHERE Id = p_TokenId AND IsDeleted = 0;

    UPDATE TokenTransaction
    SET TokenStatus   = p_NewStatus,
        ServedTime    = CASE WHEN p_NewStatus = 18004 AND ServedTime IS NULL THEN CURRENT_TIMESTAMP ELSE ServedTime END,
        CompletedTime = CASE WHEN p_NewStatus IN (18006, 18007) THEN CURRENT_TIMESTAMP ELSE CompletedTime END,
        Notes         = COALESCE(p_Reason, Notes),
        ModifiedBy    = p_UserId,
        ModifiedDate  = CURRENT_TIMESTAMP
    WHERE Id = p_TokenId AND IsDeleted = 0;

    INSERT INTO TokenAuditLog (TokenId, PreviousStatus, NewStatus, ActionByUserId, ActionTime, ActionReason)
    VALUES (p_TokenId, v_oldStatus, p_NewStatus, p_UserId, CURRENT_TIMESTAMP, TRIM(p_Reason));

    SELECT p_TokenId AS ID, 0 AS ErrNo, 1 AS RowsCount, 'Token status updated' AS ErrMsg;
END //

-- ============================================================================
-- STORED PROCEDURE: GET OPERATOR QUEUE & DAILY COUNTER METRICS
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_S_TokenQueue //
CREATE PROCEDURE PR_S_TokenQueue (
    IN p_OrganizationId INT,
    IN p_LocationId     INT,
    IN p_ProcessId      INT,
    IN p_CounterId      INT
)
BEGIN
    -- Active / Called Token for this Counter
    SELECT * FROM TokenTransaction
    WHERE OrganizationId = p_OrganizationId
      AND LocationId = p_LocationId
      AND CounterId = p_CounterId
      AND TokenStatus IN (18003, 18004, 18005) -- Calling, Active, Hold
      AND IsDeleted = 0
    ORDER BY ModifiedDate DESC;

    -- Waiting Queue List for Process
    SELECT * FROM TokenTransaction
    WHERE OrganizationId = p_OrganizationId
      AND LocationId = p_LocationId
      AND (COALESCE(p_ProcessId, -1) = -1 OR ProcessId = p_ProcessId)
      AND TokenStatus IN (18001, 18002) -- Queued, Waiting
      AND IsDeleted = 0
    ORDER BY PriorityTier DESC, IssuedTime ASC;
END //

DELIMITER ;
