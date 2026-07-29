CREATE TABLE [Organization] (
    [Id] INT IDENTITY(1,1) PRIMARY KEY,
    [RegistrationKey] UNIQUEIDENTIFIER NOT NULL,
    [Name] NVARCHAR(255) NOT NULL,
    [ParentOrganizationId] INT NULL,
    [Priority] INT NOT NULL DEFAULT 1,
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
