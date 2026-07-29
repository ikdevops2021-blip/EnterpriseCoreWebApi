-- ============================================================================================
-- DQMS STAGE 1: ADMIN MASTERS & CONFIGURATION TABLES (MySQL)
-- Script Number: 31_DQMS_Admin_Masters.sql
-- Description: Creates master tables and PR_S_* / PR_IU_* Stored Procedures following 
--              Core Web API enterprise conventions.
-- ============================================================================================

-- 1. Area / Zone Master Table
CREATE TABLE IF NOT EXISTS `Area` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `AreaCode` VARCHAR(50) NOT NULL,
    `OrganizationId` INT NOT NULL,
    `LocationId` INT NOT NULL,
    `AreaName` VARCHAR(100) NOT NULL,
    `Description` VARCHAR(250) NULL,
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy` INT NOT NULL,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy` INT NOT NULL,
    `ModifiedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted` TINYINT(1) NULL DEFAULT 0,
    `DeletedBy` INT NULL,
    `DeletedDate` DATETIME NULL,
    INDEX `IX_Area_Org_Loc` (`OrganizationId`, `LocationId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Counter / Station Master Table
CREATE TABLE IF NOT EXISTS `Counter` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `CounterCode` VARCHAR(50) NOT NULL,
    `OrganizationId` INT NOT NULL,
    `LocationId` INT NOT NULL,
    `AreaId` INT NOT NULL,
    `CounterNumber` VARCHAR(20) NOT NULL,
    `CounterName` VARCHAR(100) NOT NULL,
    `CurrentStatus` INT NOT NULL DEFAULT 0 COMMENT '0: Idle, 1: Serving, 2: Break, 3: Offline',
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy` INT NOT NULL,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy` INT NOT NULL,
    `ModifiedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted` TINYINT(1) NULL DEFAULT 0,
    `DeletedBy` INT NULL,
    `DeletedDate` DATETIME NULL,
    INDEX `IX_Counter_Area` (`AreaId`),
    INDEX `IX_Counter_Loc` (`OrganizationId`, `LocationId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Process Pipeline Master Table
CREATE TABLE IF NOT EXISTS `Process` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `ProcessCode` VARCHAR(50) NOT NULL,
    `OrganizationId` INT NOT NULL,
    `ProcessName` VARCHAR(100) NOT NULL,
    `Prefix` VARCHAR(5) NOT NULL DEFAULT 'A',
    `TargetTATMinutes` INT NOT NULL DEFAULT 15,
    `AllowSubTokens` TINYINT(1) NOT NULL DEFAULT 0,
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy` INT NOT NULL,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy` INT NOT NULL,
    `ModifiedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted` TINYINT(1) NULL DEFAULT 0,
    `DeletedBy` INT NULL,
    `DeletedDate` DATETIME NULL,
    INDEX `IX_Process_Org` (`OrganizationId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Process Multi-Level Steps Table
CREATE TABLE IF NOT EXISTS `ProcessStep` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `ProcessId` INT NOT NULL,
    `StepOrder` INT NOT NULL DEFAULT 1,
    `StepName` VARCHAR(100) NOT NULL,
    `TargetTATMinutes` INT NOT NULL DEFAULT 10,
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy` INT NOT NULL,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy` INT NOT NULL,
    `ModifiedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted` TINYINT(1) NULL DEFAULT 0,
    `DeletedBy` INT NULL,
    `DeletedDate` DATETIME NULL,
    INDEX `IX_ProcessStep_Proc` (`ProcessId`, `StepOrder`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Process Selective Blackout Days Table
CREATE TABLE IF NOT EXISTS `ProcessBlackoutDay` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `OrganizationId` INT NOT NULL,
    `LocationId` INT NOT NULL,
    `ProcessId` INT NOT NULL,
    `DayOfWeek` INT NOT NULL COMMENT '0: Sunday, 1: Monday ... 6: Saturday',
    `Reason` VARCHAR(250) NULL,
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy` INT NOT NULL,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy` INT NOT NULL,
    `ModifiedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted` TINYINT(1) NULL DEFAULT 0,
    `DeletedBy` INT NULL,
    `DeletedDate` DATETIME NULL,
    INDEX `IX_Blackout_ProcDay` (`ProcessId`, `DayOfWeek`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. Display Template Master Table
CREATE TABLE IF NOT EXISTS `DisplayTemplate` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `OrganizationId` INT NOT NULL,
    `TemplateName` VARCHAR(100) NOT NULL,
    `TemplateType` INT NOT NULL DEFAULT 1 COMMENT '1: GridView, 2: SplitScreenVideo, 3: HighDensityList',
    `LayoutConfigJson` TEXT NULL,
    `IsDefault` TINYINT(1) NOT NULL DEFAULT 0,
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy` INT NOT NULL,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy` INT NOT NULL,
    `ModifiedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted` TINYINT(1) NULL DEFAULT 0,
    `DeletedBy` INT NULL,
    `DeletedDate` DATETIME NULL,
    INDEX `IX_DisplayTemplate_Org` (`OrganizationId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. Process-to-Display Template Mapping Table
CREATE TABLE IF NOT EXISTS `ProcessDisplayMapping` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `OrganizationId` INT NOT NULL,
    `LocationId` INT NOT NULL,
    `AreaId` INT NULL,
    `ProcessId` INT NOT NULL,
    `TemplateId` INT NOT NULL,
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy` INT NOT NULL,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy` INT NOT NULL,
    `ModifiedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted` TINYINT(1) NULL DEFAULT 0,
    `DeletedBy` INT NULL,
    `DeletedDate` DATETIME NULL,
    INDEX `IX_Mapping_Lookup` (`LocationId`, `AreaId`, `ProcessId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. User Counter & Process Assignment Table
CREATE TABLE IF NOT EXISTS `UserCounterAssignment` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `OrganizationId` INT NOT NULL,
    `UserId` INT NOT NULL,
    `CounterId` INT NOT NULL,
    `ProcessId` INT NOT NULL,
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy` INT NOT NULL,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy` INT NOT NULL,
    `ModifiedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted` TINYINT(1) NULL DEFAULT 0,
    `DeletedBy` INT NULL,
    `DeletedDate` DATETIME NULL,
    INDEX `IX_UserCounter` (`UserId`, `CounterId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 9. Notification & WhatsApp Lead Threshold Config Table
CREATE TABLE IF NOT EXISTS `NotificationConfig` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `OrganizationId` INT NOT NULL,
    `LocationId` INT NOT NULL,
    `NotifyBeforePositions` INT NOT NULL DEFAULT 3,
    `EnableWhatsApp` TINYINT(1) NOT NULL DEFAULT 1,
    `EnableSms` TINYINT(1) NOT NULL DEFAULT 0,
    `WhatsAppApiKey` VARCHAR(255) NULL,
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy` INT NOT NULL,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy` INT NOT NULL,
    `ModifiedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted` TINYINT(1) NULL DEFAULT 0,
    `DeletedBy` INT NULL,
    `DeletedDate` DATETIME NULL,
    INDEX `IX_NotifConfig` (`OrganizationId`, `LocationId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DELIMITER //

-- ============================================================================
-- STORED PROCEDURES FOR AREA
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_S_Area //
CREATE PROCEDURE PR_S_Area (
    IN p_Id             INT,
    IN p_OrganizationId INT,
    IN p_LocationId     INT,
    IN p_IsActive       SMALLINT
)
BEGIN
    SELECT * FROM Area
    WHERE IsDeleted = 0
      AND (COALESCE(p_Id, -1) = -1 OR Id = p_Id)
      AND (COALESCE(p_OrganizationId, -1) = -1 OR OrganizationId = p_OrganizationId)
      AND (COALESCE(p_LocationId, -1) = -1 OR LocationId = p_LocationId)
      AND (COALESCE(p_IsActive, -1) NOT IN (0, 1) OR IsActive = p_IsActive)
    ORDER BY AreaName ASC;
END //

DROP PROCEDURE IF EXISTS PR_IU_Area (
    IN p_Id             INT,
    IN p_AreaCode       VARCHAR(50),
    IN p_OrganizationId INT,
    IN p_LocationId     INT,
    IN p_AreaName       VARCHAR(100),
    IN p_Description    VARCHAR(250),
    IN p_IsActive       TINYINT(1),
    IN p_UID            INT
) //
CREATE PROCEDURE PR_IU_Area (
    IN p_Id             INT,
    IN p_AreaCode       VARCHAR(50),
    IN p_OrganizationId INT,
    IN p_LocationId     INT,
    IN p_AreaName       VARCHAR(100),
    IN p_Description    VARCHAR(250),
    IN p_IsActive       TINYINT(1),
    IN p_UID            INT
)
proc_body: BEGIN
    DECLARE v_err INT DEFAULT 0;
    DECLARE v_rowscount INT DEFAULT 0;
    DECLARE v_errMsg VARCHAR(300) DEFAULT '';
    DECLARE v_errLine INT DEFAULT 0;
    DECLARE v_duplicateID INT DEFAULT 0;

    IF EXISTS(SELECT 1 FROM Area WHERE OrganizationId = p_OrganizationId AND LocationId = p_LocationId AND AreaName = TRIM(p_AreaName) AND IsDeleted = 0 AND (COALESCE(p_Id, 0) <= 0 OR Id <> p_Id)) THEN
        SELECT Id INTO v_duplicateID FROM Area WHERE OrganizationId = p_OrganizationId AND LocationId = p_LocationId AND AreaName = TRIM(p_AreaName) AND IsDeleted = 0 AND (COALESCE(p_Id, 0) <= 0 OR Id <> p_Id) LIMIT 1;
        SET v_err = 51;
        SET v_errMsg = CONCAT('Duplicate Area Name! Already exists with ID ', v_duplicateID);
        LEAVE proc_body;
    END IF;

    IF COALESCE(p_Id, 0) <= 0 THEN
        INSERT INTO Area (
            AreaCode, OrganizationId, LocationId, AreaName, Description, IsActive,
            CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
        ) VALUES (
            TRIM(p_AreaCode), p_OrganizationId, p_LocationId, TRIM(p_AreaName), TRIM(p_Description), COALESCE(p_IsActive, 1),
            p_UID, CURRENT_TIMESTAMP, p_UID, CURRENT_TIMESTAMP, 0
        );
        SET p_Id = LAST_INSERT_ID();
        SET v_rowscount = ROW_COUNT();
    ELSE
        UPDATE Area
        SET AreaCode     = TRIM(p_AreaCode),
            AreaName     = TRIM(p_AreaName),
            Description  = TRIM(p_Description),
            IsActive     = COALESCE(p_IsActive, IsActive),
            ModifiedBy   = p_UID,
            ModifiedDate = CURRENT_TIMESTAMP
        WHERE Id = p_Id AND IsDeleted = 0;
        SET v_rowscount = ROW_COUNT();
    END IF;

    SELECT COALESCE(p_Id, 0) AS ID, COALESCE(v_err, 0) AS ErrNo, COALESCE(v_rowscount, 0) AS RowsCount, COALESCE(v_errMsg, '') AS ErrMsg, COALESCE(v_errLine, 0) AS ErrLine;
END //

-- ============================================================================
-- STORED PROCEDURES FOR PROCESS
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_S_Process //
CREATE PROCEDURE PR_S_Process (
    IN p_Id             INT,
    IN p_OrganizationId INT,
    IN p_IsActive       SMALLINT
)
BEGIN
    SELECT * FROM Process
    WHERE IsDeleted = 0
      AND (COALESCE(p_Id, -1) = -1 OR Id = p_Id)
      AND (COALESCE(p_OrganizationId, -1) = -1 OR OrganizationId = p_OrganizationId)
      AND (COALESCE(p_IsActive, -1) NOT IN (0, 1) OR IsActive = p_IsActive)
    ORDER BY ProcessName ASC;
END //

DROP PROCEDURE IF EXISTS PR_IU_Process //
CREATE PROCEDURE PR_IU_Process (
    IN p_Id               INT,
    IN p_ProcessCode      VARCHAR(50),
    IN p_OrganizationId   INT,
    IN p_ProcessName      VARCHAR(100),
    IN p_Prefix           VARCHAR(5),
    IN p_TargetTATMinutes INT,
    IN p_AllowSubTokens   TINYINT(1),
    IN p_IsActive         TINYINT(1),
    IN p_UID              INT
)
proc_body: BEGIN
    DECLARE v_err INT DEFAULT 0;
    DECLARE v_rowscount INT DEFAULT 0;
    DECLARE v_errMsg VARCHAR(300) DEFAULT '';
    DECLARE v_errLine INT DEFAULT 0;
    DECLARE v_duplicateID INT DEFAULT 0;

    IF EXISTS(SELECT 1 FROM Process WHERE OrganizationId = p_OrganizationId AND ProcessName = TRIM(p_ProcessName) AND IsDeleted = 0 AND (COALESCE(p_Id, 0) <= 0 OR Id <> p_Id)) THEN
        SELECT Id INTO v_duplicateID FROM Process WHERE OrganizationId = p_OrganizationId AND ProcessName = TRIM(p_ProcessName) AND IsDeleted = 0 AND (COALESCE(p_Id, 0) <= 0 OR Id <> p_Id) LIMIT 1;
        SET v_err = 51;
        SET v_errMsg = CONCAT('Duplicate Process Name! Already exists with ID ', v_duplicateID);
        LEAVE proc_body;
    END IF;

    IF COALESCE(p_Id, 0) <= 0 THEN
        INSERT INTO Process (
            ProcessCode, OrganizationId, ProcessName, Prefix, TargetTATMinutes, AllowSubTokens, IsActive,
            CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
        ) VALUES (
            TRIM(p_ProcessCode), p_OrganizationId, TRIM(p_ProcessName), UPPER(TRIM(p_Prefix)), COALESCE(p_TargetTATMinutes, 15), COALESCE(p_AllowSubTokens, 0), COALESCE(p_IsActive, 1),
            p_UID, CURRENT_TIMESTAMP, p_UID, CURRENT_TIMESTAMP, 0
        );
        SET p_Id = LAST_INSERT_ID();
        SET v_rowscount = ROW_COUNT();
    ELSE
        UPDATE Process
        SET ProcessCode      = TRIM(p_ProcessCode),
            ProcessName      = TRIM(p_ProcessName),
            Prefix           = UPPER(TRIM(p_Prefix)),
            TargetTATMinutes = COALESCE(p_TargetTATMinutes, TargetTATMinutes),
            AllowSubTokens   = COALESCE(p_AllowSubTokens, AllowSubTokens),
            IsActive         = COALESCE(p_IsActive, IsActive),
            ModifiedBy       = p_UID,
            ModifiedDate     = CURRENT_TIMESTAMP
        WHERE Id = p_Id AND IsDeleted = 0;
        SET v_rowscount = ROW_COUNT();
    END IF;

    SELECT COALESCE(p_Id, 0) AS ID, COALESCE(v_err, 0) AS ErrNo, COALESCE(v_rowscount, 0) AS RowsCount, COALESCE(v_errMsg, '') AS ErrMsg, COALESCE(v_errLine, 0) AS ErrLine;
END //

-- ============================================================================
-- STORED PROCEDURES FOR COUNTER
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_S_Counter //
CREATE PROCEDURE PR_S_Counter (
    IN p_Id             INT,
    IN p_OrganizationId INT,
    IN p_LocationId     INT,
    IN p_AreaId         INT,
    IN p_IsActive       SMALLINT
)
BEGIN
    SELECT * FROM Counter
    WHERE IsDeleted = 0
      AND (COALESCE(p_Id, -1) = -1 OR Id = p_Id)
      AND (COALESCE(p_OrganizationId, -1) = -1 OR OrganizationId = p_OrganizationId)
      AND (COALESCE(p_LocationId, -1) = -1 OR LocationId = p_LocationId)
      AND (COALESCE(p_AreaId, -1) = -1 OR AreaId = p_AreaId)
      AND (COALESCE(p_IsActive, -1) NOT IN (0, 1) OR IsActive = p_IsActive)
    ORDER BY CounterNumber ASC;
END //

DROP PROCEDURE IF EXISTS PR_IU_Counter //
CREATE PROCEDURE PR_IU_Counter (
    IN p_Id             INT,
    IN p_CounterCode    VARCHAR(50),
    IN p_OrganizationId INT,
    IN p_LocationId     INT,
    IN p_AreaId         INT,
    IN p_CounterNumber  VARCHAR(20),
    IN p_CounterName    VARCHAR(100),
    IN p_CurrentStatus  INT,
    IN p_IsActive       TINYINT(1),
    IN p_UID            INT
)
proc_body: BEGIN
    DECLARE v_err INT DEFAULT 0;
    DECLARE v_rowscount INT DEFAULT 0;
    DECLARE v_errMsg VARCHAR(300) DEFAULT '';
    DECLARE v_errLine INT DEFAULT 0;
    DECLARE v_duplicateID INT DEFAULT 0;

    IF EXISTS(SELECT 1 FROM Counter WHERE OrganizationId = p_OrganizationId AND LocationId = p_LocationId AND AreaId = p_AreaId AND CounterNumber = TRIM(p_CounterNumber) AND IsDeleted = 0 AND (COALESCE(p_Id, 0) <= 0 OR Id <> p_Id)) THEN
        SELECT Id INTO v_duplicateID FROM Counter WHERE OrganizationId = p_OrganizationId AND LocationId = p_LocationId AND AreaId = p_AreaId AND CounterNumber = TRIM(p_CounterNumber) AND IsDeleted = 0 AND (COALESCE(p_Id, 0) <= 0 OR Id <> p_Id) LIMIT 1;
        SET v_err = 51;
        SET v_errMsg = CONCAT('Duplicate Counter Number in Area! Already exists with ID ', v_duplicateID);
        LEAVE proc_body;
    END IF;

    IF COALESCE(p_Id, 0) <= 0 THEN
        INSERT INTO Counter (
            CounterCode, OrganizationId, LocationId, AreaId, CounterNumber, CounterName, CurrentStatus, IsActive,
            CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
        ) VALUES (
            TRIM(p_CounterCode), p_OrganizationId, p_LocationId, p_AreaId, TRIM(p_CounterNumber), TRIM(p_CounterName), COALESCE(p_CurrentStatus, 20001), COALESCE(p_IsActive, 1),
            p_UID, CURRENT_TIMESTAMP, p_UID, CURRENT_TIMESTAMP, 0
        );
        SET p_Id = LAST_INSERT_ID();
        SET v_rowscount = ROW_COUNT();
    ELSE
        UPDATE Counter
        SET CounterCode    = TRIM(p_CounterCode),
            AreaId         = COALESCE(p_AreaId, AreaId),
            CounterNumber  = TRIM(p_CounterNumber),
            CounterName    = TRIM(p_CounterName),
            CurrentStatus  = COALESCE(p_CurrentStatus, CurrentStatus),
            IsActive       = COALESCE(p_IsActive, IsActive),
            ModifiedBy     = p_UID,
            ModifiedDate   = CURRENT_TIMESTAMP
        WHERE Id = p_Id AND IsDeleted = 0;
        SET v_rowscount = ROW_COUNT();
    END IF;

    SELECT COALESCE(p_Id, 0) AS ID, COALESCE(v_err, 0) AS ErrNo, COALESCE(v_rowscount, 0) AS RowsCount, COALESCE(v_errMsg, '') AS ErrMsg, COALESCE(v_errLine, 0) AS ErrLine;
END //

-- ============================================================================
-- STORED PROCEDURES FOR DISPLAY TEMPLATE
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_S_DisplayTemplate //
CREATE PROCEDURE PR_S_DisplayTemplate (
    IN p_Id             INT,
    IN p_OrganizationId INT,
    IN p_IsActive       SMALLINT
)
BEGIN
    SELECT * FROM DisplayTemplate
    WHERE IsDeleted = 0
      AND (COALESCE(p_Id, -1) = -1 OR Id = p_Id)
      AND (COALESCE(p_OrganizationId, -1) = -1 OR OrganizationId = p_OrganizationId)
      AND (COALESCE(p_IsActive, -1) NOT IN (0, 1) OR IsActive = p_IsActive)
    ORDER BY TemplateName ASC;
END //

DROP PROCEDURE IF EXISTS PR_IU_DisplayTemplate //
CREATE PROCEDURE PR_IU_DisplayTemplate (
    IN p_Id               INT,
    IN p_OrganizationId   INT,
    IN p_TemplateName     VARCHAR(100),
    IN p_TemplateType     INT,
    IN p_LayoutConfigJson TEXT,
    IN p_IsDefault        TINYINT(1),
    IN p_IsActive         TINYINT(1),
    IN p_UID              INT
)
proc_body: BEGIN
    DECLARE v_err INT DEFAULT 0;
    DECLARE v_rowscount INT DEFAULT 0;
    DECLARE v_errMsg VARCHAR(300) DEFAULT '';
    DECLARE v_errLine INT DEFAULT 0;
    DECLARE v_duplicateID INT DEFAULT 0;

    IF EXISTS(SELECT 1 FROM DisplayTemplate WHERE OrganizationId = p_OrganizationId AND TemplateName = TRIM(p_TemplateName) AND IsDeleted = 0 AND (COALESCE(p_Id, 0) <= 0 OR Id <> p_Id)) THEN
        SELECT Id INTO v_duplicateID FROM DisplayTemplate WHERE OrganizationId = p_OrganizationId AND TemplateName = TRIM(p_TemplateName) AND IsDeleted = 0 AND (COALESCE(p_Id, 0) <= 0 OR Id <> p_Id) LIMIT 1;
        SET v_err = 51;
        SET v_errMsg = CONCAT('Duplicate Template Name! Already exists with ID ', v_duplicateID);
        LEAVE proc_body;
    END IF;

    IF COALESCE(p_Id, 0) <= 0 THEN
        INSERT INTO DisplayTemplate (
            OrganizationId, TemplateName, TemplateType, LayoutConfigJson, IsDefault, IsActive,
            CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
        ) VALUES (
            p_OrganizationId, TRIM(p_TemplateName), COALESCE(p_TemplateType, 21001), p_LayoutConfigJson, COALESCE(p_IsDefault, 0), COALESCE(p_IsActive, 1),
            p_UID, CURRENT_TIMESTAMP, p_UID, CURRENT_TIMESTAMP, 0
        );
        SET p_Id = LAST_INSERT_ID();
        SET v_rowscount = ROW_COUNT();
    ELSE
        UPDATE DisplayTemplate
        SET TemplateName     = TRIM(p_TemplateName),
            TemplateType     = COALESCE(p_TemplateType, TemplateType),
            LayoutConfigJson = p_LayoutConfigJson,
            IsDefault        = COALESCE(p_IsDefault, IsDefault),
            IsActive         = COALESCE(p_IsActive, IsActive),
            ModifiedBy       = p_UID,
            ModifiedDate     = CURRENT_TIMESTAMP
        WHERE Id = p_Id AND IsDeleted = 0;
        SET v_rowscount = ROW_COUNT();
    END IF;

    SELECT COALESCE(p_Id, 0) AS ID, COALESCE(v_err, 0) AS ErrNo, COALESCE(v_rowscount, 0) AS RowsCount, COALESCE(v_errMsg, '') AS ErrMsg, COALESCE(v_errLine, 0) AS ErrLine;
END //

DELIMITER ;
