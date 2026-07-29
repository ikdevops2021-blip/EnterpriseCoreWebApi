CREATE TABLE [Role] (
    [Id] INT PRIMARY KEY IDENTITY(1,1),
    [Name] NVARCHAR(100) NOT NULL,
    [Description] NVARCHAR(250) NULL,
    [Priority] INT NOT NULL DEFAULT 1,
    [OrganizationId] INT NULL,
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
