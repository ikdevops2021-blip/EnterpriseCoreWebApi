-- ============================================================================================
-- DQMS STAGE 4: DIGITAL SIGNAGE CAMPAIGNS & EMERGENCY PUBLIC BROADCAST ENGINE (MySQL)
-- Script Number: 42_DQMS_Digital_Signage_Emergency_Broadcast.sql
-- Description: Rich media video/image campaigns, time-slot scheduling, and real-time emergency broadcast overlay.
-- ============================================================================================

-- 1. SignageCampaign Table
CREATE TABLE IF NOT EXISTS `SignageCampaign` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `OrganizationId` INT NOT NULL,
    `CampaignName` VARCHAR(150) NOT NULL,
    `CampaignType` INT NOT NULL DEFAULT 1,
    `Priority` INT NOT NULL DEFAULT 5,
    `StartDate` DATETIME NOT NULL,
    `EndDate` DATETIME NOT NULL,
    `DailyStartTime` TIME NULL,
    `DailyEndTime` TIME NULL,
    `DaysOfWeek` VARCHAR(30) NOT NULL DEFAULT '1,2,3,4,5,6,7',
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy` INT NOT NULL DEFAULT 1,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy` INT NOT NULL DEFAULT 1,
    `ModifiedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `IsDeleted` TINYINT(1) NOT NULL DEFAULT 0,
    INDEX `IX_SignageCampaign_Org_Active` (`OrganizationId`, `IsActive`, `IsDeleted`, `StartDate`, `EndDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. SignageMediaItem Table
CREATE TABLE IF NOT EXISTS `SignageMediaItem` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `CampaignId` INT NOT NULL,
    `MediaType` INT NOT NULL DEFAULT 1,
    `MediaUrl` VARCHAR(500) NOT NULL,
    `LocalCachePath` VARCHAR(500) NULL,
    `Title` VARCHAR(150) NOT NULL,
    `DurationSeconds` INT NOT NULL DEFAULT 15,
    `DisplayOrder` INT NOT NULL DEFAULT 1,
    `MuteAudio` TINYINT(1) NOT NULL DEFAULT 1,
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `FK_SignageMediaItem_Campaign` FOREIGN KEY (`CampaignId`) 
        REFERENCES `SignageCampaign`(`Id`) ON DELETE CASCADE,
    INDEX `IX_SignageMediaItem_Campaign` (`CampaignId`, `DisplayOrder`, `IsActive`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. SignageCampaignMapping Table
CREATE TABLE IF NOT EXISTS `SignageCampaignMapping` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `CampaignId` INT NOT NULL,
    `OrganizationId` INT NOT NULL,
    `LocationId` INT NOT NULL,
    `AreaId` INT NULL,
    `TemplateId` INT NULL,
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `FK_SignageCampaignMapping_Campaign` FOREIGN KEY (`CampaignId`) 
        REFERENCES `SignageCampaign`(`Id`) ON DELETE CASCADE,
    INDEX `IX_SignageCampaignMapping_Loc` (`OrganizationId`, `LocationId`, `AreaId`, `IsActive`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. EmergencyBroadcast Table
CREATE TABLE IF NOT EXISTS `EmergencyBroadcast` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `OrganizationId` INT NOT NULL,
    `LocationId` INT NULL,
    `AreaId` INT NULL,
    `BroadcastCode` VARCHAR(50) NOT NULL,
    `Title` VARCHAR(150) NOT NULL,
    `MessageText` VARCHAR(1000) NOT NULL,
    `Severity` INT NOT NULL DEFAULT 3,
    `AudioSirenType` INT NOT NULL DEFAULT 1,
    `FlashColorHex` VARCHAR(10) NOT NULL DEFAULT '#FF1744',
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    `TriggeredByUserId` INT NOT NULL,
    `TriggeredAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `DismissedByUserId` INT NULL,
    `DismissedAt` DATETIME NULL,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `IX_EmergencyBroadcast_Active` (`OrganizationId`, `LocationId`, `IsActive`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- STORED PROCEDURE: INSERT / UPDATE SIGNAGE CAMPAIGN (MySQL)
-- ============================================================================
DROP PROCEDURE IF EXISTS `PR_IU_SignageCampaign`;
DELIMITER $$
CREATE PROCEDURE `PR_IU_SignageCampaign`(
    IN `p_Id` INT,
    IN `p_OrganizationId` INT,
    IN `p_CampaignName` VARCHAR(150),
    IN `p_CampaignType` INT,
    IN `p_Priority` INT,
    IN `p_StartDate` DATETIME,
    IN `p_EndDate` DATETIME,
    IN `p_DailyStartTime` TIME,
    IN `p_DailyEndTime` TIME,
    IN `p_DaysOfWeek` VARCHAR(30),
    IN `p_LocationId` INT,
    IN `p_AreaId` INT,
    IN `p_IsActive` TINYINT(1),
    IN `p_UserId` INT
)
BEGIN
    DECLARE v_campaignId INT;
    SET v_campaignId = IFNULL(p_Id, 0);

    IF v_campaignId <= 0 THEN
        INSERT INTO `SignageCampaign` (
            `OrganizationId`, `CampaignName`, `CampaignType`, `Priority`,
            `StartDate`, `EndDate`, `DailyStartTime`, `DailyEndTime`, `DaysOfWeek`,
            `IsActive`, `CreatedBy`, `CreatedDate`, `ModifiedBy`, `ModifiedDate`, `IsDeleted`
        ) VALUES (
            p_OrganizationId, p_CampaignName, IFNULL(p_CampaignType, 1), IFNULL(p_Priority, 5),
            p_StartDate, p_EndDate, p_DailyStartTime, p_DailyEndTime, IFNULL(p_DaysOfWeek, '1,2,3,4,5,6,7'),
            IFNULL(p_IsActive, 1), IFNULL(p_UserId, 1), NOW(), IFNULL(p_UserId, 1), NOW(), 0
        );
        SET v_campaignId = LAST_INSERT_ID();

        IF IFNULL(p_LocationId, 0) > 0 THEN
            INSERT INTO `SignageCampaignMapping` (
                `CampaignId`, `OrganizationId`, `LocationId`, `AreaId`, `IsActive`, `CreatedDate`
            ) VALUES (
                v_campaignId, p_OrganizationId, p_LocationId, p_AreaId, 1, NOW()
            );
        END IF;
    ELSE
        UPDATE `SignageCampaign`
        SET `CampaignName` = p_CampaignName,
            `CampaignType` = IFNULL(p_CampaignType, `CampaignType`),
            `Priority` = IFNULL(p_Priority, `Priority`),
            `StartDate` = p_StartDate,
            `EndDate` = p_EndDate,
            `DailyStartTime` = p_DailyStartTime,
            `DailyEndTime` = p_DailyEndTime,
            `DaysOfWeek` = IFNULL(p_DaysOfWeek, `DaysOfWeek`),
            `IsActive` = IFNULL(p_IsActive, `IsActive`),
            `ModifiedBy` = IFNULL(p_UserId, 1),
            `ModifiedDate` = NOW()
        WHERE `Id` = v_campaignId AND `OrganizationId` = p_OrganizationId;

        IF IFNULL(p_LocationId, 0) > 0 THEN
            IF NOT EXISTS (SELECT 1 FROM `SignageCampaignMapping` WHERE `CampaignId` = v_campaignId AND `LocationId` = p_LocationId) THEN
                INSERT INTO `SignageCampaignMapping` (
                    `CampaignId`, `OrganizationId`, `LocationId`, `AreaId`, `IsActive`, `CreatedDate`
                ) VALUES (
                    v_campaignId, p_OrganizationId, p_LocationId, p_AreaId, 1, NOW()
                );
            END IF;
        END IF;
    END IF;

    SELECT v_campaignId AS `Id`, 0 AS `ErrNo`, 'Success' AS `ErrMsg`;
END$$
DELIMITER ;

-- ============================================================================
-- STORED PROCEDURE: GET ACTIVE SIGNAGE PLAYLIST FOR TV DISPLAY (MySQL)
-- ============================================================================
DROP PROCEDURE IF EXISTS `PR_S_ActiveSignagePlaylist`;
DELIMITER $$
CREATE PROCEDURE `PR_S_ActiveSignagePlaylist`(
    IN `p_OrganizationId` INT,
    IN `p_LocationId` INT,
    IN `p_AreaId` INT
)
BEGIN
    DECLARE v_now DATETIME;
    DECLARE v_currentTime TIME;
    DECLARE v_currentDayStr VARCHAR(2);

    SET v_now = NOW();
    SET v_currentTime = CURTIME();
    SET v_currentDayStr = CAST(DAYOFWEEK(v_now) AS CHAR);

    SELECT 
        M.`Id`,
        M.`CampaignId`,
        C.`CampaignName`,
        C.`CampaignType`,
        C.`Priority`,
        M.`MediaType`,
        M.`MediaUrl`,
        M.`LocalCachePath`,
        M.`Title`,
        M.`DurationSeconds`,
        M.`DisplayOrder`,
        M.`MuteAudio`
    FROM `SignageMediaItem` M
    INNER JOIN `SignageCampaign` C ON M.`CampaignId` = C.`Id`
    INNER JOIN `SignageCampaignMapping` MAP ON C.`Id` = MAP.`CampaignId`
    WHERE C.`OrganizationId` = p_OrganizationId
      AND C.`IsActive` = 1
      AND C.`IsDeleted` = 0
      AND M.`IsActive` = 1
      AND MAP.`IsActive` = 1
      AND MAP.`LocationId` = p_LocationId
      AND (MAP.`AreaId` IS NULL OR p_AreaId IS NULL OR MAP.`AreaId` = p_AreaId)
      AND v_now BETWEEN C.`StartDate` AND C.`EndDate`
      AND (C.`DailyStartTime` IS NULL OR v_currentTime >= C.`DailyStartTime`)
      AND (C.`DailyEndTime` IS NULL OR v_currentTime <= C.`DailyEndTime`)
      AND (C.`DaysOfWeek` LIKE CONCAT('%', v_currentDayStr, '%'))
    ORDER BY C.`Priority` DESC, M.`DisplayOrder` ASC;
END$$
DELIMITER ;

-- ============================================================================
-- STORED PROCEDURE: TRIGGER OR DISMISS EMERGENCY BROADCAST (MySQL)
-- ============================================================================
DROP PROCEDURE IF EXISTS `PR_IU_EmergencyBroadcast`;
DELIMITER $$
CREATE PROCEDURE `PR_IU_EmergencyBroadcast`(
    IN `p_Action` VARCHAR(20),
    IN `p_BroadcastId` INT,
    IN `p_OrganizationId` INT,
    IN `p_LocationId` INT,
    IN `p_AreaId` INT,
    IN `p_BroadcastCode` VARCHAR(50),
    IN `p_Title` VARCHAR(150),
    IN `p_MessageText` VARCHAR(1000),
    IN `p_Severity` INT,
    IN `p_AudioSirenType` INT,
    IN `p_FlashColorHex` VARCHAR(10),
    IN `p_UserId` INT
)
BEGIN
    DECLARE v_id INT;
    SET v_id = IFNULL(p_BroadcastId, 0);

    IF UPPER(p_Action) = 'TRIGGER' THEN
        -- Deactivate prior active alerts for this target location
        UPDATE `EmergencyBroadcast`
        SET `IsActive` = 0,
            `DismissedByUserId` = IFNULL(p_UserId, 1),
            `DismissedAt` = NOW()
        WHERE `OrganizationId` = p_OrganizationId
          AND `IsActive` = 1
          AND (`LocationId` IS NULL OR p_LocationId IS NULL OR `LocationId` = p_LocationId);

        INSERT INTO `EmergencyBroadcast` (
            `OrganizationId`, `LocationId`, `AreaId`, `BroadcastCode`, `Title`, `MessageText`,
            `Severity`, `AudioSirenType`, `FlashColorHex`, `IsActive`, `TriggeredByUserId`, `TriggeredAt`
        ) VALUES (
            p_OrganizationId, p_LocationId, p_AreaId, IFNULL(p_BroadcastCode, 'CODE_RED'),
            IFNULL(p_Title, 'EMERGENCY ALERT'), IFNULL(p_MessageText, ''),
            IFNULL(p_Severity, 3), IFNULL(p_AudioSirenType, 1), IFNULL(p_FlashColorHex, '#FF1744'),
            1, IFNULL(p_UserId, 1), NOW()
        );

        SET v_id = LAST_INSERT_ID();
        SELECT v_id AS `Id`, 0 AS `ErrNo`, 'Emergency broadcast triggered' AS `ErrMsg`;
    ELSEIF UPPER(p_Action) = 'DISMISS' THEN
        UPDATE `EmergencyBroadcast`
        SET `IsActive` = 0,
            `DismissedByUserId` = IFNULL(p_UserId, 1),
            `DismissedAt` = NOW()
        WHERE `OrganizationId` = p_OrganizationId
          AND (v_id <= 0 OR `Id` = v_id)
          AND `IsActive` = 1;

        SELECT v_id AS `Id`, 0 AS `ErrNo`, 'Emergency broadcast dismissed (ALL CLEAR)' AS `ErrMsg`;
    END IF;
END$$
DELIMITER ;

-- ============================================================================
-- STORED PROCEDURE: GET ACTIVE EMERGENCY BROADCAST (MySQL)
-- ============================================================================
DROP PROCEDURE IF EXISTS `PR_S_ActiveEmergencyBroadcast`;
DELIMITER $$
CREATE PROCEDURE `PR_S_ActiveEmergencyBroadcast`(
    IN `p_OrganizationId` INT,
    IN `p_LocationId` INT,
    IN `p_AreaId` INT
)
BEGIN
    SELECT 
        `Id`,
        `OrganizationId`,
        `LocationId`,
        `AreaId`,
        `BroadcastCode`,
        `Title`,
        `MessageText`,
        `Severity`,
        `AudioSirenType`,
        `FlashColorHex`,
        `IsActive`,
        `TriggeredByUserId`,
        `TriggeredAt`
    FROM `EmergencyBroadcast`
    WHERE `OrganizationId` = p_OrganizationId
      AND `IsActive` = 1
      AND (`LocationId` IS NULL OR p_LocationId IS NULL OR `LocationId` = p_LocationId)
      AND (`AreaId` IS NULL OR p_AreaId IS NULL OR `AreaId` = p_AreaId)
    ORDER BY `Severity` DESC, `TriggeredAt` DESC
    LIMIT 1;
END$$
DELIMITER ;

-- ============================================================================
-- SEED NAVIGATION MENU FOR DIGITAL SIGNAGE CAMPAIGNS (MySQL)
-- ============================================================================
INSERT INTO `NavigationMenu` (
    `ParentId`, `Title`, `RouteUrl`, `IconName`, `DisplayOrder`,
    `RequiredPermission`, `IsActive`, `CreatedBy`, `CreatedDate`, `ModifiedBy`, `ModifiedDate`, `IsDeleted`
)
SELECT 
    (SELECT `Id` FROM `NavigationMenu` WHERE `RouteUrl` = '/admin' OR `Title` LIKE '%Admin%' ORDER BY `Id` ASC LIMIT 1),
    'Signage & Broadcast', '/admin/signage-campaigns', 'campaign_rounded', 19,
    'ManageSignage', 1, 1, NOW(), 1, NOW(), 0
FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM `NavigationMenu` WHERE `RouteUrl` = '/admin/signage-campaigns'
);
