CREATE TABLE `StoredFile` (
    `Id` CHAR(36) NOT NULL PRIMARY KEY,
    `FileName` VARCHAR(255) NOT NULL,
    `ContentType` VARCHAR(100) NOT NULL,
    `SizeBytes` BIGINT NOT NULL,
    `StorageProvider` VARCHAR(100) NOT NULL,
    `PathOrUrl` VARCHAR(1000) NOT NULL,
    `OrganizationId` INT NULL,
    `CreatedBy` INT NOT NULL,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy` INT NOT NULL,
    `ModifiedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted` TINYINT(1) NULL DEFAULT 0,
    `DeletedBy` INT NULL,
    `DeletedDate` DATETIME NULL
);
