CREATE TABLE [StoredFile] (
    [Id] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    [FileName] NVARCHAR(255) NOT NULL,
    [ContentType] NVARCHAR(100) NOT NULL,
    [SizeBytes] BIGINT NOT NULL,
    [StorageProvider] NVARCHAR(100) NOT NULL,
    [PathOrUrl] NVARCHAR(1000) NOT NULL,
    [OrganizationId] INT NULL,
    [CreatedBy] INT NOT NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedBy] INT NOT NULL,
    [ModifiedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [IsDeleted] BIT NULL DEFAULT 0,
    [DeletedBy] INT NULL,
    [DeletedDate] DATETIME NULL
);
GO
