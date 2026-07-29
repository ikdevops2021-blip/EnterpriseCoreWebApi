CREATE TABLE EmailSignatures (
    SignatureId INT PRIMARY KEY AUTO_INCREMENT,
    OrganizationId INT NOT NULL,
    LogoUrl TEXT NULL,
    LogoLink TEXT NULL,
    TemplateHtml TEXT NOT NULL,

    CreatedBy INT NOT NULL,
    CreateDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    ModifiedBy INT NOT NULL,
    ModifyDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsDeleted TINYINT(1) DEFAULT 0,
    DeletedBy INT NULL,
    DeletedDate DATETIME NULL
);
