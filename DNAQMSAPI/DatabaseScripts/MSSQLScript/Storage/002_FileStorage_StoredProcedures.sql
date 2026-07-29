CREATE OR ALTER PROCEDURE [dbo].[pr_GetOrganizationStorageConfig]
    @OrganizationId INT,
    @ProviderName NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM [dbo].[OrganizationStorageConfig]
    WHERE (OrganizationId = @OrganizationId OR OrganizationId = 0)
      AND ProviderName = @ProviderName 
      AND IsDeleted = 0;
END
GO

CREATE OR ALTER PROCEDURE [dbo].[pr_GetStoredFileMetadata]
    @Id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM [dbo].[StoredFile] WHERE Id = @Id;
END
GO

CREATE OR ALTER PROCEDURE [dbo].[pr_InsertStoredFileMetadata]
    @Id UNIQUEIDENTIFIER,
    @FileName NVARCHAR(255),
    @ContentType NVARCHAR(100),
    @SizeBytes BIGINT,
    @StorageProvider NVARCHAR(100),
    @PathOrUrl NVARCHAR(1000),
    @OrganizationId INT,
    @CreatedBy INT,
    @CreatedDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [dbo].[StoredFile] (
        Id, FileName, ContentType, SizeBytes, StorageProvider, 
        PathOrUrl, OrganizationId, CreatedBy, CreatedDate
    )
    VALUES (
        @Id, @FileName, @ContentType, @SizeBytes, @StorageProvider, 
        @PathOrUrl, @OrganizationId, @CreatedBy, @CreatedDate
    );
END
GO

CREATE OR ALTER PROCEDURE [dbo].[pr_MarkStoredFileAsDeleted]
    @Id UNIQUEIDENTIFIER,
    @DeletedDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [dbo].[StoredFile] 
    SET IsDeleted = 1, DeletedDate = @DeletedDate 
    WHERE Id = @Id;
END
GO

CREATE OR ALTER PROCEDURE [dbo].[pr_InsertFileAuditLog]
    @Guid UNIQUEIDENTIFIER,
    @FileId UNIQUEIDENTIFIER,
    @Action NVARCHAR(100),
    @UserId INT,
    @OrganizationId INT,
    @IPAddress NVARCHAR(50),
    @CreatedDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [dbo].[FileAuditLogs] (Guid, FileId, Action, UserId, OrganizationId, IPAddress, CreatedDate)
    VALUES (@Guid, @FileId, @Action, @UserId, @OrganizationId, @IPAddress, @CreatedDate);
END
GO
