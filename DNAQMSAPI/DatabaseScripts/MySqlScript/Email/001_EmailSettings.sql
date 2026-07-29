-- NOTE: SmtpPass should be encrypted using application-level encryption

CREATE TABLE EmailSettings (
    SettingId INT PRIMARY KEY AUTO_INCREMENT,
    OrganizationId INT NOT NULL,
    SmtpHost VARCHAR(255) NOT NULL,
    SmtpPort INT NOT NULL,
    SmtpUser VARCHAR(255) NOT NULL,
    SmtpPass TEXT NOT NULL,
    SenderDescription VARCHAR(255) NULL,
    EnableSSL TINYINT(1) DEFAULT 1,
    BypassCertificateValidation TINYINT(1) DEFAULT 0,
    Active TINYINT(1) DEFAULT 0,

    CreatedBy INT NOT NULL,
    CreateDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    ModifiedBy INT NOT NULL,
    ModifyDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsDeleted TINYINT(1) DEFAULT 0,
    DeletedBy INT NULL,
    DeletedDate DATETIME NULL
);

CREATE INDEX IX_EmailSettings_Organization_Active 
ON EmailSettings(OrganizationId, Active, IsDeleted);
