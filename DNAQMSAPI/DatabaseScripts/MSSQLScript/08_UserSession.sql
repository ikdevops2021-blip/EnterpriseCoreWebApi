CREATE TABLE [UserSession] (
    [Id] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    [UserId] INT NOT NULL,
    [RefreshTokenHash] NVARCHAR(255) NOT NULL,
    [ExpiresAt] DATETIME NOT NULL,
    [IpAddress] NVARCHAR(50) NULL,
    [UserAgent] NVARCHAR(MAX) NULL,
    [IsRevoked] BIT NOT NULL DEFAULT 0,
    [CreatedBy] INT NOT NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ModifiedBy] INT NOT NULL,
    [ModifiedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [IsDeleted] BIT NULL DEFAULT 0,
    [DeletedBy] INT NULL,
    [DeletedDate] DATETIME NULL
);
GO
