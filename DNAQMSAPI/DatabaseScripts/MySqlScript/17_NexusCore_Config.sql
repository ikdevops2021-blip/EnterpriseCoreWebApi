CREATE TABLE IF NOT EXISTS `ConfigCategory` (
    `CategoryID` INT NOT NULL AUTO_INCREMENT,
    `CategoryCode` VARCHAR(50) COLLATE utf8mb4_general_ci NOT NULL,
    `CategoryName` VARCHAR(100) COLLATE utf8mb4_general_ci NOT NULL,
    `Description` LONGTEXT COLLATE utf8mb4_general_ci,
    `Priority` INT NOT NULL DEFAULT '1',
    `Active` TINYINT(1) NOT NULL DEFAULT '1',
    `AllowModify` TINYINT(1) NOT NULL DEFAULT '0',
    `ParentCategoryID` INT DEFAULT NULL,
    `CreatedBy` INT NOT NULL,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy` INT NOT NULL,
    `ModifiedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted` TINYINT(1) DEFAULT '0',
    `DeletedBy` INT DEFAULT NULL,
    `DeletedDate` DATETIME DEFAULT NULL,
    `CategoryExternalID` VARCHAR(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `CategoryExternalName` VARCHAR(200) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `CategoryExternalCode` VARCHAR(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `CategoryColor` VARCHAR(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `CategoryIcon` VARCHAR(200) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `CategoryImage` VARCHAR(200) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `Attribute1` VARCHAR(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `Attribute2` VARCHAR(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `Attribute3` VARCHAR(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
    PRIMARY KEY (`CategoryID`),
    UNIQUE KEY `CategoryName` (`CategoryName`),
    KEY `fk_category_parent` (`ParentCategoryID`),
    KEY `idx_category_name` (`CategoryName`),
    CONSTRAINT `fk_category_parent` FOREIGN KEY (`ParentCategoryID`) REFERENCES `ConfigCategory` (`CategoryID`) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS `ConfigParameters` (
    `ParameterID` INT NOT NULL AUTO_INCREMENT,
    `CategoryID` INT NOT NULL,
    `ParameterCode` VARCHAR(50) COLLATE utf8mb4_general_ci NOT NULL,
    `ParameterName` VARCHAR(200) COLLATE utf8mb4_general_ci NOT NULL,
    `Priority` TINYINT NOT NULL DEFAULT '1',
    `IsDefault` TINYINT(1) DEFAULT NULL,
    `IsActive` TINYINT(1) NOT NULL DEFAULT '1',
    `ParameterExternalID` VARCHAR(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `ParameterExternalName` VARCHAR(200) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `ParameterExternalCode` VARCHAR(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `ParameterColor` VARCHAR(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `ParameterIcon` VARCHAR(200) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `ParameterImage` VARCHAR(200) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `Attribute1` VARCHAR(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `Attribute2` VARCHAR(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `Attribute3` VARCHAR(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
    `CreatedBy` INT NOT NULL,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy` INT NOT NULL,
    `ModifiedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted` TINYINT(1) DEFAULT '0',
    `DeletedBy` INT DEFAULT NULL,
    `DeletedDate` DATETIME DEFAULT NULL,
    PRIMARY KEY (`ParameterID`),
    UNIQUE KEY `uq_param_category_code` (`CategoryID`, `ParameterCode`),
    UNIQUE KEY `uq_param_category_name` (`CategoryID`, `ParameterName`),
    KEY `idx_param_category` (`CategoryID`),
    CONSTRAINT `fk_param_category` FOREIGN KEY (`CategoryID`) REFERENCES `ConfigCategory` (`CategoryID`) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS SystemConfigurationKeys (
    SystemConfigurationKeyID INT PRIMARY KEY AUTO_INCREMENT,
    
    `Key` VARCHAR(250) NOT NULL UNIQUE,                                      
    Value LONGTEXT NOT NULL,                                           
    Description LONGTEXT,                                              
    
    AcceptedValues LONGTEXT,                                           
    DataTypeID INT NOT NULL,
    AllowEdit TINYINT(1) DEFAULT 0,                                       
    
    Active TINYINT(1) DEFAULT 1,                                           
    
    CreatedBy INT NOT NULL,
    CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ModifiedBy INT NOT NULL,
    ModifiedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IsDeleted TINYINT(1) NULL DEFAULT 0,
    DeletedBy INT NULL,
    DeletedDate DATETIME NULL,
    KEY `idx_sysconfig_datatype` (`DataTypeID`),
    CONSTRAINT `fk_sysconfig_datatype` FOREIGN KEY (`DataTypeID`) REFERENCES `ConfigParameters` (`ParameterID`) ON DELETE RESTRICT
);

-- Indices creation
SET @exist_syskey = (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'SystemConfigurationKeys' AND index_name = 'idx_sysconfig_key');
SET @sql_syskey = IF(@exist_syskey = 0, 'CREATE INDEX idx_sysconfig_key ON SystemConfigurationKeys(`Key`);', 'SELECT 1;');
PREPARE stmt_syskey FROM @sql_syskey; EXECUTE stmt_syskey; DEALLOCATE PREPARE stmt_syskey;

SET @exist_sysactive = (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'SystemConfigurationKeys' AND index_name = 'idx_sysconfig_active');
SET @sql_sysactive = IF(@exist_sysactive = 0, 'CREATE INDEX idx_sysconfig_active ON SystemConfigurationKeys(Active, IsDeleted);', 'SELECT 1;');
PREPARE stmt_sysactive FROM @sql_sysactive; EXECUTE stmt_sysactive; DEALLOCATE PREPARE stmt_sysactive;
