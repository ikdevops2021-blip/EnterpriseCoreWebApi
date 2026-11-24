-- ============================================================================================
-- DQMS STAGE 4: WEBHOOK NOTIFICATION ENGINE (MS SQL Server)
-- Script Number: 40_DQMS_Webhook_Notification_Engine.sql
-- Description: Creates WebhookSubscription and WebhookDeliveryLog tables, indexes,
--              stored procedures (PR_IU_WebhookSubscription, PR_S_WebhookSubscriptions,
--              PR_D_WebhookSubscription, PR_IU_WebhookDeliveryLog, PR_S_WebhookDeliveryLogs),
--              and seeds NavigationMenu for '/admin/webhooks'.
-- ============================================================================================

USE [dnaqms];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================================
-- 1. Table: WebhookSubscription (Registry of external HTTP consumer endpoints)
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WebhookSubscription]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[WebhookSubscription] (
        [Id]                  INT IDENTITY(1,1) PRIMARY KEY,
        [OrganizationId]      INT NOT NULL,
        [LocationId]          INT NULL,                               -- NULL = all locations in organization
        [Name]                NVARCHAR(150) NOT NULL,                 -- e.g. "Main Hospital HIS Integration"
        [EndpointUrl]         NVARCHAR(500) NOT NULL,                 -- Target HTTPS webhook endpoint
        [SecretKey]           NVARCHAR(128) NOT NULL,                 -- Cryptographic signing secret (whsec_...)
        [SubscribedEvents]    NVARCHAR(255) NOT NULL,                 -- Comma-separated (token.issued,token.called,etc.)
        [IsActive]            BIT NOT NULL DEFAULT 1,
        [MaxRetryAttempts]    INT NOT NULL DEFAULT 3,
        [TimeoutSeconds]      INT NOT NULL DEFAULT 10,
        [ConsecutiveFailures] INT NOT NULL DEFAULT 0,                 -- Circuit breaker failure counter
        [CircuitBreakerUntil] DATETIME NULL,                          -- Cooldown deadline if circuit breaker tripped
        [CreatedBy]           INT NOT NULL DEFAULT 0,
        [CreatedDate]         DATETIME NOT NULL DEFAULT GETDATE(),
        [ModifiedBy]          INT NOT NULL DEFAULT 0,
        [ModifiedDate]        DATETIME NOT NULL DEFAULT GETDATE(),
        [IsDeleted]           BIT NOT NULL DEFAULT 0,
        [DeletedBy]           INT NULL,
        [DeletedDate]         DATETIME NULL
    );

    CREATE NONCLUSTERED INDEX [IX_WebhookSubscription_ActiveLookup]
    ON [dbo].[WebhookSubscription] ([OrganizationId], [IsActive], [IsDeleted])
    INCLUDE ([LocationId], [Name], [EndpointUrl], [SecretKey], [SubscribedEvents], [TimeoutSeconds], [ConsecutiveFailures], [CircuitBreakerUntil]);
END
GO

-- ============================================================================
-- 2. Table: WebhookDeliveryLog (Delivery audit, HTTP latency, payload history)
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WebhookDeliveryLog]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[WebhookDeliveryLog] (
        [Id]                    BIGINT IDENTITY(1,1) PRIMARY KEY,
        [DeliveryId]            NVARCHAR(64) NOT NULL,                -- Unique dispatch idempotency ID (evt_guid)
        [WebhookSubscriptionId] INT NOT NULL,
        [OrganizationId]        INT NOT NULL,
        [EventCode]             NVARCHAR(50) NOT NULL,                -- token.called, token.completed, etc.
        [PayloadJson]           NVARCHAR(MAX) NOT NULL,
        [ResponseStatusCode]    INT NULL,                             -- HTTP status code (200, 500, or 0 on timeout)
        [ResponseBody]          NVARCHAR(1000) NULL,                  -- HTTP response snippet or error reason
        [DurationMs]            INT NOT NULL DEFAULT 0,               -- Round-trip dispatch latency in milliseconds
        [AttemptCount]          INT NOT NULL DEFAULT 1,
        [DeliveryStatus]        NVARCHAR(30) NOT NULL DEFAULT 'Success', -- Success, PendingRetry, DeadLetter
        [NextRetryTime]         DATETIME NULL,
        [CreatedDate]           DATETIME NOT NULL DEFAULT GETDATE(),

        CONSTRAINT [FK_WebhookDeliveryLog_Subscription]
            FOREIGN KEY ([WebhookSubscriptionId]) REFERENCES [dbo].[WebhookSubscription]([Id])
    );

    CREATE NONCLUSTERED INDEX [IX_WebhookDeliveryLog_Lookup]
    ON [dbo].[WebhookDeliveryLog] ([WebhookSubscriptionId], [CreatedDate] DESC)
    INCLUDE ([EventCode], [ResponseStatusCode], [DurationMs], [DeliveryStatus], [AttemptCount]);
END
GO

-- ============================================================================
-- 3. Stored Procedure: PR_IU_WebhookSubscription
-- ============================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_IU_WebhookSubscription]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[PR_IU_WebhookSubscription];
GO

CREATE PROCEDURE [dbo].[PR_IU_WebhookSubscription]
    @p_Id INT = 0,
    @p_OrganizationId INT,
    @p_LocationId INT = NULL,
    @p_Name NVARCHAR(150),
    @p_EndpointUrl NVARCHAR(500),
    @p_SecretKey NVARCHAR(128),
    @p_SubscribedEvents NVARCHAR(255),
    @p_IsActive BIT = 1,
    @p_MaxRetryAttempts INT = 3,
    @p_TimeoutSeconds INT = 10,
    @p_UserId INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF (@p_Id IS NULL OR @p_Id <= 0)
    BEGIN
        INSERT INTO [dbo].[WebhookSubscription]
        (
            [OrganizationId], [LocationId], [Name], [EndpointUrl], [SecretKey],
            [SubscribedEvents], [IsActive], [MaxRetryAttempts], [TimeoutSeconds],
            [ConsecutiveFailures], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsDeleted]
        )
        VALUES
        (
            @p_OrganizationId, @p_LocationId, @p_Name, @p_EndpointUrl, @p_SecretKey,
            @p_SubscribedEvents, @p_IsActive, @p_MaxRetryAttempts, @p_TimeoutSeconds,
            0, @p_UserId, GETDATE(), @p_UserId, GETDATE(), 0
        );

        SELECT SCOPE_IDENTITY() AS [NewId];
    END
    ELSE
    BEGIN
        UPDATE [dbo].[WebhookSubscription]
        SET
            [OrganizationId] = @p_OrganizationId,
            [LocationId] = @p_LocationId,
            [Name] = @p_Name,
            [EndpointUrl] = @p_EndpointUrl,
            [SecretKey] = CASE WHEN @p_SecretKey IS NOT NULL AND LEN(@p_SecretKey) > 0 THEN @p_SecretKey ELSE [SecretKey] END,
            [SubscribedEvents] = @p_SubscribedEvents,
            [IsActive] = @p_IsActive,
            [MaxRetryAttempts] = @p_MaxRetryAttempts,
            [TimeoutSeconds] = @p_TimeoutSeconds,
            [ModifiedBy] = @p_UserId,
            [ModifiedDate] = GETDATE()
        WHERE [Id] = @p_Id AND [IsDeleted] = 0;

        SELECT @p_Id AS [NewId];
    END
END
GO

-- ============================================================================
-- 4. Stored Procedure: PR_S_WebhookSubscriptions
-- ============================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_S_WebhookSubscriptions]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[PR_S_WebhookSubscriptions];
GO

CREATE PROCEDURE [dbo].[PR_S_WebhookSubscriptions]
    @p_OrganizationId INT = -1,
    @p_LocationId INT = -1,
    @p_Id INT = -1,
    @p_IsActive INT = -1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.[Id],
        s.[OrganizationId],
        s.[LocationId],
        s.[Name],
        s.[EndpointUrl],
        s.[SecretKey],
        s.[SubscribedEvents],
        s.[IsActive],
        s.[MaxRetryAttempts],
        s.[TimeoutSeconds],
        s.[ConsecutiveFailures],
        s.[CircuitBreakerUntil],
        s.[CreatedBy],
        s.[CreatedDate],
        s.[ModifiedBy],
        s.[ModifiedDate],
        (
            SELECT TOP 1 l.[DeliveryStatus]
            FROM [dbo].[WebhookDeliveryLog] l
            WHERE l.[WebhookSubscriptionId] = s.[Id]
            ORDER BY l.[CreatedDate] DESC
        ) AS [LastDeliveryStatus],
        (
            SELECT TOP 1 l.[ResponseStatusCode]
            FROM [dbo].[WebhookDeliveryLog] l
            WHERE l.[WebhookSubscriptionId] = s.[Id]
            ORDER BY l.[CreatedDate] DESC
        ) AS [LastResponseStatusCode],
        (
            SELECT TOP 1 l.[CreatedDate]
            FROM [dbo].[WebhookDeliveryLog] l
            WHERE l.[WebhookSubscriptionId] = s.[Id]
            ORDER BY l.[CreatedDate] DESC
        ) AS [LastDeliveryDate]
    FROM [dbo].[WebhookSubscription] s
    WHERE s.[IsDeleted] = 0
      AND (@p_Id = -1 OR s.[Id] = @p_Id)
      AND (@p_OrganizationId = -1 OR s.[OrganizationId] = @p_OrganizationId)
      AND (@p_LocationId = -1 OR s.[LocationId] IS NULL OR s.[LocationId] = @p_LocationId)
      AND (@p_IsActive = -1 OR s.[IsActive] = @p_IsActive)
    ORDER BY s.[CreatedDate] DESC;
END
GO

-- ============================================================================
-- 5. Stored Procedure: PR_D_WebhookSubscription
-- ============================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_D_WebhookSubscription]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[PR_D_WebhookSubscription];
GO

CREATE PROCEDURE [dbo].[PR_D_WebhookSubscription]
    @p_Id INT,
    @p_UserId INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[WebhookSubscription]
    SET
        [IsDeleted] = 1,
        [DeletedBy] = @p_UserId,
        [DeletedDate] = GETDATE()
    WHERE [Id] = @p_Id;

    SELECT @@ROWCOUNT AS [RowsAffected];
END
GO

-- ============================================================================
-- 6. Stored Procedure: PR_IU_WebhookDeliveryLog
-- ============================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_IU_WebhookDeliveryLog]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[PR_IU_WebhookDeliveryLog];
GO

CREATE PROCEDURE [dbo].[PR_IU_WebhookDeliveryLog]
    @p_DeliveryId NVARCHAR(64),
    @p_WebhookSubscriptionId INT,
    @p_OrganizationId INT,
    @p_EventCode NVARCHAR(50),
    @p_PayloadJson NVARCHAR(MAX),
    @p_ResponseStatusCode INT = NULL,
    @p_ResponseBody NVARCHAR(1000) = NULL,
    @p_DurationMs INT = 0,
    @p_AttemptCount INT = 1,
    @p_DeliveryStatus NVARCHAR(30) = 'Success',
    @p_NextRetryTime DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[WebhookDeliveryLog]
    (
        [DeliveryId], [WebhookSubscriptionId], [OrganizationId], [EventCode],
        [PayloadJson], [ResponseStatusCode], [ResponseBody], [DurationMs],
        [AttemptCount], [DeliveryStatus], [NextRetryTime], [CreatedDate]
    )
    VALUES
    (
        @p_DeliveryId, @p_WebhookSubscriptionId, @p_OrganizationId, @p_EventCode,
        @p_PayloadJson, @p_ResponseStatusCode, @p_ResponseBody, @p_DurationMs,
        @p_AttemptCount, @p_DeliveryStatus, @p_NextRetryTime, GETDATE()
    );

    -- Update subscription health / consecutive failures
    IF (@p_DeliveryStatus = 'Success')
    BEGIN
        UPDATE [dbo].[WebhookSubscription]
        SET [ConsecutiveFailures] = 0,
            [CircuitBreakerUntil] = NULL
        WHERE [Id] = @p_WebhookSubscriptionId;
    END
    ELSE
    BEGIN
        UPDATE [dbo].[WebhookSubscription]
        SET [ConsecutiveFailures] = [ConsecutiveFailures] + 1,
            [CircuitBreakerUntil] = CASE 
                WHEN [ConsecutiveFailures] + 1 >= 10 THEN DATEADD(MINUTE, 15, GETDATE()) 
                ELSE [CircuitBreakerUntil] 
            END
        WHERE [Id] = @p_WebhookSubscriptionId;
    END

    SELECT SCOPE_IDENTITY() AS [LogId];
END
GO

-- ============================================================================
-- 7. Stored Procedure: PR_S_WebhookDeliveryLogs
-- ============================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PR_S_WebhookDeliveryLogs]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[PR_S_WebhookDeliveryLogs];
GO

CREATE PROCEDURE [dbo].[PR_S_WebhookDeliveryLogs]
    @p_WebhookSubscriptionId INT = -1,
    @p_OrganizationId INT = -1,
    @p_DeliveryStatus NVARCHAR(30) = NULL,
    @p_PageNumber INT = 1,
    @p_PageSize INT = 50
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@p_PageNumber - 1) * @p_PageSize;

    SELECT
        l.[Id],
        l.[DeliveryId],
        l.[WebhookSubscriptionId],
        s.[Name] AS [SubscriptionName],
        l.[OrganizationId],
        l.[EventCode],
        l.[PayloadJson],
        l.[ResponseStatusCode],
        l.[ResponseBody],
        l.[DurationMs],
        l.[AttemptCount],
        l.[DeliveryStatus],
        l.[NextRetryTime],
        l.[CreatedDate]
    FROM [dbo].[WebhookDeliveryLog] l
    INNER JOIN [dbo].[WebhookSubscription] s ON l.[WebhookSubscriptionId] = s.[Id]
    WHERE (@p_WebhookSubscriptionId = -1 OR l.[WebhookSubscriptionId] = @p_WebhookSubscriptionId)
      AND (@p_OrganizationId = -1 OR l.[OrganizationId] = @p_OrganizationId)
      AND (@p_DeliveryStatus IS NULL OR l.[DeliveryStatus] = @p_DeliveryStatus)
    ORDER BY l.[CreatedDate] DESC
    OFFSET @Offset ROWS
    FETCH NEXT @p_PageSize ROWS ONLY;
END
GO

-- ============================================================================
-- 8. Seed NavigationMenu Entry: /admin/webhooks
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[NavigationMenu] WHERE [RoutePath] = '/admin/webhooks')
BEGIN
    INSERT INTO [dbo].[NavigationMenu]
    (
        [Title], [IconName], [RoutePath], [SortOrder], [ParentId], [RequiredPermission],
        [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsDeleted]
    )
    VALUES
    (
        'Webhook Integrations', 'webhook_rounded', '/admin/webhooks', 15, NULL, 'Admin',
        1, 1, GETDATE(), 1, GETDATE(), 0
    );
END
GO
