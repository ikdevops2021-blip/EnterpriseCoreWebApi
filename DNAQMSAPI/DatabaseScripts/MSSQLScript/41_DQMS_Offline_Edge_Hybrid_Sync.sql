-- ============================================================================
-- DQMS Enterprise - Database Migration Script 41
-- Feature: Offline Edge Resilience & Hybrid Sync Engine
-- Database Engine: Microsoft SQL Server (T-SQL)
-- Date: November 24, 2026
-- Description:
--   1. Alters TokenTransaction table with ClientTokenGuid (UUIDv7),
--      IsOfflineGenerated, EdgeNodeId, and SyncedAt columns.
--   2. Creates unique index UX_TokenTransaction_ClientTokenGuid for anti-collision.
--   3. Creates EdgeNodeRegistration table for branch appliance authorization.
--   4. Creates EdgeSyncAuditLog table for sync telemetry and conflict audit.
--   5. Creates stored procedures:
--      - PR_IU_EdgeNodeRegistration
--      - PR_S_EdgeNodes
--      - PR_IU_ProcessEdgeSyncBatch
--   6. Seeds NavigationMenu entry for /admin/edge-nodes.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Alter TokenTransaction with Edge Sync Columns
-- ----------------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('TokenTransaction') AND name = 'ClientTokenGuid'
)
BEGIN
    ALTER TABLE TokenTransaction ADD ClientTokenGuid UNIQUEIDENTIFIER NULL;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('TokenTransaction') AND name = 'IsOfflineGenerated'
)
BEGIN
    ALTER TABLE TokenTransaction ADD IsOfflineGenerated BIT NOT NULL CONSTRAINT DF_TokenTransaction_IsOfflineGenerated DEFAULT 0;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('TokenTransaction') AND name = 'EdgeNodeId'
)
BEGIN
    ALTER TABLE TokenTransaction ADD EdgeNodeId NVARCHAR(64) NULL;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('TokenTransaction') AND name = 'SyncedAt'
)
BEGIN
    ALTER TABLE TokenTransaction ADD SyncedAt DATETIME NULL;
END
GO

-- Unique Index to prevent duplicate token ingestion across edge retries
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'UX_TokenTransaction_ClientTokenGuid' AND object_id = OBJECT_ID('TokenTransaction')
)
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_TokenTransaction_ClientTokenGuid
    ON TokenTransaction(ClientTokenGuid)
    WHERE ClientTokenGuid IS NOT NULL;
END
GO

-- ----------------------------------------------------------------------------
-- 2. Create Table: EdgeNodeRegistration
-- ----------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'EdgeNodeRegistration')
BEGIN
    CREATE TABLE EdgeNodeRegistration (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        NodeId NVARCHAR(64) NOT NULL CONSTRAINT UQ_EdgeNode_NodeId UNIQUE,
        NodeName NVARCHAR(128) NOT NULL,
        OrganizationId INT NOT NULL,
        LocationId INT NOT NULL,
        MacAddress NVARCHAR(64) NULL,
        IpAddress NVARCHAR(64) NULL,
        SecretKeyHash NVARCHAR(256) NOT NULL,
        SoftwareVersion NVARCHAR(32) NULL,
        IsActive BIT NOT NULL CONSTRAINT DF_EdgeNode_IsActive DEFAULT 1,
        LastHeartbeatAt DATETIME NULL,
        LastSyncAt DATETIME NULL,
        PendingJournalCount INT NOT NULL CONSTRAINT DF_EdgeNode_PendingJournal DEFAULT 0,
        CreatedBy INT NOT NULL CONSTRAINT DF_EdgeNode_CreatedBy DEFAULT 0,
        CreatedDate DATETIME NOT NULL CONSTRAINT DF_EdgeNode_CreatedDate DEFAULT GETUTCDATE(),
        ModifiedBy INT NOT NULL CONSTRAINT DF_EdgeNode_ModifiedBy DEFAULT 0,
        ModifiedDate DATETIME NOT NULL CONSTRAINT DF_EdgeNode_ModifiedDate DEFAULT GETUTCDATE()
    );

    CREATE NONCLUSTERED INDEX IX_EdgeNode_OrgLocation 
    ON EdgeNodeRegistration(OrganizationId, LocationId, IsActive);
END
GO

-- ----------------------------------------------------------------------------
-- 3. Create Table: EdgeSyncAuditLog
-- ----------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'EdgeSyncAuditLog')
BEGIN
    CREATE TABLE EdgeSyncAuditLog (
        Id BIGINT IDENTITY(1,1) PRIMARY KEY,
        BatchId NVARCHAR(64) NOT NULL,
        NodeId NVARCHAR(64) NOT NULL,
        OrganizationId INT NOT NULL,
        LocationId INT NOT NULL,
        RecordsCount INT NOT NULL,
        ConflictsResolved INT NOT NULL CONSTRAINT DF_EdgeSyncAudit_Conflicts DEFAULT 0,
        DurationMs INT NOT NULL CONSTRAINT DF_EdgeSyncAudit_Duration DEFAULT 0,
        Status NVARCHAR(32) NOT NULL, -- Success, Partial, Failed
        ErrorMessage NVARCHAR(MAX) NULL,
        CreatedDate DATETIME NOT NULL CONSTRAINT DF_EdgeSyncAudit_CreatedDate DEFAULT GETUTCDATE()
    );

    CREATE NONCLUSTERED INDEX IX_EdgeSyncAudit_BatchNode
    ON EdgeSyncAuditLog(NodeId, BatchId, CreatedDate DESC);
END
GO

-- ----------------------------------------------------------------------------
-- 4. Stored Procedure: PR_IU_EdgeNodeRegistration
-- ----------------------------------------------------------------------------
IF OBJECT_ID('PR_IU_EdgeNodeRegistration', 'P') IS NOT NULL
    DROP PROCEDURE PR_IU_EdgeNodeRegistration;
GO

CREATE PROCEDURE PR_IU_EdgeNodeRegistration
    @Id INT = 0,
    @NodeId NVARCHAR(64),
    @NodeName NVARCHAR(128),
    @OrganizationId INT,
    @LocationId INT,
    @MacAddress NVARCHAR(64) = NULL,
    @IpAddress NVARCHAR(64) = NULL,
    @SecretKeyHash NVARCHAR(256),
    @SoftwareVersion NVARCHAR(32) = '1.0.0',
    @IsActive BIT = 1,
    @UserId INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF @Id = 0 OR NOT EXISTS (SELECT 1 FROM EdgeNodeRegistration WHERE Id = @Id OR NodeId = @NodeId)
    BEGIN
        INSERT INTO EdgeNodeRegistration (
            NodeId, NodeName, OrganizationId, LocationId,
            MacAddress, IpAddress, SecretKeyHash, SoftwareVersion,
            IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate
        ) VALUES (
            @NodeId, @NodeName, @OrganizationId, @LocationId,
            @MacAddress, @IpAddress, @SecretKeyHash, @SoftwareVersion,
            @IsActive, @UserId, GETUTCDATE(), @UserId, GETUTCDATE()
        );
        SELECT SCOPE_IDENTITY() AS NewId;
    END
    ELSE
    BEGIN
        UPDATE EdgeNodeRegistration
        SET NodeName = @NodeName,
            OrganizationId = @OrganizationId,
            LocationId = @LocationId,
            MacAddress = ISNULL(@MacAddress, MacAddress),
            IpAddress = ISNULL(@IpAddress, IpAddress),
            SecretKeyHash = CASE WHEN LEN(@SecretKeyHash) > 0 THEN @SecretKeyHash ELSE SecretKeyHash END,
            SoftwareVersion = ISNULL(@SoftwareVersion, SoftwareVersion),
            IsActive = @IsActive,
            ModifiedBy = @UserId,
            ModifiedDate = GETUTCDATE()
        WHERE Id = @Id OR NodeId = @NodeId;

        SELECT ISNULL(@Id, (SELECT Id FROM EdgeNodeRegistration WHERE NodeId = @NodeId)) AS NewId;
    END
END
GO

-- ----------------------------------------------------------------------------
-- 5. Stored Procedure: PR_S_EdgeNodes
-- ----------------------------------------------------------------------------
IF OBJECT_ID('PR_S_EdgeNodes', 'P') IS NOT NULL
    DROP PROCEDURE PR_S_EdgeNodes;
GO

CREATE PROCEDURE PR_S_EdgeNodes
    @OrganizationId INT = -1,
    @LocationId INT = -1,
    @NodeId NVARCHAR(64) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Id,
        NodeId,
        NodeName,
        OrganizationId,
        LocationId,
        MacAddress,
        IpAddress,
        SoftwareVersion,
        IsActive,
        LastHeartbeatAt,
        LastSyncAt,
        PendingJournalCount,
        CreatedDate,
        ModifiedDate
    FROM EdgeNodeRegistration
    WHERE (@OrganizationId = -1 OR OrganizationId = @OrganizationId)
      AND (@LocationId = -1 OR LocationId = @LocationId)
      AND (@NodeId IS NULL OR NodeId = @NodeId)
    ORDER BY LastHeartbeatAt DESC, NodeName ASC;
END
GO

-- ----------------------------------------------------------------------------
-- 6. Stored Procedure: PR_IU_ProcessEdgeSyncBatch
-- Ingests offline tokens and reconciles status transitions with state dominance
-- ----------------------------------------------------------------------------
IF OBJECT_ID('PR_IU_ProcessEdgeSyncBatch', 'P') IS NOT NULL
    DROP PROCEDURE PR_IU_ProcessEdgeSyncBatch;
GO

CREATE PROCEDURE PR_IU_ProcessEdgeSyncBatch
    @BatchId NVARCHAR(64),
    @NodeId NVARCHAR(64),
    @OrganizationId INT,
    @LocationId INT,
    @PayloadJson NVARCHAR(MAX),
    @UserId INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @StartTime DATETIME = GETUTCDATE();
        DECLARE @RecordsIngested INT = 0;
        DECLARE @ConflictsResolved INT = 0;

        -- Process each item in JSON array
        -- Expected JSON format:
        -- [
        --   {
        --     "clientTokenGuid": "...",
        --     "tokenNumber": "OFF-A-001",
        --     "processId": 1,
        --     "counterId": 1,
        --     "priorityTier": 19001,
        --     "tokenStatus": 18007,
        --     "createdDate": "2026-11-24T10:00:00Z",
        --     "calledTime": "2026-11-24T10:05:00Z",
        --     "completedTime": "2026-11-24T10:15:00Z",
        --     "customerName": "John Doe",
        --     "customerPhone": "+1234567890"
        --   }
        -- ]
        IF ISJSON(@PayloadJson) = 1
        BEGIN
            -- 1. Insert new tokens that don't exist yet in TokenTransaction
            INSERT INTO TokenTransaction (
                OrganizationId, LocationId, AreaId, ProcessId, CounterId,
                TokenNumber, PriorityTier, TokenStatus, QueuePosition,
                CreatedDate, CalledTime, CompletedTime, CustomerName, CustomerPhone,
                ClientTokenGuid, IsOfflineGenerated, EdgeNodeId, SyncedAt
            )
            SELECT 
                @OrganizationId,
                @LocationId,
                1, -- Default Area
                j.ProcessId,
                j.CounterId,
                j.TokenNumber,
                ISNULL(j.PriorityTier, 19001),
                j.TokenStatus,
                1,
                CONVERT(DATETIME, j.CreatedDate, 126),
                CASE WHEN j.CalledTime IS NOT NULL THEN CONVERT(DATETIME, j.CalledTime, 126) ELSE NULL END,
                CASE WHEN j.CompletedTime IS NOT NULL THEN CONVERT(DATETIME, j.CompletedTime, 126) ELSE NULL END,
                j.CustomerName,
                j.CustomerPhone,
                CONVERT(UNIQUEIDENTIFIER, j.ClientTokenGuid),
                1, -- IsOfflineGenerated
                @NodeId,
                GETUTCDATE()
            FROM OPENJSON(@PayloadJson)
            WITH (
                ClientTokenGuid NVARCHAR(64) '$.clientTokenGuid',
                TokenNumber NVARCHAR(32) '$.tokenNumber',
                ProcessId INT '$.processId',
                CounterId INT '$.counterId',
                PriorityTier INT '$.priorityTier',
                TokenStatus INT '$.tokenStatus',
                CreatedDate NVARCHAR(64) '$.createdDate',
                CalledTime NVARCHAR(64) '$.calledTime',
                CompletedTime NVARCHAR(64) '$.completedTime',
                CustomerName NVARCHAR(100) '$.customerName',
                CustomerPhone NVARCHAR(50) '$.customerPhone'
            ) AS j
            WHERE NOT EXISTS (
                SELECT 1 FROM TokenTransaction t 
                WHERE t.ClientTokenGuid = CONVERT(UNIQUEIDENTIFIER, j.ClientTokenGuid)
            );

            SET @RecordsIngested = @@ROWCOUNT;

            -- 2. For tokens that already existed (e.g. issued online but updated offline),
            -- apply State Dominance: Completed(18007) > Active(18004) > Calling(18003) > Waiting(18002)
            UPDATE t
            SET 
                t.TokenStatus = CASE 
                    WHEN j.TokenStatus = 18007 THEN 18007 -- Completed dominates
                    WHEN j.TokenStatus = 18004 AND t.TokenStatus NOT IN (18007) THEN 18004
                    WHEN j.TokenStatus = 18003 AND t.TokenStatus NOT IN (18004, 18007) THEN 18003
                    ELSE t.TokenStatus 
                END,
                t.CounterId = ISNULL(j.CounterId, t.CounterId),
                t.CalledTime = ISNULL(CONVERT(DATETIME, j.CalledTime, 126), t.CalledTime),
                t.CompletedTime = ISNULL(CONVERT(DATETIME, j.CompletedTime, 126), t.CompletedTime),
                t.SyncedAt = GETUTCDATE()
            FROM TokenTransaction t
            INNER JOIN OPENJSON(@PayloadJson)
            WITH (
                ClientTokenGuid NVARCHAR(64) '$.clientTokenGuid',
                CounterId INT '$.counterId',
                TokenStatus INT '$.tokenStatus',
                CalledTime NVARCHAR(64) '$.calledTime',
                CompletedTime NVARCHAR(64) '$.completedTime'
            ) AS j ON t.ClientTokenGuid = CONVERT(UNIQUEIDENTIFIER, j.ClientTokenGuid)
            WHERE t.TokenStatus <> j.TokenStatus;

            SET @ConflictsResolved = @@ROWCOUNT;
        END

        -- 3. Record Audit Log
        DECLARE @DurationMs INT = DATEDIFF(MILLISECOND, @StartTime, GETUTCDATE());

        INSERT INTO EdgeSyncAuditLog (
            BatchId, NodeId, OrganizationId, LocationId,
            RecordsCount, ConflictsResolved, DurationMs, Status
        ) VALUES (
            @BatchId, @NodeId, @OrganizationId, @LocationId,
            @RecordsIngested, @ConflictsResolved, @DurationMs, 'Success'
        );

        -- 4. Update Node LastSyncAt
        UPDATE EdgeNodeRegistration
        SET LastSyncAt = GETUTCDATE(),
            LastHeartbeatAt = GETUTCDATE(),
            PendingJournalCount = 0
        WHERE NodeId = @NodeId;

        COMMIT TRANSACTION;

        SELECT 
            @BatchId AS BatchId,
            @RecordsIngested AS RecordsIngested,
            @ConflictsResolved AS ConflictsResolved,
            @DurationMs AS DurationMs,
            'Success' AS Status;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(MAX) = ERROR_MESSAGE();

        INSERT INTO EdgeSyncAuditLog (
            BatchId, NodeId, OrganizationId, LocationId,
            RecordsCount, ConflictsResolved, DurationMs, Status, ErrorMessage
        ) VALUES (
            @BatchId, @NodeId, @OrganizationId, @LocationId,
            0, 0, 0, 'Failed', @ErrMsg
        );

        THROW;
    END CATCH
END
GO

-- ----------------------------------------------------------------------------
-- 7. Seed NavigationMenu entry for /admin/edge-nodes
-- ----------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM NavigationMenu WHERE RoutePath = '/admin/edge-nodes')
BEGIN
    INSERT INTO NavigationMenu (
        ParentId, Title, IconName, RoutePath, SortOrder,
        IsActive, RequiredPermission, CreatedBy, CreatedDate
    ) VALUES (
        0,
        'Edge Appliances & Sync',
        'hub_rounded',
        '/admin/edge-nodes',
        16,
        1,
        'Admin.EdgeSync',
        1,
        GETUTCDATE()
    );
END
GO
