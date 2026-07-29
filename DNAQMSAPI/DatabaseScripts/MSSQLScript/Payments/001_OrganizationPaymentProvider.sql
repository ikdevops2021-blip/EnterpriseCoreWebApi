CREATE TABLE [OrganizationPaymentProvider] (
    [Id] INT IDENTITY(1,1) PRIMARY KEY,
    [OrganizationId] INT NOT NULL,
    [ProviderName] NVARCHAR(100) NOT NULL,
    [ConfigurationJson] NVARCHAR(MAX) NULL,
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedBy] INT NOT NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedBy] INT NOT NULL,
    [ModifiedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [IsDeleted] BIT NULL DEFAULT 0,
    [DeletedBy] INT NULL,
    [DeletedDate] DATETIME NULL
);
GO
