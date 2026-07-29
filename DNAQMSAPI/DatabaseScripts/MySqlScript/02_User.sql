-- ===================================================================================
-- DNAQMS API - USER TABLE SCHEMA WITH USERCODE, DISPLAYNAME, TITLE, GENDER & PROFILE IMAGE (MySQL)
-- File Path: DNAQMSAPI/DatabaseScripts/MySqlScript/02_User.sql
-- ===================================================================================

USE `dnaqms`;

CREATE TABLE IF NOT EXISTS `User` (
    `Id`                INT AUTO_INCREMENT PRIMARY KEY,
    `UserCode`          VARCHAR(50) NOT NULL,              -- Custom user identifier (default: Email). Unique among active users.
    `TitleId`           INT NULL,                          -- ConfigParameters Category 2 (C_TITLE: 2001..2009)
    `FirstName`         VARCHAR(250) NOT NULL,
    `LastName`          VARCHAR(250) NOT NULL,
    `DisplayName`       VARCHAR(250) NULL,                 -- Auto-generated: FirstName + ' ' + LastName (or custom)
    `GenderId`          INT NULL,                          -- ConfigParameters Category 1 (C_GENDER: 1001..1005)
    `ProfileImageUrl`   VARCHAR(500) NULL,
    `Email`             VARCHAR(255) NOT NULL UNIQUE,
    `PasswordHash`      TEXT NOT NULL,
    `IsActive`          TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy`         INT NOT NULL,
    `CreatedDate`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy`        INT NOT NULL DEFAULT 0,
    `ModifiedDate`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted`         TINYINT(1) NULL DEFAULT 0,
    `DeletedBy`         INT NULL,
    `DeletedDate`       DATETIME NULL,

    CONSTRAINT `FK_User_Title` 
        FOREIGN KEY (`TitleId`) REFERENCES `ConfigParameters`(`ParameterID`),

    CONSTRAINT `FK_User_Gender` 
        FOREIGN KEY (`GenderId`) REFERENCES `ConfigParameters`(`ParameterID`),

    -- Unique index on UserCode (MySQL does not support filtered indexes; uniqueness enforced via SP validation)
    UNIQUE INDEX `UX_Users_UserCode` (`UserCode`)
);
