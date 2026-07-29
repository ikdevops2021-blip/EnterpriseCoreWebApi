-- ============================================================================================
-- DQMS STAGE 3: CUSTOMER & PUBLIC DISPLAY MANAGEMENT (MySQL)
-- Script Number: 34_DQMS_Customer_Display.sql
-- Description: Overhead display queries, mobile web tracking, and WhatsApp threshold trigger.
-- ============================================================================================

-- 1. Display TV Session Tracking Table
CREATE TABLE IF NOT EXISTS `DisplaySession` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `OrganizationId` INT NOT NULL,
    `LocationId` INT NOT NULL,
    `TemplateId` INT NOT NULL,
    `IpAddress` VARCHAR(45) NULL,
    `DeviceName` VARCHAR(100) NULL,
    `LastPulseTime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Customer Notification Outbox Queue Table
CREATE TABLE IF NOT EXISTS `CustomerNotificationQueue` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `TokenId` INT NOT NULL,
    `CustomerPhone` VARCHAR(20) NOT NULL,
    `MessageText` VARCHAR(500) NOT NULL,
    `NotificationType` INT NOT NULL DEFAULT 1 COMMENT '1: WhatsApp, 2: SMS',
    `Status` INT NOT NULL DEFAULT 0 COMMENT '0: Pending, 1: Sent, 2: Failed',
    `SentTime` DATETIME NULL,
    `RetryCount` INT NOT NULL DEFAULT 0,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `IX_Notif_Status` (`Status`, `CreatedDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DELIMITER //

-- ============================================================================
-- STORED PROCEDURE: PUBLIC OVERHEAD TV DISPLAY BOARD DATA
-- Returns Now Calling tokens (with flash flag) & Active Counters list
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_S_PublicDisplayBoard //
CREATE PROCEDURE PR_S_PublicDisplayBoard (
    IN p_OrganizationId INT,
    IN p_LocationId     INT,
    IN p_AreaId         INT
)
BEGIN
    -- 1. Now Calling / Flash Alert Tokens (Called in last 3 minutes)
    SELECT 
        T.Id,
        T.TokenNumber,
        T.ProcessId,
        P.ProcessName,
        P.Prefix,
        T.CounterId,
        C.CounterNumber,
        C.CounterName,
        T.TokenStatus,
        T.CalledTime,
        CASE WHEN TIMESTAMPDIFF(SECOND, T.CalledTime, CURRENT_TIMESTAMP) <= 30 THEN 1 ELSE 0 END AS FlashAlert
    FROM TokenTransaction T
    INNER JOIN Process P ON T.ProcessId = P.Id
    INNER JOIN Counter C ON T.CounterId = C.Id
    WHERE T.OrganizationId = p_OrganizationId
      AND T.LocationId = p_LocationId
      AND (COALESCE(p_AreaId, -1) = -1 OR T.AreaId = p_AreaId)
      AND T.TokenStatus IN (18003, 18004) -- Calling, Active
      AND T.IsDeleted = 0
    ORDER BY T.CalledTime DESC;

    -- 2. Currently Waiting Count Summary per Process
    SELECT 
        P.Id AS ProcessId,
        P.ProcessName,
        P.Prefix,
        COUNT(T.Id) AS WaitingCount
    FROM Process P
    LEFT JOIN TokenTransaction T ON P.Id = T.ProcessId AND T.TokenStatus IN (18001, 18002) AND T.IsDeleted = 0
    WHERE P.OrganizationId = p_OrganizationId AND P.IsActive = 1 AND P.IsDeleted = 0
    GROUP BY P.Id, P.ProcessName, P.Prefix
    ORDER BY P.ProcessName ASC;
END //

-- ============================================================================
-- STORED PROCEDURE: PUBLIC MOBILE WEB TOKEN STATUS TRACKER
-- Allows customer to view live position in queue
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_S_PublicTokenStatus //
CREATE PROCEDURE PR_S_PublicTokenStatus (
    IN p_TokenId INT
)
BEGIN
    DECLARE v_processId INT DEFAULT 0;
    DECLARE v_issuedTime DATETIME;
    DECLARE v_priority INT DEFAULT 19001;
    DECLARE v_status INT DEFAULT 18001;
    DECLARE v_aheadCount INT DEFAULT 0;
    DECLARE v_targetTAT INT DEFAULT 15;

    SELECT ProcessId, IssuedTime, PriorityTier, TokenStatus
    INTO v_processId, v_issuedTime, v_priority, v_status
    FROM TokenTransaction
    WHERE Id = p_TokenId AND IsDeleted = 0;

    IF v_processId > 0 THEN
        SELECT TargetTATMinutes INTO v_targetTAT FROM Process WHERE Id = v_processId;

        -- Calculate number of waiting customers ahead
        SELECT COUNT(Id) INTO v_aheadCount
        FROM TokenTransaction
        WHERE ProcessId = v_processId
          AND TokenStatus IN (18001, 18002)
          AND IsDeleted = 0
          AND (PriorityTier > v_priority OR (PriorityTier = v_priority AND IssuedTime < v_issuedTime));

        SELECT 
            T.Id,
            T.TokenNumber,
            P.ProcessName,
            T.TokenStatus,
            v_aheadCount AS CustomersAhead,
            (v_aheadCount + 1) * COALESCE(v_targetTAT, 15) AS EstimatedWaitMinutes,
            C.CounterNumber,
            C.CounterName
        FROM TokenTransaction T
        INNER JOIN Process P ON T.ProcessId = P.Id
        LEFT JOIN Counter C ON T.CounterId = C.Id
        WHERE T.Id = p_TokenId;
    END IF;
END //

DELIMITER ;
