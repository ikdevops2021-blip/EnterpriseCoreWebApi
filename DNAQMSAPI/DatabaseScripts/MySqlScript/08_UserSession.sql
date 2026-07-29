CREATE TABLE `UserSession` (
    `Id` CHAR(36) NOT NULL PRIMARY KEY,
    `UserId` INT NOT NULL,
    `RefreshTokenHash` VARCHAR(255) NOT NULL,
    `ExpiresAt` DATETIME NOT NULL,
    `IpAddress` VARCHAR(50) NULL,
    `UserAgent` TEXT NULL,
    `IsRevoked` TINYINT(1) NOT NULL DEFAULT 0,
    `CreatedBy` INT NOT NULL,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy` INT NOT NULL,
    `ModifiedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted` TINYINT(1) NULL DEFAULT 0,
    `DeletedBy` INT NULL,
    `DeletedDate` DATETIME NULL
);
