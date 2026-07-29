CREATE TABLE IF NOT EXISTS `FileAuditLogs` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `Guid` CHAR(36) NOT NULL UNIQUE,
    `FileId` CHAR(36) NOT NULL,
    `Action` VARCHAR(100) NOT NULL,
    `UserId` INT NOT NULL,
    `OrganizationId` INT NULL,
    `IPAddress` VARCHAR(50) NULL,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_fileauditlogs_storedfile` FOREIGN KEY (`FileId`) REFERENCES `StoredFile`(`Id`)
);
