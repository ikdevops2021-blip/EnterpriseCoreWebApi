CREATE TABLE [UserOrganization] (
    [Id] INT IDENTITY(1,1) PRIMARY KEY,
    [UserId] INT NOT NULL,
    [OrganizationId] INT NOT NULL,
    [CreatedBy] INT NOT NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedBy] INT NOT NULL,
    [ModifiedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [IsDeleted] BIT NULL DEFAULT 0,
    [DeletedBy] INT NULL,
    [DeletedDate] DATETIME NULL
);
GO
