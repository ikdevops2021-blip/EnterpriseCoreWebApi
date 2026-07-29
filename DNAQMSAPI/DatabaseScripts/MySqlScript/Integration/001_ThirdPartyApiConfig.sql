CREATE TABLE IF NOT EXISTS `ThirdPartyApiConfig` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `Name` VARCHAR(255) NOT NULL,
    `TenantId` INT NULL,
    `BaseUrl` VARCHAR(1000) NOT NULL,
    `AuthType` INT NOT NULL DEFAULT 0, -- 0=ApiKey, 1=Basic, 2=JwtBearer, 3=OAuth2
    `ApiKey` VARCHAR(1000) NULL,
    `Username` VARCHAR(255) NULL,
    `Password` VARCHAR(1000) NULL,
    `ClientId` VARCHAR(500) NULL,
    `ClientSecret` VARCHAR(1000) NULL,
    `TokenEndpoint` VARCHAR(1000) NULL,
    `Scope` VARCHAR(500) NULL,
    `AccessToken` TEXT NULL,
    `RefreshToken` TEXT NULL,
    `TokenExpiry` DATETIME NULL,
    `IsGlobal` TINYINT(1) NOT NULL DEFAULT 0,
    `IsActive` TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy` INT NOT NULL,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy` INT NOT NULL,
    `ModifiedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `IsDeleted` TINYINT(1) NULL DEFAULT 0,
    `DeletedBy` INT NULL,
    `DeletedDate` DATETIME NULL
);

CREATE TABLE IF NOT EXISTS `IntegrationLogs` (
    `Id` INT AUTO_INCREMENT PRIMARY KEY,
    `ConfigId` INT NOT NULL,
    `Endpoint` VARCHAR(1000) NOT NULL,
    `HttpMethod` VARCHAR(10) NOT NULL,
    `RequestBody` TEXT NULL,
    `ResponseBody` TEXT NULL,
    `StatusCode` INT NOT NULL,
    `DurationMs` INT NOT NULL,
    `ErrorMessage` TEXT NULL,
    `CreatedBy` INT NOT NULL,
    `CreatedDate` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
