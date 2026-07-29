CREATE TABLE [UserDevice] (
    [Id] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    [UserId] INT NOT NULL,
    [DeviceIdentifier] NVARCHAR(255) NOT NULL,
    [DeviceName] NVARCHAR(255) NULL,
    [LastSeenAt] DATETIME NOT NULL,
    [IsTrusted] BIT NOT NULL DEFAULT 0,
    [CreatedBy] INT NOT NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedBy] INT NOT NULL,
    [ModifiedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [IsDeleted] BIT NULL DEFAULT 0,
    [DeletedBy] INT NULL,
    [DeletedDate] DATETIME NULL
);
GO
