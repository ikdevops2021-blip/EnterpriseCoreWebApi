CREATE TABLE `UserDevice` (
    `Id` CHAR(36) NOT NULL PRIMARY KEY,
    `UserId` INT NOT NULL,
    `DeviceIdentifier` VARCHAR(255) NOT NULL,
    `DeviceName` VARCHAR(255) NULL,
    `LastSeenAt` DATETIME NOT NULL,
    `IsTrusted` TINYINT(1) NOT NULL DEFAULT 0,
    `CreatedBy` INT NOT NULL,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy` INT NOT NULL,
    `ModifiedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted` TINYINT(1) NULL DEFAULT 0,
    `DeletedBy` INT NULL,
    `DeletedDate` DATETIME NULL
);
