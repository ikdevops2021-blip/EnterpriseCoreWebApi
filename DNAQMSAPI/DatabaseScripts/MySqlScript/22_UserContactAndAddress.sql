-- ===================================================================================
-- DNAQMS API - LOCATION MASTERS, USER ADDRESSES & USER CONTACTS SCHEMA (MySQL)
-- File Path: DNAQMSAPI/DatabaseScripts/MySqlScript/22_UserContactAndAddress.sql
-- ===================================================================================

USE `dnaqms`;

-- -----------------------------------------------------------------------------------
-- 1. COUNTRY MASTER TABLE
-- -----------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `Country` (
    `CountryId`             INT AUTO_INCREMENT PRIMARY KEY,
    `CountryName`           VARCHAR(100) NOT NULL,
    `CountryCode`           VARCHAR(5) NOT NULL,
    `InternationalDialing`  VARCHAR(10) NULL,
    
    -- Generic Attributes
    `Attribute1`            VARCHAR(100) NULL,
    `Attribute2`            VARCHAR(100) NULL,
    `Attribute3`            VARCHAR(100) NULL,
    
    -- Audit Metadata
    `IsActive`              TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy`             INT NOT NULL,
    `CreatedDate`           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy`            INT NOT NULL DEFAULT 0,
    `ModifiedDate`          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted`             TINYINT(1) NULL DEFAULT 0,
    `DeletedBy`             INT NULL,
    `DeletedDate`           DATETIME NULL,
    KEY `idx_country_name` (`CountryName`),
    KEY `idx_country_code` (`CountryCode`)
);

-- -----------------------------------------------------------------------------------
-- 2. STATE MASTER TABLE
-- -----------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `State` (
    `StateId`               INT AUTO_INCREMENT PRIMARY KEY,
    `CountryId`             INT NOT NULL,
    `StateName`             VARCHAR(100) NOT NULL,
    `StateCode`             VARCHAR(10) NULL,
    
    -- Generic Attributes
    `Attribute1`            VARCHAR(100) NULL,
    `Attribute2`            VARCHAR(100) NULL,
    `Attribute3`            VARCHAR(100) NULL,
    
    -- Audit Metadata
    `IsActive`              TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy`             INT NOT NULL,
    `CreatedDate`           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy`            INT NOT NULL DEFAULT 0,
    `ModifiedDate`          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted`             TINYINT(1) NULL DEFAULT 0,
    `DeletedBy`             INT NULL,
    `DeletedDate`           DATETIME NULL,

    CONSTRAINT `FK_State_Country` 
        FOREIGN KEY (`CountryId`) REFERENCES `Country`(`CountryId`)
);

-- -----------------------------------------------------------------------------------
-- 3. CITY MASTER TABLE
-- -----------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `City` (
    `CityId`                INT AUTO_INCREMENT PRIMARY KEY,
    `StateId`               INT NOT NULL,
    `CityName`              VARCHAR(100) NOT NULL,
    `CityCode`              VARCHAR(10) NULL,
    
    -- Generic Attributes
    `Attribute1`            VARCHAR(100) NULL,
    `Attribute2`            VARCHAR(100) NULL,
    `Attribute3`            VARCHAR(100) NULL,
    
    -- Audit Metadata
    `IsActive`              TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy`             INT NOT NULL,
    `CreatedDate`           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy`            INT NOT NULL DEFAULT 0,
    `ModifiedDate`          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted`             TINYINT(1) NULL DEFAULT 0,
    `DeletedBy`             INT NULL,
    `DeletedDate`           DATETIME NULL,

    CONSTRAINT `FK_City_State` 
        FOREIGN KEY (`StateId`) REFERENCES `State`(`StateId`)
);

-- -----------------------------------------------------------------------------------
-- 4. USER ADDRESSES TABLE
-- -----------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `UserAddresses` (
    `AddressId`             BIGINT AUTO_INCREMENT PRIMARY KEY,
    `UserId`                INT NOT NULL,
    `AddressTypeId`         INT NOT NULL,                -- ConfigParameters (4001..4005)
    
    -- Address Attributes
    `AddressLine1`          VARCHAR(255) NOT NULL,
    `AddressLine2`          VARCHAR(255) NULL,
    `PostalCode`            VARCHAR(20) NOT NULL,

    -- Foreign Keys to Location Masters
    `CountryId`             INT NOT NULL,
    `StateId`               INT NOT NULL,
    `CityId`                INT NOT NULL,

    -- Geolocation Attributes
    `Latitude`              DECIMAL(9,6) NULL,
    `Longitude`             DECIMAL(9,6) NULL,
    
    -- Flags
    `IsPrimary`             TINYINT(1) NOT NULL DEFAULT 0,
    
    -- Audit Metadata
    `IsActive`              TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy`             INT NOT NULL,
    `CreatedDate`           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy`            INT NOT NULL DEFAULT 0,
    `ModifiedDate`          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted`             TINYINT(1) NULL DEFAULT 0,
    `DeletedBy`             INT NULL,
    `DeletedDate`           DATETIME NULL,

    -- Foreign Key Constraints
    CONSTRAINT `FK_UserAddresses_User` 
        FOREIGN KEY (`UserId`) REFERENCES `User`(`Id`) ON DELETE CASCADE,
        
    CONSTRAINT `FK_UserAddresses_Config` 
        FOREIGN KEY (`AddressTypeId`) REFERENCES `ConfigParameters`(`ParameterID`),

    CONSTRAINT `FK_UserAddresses_Country` 
        FOREIGN KEY (`CountryId`) REFERENCES `Country`(`CountryId`),

    CONSTRAINT `FK_UserAddresses_State` 
        FOREIGN KEY (`StateId`) REFERENCES `State`(`StateId`),

    CONSTRAINT `FK_UserAddresses_City` 
        FOREIGN KEY (`CityId`) REFERENCES `City`(`CityId`)
);

-- -----------------------------------------------------------------------------------
-- 5. USER CONTACTS TABLE
-- -----------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `UserContacts` (
    `ContactId`             BIGINT AUTO_INCREMENT PRIMARY KEY,
    `UserId`                INT NOT NULL,                 -- Primary System User
    `ContactTypeId`         INT NOT NULL,                 -- ConfigParameters Category 5  (5001..5006)
    `RelationshipTypeId`    INT NOT NULL,                 -- ConfigParameters Category 16 (16001..16024)
    
    -- Contact Information
    `ContactValue`          VARCHAR(255) NOT NULL,
    `CountryCode`           VARCHAR(5) NULL,              -- Dialing code (e.g., '+1', '+91')
    
    -- Business Flags
    `IsPrimary`             TINYINT(1) NOT NULL DEFAULT 0,
    `IsEmergency`           TINYINT(1) NOT NULL DEFAULT 0,  -- Emergency Contact Flag
    `IsVerified`            TINYINT(1) NOT NULL DEFAULT 0,
    
    -- Audit Metadata
    `IsActive`              TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy`             INT NOT NULL,
    `CreatedDate`           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy`            INT NOT NULL DEFAULT 0,
    `ModifiedDate`          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted`             TINYINT(1) NULL DEFAULT 0,
    `DeletedBy`             INT NULL,
    `DeletedDate`           DATETIME NULL,

    -- Foreign Key Constraints
    CONSTRAINT `FK_UserContacts_User` 
        FOREIGN KEY (`UserId`) REFERENCES `User`(`Id`) ON DELETE CASCADE,
        
    CONSTRAINT `FK_UserContacts_ContactType` 
        FOREIGN KEY (`ContactTypeId`) REFERENCES `ConfigParameters`(`ParameterID`),

    CONSTRAINT `FK_UserContacts_RelationshipType` 
        FOREIGN KEY (`RelationshipTypeId`) REFERENCES `ConfigParameters`(`ParameterID`)
);

-- -----------------------------------------------------------------------------------
-- 6. PERFORMANCE INDEXES
-- -----------------------------------------------------------------------------------
CREATE INDEX `IX_UserAddresses_User_Locations` 
ON `UserAddresses` (`UserId`, `AddressTypeId`, `CountryId`, `StateId`, `CityId`, `IsDeleted`, `IsActive`);

CREATE INDEX `IX_UserContacts_User_Relationship` 
ON `UserContacts` (`UserId`, `RelationshipTypeId`, `ContactTypeId`, `IsEmergency`, `IsDeleted`, `IsActive`);

CREATE INDEX `IX_UserContacts_ContactValue` 
ON `UserContacts` (`ContactValue`, `IsDeleted`);
