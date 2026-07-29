-- MySQL Table Definitions for Integration Module

-- 1. API Integrations
CREATE TABLE `APIIntegrations` (
	`IntegrationID` INT AUTO_INCREMENT NOT NULL,
	`TenantId` INT NOT NULL,
	`ProviderName` VARCHAR(50) NOT NULL,
	`Description` VARCHAR(255) NULL,
	`BaseUrl` VARCHAR(255) NOT NULL,
	`Active` TINYINT(1) NULL DEFAULT 1,
	`AuditLevel` INT NOT NULL DEFAULT 1 COMMENT '0: No Logging, 1: Log Errors Only (StatusCode != 200), 2: Log Everything (All Requests/Responses)',
	`AuthType` INT NOT NULL DEFAULT 1 COMMENT '0:ApiKey, 1:Bearer, 2:Basic, 3:OAuth2, 4:HMAC_Signing, 5:Anonymous',
	`ApiKey` LONGTEXT NULL,
	`ApiUsername` VARCHAR(100) NULL,
	`ApiPassword` LONGTEXT NULL,
	`TokenUrl` LONGTEXT NULL,
	`ClientID` LONGTEXT NULL,
	`CurrentToken` LONGTEXT NULL,
	`ClientSecret` LONGTEXT NULL,
	`TokenExpiration` DATETIME NULL,
	`HMACSecretKey` LONGTEXT NULL,
	`HMACHeaderName` LONGTEXT NULL,
	`RequiresCertificate` TINYINT(1) NULL DEFAULT 0,
	`CreatedBy` INT NOT NULL,
	`CreatedDate` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
	`ModifiedBy` INT NOT NULL,
	`ModifiedDate` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
	`IsDeleted` TINYINT(1) NULL DEFAULT 0,
	`DeletedBy` INT NULL,
	`DeletedDate` DATETIME NULL,
	PRIMARY KEY (`IntegrationID`)
);

-- 2. API Endpoints
CREATE TABLE `ApiEndpoints` (
	`EndpointID` INT AUTO_INCREMENT NOT NULL,
	`IntegrationID` INT NULL,
	`ActionName` VARCHAR(50) NOT NULL,
	`RelativePath` VARCHAR(255) NOT NULL,
	`HttpMethod` VARCHAR(10) NOT NULL,
	`Description` VARCHAR(255) NULL,
	`Active` TINYINT(1) NULL DEFAULT 1,
	`SampleAPIRequest` LONGTEXT NULL,
	`SampleAPIResponse` LONGTEXT NULL,
	`CreatedBy` INT NOT NULL,
	`CreatedDate` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
	`ModifiedBy` INT NOT NULL,
	`ModifiedDate` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
	`IsDeleted` TINYINT(1) NULL DEFAULT 0,
	`DeletedBy` INT NULL,
	`DeletedDate` DATETIME NULL,
	PRIMARY KEY (`EndpointID`),
	FOREIGN KEY (`IntegrationID`) REFERENCES `APIIntegrations`(`IntegrationID`)
);

-- 3. API Audit Logs
CREATE TABLE `APIAuditLogs` (
	`AuditID` BIGINT AUTO_INCREMENT NOT NULL,
	`IntegrationID` INT NOT NULL,
	`ActionName` VARCHAR(50) NOT NULL,
	`RequestUrl` LONGTEXT NOT NULL,
	`HttpMethod` VARCHAR(10) NOT NULL,
	`RequestBody` LONGTEXT NULL,
	`ResponseBody` LONGTEXT NULL,
	`StatusCode` INT NULL,
	`DurationMs` INT NOT NULL,
	`ErrorMessage` LONGTEXT NULL,
	`CreatedDate` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
	`CreatedBy` INT NULL,
	PRIMARY KEY (`AuditID`)
);
