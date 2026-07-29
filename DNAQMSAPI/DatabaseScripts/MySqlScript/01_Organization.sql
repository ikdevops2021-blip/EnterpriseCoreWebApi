CREATE TABLE `Organization` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `RegistrationKey` CHAR(36) NOT NULL,
    `Name` VARCHAR(255) NOT NULL,
    `ParentOrganizationId` INT NULL,
    `Priority` INT NOT NULL DEFAULT 1,
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy` INT NOT NULL,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy` INT NOT NULL,
    `ModifiedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted` TINYINT(1) NULL DEFAULT 0,
    `DeletedBy` INT NULL,
    `DeletedDate` DATETIME NULL
);
