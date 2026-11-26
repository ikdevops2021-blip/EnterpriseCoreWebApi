-- ============================================================================================
-- DQMS STAGE 4: MULTI-REGION DATA RESIDENCY, SHARDING & GDPR COMPLIANCE ENGINE (MSSQL)
-- Script Number: 43_DQMS_MultiRegion_DataResidency_GDPR.sql
-- Description: Geographic residency sharding, field-level AES-256 encryption columns,
--              Article 17 Right-To-Be-Forgotten cryptographic erasure, automated retention purge,
--              sovereign audit logging, and NavigationMenu seeding.
-- ============================================================================================

-- 1. OrganizationDataResidency Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'OrganizationDataResidency')
BEGIN
    CREATE TABLE dbo.OrganizationDataResidency (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        OrganizationId INT NOT NULL,
        DataRegion NVARCHAR(50) NOT NULL, -- 'eu-central-1', 'me-central-1', 'us-east-1', 'ap-south-1'
        Jurisdiction NVARCHAR(50) NOT NULL, -- 'GDPR', 'NESA', 'PDPL', 'HIPAA', 'DPDP'
        KmsKeyArn NVARCHAR(250) NULL,
        DataRetentionDays INT NOT NULL DEFAULT 90,
        AutoAnonymizeOnComplete BIT NOT NULL DEFAULT 0,
        EnableBlindIndexing BIT NOT NULL DEFAULT 1,
        AllowCrossBorderDiagnostics BIT NOT NULL DEFAULT 0,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT UQ_OrgResidency_OrgId UNIQUE (OrganizationId)
    );

    CREATE NONCLUSTERED INDEX IX_OrgDataResidency_Region
        ON dbo.OrganizationDataResidency(DataRegion, Jurisdiction);
END;
GO

-- 2. GdprAuditLog Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'GdprAuditLog')
BEGIN
    CREATE TABLE dbo.GdprAuditLog (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        OrganizationId INT NOT NULL,
        ActionType NVARCHAR(100) NOT NULL, -- 'Article17_RightToBeForgotten', 'Retention_Purge', 'Article20_DataExport'
        RecordsAffected INT NOT NULL DEFAULT 0,
        RequestedByUserId INT NOT NULL DEFAULT 1,
        AuditReason NVARCHAR(250) NULL,
        ExecutionTime DATETIME NOT NULL DEFAULT GETDATE()
    );

    CREATE NONCLUSTERED INDEX IX_GdprAuditLog_Org_Time
        ON dbo.GdprAuditLog(OrganizationId, ExecutionTime DESC);
END;
GO

-- 3. Alter TokenTransaction with Encryption & Blind Index Columns (if missing)
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'TokenTransaction')
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TokenTransaction') AND name = 'EncryptedCustomerName')
    BEGIN
        ALTER TABLE dbo.TokenTransaction ADD
            EncryptedCustomerName VARBINARY(MAX) NULL,
            EncryptedCustomerPhone VARBINARY(MAX) NULL,
            EncryptedNotes VARBINARY(MAX) NULL,
            PhoneBlindIndex NVARCHAR(64) NULL,
            NationalIdBlindIndex NVARCHAR(64) NULL,
            EncryptionKeyVersion INT NOT NULL DEFAULT 1,
            IsAnonymized BIT NOT NULL DEFAULT 0,
            AnonymizedDate DATETIME NULL;
    END;

    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_TokenTransaction_PhoneBlindIndex' AND object_id = OBJECT_ID('dbo.TokenTransaction'))
    BEGIN
        CREATE NONCLUSTERED INDEX IX_TokenTransaction_PhoneBlindIndex
        ON dbo.TokenTransaction (OrganizationId, PhoneBlindIndex)
        INCLUDE (TokenNumber, TokenStatus, CreatedDate)
        WHERE IsDeleted = 0;
    END;
END;
GO

-- ============================================================================
-- STORED PROCEDURE: UPSERT ORGANIZATION DATA RESIDENCY
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.PR_IU_OrganizationDataResidency
    @p_OrganizationId INT,
    @p_DataRegion NVARCHAR(50),
    @p_Jurisdiction NVARCHAR(50),
    @p_KmsKeyArn NVARCHAR(250) = NULL,
    @p_DataRetentionDays INT = 90,
    @p_AutoAnonymizeOnComplete BIT = 0,
    @p_EnableBlindIndexing BIT = 1,
    @p_AllowCrossBorderDiagnostics BIT = 0,
    @p_ResidencyId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.OrganizationDataResidency WHERE OrganizationId = @p_OrganizationId)
    BEGIN
        UPDATE dbo.OrganizationDataResidency
        SET DataRegion = @p_DataRegion,
            Jurisdiction = @p_Jurisdiction,
            KmsKeyArn = @p_KmsKeyArn,
            DataRetentionDays = @p_DataRetentionDays,
            AutoAnonymizeOnComplete = @p_AutoAnonymizeOnComplete,
            EnableBlindIndexing = @p_EnableBlindIndexing,
            AllowCrossBorderDiagnostics = @p_AllowCrossBorderDiagnostics,
            ModifiedDate = GETDATE()
        WHERE OrganizationId = @p_OrganizationId;

        SELECT @p_ResidencyId = Id FROM dbo.OrganizationDataResidency WHERE OrganizationId = @p_OrganizationId;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.OrganizationDataResidency (
            OrganizationId, DataRegion, Jurisdiction, KmsKeyArn,
            DataRetentionDays, AutoAnonymizeOnComplete, EnableBlindIndexing,
            AllowCrossBorderDiagnostics, CreatedDate, ModifiedDate
        ) VALUES (
            @p_OrganizationId, @p_DataRegion, @p_Jurisdiction, @p_KmsKeyArn,
            @p_DataRetentionDays, @p_AutoAnonymizeOnComplete, @p_EnableBlindIndexing,
            @p_AllowCrossBorderDiagnostics, GETDATE(), GETDATE()
        );

        SET @p_ResidencyId = SCOPE_IDENTITY();
    END;
END;
GO

-- ============================================================================
-- STORED PROCEDURE: GET ORGANIZATION DATA RESIDENCY
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.PR_S_OrganizationDataResidency
    @p_OrganizationId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @p_OrganizationId IS NOT NULL AND @p_OrganizationId > 0
    BEGIN
        SELECT 
            Id,
            OrganizationId,
            DataRegion,
            Jurisdiction,
            KmsKeyArn,
            DataRetentionDays,
            AutoAnonymizeOnComplete,
            EnableBlindIndexing,
            AllowCrossBorderDiagnostics,
            CreatedDate,
            ModifiedDate
        FROM dbo.OrganizationDataResidency
        WHERE OrganizationId = @p_OrganizationId;
    END
    ELSE
    BEGIN
        SELECT 
            Id,
            OrganizationId,
            DataRegion,
            Jurisdiction,
            KmsKeyArn,
            DataRetentionDays,
            AutoAnonymizeOnComplete,
            EnableBlindIndexing,
            AllowCrossBorderDiagnostics,
            CreatedDate,
            ModifiedDate
        FROM dbo.OrganizationDataResidency
        ORDER BY OrganizationId ASC;
    END;
END;
GO

-- ============================================================================
-- STORED PROCEDURE: GDPR ARTICLE 17 RIGHT-TO-BE-FORGOTTEN (ATOMIC ERASURE)
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.PR_IU_GdprRightToBeForgotten
    @p_OrganizationId INT,
    @p_PhoneBlindIndex NVARCHAR(64),
    @p_RequestedByUserId INT = 1,
    @p_AuditReason NVARCHAR(250) = 'GDPR Article 17 Right-To-Be-Forgotten Request',
    @p_AffectedRecordsCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @p_AffectedRecordsCount = 0;

    BEGIN TRANSACTION;
    BEGIN TRY
        -- 1. Overwrite Customer PII with irreversible synthetic tombstones while preserving queuing stats
        UPDATE dbo.TokenTransaction
        SET CustomerName = '[ANONYMIZED-GDPR-ART17]',
            CustomerPhone = '[ANONYMIZED]',
            Notes = NULL,
            EncryptedCustomerName = NULL,
            EncryptedCustomerPhone = NULL,
            EncryptedNotes = NULL,
            PhoneBlindIndex = NULL,
            NationalIdBlindIndex = NULL,
            IsAnonymized = 1,
            AnonymizedDate = GETDATE(),
            ModifiedBy = @p_RequestedByUserId,
            ModifiedDate = GETDATE()
        WHERE OrganizationId = @p_OrganizationId
          AND PhoneBlindIndex = @p_PhoneBlindIndex
          AND IsAnonymized = 0;

        SET @p_AffectedRecordsCount = @@ROWCOUNT;

        -- 2. Scrub pending notification queue items for matching phone
        DELETE FROM dbo.CustomerNotificationQueue
        WHERE OrganizationId = @p_OrganizationId
          AND (RecipientPhone = @p_PhoneBlindIndex OR Notes LIKE '%' + @p_PhoneBlindIndex + '%');

        -- 3. Insert Sovereign Audit Record
        INSERT INTO dbo.GdprAuditLog (
            OrganizationId,
            ActionType,
            RecordsAffected,
            RequestedByUserId,
            AuditReason,
            ExecutionTime
        ) VALUES (
            @p_OrganizationId,
            'Article17_RightToBeForgotten',
            @p_AffectedRecordsCount,
            @p_RequestedByUserId,
            @p_AuditReason,
            GETDATE()
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ============================================================================
-- STORED PROCEDURE: PURGE EXPIRED DATA RETENTION (CHUNKED BATCH PURGE)
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.PR_IU_PurgeExpiredDataRetention
    @p_OrganizationId INT,
    @p_PurgedCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @p_PurgedCount = 0;

    DECLARE @v_RetentionDays INT;
    SELECT @v_RetentionDays = DataRetentionDays
    FROM dbo.OrganizationDataResidency
    WHERE OrganizationId = @p_OrganizationId;

    IF @v_RetentionDays IS NULL OR @v_RetentionDays <= 0
        SET @v_RetentionDays = 90;

    DECLARE @v_CutoffDate DATETIME = DATEADD(DAY, -@v_RetentionDays, GETDATE());
    DECLARE @v_BatchRows INT = 1;
    DECLARE @v_TotalPurged INT = 0;

    -- Chunked batch execution (1,000 rows per loop) to avoid transaction log saturation
    WHILE @v_BatchRows > 0
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            UPDATE TOP (1000) dbo.TokenTransaction WITH (ROWLOCK, READPAST)
            SET CustomerName = '[PURGED-RETENTION-POLICY]',
                CustomerPhone = '[PURGED]',
                Notes = NULL,
                EncryptedCustomerName = NULL,
                EncryptedCustomerPhone = NULL,
                EncryptedNotes = NULL,
                PhoneBlindIndex = NULL,
                NationalIdBlindIndex = NULL,
                IsAnonymized = 1,
                AnonymizedDate = GETDATE()
            WHERE OrganizationId = @p_OrganizationId
              AND CreatedDate < @v_CutoffDate
              AND TokenStatus IN (18005, 18006, 18007) -- Hold, Canceled, Completed
              AND IsAnonymized = 0;

            SET @v_BatchRows = @@ROWCOUNT;
            SET @v_TotalPurged = @v_TotalPurged + @v_BatchRows;

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
    END;

    SET @p_PurgedCount = @v_TotalPurged;

    IF @p_PurgedCount > 0
    BEGIN
        INSERT INTO dbo.GdprAuditLog (
            OrganizationId, ActionType, RecordsAffected,
            RequestedByUserId, AuditReason, ExecutionTime
        ) VALUES (
            @p_OrganizationId, 'Retention_Purge', @p_PurgedCount,
            1, CONCAT('Automated purge of records older than ', @v_RetentionDays, ' days'), GETDATE()
        );
    END;
END;
GO

-- ============================================================================
-- STORED PROCEDURE: GET GDPR AUDIT LOGS
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.PR_S_GdprAuditLogs
    @p_OrganizationId INT,
    @p_PageSize INT = 50,
    @p_PageIndex INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_Offset INT = (@p_PageIndex - 1) * @p_PageSize;

    SELECT 
        Id,
        OrganizationId,
        ActionType,
        RecordsAffected,
        RequestedByUserId,
        AuditReason,
        ExecutionTime
    FROM dbo.GdprAuditLog
    WHERE OrganizationId = @p_OrganizationId
    ORDER BY ExecutionTime DESC
    OFFSET @v_Offset ROWS
    FETCH NEXT @p_PageSize ROWS ONLY;
END;
GO

-- ============================================================================
-- SEED NAVIGATION MENU FOR DATA RESIDENCY & PRIVACY (MSSQL)
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM dbo.NavigationMenu WHERE RouteUrl = '/admin/data-residency')
BEGIN
    DECLARE @v_adminParentId INT = NULL;
    SELECT TOP 1 @v_adminParentId = Id FROM dbo.NavigationMenu WHERE RouteUrl = '/admin' OR Title LIKE '%Admin%' ORDER BY Id ASC;

    INSERT INTO dbo.NavigationMenu (
        ParentId, Title, RouteUrl, IconName, DisplayOrder,
        RequiredPermission, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
    ) VALUES (
        @v_adminParentId, 'Data Residency & GDPR', '/admin/data-residency', 'security_rounded', 20,
        'Privacy.Manage', 1, 1, GETDATE(), 1, GETDATE(), 0
    );
END;
GO
