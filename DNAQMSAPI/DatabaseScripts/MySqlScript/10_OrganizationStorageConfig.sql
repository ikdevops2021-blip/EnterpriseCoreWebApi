CREATE TABLE `OrganizationStorageConfig` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `OrganizationId` INT NOT NULL,
    `ProviderName` VARCHAR(100) NOT NULL,
    `ConfigurationJson` TEXT NULL,
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy` INT NOT NULL,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy` INT NOT NULL,
    `ModifiedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted` TINYINT(1) NULL DEFAULT 0,
    `DeletedBy` INT NULL,
    `DeletedDate` DATETIME NULL
);
