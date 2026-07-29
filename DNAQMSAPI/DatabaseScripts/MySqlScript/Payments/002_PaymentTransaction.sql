CREATE TABLE `PaymentTransaction` (
    `Id` CHAR(36) NOT NULL PRIMARY KEY,
    `UserId` INT NOT NULL,
    `TargetOrganizationId` INT NOT NULL,
    `Amount` DECIMAL(18,2) NOT NULL,
    `Currency` VARCHAR(10) NOT NULL,
    `Status` VARCHAR(50) NOT NULL,
    `Provider` VARCHAR(100) NOT NULL,
    `ProviderTransactionId` VARCHAR(255) NULL,
    `CreatedBy` INT NOT NULL,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy` INT NOT NULL,
    `ModifiedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted` TINYINT(1) NULL DEFAULT 0,
    `DeletedBy` INT NULL,
    `DeletedDate` DATETIME NULL
);
