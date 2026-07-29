-- ============================================================================================
-- DQMS STAGE 1: ADMIN MASTERS & CONFIGURATION TABLES (MySQL)
-- Script Number: 31_DQMS_Admin_Masters.sql
-- Description: Creates master tables for Location, Area, Counter, Process Pipeline, 
--              Display Templates, Blackout Days, and Staff Counter Assignments.
-- ============================================================================================

-- 1. Area / Zone Master Table
CREATE TABLE IF NOT EXISTS `DQMS_Area` (
    `AreaId` VARCHAR(50) NOT NULL,
    `OrganizationId` VARCHAR(50) NOT NULL,
    `LocationId` VARCHAR(50) NOT NULL,
    `AreaName` VARCHAR(100) NOT NULL,
    `AreaCode` VARCHAR(20) NOT NULL,
    `Description` VARCHAR(255) NULL,
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy` VARCHAR(50) NOT NULL,
    `CreatedOn` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `UpdatedBy` VARCHAR(50) NULL,
    `UpdatedOn` DATETIME NULL,
    PRIMARY KEY (`AreaId`),
    INDEX `IX_DQMS_Area_Org_Loc` (`OrganizationId`, `LocationId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Counter / Station Master Table
CREATE TABLE IF NOT EXISTS `DQMS_Counter` (
    `CounterId` VARCHAR(50) NOT NULL,
    `OrganizationId` VARCHAR(50) NOT NULL,
    `LocationId` VARCHAR(50) NOT NULL,
    `AreaId` VARCHAR(50) NOT NULL,
    `CounterNumber` VARCHAR(20) NOT NULL,
    `CounterName` VARCHAR(100) NOT NULL,
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    `CurrentStatus` INT NOT NULL DEFAULT 0 COMMENT '0: Idle, 1: Serving, 2: Break, 3: Offline',
    `CreatedBy` VARCHAR(50) NOT NULL,
    `CreatedOn` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `UpdatedBy` VARCHAR(50) NULL,
    `UpdatedOn` DATETIME NULL,
    PRIMARY KEY (`CounterId`),
    INDEX `IX_DQMS_Counter_Area` (`AreaId`),
    INDEX `IX_DQMS_Counter_Loc` (`OrganizationId`, `LocationId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Process Pipeline Master Table
CREATE TABLE IF NOT EXISTS `DQMS_Process` (
    `ProcessId` VARCHAR(50) NOT NULL,
    `OrganizationId` VARCHAR(50) NOT NULL,
    `ProcessName` VARCHAR(100) NOT NULL,
    `ProcessCode` VARCHAR(20) NOT NULL,
    `Prefix` VARCHAR(5) NOT NULL DEFAULT 'A',
    `TargetTATMinutes` INT NOT NULL DEFAULT 15,
    `AllowSubTokens` TINYINT(1) NOT NULL DEFAULT 0,
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy` VARCHAR(50) NOT NULL,
    `CreatedOn` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `UpdatedBy` VARCHAR(50) NULL,
    `UpdatedOn` DATETIME NULL,
    PRIMARY KEY (`ProcessId`),
    INDEX `IX_DQMS_Process_Org` (`OrganizationId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Process Multi-Level Steps Table
CREATE TABLE IF NOT EXISTS `DQMS_ProcessStep` (
    `StepId` VARCHAR(50) NOT NULL,
    `ProcessId` VARCHAR(50) NOT NULL,
    `StepOrder` INT NOT NULL DEFAULT 1,
    `StepName` VARCHAR(100) NOT NULL,
    `TargetTATMinutes` INT NOT NULL DEFAULT 10,
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`StepId`),
    INDEX `IX_DQMS_ProcessStep_Proc` (`ProcessId`, `StepOrder`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Process Selective Blackout Days Table
CREATE TABLE IF NOT EXISTS `DQMS_ProcessBlackoutDay` (
    `BlackoutId` VARCHAR(50) NOT NULL,
    `OrganizationId` VARCHAR(50) NOT NULL,
    `LocationId` VARCHAR(50) NOT NULL,
    `ProcessId` VARCHAR(50) NOT NULL,
    `DayOfWeek` INT NOT NULL COMMENT '0: Sunday, 1: Monday ... 6: Saturday',
    `Reason` VARCHAR(255) NULL,
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`BlackoutId`),
    INDEX `IX_DQMS_Blackout_ProcDay` (`ProcessId`, `DayOfWeek`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. Display Template Master Table
CREATE TABLE IF NOT EXISTS `DQMS_DisplayTemplate` (
    `TemplateId` VARCHAR(50) NOT NULL,
    `OrganizationId` VARCHAR(50) NOT NULL,
    `TemplateName` VARCHAR(100) NOT NULL,
    `TemplateType` INT NOT NULL DEFAULT 1 COMMENT '1: GridView, 2: SplitScreenVideo, 3: HighDensityList',
    `LayoutConfigJson` TEXT NULL,
    `IsDefault` TINYINT(1) NOT NULL DEFAULT 0,
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy` VARCHAR(50) NOT NULL,
    `CreatedOn` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`TemplateId`),
    INDEX `IX_DQMS_DisplayTemplate_Org` (`OrganizationId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. Process-to-Display Template Mapping Table
CREATE TABLE IF NOT EXISTS `DQMS_ProcessDisplayMapping` (
    `MappingId` VARCHAR(50) NOT NULL,
    `OrganizationId` VARCHAR(50) NOT NULL,
    `LocationId` VARCHAR(50) NOT NULL,
    `AreaId` VARCHAR(50) NULL,
    `ProcessId` VARCHAR(50) NOT NULL,
    `TemplateId` VARCHAR(50) NOT NULL,
    PRIMARY KEY (`MappingId`),
    INDEX `IX_DQMS_Mapping_Lookup` (`LocationId`, `AreaId`, `ProcessId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. User Counter & Process Assignment Table
CREATE TABLE IF NOT EXISTS `DQMS_UserCounterAssignment` (
    `AssignmentId` VARCHAR(50) NOT NULL,
    `OrganizationId` VARCHAR(50) NOT NULL,
    `UserId` VARCHAR(50) NOT NULL,
    `CounterId` VARCHAR(50) NOT NULL,
    `ProcessId` VARCHAR(50) NOT NULL,
    `AssignedOn` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`AssignmentId`),
    INDEX `IX_DQMS_UserCounter` (`UserId`, `CounterId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 9. Notification & WhatsApp Lead Threshold Config Table
CREATE TABLE IF NOT EXISTS `DQMS_NotificationConfig` (
    `ConfigId` VARCHAR(50) NOT NULL,
    `OrganizationId` VARCHAR(50) NOT NULL,
    `LocationId` VARCHAR(50) NOT NULL,
    `NotifyBeforePositions` INT NOT NULL DEFAULT 3,
    `EnableWhatsApp` TINYINT(1) NOT NULL DEFAULT 1,
    `EnableSms` TINYINT(1) NOT NULL DEFAULT 0,
    `WhatsAppApiKey` VARCHAR(255) NULL,
    `CreatedOn` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`ConfigId`),
    INDEX `IX_DQMS_NotifConfig` (`OrganizationId`, `LocationId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
