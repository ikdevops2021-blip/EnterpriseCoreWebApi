DELIMITER //

DROP PROCEDURE IF EXISTS pr_GetOrganizationStorageConfig //
CREATE PROCEDURE pr_GetOrganizationStorageConfig(
    IN p_OrganizationId INT,
    IN p_ProviderName VARCHAR(100)
)
BEGIN
    SELECT * FROM OrganizationStorageConfig 
    WHERE (OrganizationId = p_OrganizationId OR OrganizationId = 0)
      AND ProviderName = p_ProviderName 
      AND IsDeleted = 0;
END //

DROP PROCEDURE IF EXISTS pr_GetStoredFileMetadata //
CREATE PROCEDURE pr_GetStoredFileMetadata(
    IN p_Id CHAR(36)
)
BEGIN
    SELECT * FROM StoredFile WHERE Id = p_Id;
END //

DROP PROCEDURE IF EXISTS pr_InsertStoredFileMetadata //
CREATE PROCEDURE pr_InsertStoredFileMetadata(
    IN p_Id CHAR(36),
    IN p_FileName VARCHAR(255),
    IN p_ContentType VARCHAR(100),
    IN p_SizeBytes BIGINT,
    IN p_StorageProvider VARCHAR(100),
    IN p_PathOrUrl VARCHAR(1000),
    IN p_OrganizationId INT,
    IN p_CreatedBy INT,
    IN p_CreatedDate DATETIME
)
BEGIN
    INSERT INTO StoredFile (
        Id, FileName, ContentType, SizeBytes, StorageProvider, 
        PathOrUrl, OrganizationId, CreatedBy, CreatedDate
    )
    VALUES (
        p_Id, p_FileName, p_ContentType, p_SizeBytes, p_StorageProvider, 
        p_PathOrUrl, p_OrganizationId, p_CreatedBy, p_CreatedDate
    );
END //

DROP PROCEDURE IF EXISTS pr_MarkStoredFileAsDeleted //
CREATE PROCEDURE pr_MarkStoredFileAsDeleted(
    IN p_Id CHAR(36),
    IN p_DeletedDate DATETIME
)
BEGIN
    UPDATE StoredFile 
    SET IsDeleted = 1, DeletedDate = p_DeletedDate 
    WHERE Id = p_Id;
END //

DROP PROCEDURE IF EXISTS pr_InsertFileAuditLog //
CREATE PROCEDURE pr_InsertFileAuditLog(
    IN p_Guid CHAR(36),
    IN p_FileId CHAR(36),
    IN p_Action VARCHAR(100),
    IN p_UserId INT,
    IN p_OrganizationId INT,
    IN p_IPAddress VARCHAR(50),
    IN p_CreatedDate DATETIME
)
BEGIN
    INSERT INTO FileAuditLogs (Guid, FileId, Action, UserId, OrganizationId, IPAddress, CreatedDate)
    VALUES (p_Guid, p_FileId, p_Action, p_UserId, p_OrganizationId, p_IPAddress, p_CreatedDate);
END //

DELIMITER ;
