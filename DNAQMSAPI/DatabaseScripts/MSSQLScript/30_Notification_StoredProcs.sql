-- ===================================================================================
-- DNAQMS API - NOTIFICATION & MESSAGING STORED PROCEDURES (MS SQL Server)
-- File Path: DNAQMSAPI/DatabaseScripts/MSSQLScript/30_Notification_StoredProcs.sql
-- ===================================================================================

USE [dnaqms];
GO

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. PR_S_NotificationTemplate: Template lookup joining ConfigParameters (Category 17: C_NOTIFICATION_EVENT)
-- ─────────────────────────────────────────────────────────────────────────────
IF OBJECT_ID('dbo.PR_S_NotificationTemplate', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_S_NotificationTemplate;
GO
CREATE PROCEDURE dbo.PR_S_NotificationTemplate
    @p_Id             INT = -1,
    @p_OrganizationId INT = -1,
    @p_EventCode      NVARCHAR(100) = '',
    @p_EventId        INT = -1
AS
BEGIN
    SET NOCOUNT ON;

    IF ISNULL(@p_Id, -1) > 0
    BEGIN
        SELECT t.*, o.Name AS OrganizationName, cp.ParameterName AS EventName
        FROM [NotificationTemplate] t WITH(NOLOCK)
        LEFT JOIN [Organization] o WITH(NOLOCK) ON t.OrganizationId = o.Id
        LEFT JOIN [ConfigParameters] cp WITH(NOLOCK) ON t.EventId = cp.ParameterID AND cp.IsDeleted = 0
        WHERE t.Id = @p_Id AND t.IsDeleted = 0;
    END
    ELSE IF ISNULL(@p_EventId, -1) > 0 OR ISNULL(@p_EventCode, '') != ''
    BEGIN
        -- Try Center-specific template first; fallback to Global (OrganizationId IS NULL)
        SELECT TOP 1 t.*, o.Name AS OrganizationName, cp.ParameterName AS EventName
        FROM [NotificationTemplate] t WITH(NOLOCK)
        LEFT JOIN [Organization] o WITH(NOLOCK) ON t.OrganizationId = o.Id
        LEFT JOIN [ConfigParameters] cp WITH(NOLOCK) ON t.EventId = cp.ParameterID AND cp.IsDeleted = 0
        WHERE ( (ISNULL(@p_EventId, -1) > 0 AND t.EventId = @p_EventId) OR (ISNULL(@p_EventCode, '') != '' AND (t.EventCode = @p_EventCode OR cp.ParameterCode = @p_EventCode)) )
          AND t.IsDeleted = 0 
          AND t.IsActive = 1
          AND (@p_OrganizationId IS NULL OR @p_OrganizationId = -1 OR t.OrganizationId = @p_OrganizationId OR t.OrganizationId IS NULL)
        ORDER BY t.OrganizationId DESC; -- Non-null Center template ranks ahead of NULL global
    END
    ELSE
    BEGIN
        SELECT t.*, o.Name AS OrganizationName, cp.ParameterName AS EventName
        FROM [NotificationTemplate] t WITH(NOLOCK)
        LEFT JOIN [Organization] o WITH(NOLOCK) ON t.OrganizationId = o.Id
        LEFT JOIN [ConfigParameters] cp WITH(NOLOCK) ON t.EventId = cp.ParameterID AND cp.IsDeleted = 0
        WHERE t.IsDeleted = 0
          AND (ISNULL(@p_OrganizationId, -1) = -1 OR t.OrganizationId = @p_OrganizationId OR t.OrganizationId IS NULL)
        ORDER BY t.EventId ASC, t.OrganizationId DESC;
    END
END
GO

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. PR_IU_NotificationTemplate: Create or Update Notification Template
-- ─────────────────────────────────────────────────────────────────────────────
IF OBJECT_ID('dbo.PR_IU_NotificationTemplate', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_IU_NotificationTemplate;
GO
CREATE PROCEDURE dbo.PR_IU_NotificationTemplate
    @p_Id              INT = 0 OUTPUT,
    @p_OrganizationId  INT = NULL,
    @p_EventId         INT = NULL,
    @p_EventCode       NVARCHAR(100) = NULL,
    @p_CategoryId      INT = 2001,
    @p_SubjectTemplate NVARCHAR(255) = '',
    @p_BodyTemplate     NVARCHAR(MAX) = '',
    @p_SendInApp       BIT = 1,
    @p_SendEmail       BIT = 1,
    @p_SendSMS         BIT = 0,
    @p_IsActive        BIT = 1,
    @p_UID             INT = -1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err INT = 0, @rowscount INT = 0, @errMsg VARCHAR(300) = '', @errLine INT = 0;
    DECLARE @duplicateID INT = 0;

    BEGIN TRY
        IF ISNULL(@p_EventId, 0) <= 0 AND ISNULL(@p_EventCode, '') != ''
        BEGIN
            SELECT TOP 1 @p_EventId = ParameterID FROM [ConfigParameters] WITH(NOLOCK)
            WHERE CategoryID = 17 AND ParameterCode = LTRIM(RTRIM(@p_EventCode)) AND IsDeleted = 0;
        END

        IF ISNULL(@p_EventId, 0) <= 0
        BEGIN
            SELECT @err = 52, @errMsg = 'Invalid EventId or EventCode! Event must be registered in ConfigParameters under category C_NOTIFICATION_EVENT (17).';
            GOTO ExResult;
        END

        IF ISNULL(@p_EventCode, '') = ''
        BEGIN
            SELECT TOP 1 @p_EventCode = ParameterCode FROM [ConfigParameters] WITH(NOLOCK) WHERE ParameterID = @p_EventId;
        END

        IF EXISTS(SELECT 1 FROM [NotificationTemplate] WITH(NOLOCK) 
                  WHERE EventId = @p_EventId 
                    AND ((@p_OrganizationId IS NULL AND OrganizationId IS NULL) OR OrganizationId = @p_OrganizationId)
                    AND IsDeleted = 0 
                    AND (ISNULL(@p_Id, 0) <= 0 OR Id <> @p_Id))
        BEGIN
            SELECT TOP 1 @duplicateID = Id FROM [NotificationTemplate] WITH(NOLOCK) 
            WHERE EventId = @p_EventId 
              AND ((@p_OrganizationId IS NULL AND OrganizationId IS NULL) OR OrganizationId = @p_OrganizationId)
              AND IsDeleted = 0 
              AND (ISNULL(@p_Id, 0) <= 0 OR Id <> @p_Id);
            SELECT @err = 51, @errMsg = 'Duplicate Template! EventId ' + CAST(@p_EventId AS VARCHAR(10)) + ' already exists with ID ' + CAST(@duplicateID AS VARCHAR(10));
            GOTO ExResult;
        END

        BEGIN TRANSACTION;

        IF ISNULL(@p_Id, 0) <= 0
        BEGIN
            INSERT INTO [NotificationTemplate] (
                OrganizationId, EventId, EventCode, CategoryId, SubjectTemplate, BodyTemplate,
                SendInApp, SendEmail, SendSMS, IsActive,
                CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
            ) VALUES (
                @p_OrganizationId, @p_EventId, LTRIM(RTRIM(@p_EventCode)), @p_CategoryId, LTRIM(RTRIM(@p_SubjectTemplate)), LTRIM(RTRIM(@p_BodyTemplate)),
                ISNULL(@p_SendInApp, 1), ISNULL(@p_SendEmail, 1), ISNULL(@p_SendSMS, 0), ISNULL(@p_IsActive, 1),
                @p_UID, GETDATE(), @p_UID, GETDATE(), 0
            );

            SET @p_Id = SCOPE_IDENTITY();
            SELECT @rowscount = @@ROWCOUNT;
        END
        ELSE
        BEGIN
            UPDATE [NotificationTemplate]
            SET OrganizationId  = @p_OrganizationId,
                EventId         = @p_EventId,
                EventCode       = LTRIM(RTRIM(@p_EventCode)),
                CategoryId      = @p_CategoryId,
                SubjectTemplate = LTRIM(RTRIM(@p_SubjectTemplate)),
                BodyTemplate    = LTRIM(RTRIM(@p_BodyTemplate)),
                SendInApp       = ISNULL(@p_SendInApp, SendInApp),
                SendEmail       = ISNULL(@p_SendEmail, SendEmail),
                SendSMS         = ISNULL(@p_SendSMS, SendSMS),
                IsActive        = ISNULL(@p_IsActive, IsActive),
                ModifiedBy      = @p_UID,
                ModifiedDate    = GETDATE()
            WHERE Id = @p_Id AND IsDeleted = 0;

            SELECT @rowscount = @@ROWCOUNT;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT @p_Id = 0, @err = ISNULL(ERROR_NUMBER(), 50000), @errMsg = ISNULL(ERROR_MESSAGE(), ''), @errLine = ISNULL(ERROR_LINE(), 0);
    END CATCH

ExResult:
    SELECT ISNULL(@p_Id, 0) AS ID, ISNULL(@err, 0) AS ErrNo, ISNULL(@rowscount, 0) AS RowsCount, ISNULL(@errMsg, '') AS ErrMsg, ISNULL(@errLine, 0) AS ErrLine;
END
GO

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. PR_S_UserNotification: Get In-App Notification Bell Feed
-- ─────────────────────────────────────────────────────────────────────────────
IF OBJECT_ID('dbo.PR_S_UserNotification', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_S_UserNotification;
GO
CREATE PROCEDURE dbo.PR_S_UserNotification
    @p_UserId         INT,
    @p_OrganizationId INT = -1,
    @p_IsRead         SMALLINT = -1, -- -1: All, 0: Unread, 1: Read
    @p_PageNumber     INT = 1,
    @p_PageSize       INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    SET @p_PageNumber = IIF(ISNULL(@p_PageNumber, 1) < 1, 1, @p_PageNumber);
    SET @p_PageSize = IIF(ISNULL(@p_PageSize, 20) < 1, 20, @p_PageSize);
    DECLARE @Offset INT = (@p_PageNumber - 1) * @p_PageSize;

    SELECT 
        n.Id,
        n.OrganizationId,
        o.Name AS OrganizationName,
        n.UserId,
        n.EventId,
        n.EventCode,
        cp.ParameterName AS EventName,
        n.CategoryId,
        n.Title,
        n.Message,
        n.ActionUrl,
        n.IsRead,
        n.ReadDate,
        n.CreatedDate
    FROM [UserNotification] n WITH(NOLOCK)
    INNER JOIN [Organization] o WITH(NOLOCK) ON n.OrganizationId = o.Id
    LEFT JOIN [ConfigParameters] cp WITH(NOLOCK) ON n.EventId = cp.ParameterID AND cp.IsDeleted = 0
    WHERE n.UserId = @p_UserId
      AND n.IsDeleted = 0
      AND (ISNULL(@p_OrganizationId, -1) = -1 OR n.OrganizationId = @p_OrganizationId)
      AND (ISNULL(@p_IsRead, -1) NOT IN (0, 1) OR n.IsRead = @p_IsRead)
    ORDER BY n.CreatedDate DESC
    OFFSET @Offset ROWS FETCH NEXT @p_PageSize ROWS ONLY;
END
GO

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. PR_S_UnreadNotificationCount: Get Unread Notification Badge Count
-- ─────────────────────────────────────────────────────────────────────────────
IF OBJECT_ID('dbo.PR_S_UnreadNotificationCount', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_S_UnreadNotificationCount;
GO
CREATE PROCEDURE dbo.PR_S_UnreadNotificationCount
    @p_UserId         INT,
    @p_OrganizationId INT = -1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(*) AS UnreadCount
    FROM [UserNotification] WITH(NOLOCK)
    WHERE UserId = @p_UserId
      AND IsRead = 0
      AND IsDeleted = 0
      AND (ISNULL(@p_OrganizationId, -1) = -1 OR OrganizationId = @p_OrganizationId);
END
GO

-- ─────────────────────────────────────────────────────────────────────────────
-- 5. PR_IU_UserNotification: Insert Notification or Mark Single Read
-- ─────────────────────────────────────────────────────────────────────────────
IF OBJECT_ID('dbo.PR_IU_UserNotification', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_IU_UserNotification;
GO
CREATE PROCEDURE dbo.PR_IU_UserNotification
    @p_Id             BIGINT = 0 OUTPUT,
    @p_OrganizationId INT = NULL,
    @p_UserId         INT = NULL,
    @p_EventId        INT = NULL,
    @p_EventCode      NVARCHAR(100) = NULL,
    @p_CategoryId     INT = NULL,
    @p_Title          NVARCHAR(255) = NULL,
    @p_Message        NVARCHAR(MAX) = NULL,
    @p_ActionUrl      NVARCHAR(500) = NULL,
    @p_IsRead         BIT = 0,
    @p_UID            INT = -1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err INT = 0, @rowscount INT = 0, @errMsg VARCHAR(300) = '', @errLine INT = 0;

    BEGIN TRY
        IF ISNULL(@p_EventId, 0) <= 0 AND ISNULL(@p_EventCode, '') != ''
        BEGIN
            SELECT TOP 1 @p_EventId = ParameterID FROM [ConfigParameters] WITH(NOLOCK)
            WHERE CategoryID = 17 AND ParameterCode = LTRIM(RTRIM(@p_EventCode)) AND IsDeleted = 0;
        END

        BEGIN TRANSACTION;

        IF ISNULL(@p_Id, 0) <= 0
        BEGIN
            INSERT INTO [UserNotification] (
                OrganizationId, UserId, EventId, EventCode, CategoryId, Title, Message, ActionUrl, IsRead,
                CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
            ) VALUES (
                @p_OrganizationId, @p_UserId, @p_EventId, LTRIM(RTRIM(@p_EventCode)), @p_CategoryId, LTRIM(RTRIM(@p_Title)), LTRIM(RTRIM(@p_Message)), LTRIM(RTRIM(@p_ActionUrl)), ISNULL(@p_IsRead, 0),
                @p_UID, GETDATE(), @p_UID, GETDATE(), 0
            );

            SET @p_Id = SCOPE_IDENTITY();
            SELECT @rowscount = @@ROWCOUNT;
        END
        ELSE
        BEGIN
            UPDATE [UserNotification]
            SET IsRead       = ISNULL(@p_IsRead, IsRead),
                ReadDate     = IIF(@p_IsRead = 1, GETDATE(), ReadDate),
                ModifiedBy   = @p_UID,
                ModifiedDate = GETDATE()
            WHERE Id = @p_Id AND UserId = @p_UserId AND IsDeleted = 0;

            SELECT @rowscount = @@ROWCOUNT;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT @p_Id = 0, @err = ISNULL(ERROR_NUMBER(), 50000), @errMsg = ISNULL(ERROR_MESSAGE(), ''), @errLine = ISNULL(ERROR_LINE(), 0);
    END CATCH

ExResult:
    SELECT ISNULL(@p_Id, 0) AS ID, ISNULL(@err, 0) AS ErrNo, ISNULL(@rowscount, 0) AS RowsCount, ISNULL(@errMsg, '') AS ErrMsg, ISNULL(@errLine, 0) AS ErrLine;
END
GO

-- ─────────────────────────────────────────────────────────────────────────────
-- 6. PR_U_MarkAllNotificationsRead: Mark all notifications read for user
-- ─────────────────────────────────────────────────────────────────────────────
IF OBJECT_ID('dbo.PR_U_MarkAllNotificationsRead', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_U_MarkAllNotificationsRead;
GO
CREATE PROCEDURE dbo.PR_U_MarkAllNotificationsRead
    @p_UserId         INT,
    @p_OrganizationId INT = -1
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [UserNotification]
    SET IsRead       = 1,
        ReadDate     = GETDATE(),
        ModifiedBy   = @p_UserId,
        ModifiedDate = GETDATE()
    WHERE UserId = @p_UserId
      AND IsRead = 0
      AND IsDeleted = 0
      AND (ISNULL(@p_OrganizationId, -1) = -1 OR OrganizationId = @p_OrganizationId);

    SELECT @@ROWCOUNT AS AffectedRows;
END
GO
