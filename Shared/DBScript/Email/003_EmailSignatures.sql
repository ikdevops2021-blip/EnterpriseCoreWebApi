CREATE TABLE EmailSignatures (
    SignatureId INT PRIMARY KEY IDENTITY(1,1),
    CenterId INT NOT NULL,
    LogoUrl NVARCHAR(MAX) NULL,
    LogoLink NVARCHAR(MAX) NULL,
    TemplateHtml NVARCHAR(MAX) NOT NULL,

    CreatedBy INT NOT NULL,
    CreateDate DATETIME DEFAULT GETDATE(),
    ModifiedBy INT NOT NULL,
    ModifyDate DATETIME DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0,
    DeletedBy INT NULL,
    DeletedDate DATETIME NULL
);
