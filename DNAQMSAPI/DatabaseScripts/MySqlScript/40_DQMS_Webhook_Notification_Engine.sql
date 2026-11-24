-- ============================================================================================
-- DQMS STAGE 4: WEBHOOK NOTIFICATION ENGINE (MySQL 8.0)
-- Script Number: 40_DQMS_Webhook_Notification_Engine.sql
-- Description: Creates WebhookSubscription and WebhookDeliveryLog tables, indexes,
--              stored procedures (PR_IU_WebhookSubscription, PR_S_WebhookSubscriptions,
--              PR_D_WebhookSubscription, PR_IU_WebhookDeliveryLog, PR_S_WebhookDeliveryLogs),
--              and seeds NavigationMenu for '/admin/webhooks'.
-- ============================================================================================

USE `dnaqms`;

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;

-- ============================================================================
-- 1. Table: WebhookSubscription
-- ============================================================================
CREATE TABLE IF NOT EXISTS `WebhookSubscription` (
    `Id`                  INT AUTO_INCREMENT PRIMARY KEY,
    `OrganizationId`      INT NOT NULL,
    `LocationId`          INT NULL,
    `Name`                VARCHAR(150) NOT NULL,
    `EndpointUrl`         VARCHAR(500) NOT NULL,
    `SecretKey`           VARCHAR(128) NOT NULL,
    `SubscribedEvents`    VARCHAR(255) NOT NULL,
    `IsActive`            TINYINT(1) NOT NULL DEFAULT 1,
    `MaxRetryAttempts`    INT NOT NULL DEFAULT 3,
    `TimeoutSeconds`      INT NOT NULL DEFAULT 10,
    `ConsecutiveFailures` INT NOT NULL DEFAULT 0,
    `CircuitBreakerUntil` DATETIME NULL,
    `CreatedBy`           INT NOT NULL DEFAULT 0,
    `CreatedDate`         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy`          INT NOT NULL DEFAULT 0,
    `ModifiedDate`        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `IsDeleted`           TINYINT(1) NOT NULL DEFAULT 0,
    `DeletedBy`           INT NULL,
    `DeletedDate`         DATETIME NULL,
    INDEX `IX_WebhookSubscription_ActiveLookup` (`OrganizationId`, `IsActive`, `IsDeleted`, `LocationId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- 2. Table: WebhookDeliveryLog
-- ============================================================================
CREATE TABLE IF NOT EXISTS `WebhookDeliveryLog` (
    `Id`                    BIGINT AUTO_INCREMENT PRIMARY KEY,
    `DeliveryId`            VARCHAR(64) NOT NULL,
    `WebhookSubscriptionId` INT NOT NULL,
    `OrganizationId`        INT NOT NULL,
    `EventCode`             VARCHAR(50) NOT NULL,
    `PayloadJson`           LONGTEXT NOT NULL,
    `ResponseStatusCode`    INT NULL,
    `ResponseBody`          VARCHAR(1000) NULL,
    `DurationMs`            INT NOT NULL DEFAULT 0,
    `AttemptCount`          INT NOT NULL DEFAULT 1,
    `DeliveryStatus`        VARCHAR(30) NOT NULL DEFAULT 'Success',
    `NextRetryTime`         DATETIME NULL,
    `CreatedDate`           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `IX_WebhookDeliveryLog_Lookup` (`WebhookSubscriptionId`, `CreatedDate` DESC),
    CONSTRAINT `FK_WebhookDeliveryLog_Subscription`
        FOREIGN KEY (`WebhookSubscriptionId`) REFERENCES `WebhookSubscription` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DELIMITER //

-- ============================================================================
-- 3. Stored Procedure: PR_IU_WebhookSubscription
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_IU_WebhookSubscription //
CREATE PROCEDURE PR_IU_WebhookSubscription (
    IN p_Id INT,
    IN p_OrganizationId INT,
    IN p_LocationId INT,
    IN p_Name VARCHAR(150),
    IN p_EndpointUrl VARCHAR(500),
    IN p_SecretKey VARCHAR(128),
    IN p_SubscribedEvents VARCHAR(255),
    IN p_IsActive TINYINT,
    IN p_MaxRetryAttempts INT,
    IN p_TimeoutSeconds INT,
    IN p_UserId INT
)
BEGIN
    IF (p_Id IS NULL OR p_Id <= 0) THEN
        INSERT INTO WebhookSubscription
        (
            OrganizationId, LocationId, Name, EndpointUrl, SecretKey,
            SubscribedEvents, IsActive, MaxRetryAttempts, TimeoutSeconds,
            ConsecutiveFailures, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
        )
        VALUES
        (
            p_OrganizationId, p_LocationId, p_Name, p_EndpointUrl, p_SecretKey,
            p_SubscribedEvents, COALESCE(p_IsActive, 1), COALESCE(p_MaxRetryAttempts, 3), COALESCE(p_TimeoutSeconds, 10),
            0, p_UserId, NOW(), p_UserId, NOW(), 0
        );

        SELECT LAST_INSERT_ID() AS NewId;
    ELSE
        UPDATE WebhookSubscription
        SET
            OrganizationId = p_OrganizationId,
            LocationId = p_LocationId,
            Name = p_Name,
            EndpointUrl = p_EndpointUrl,
            SecretKey = CASE WHEN p_SecretKey IS NOT NULL AND CHAR_LENGTH(p_SecretKey) > 0 THEN p_SecretKey ELSE SecretKey END,
            SubscribedEvents = p_SubscribedEvents,
            IsActive = COALESCE(p_IsActive, IsActive),
            MaxRetryAttempts = COALESCE(p_MaxRetryAttempts, MaxRetryAttempts),
            TimeoutSeconds = COALESCE(p_TimeoutSeconds, TimeoutSeconds),
            ModifiedBy = p_UserId,
            ModifiedDate = NOW()
        WHERE Id = p_Id AND IsDeleted = 0;

        SELECT p_Id AS NewId;
    END IF;
END //

-- ============================================================================
-- 4. Stored Procedure: PR_S_WebhookSubscriptions
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_S_WebhookSubscriptions //
CREATE PROCEDURE PR_S_WebhookSubscriptions (
    IN p_OrganizationId INT,
    IN p_LocationId INT,
    IN p_Id INT,
    IN p_IsActive INT
)
BEGIN
    SELECT
        s.Id,
        s.OrganizationId,
        s.LocationId,
        s.Name,
        s.EndpointUrl,
        s.SecretKey,
        s.SubscribedEvents,
        s.IsActive,
        s.MaxRetryAttempts,
        s.TimeoutSeconds,
        s.ConsecutiveFailures,
        s.CircuitBreakerUntil,
        s.CreatedBy,
        s.CreatedDate,
        s.ModifiedBy,
        s.ModifiedDate,
        (
            SELECT l.DeliveryStatus
            FROM WebhookDeliveryLog l
            WHERE l.WebhookSubscriptionId = s.Id
            ORDER BY l.CreatedDate DESC
            LIMIT 1
        ) AS LastDeliveryStatus,
        (
            SELECT l.ResponseStatusCode
            FROM WebhookDeliveryLog l
            WHERE l.WebhookSubscriptionId = s.Id
            ORDER BY l.CreatedDate DESC
            LIMIT 1
        ) AS LastResponseStatusCode,
        (
            SELECT l.CreatedDate
            FROM WebhookDeliveryLog l
            WHERE l.WebhookSubscriptionId = s.Id
            ORDER BY l.CreatedDate DESC
            LIMIT 1
        ) AS LastDeliveryDate
    FROM WebhookSubscription s
    WHERE s.IsDeleted = 0
      AND (COALESCE(p_Id, -1) = -1 OR s.Id = p_Id)
      AND (COALESCE(p_OrganizationId, -1) = -1 OR s.OrganizationId = p_OrganizationId)
      AND (COALESCE(p_LocationId, -1) = -1 OR s.LocationId IS NULL OR s.LocationId = p_LocationId)
      AND (COALESCE(p_IsActive, -1) = -1 OR s.IsActive = p_IsActive)
    ORDER BY s.CreatedDate DESC;
END //

-- ============================================================================
-- 5. Stored Procedure: PR_D_WebhookSubscription
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_D_WebhookSubscription //
CREATE PROCEDURE PR_D_WebhookSubscription (
    IN p_Id INT,
    IN p_UserId INT
)
BEGIN
    UPDATE WebhookSubscription
    SET
        IsDeleted = 1,
        DeletedBy = p_UserId,
        DeletedDate = NOW()
    WHERE Id = p_Id;

    SELECT ROW_COUNT() AS RowsAffected;
END //

-- ============================================================================
-- 6. Stored Procedure: PR_IU_WebhookDeliveryLog
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_IU_WebhookDeliveryLog //
CREATE PROCEDURE PR_IU_WebhookDeliveryLog (
    IN p_DeliveryId VARCHAR(64),
    IN p_WebhookSubscriptionId INT,
    IN p_OrganizationId INT,
    IN p_EventCode VARCHAR(50),
    IN p_PayloadJson LONGTEXT,
    IN p_ResponseStatusCode INT,
    IN p_ResponseBody VARCHAR(1000),
    IN p_DurationMs INT,
    IN p_AttemptCount INT,
    IN p_DeliveryStatus VARCHAR(30),
    IN p_NextRetryTime DATETIME
)
BEGIN
    INSERT INTO WebhookDeliveryLog
    (
        DeliveryId, WebhookSubscriptionId, OrganizationId, EventCode,
        PayloadJson, ResponseStatusCode, ResponseBody, DurationMs,
        AttemptCount, DeliveryStatus, NextRetryTime, CreatedDate
    )
    VALUES
    (
        p_DeliveryId, p_WebhookSubscriptionId, p_OrganizationId, p_EventCode,
        p_PayloadJson, p_ResponseStatusCode, p_ResponseBody, COALESCE(p_DurationMs, 0),
        COALESCE(p_AttemptCount, 1), COALESCE(p_DeliveryStatus, 'Success'), p_NextRetryTime, NOW()
    );

    IF (p_DeliveryStatus = 'Success') THEN
        UPDATE WebhookSubscription
        SET ConsecutiveFailures = 0,
            CircuitBreakerUntil = NULL
        WHERE Id = p_WebhookSubscriptionId;
    ELSE
        UPDATE WebhookSubscription
        SET ConsecutiveFailures = ConsecutiveFailures + 1,
            CircuitBreakerUntil = CASE 
                WHEN ConsecutiveFailures + 1 >= 10 THEN DATE_ADD(NOW(), INTERVAL 15 MINUTE) 
                ELSE CircuitBreakerUntil 
            END
        WHERE Id = p_WebhookSubscriptionId;
    END IF;

    SELECT LAST_INSERT_ID() AS LogId;
END //

-- ============================================================================
-- 7. Stored Procedure: PR_S_WebhookDeliveryLogs
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_S_WebhookDeliveryLogs //
CREATE PROCEDURE PR_S_WebhookDeliveryLogs (
    IN p_WebhookSubscriptionId INT,
    IN p_OrganizationId INT,
    IN p_DeliveryStatus VARCHAR(30),
    IN p_PageNumber INT,
    IN p_PageSize INT
)
BEGIN
    DECLARE v_Offset INT;
    SET v_Offset = (COALESCE(p_PageNumber, 1) - 1) * COALESCE(p_PageSize, 50);

    SELECT
        l.Id,
        l.DeliveryId,
        l.WebhookSubscriptionId,
        s.Name AS SubscriptionName,
        l.OrganizationId,
        l.EventCode,
        l.PayloadJson,
        l.ResponseStatusCode,
        l.ResponseBody,
        l.DurationMs,
        l.AttemptCount,
        l.DeliveryStatus,
        l.NextRetryTime,
        l.CreatedDate
    FROM WebhookDeliveryLog l
    INNER JOIN WebhookSubscription s ON l.WebhookSubscriptionId = s.Id
    WHERE (COALESCE(p_WebhookSubscriptionId, -1) = -1 OR l.WebhookSubscriptionId = p_WebhookSubscriptionId)
      AND (COALESCE(p_OrganizationId, -1) = -1 OR l.OrganizationId = p_OrganizationId)
      AND (p_DeliveryStatus IS NULL OR l.DeliveryStatus = p_DeliveryStatus)
    ORDER BY l.CreatedDate DESC
    LIMIT v_Offset, p_PageSize;
END //

DELIMITER ;

-- ============================================================================
-- 8. Seed NavigationMenu Entry: /admin/webhooks
-- ============================================================================
INSERT INTO `NavigationMenu`
(
    `Title`, `IconName`, `RoutePath`, `SortOrder`, `ParentId`, `RequiredPermission`,
    `IsActive`, `CreatedBy`, `CreatedDate`, `ModifiedBy`, `ModifiedDate`, `IsDeleted`
)
SELECT 'Webhook Integrations', 'webhook_rounded', '/admin/webhooks', 15, NULL, 'Admin', 1, 1, NOW(), 1, NOW(), 0
WHERE NOT EXISTS (
    SELECT 1 FROM `NavigationMenu` WHERE `RoutePath` = '/admin/webhooks'
);
