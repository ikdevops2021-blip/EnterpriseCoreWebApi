-- NOTE: SmtpPass should be encrypted using application-level encryption

CREATE TABLE EmailSettings (
    SettingId INT PRIMARY KEY IDENTITY(1,1),
    OrganizationId INT NOT NULL,
    SmtpHost NVARCHAR(255) NOT NULL,
    SmtpPort INT NOT NULL,
    SmtpUser NVARCHAR(255) NOT NULL,
    SmtpPass NVARCHAR(MAX) NOT NULL,
    SenderDescription NVARCHAR(255) NULL,
    EnableSSL BIT DEFAULT 1,
    BypassCertificateValidation BIT DEFAULT 0,
    Active BIT DEFAULT 0,

    CreatedBy INT NOT NULL,
    CreateDate DATETIME DEFAULT GETDATE(),
    ModifiedBy INT NOT NULL,
    ModifyDate DATETIME DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0,
    DeletedBy INT NULL,
    DeletedDate DATETIME NULL
);

CREATE INDEX IX_EmailSettings_Organization_Active 
ON EmailSettings(OrganizationId, Active) 
WHERE IsDeleted = 0;
