IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FileAuditLogs]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[FileAuditLogs] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [Guid] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() UNIQUE,
        [FileId] UNIQUEIDENTIFIER NOT NULL,
        [Action] NVARCHAR(100) NOT NULL,
        [UserId] INT NOT NULL,
        [OrganizationId] INT NULL,
        [IPAddress] NVARCHAR(50) NULL,
        [CreatedDate] DATETIME NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [FK_FileAuditLogs_StoredFile] FOREIGN KEY ([FileId]) REFERENCES [dbo].[StoredFile]([Id])
    );
END
GO
