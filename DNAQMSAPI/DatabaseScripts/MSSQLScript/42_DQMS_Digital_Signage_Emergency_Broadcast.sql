-- ============================================================================================
-- DQMS STAGE 4: DIGITAL SIGNAGE CAMPAIGNS & EMERGENCY PUBLIC BROADCAST ENGINE (MSSQL)
-- Script Number: 42_DQMS_Digital_Signage_Emergency_Broadcast.sql
-- Description: Rich media video/image campaigns, time-slot scheduling, and real-time emergency broadcast overlay.
-- ============================================================================================

-- 1. SignageCampaign Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SignageCampaign')
BEGIN
    CREATE TABLE dbo.SignageCampaign (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        OrganizationId INT NOT NULL,
        CampaignName NVARCHAR(150) NOT NULL,
        CampaignType INT NOT NULL DEFAULT 1, -- 1=Promotional, 2=Health Advisory, 3=Corporate
        Priority INT NOT NULL DEFAULT 5,     -- 1 (Lowest) to 10 (Highest)
        StartDate DATETIME NOT NULL,
        EndDate DATETIME NOT NULL,
        DailyStartTime TIME NULL,            -- e.g. '08:00:00'
        DailyEndTime TIME NULL,              -- e.g. '18:00:00'
        DaysOfWeek NVARCHAR(30) NOT NULL DEFAULT '1,2,3,4,5,6,7',
        IsActive BIT NOT NULL DEFAULT 1,
        CreatedBy INT NOT NULL DEFAULT 1,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        ModifiedBy INT NOT NULL DEFAULT 1,
        ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(),
        IsDeleted BIT NOT NULL DEFAULT 0
    );

    CREATE NONCLUSTERED INDEX IX_SignageCampaign_Org_Active 
        ON dbo.SignageCampaign(OrganizationId, IsActive, IsDeleted, StartDate, EndDate);
END;
GO

-- 2. SignageMediaItem Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SignageMediaItem')
BEGIN
    CREATE TABLE dbo.SignageMediaItem (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        CampaignId INT NOT NULL,
        MediaType INT NOT NULL DEFAULT 1,    -- 1=Image, 2=Video, 3=Html5/Url, 4=TickerText
        MediaUrl NVARCHAR(500) NOT NULL,
        LocalCachePath NVARCHAR(500) NULL,
        Title NVARCHAR(150) NOT NULL,
        DurationSeconds INT NOT NULL DEFAULT 15,
        DisplayOrder INT NOT NULL DEFAULT 1,
        MuteAudio BIT NOT NULL DEFAULT 1,
        IsActive BIT NOT NULL DEFAULT 1,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_SignageMediaItem_Campaign FOREIGN KEY (CampaignId) 
            REFERENCES dbo.SignageCampaign(Id) ON DELETE CASCADE
    );

    CREATE NONCLUSTERED INDEX IX_SignageMediaItem_Campaign 
        ON dbo.SignageMediaItem(CampaignId, DisplayOrder, IsActive);
END;
GO

-- 3. SignageCampaignMapping Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SignageCampaignMapping')
BEGIN
    CREATE TABLE dbo.SignageCampaignMapping (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        CampaignId INT NOT NULL,
        OrganizationId INT NOT NULL,
        LocationId INT NOT NULL,
        AreaId INT NULL,                     -- NULL applies to all areas in location
        TemplateId INT NULL,                 -- NULL applies to all display boards
        IsActive BIT NOT NULL DEFAULT 1,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_SignageCampaignMapping_Campaign FOREIGN KEY (CampaignId) 
            REFERENCES dbo.SignageCampaign(Id) ON DELETE CASCADE
    );

    CREATE NONCLUSTERED INDEX IX_SignageCampaignMapping_Loc 
        ON dbo.SignageCampaignMapping(OrganizationId, LocationId, AreaId, IsActive);
END;
GO

-- 4. EmergencyBroadcast Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EmergencyBroadcast')
BEGIN
    CREATE TABLE dbo.EmergencyBroadcast (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        OrganizationId INT NOT NULL,
        LocationId INT NULL,                 -- NULL = Tenant-wide broadcast
        AreaId INT NULL,                     -- NULL = Location-wide broadcast
        BroadcastCode NVARCHAR(50) NOT NULL, -- 'CODE_RED', 'CODE_BLUE', 'EVACUATION', 'WEATHER', 'CUSTOM'
        Title NVARCHAR(150) NOT NULL,
        MessageText NVARCHAR(1000) NOT NULL,
        Severity INT NOT NULL DEFAULT 3,     -- 1=Info (Cyan), 2=Warning (Amber), 3=Critical (Red)
        AudioSirenType INT NOT NULL DEFAULT 1, -- 0=None, 1=Pulse, 2=Wail, 3=Continuous
        FlashColorHex NVARCHAR(10) NOT NULL DEFAULT '#FF1744',
        IsActive BIT NOT NULL DEFAULT 1,
        TriggeredByUserId INT NOT NULL,
        TriggeredAt DATETIME NOT NULL DEFAULT GETDATE(),
        DismissedByUserId INT NULL,
        DismissedAt DATETIME NULL,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
    );

    CREATE NONCLUSTERED INDEX IX_EmergencyBroadcast_Active 
        ON dbo.EmergencyBroadcast(OrganizationId, LocationId, IsActive);
END;
GO

-- ============================================================================
-- STORED PROCEDURE: INSERT / UPDATE SIGNAGE CAMPAIGN (MSSQL)
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.PR_IU_SignageCampaign
    @p_Id INT = 0,
    @p_OrganizationId INT,
    @p_CampaignName NVARCHAR(150),
    @p_CampaignType INT = 1,
    @p_Priority INT = 5,
    @p_StartDate DATETIME,
    @p_EndDate DATETIME,
    @p_DailyStartTime TIME = NULL,
    @p_DailyEndTime TIME = NULL,
    @p_DaysOfWeek NVARCHAR(30) = '1,2,3,4,5,6,7',
    @p_LocationId INT = 0,
    @p_AreaId INT = NULL,
    @p_IsActive BIT = 1,
    @p_UserId INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_campaignId INT = @p_Id;

    IF @v_campaignId <= 0
    BEGIN
        INSERT INTO dbo.SignageCampaign (
            OrganizationId, CampaignName, CampaignType, Priority,
            StartDate, EndDate, DailyStartTime, DailyEndTime, DaysOfWeek,
            IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
        ) VALUES (
            @p_OrganizationId, @p_CampaignName, @p_CampaignType, @p_Priority,
            @p_StartDate, @p_EndDate, @p_DailyStartTime, @p_DailyEndTime, @p_DaysOfWeek,
            @p_IsActive, @p_UserId, GETDATE(), @p_UserId, GETDATE(), 0
        );

        SET @v_campaignId = SCOPE_IDENTITY();

        IF @p_LocationId > 0
        BEGIN
            INSERT INTO dbo.SignageCampaignMapping (
                CampaignId, OrganizationId, LocationId, AreaId, IsActive, CreatedDate
            ) VALUES (
                @v_campaignId, @p_OrganizationId, @p_LocationId, @p_AreaId, 1, GETDATE()
            );
        END;
    END
    ELSE
    BEGIN
        UPDATE dbo.SignageCampaign
        SET CampaignName = @p_CampaignName,
            CampaignType = @p_CampaignType,
            Priority = @p_Priority,
            StartDate = @p_StartDate,
            EndDate = @p_EndDate,
            DailyStartTime = @p_DailyStartTime,
            DailyEndTime = @p_DailyEndTime,
            DaysOfWeek = @p_DaysOfWeek,
            IsActive = @p_IsActive,
            ModifiedBy = @p_UserId,
            ModifiedDate = GETDATE()
        WHERE Id = @v_campaignId AND OrganizationId = @p_OrganizationId;

        IF @p_LocationId > 0
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.SignageCampaignMapping WHERE CampaignId = @v_campaignId AND LocationId = @p_LocationId)
            BEGIN
                INSERT INTO dbo.SignageCampaignMapping (
                    CampaignId, OrganizationId, LocationId, AreaId, IsActive, CreatedDate
                ) VALUES (
                    @v_campaignId, @p_OrganizationId, @p_LocationId, @p_AreaId, 1, GETDATE()
                );
            END;
        END;
    END;

    SELECT @v_campaignId AS Id, 0 AS ErrNo, 'Success' AS ErrMsg;
END;
GO

-- ============================================================================
-- STORED PROCEDURE: GET ACTIVE SIGNAGE PLAYLIST FOR TV DISPLAY (MSSQL)
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.PR_S_ActiveSignagePlaylist
    @p_OrganizationId INT,
    @p_LocationId INT,
    @p_AreaId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_now DATETIME = GETDATE();
    DECLARE @v_currentTime TIME = CAST(@v_now AS TIME);
    DECLARE @v_currentDayStr NVARCHAR(2) = CAST(DATEPART(WEEKDAY, @v_now) AS NVARCHAR(2));

    SELECT 
        M.Id,
        M.CampaignId,
        C.CampaignName,
        C.CampaignType,
        C.Priority,
        M.MediaType,
        M.MediaUrl,
        M.LocalCachePath,
        M.Title,
        M.DurationSeconds,
        M.DisplayOrder,
        M.MuteAudio
    FROM dbo.SignageMediaItem M
    INNER JOIN dbo.SignageCampaign C ON M.CampaignId = C.Id
    INNER JOIN dbo.SignageCampaignMapping MAP ON C.Id = MAP.CampaignId
    WHERE C.OrganizationId = @p_OrganizationId
      AND C.IsActive = 1
      AND C.IsDeleted = 0
      AND M.IsActive = 1
      AND MAP.IsActive = 1
      AND MAP.LocationId = @p_LocationId
      AND (MAP.AreaId IS NULL OR @p_AreaId IS NULL OR MAP.AreaId = @p_AreaId)
      AND @v_now BETWEEN C.StartDate AND C.EndDate
      AND (C.DailyStartTime IS NULL OR @v_currentTime >= C.DailyStartTime)
      AND (C.DailyEndTime IS NULL OR @v_currentTime <= C.DailyEndTime)
      AND (C.DaysOfWeek LIKE '%' + @v_currentDayStr + '%')
    ORDER BY C.Priority DESC, M.DisplayOrder ASC;
END;
GO

-- ============================================================================
-- STORED PROCEDURE: TRIGGER OR DISMISS EMERGENCY BROADCAST (MSSQL)
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.PR_IU_EmergencyBroadcast
    @p_Action NVARCHAR(20), -- 'TRIGGER' or 'DISMISS'
    @p_BroadcastId INT = 0,
    @p_OrganizationId INT,
    @p_LocationId INT = NULL,
    @p_AreaId INT = NULL,
    @p_BroadcastCode NVARCHAR(50) = 'CODE_RED',
    @p_Title NVARCHAR(150) = 'EMERGENCY ALERT',
    @p_MessageText NVARCHAR(1000) = '',
    @p_Severity INT = 3,
    @p_AudioSirenType INT = 1,
    @p_FlashColorHex NVARCHAR(10) = '#FF1744',
    @p_UserId INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_id INT = @p_BroadcastId;

    IF UPPER(@p_Action) = 'TRIGGER'
    BEGIN
        -- Deactivate prior active alerts for this target location to avoid conflicting sirens
        UPDATE dbo.EmergencyBroadcast
        SET IsActive = 0,
            DismissedByUserId = @p_UserId,
            DismissedAt = GETDATE()
        WHERE OrganizationId = @p_OrganizationId
          AND IsActive = 1
          AND (LocationId IS NULL OR @p_LocationId IS NULL OR LocationId = @p_LocationId);

        INSERT INTO dbo.EmergencyBroadcast (
            OrganizationId, LocationId, AreaId, BroadcastCode, Title, MessageText,
            Severity, AudioSirenType, FlashColorHex, IsActive, TriggeredByUserId, TriggeredAt
        ) VALUES (
            @p_OrganizationId, @p_LocationId, @p_AreaId, @p_BroadcastCode, @p_Title, @p_MessageText,
            @p_Severity, @p_AudioSirenType, @p_FlashColorHex, 1, @p_UserId, GETDATE()
        );

        SET @v_id = SCOPE_IDENTITY();
        SELECT @v_id AS Id, 0 AS ErrNo, 'Emergency broadcast triggered' AS ErrMsg;
    END
    ELSE IF UPPER(@p_Action) = 'DISMISS'
    BEGIN
        UPDATE dbo.EmergencyBroadcast
        SET IsActive = 0,
            DismissedByUserId = @p_UserId,
            DismissedAt = GETDATE()
        WHERE OrganizationId = @p_OrganizationId
          AND (@v_id <= 0 OR Id = @v_id)
          AND IsActive = 1;

        SELECT @v_id AS Id, 0 AS ErrNo, 'Emergency broadcast dismissed (ALL CLEAR)' AS ErrMsg;
    END;
END;
GO

-- ============================================================================
-- STORED PROCEDURE: GET ACTIVE EMERGENCY BROADCAST (MSSQL)
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.PR_S_ActiveEmergencyBroadcast
    @p_OrganizationId INT,
    @p_LocationId INT = NULL,
    @p_AreaId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        Id,
        OrganizationId,
        LocationId,
        AreaId,
        BroadcastCode,
        Title,
        MessageText,
        Severity,
        AudioSirenType,
        FlashColorHex,
        IsActive,
        TriggeredByUserId,
        TriggeredAt
    FROM dbo.EmergencyBroadcast
    WHERE OrganizationId = @p_OrganizationId
      AND IsActive = 1
      AND (LocationId IS NULL OR @p_LocationId IS NULL OR LocationId = @p_LocationId)
      AND (AreaId IS NULL OR @p_AreaId IS NULL OR AreaId = @p_AreaId)
    ORDER BY Severity DESC, TriggeredAt DESC;
END;
GO

-- ============================================================================
-- SEED NAVIGATION MENU FOR DIGITAL SIGNAGE CAMPAIGNS (MSSQL)
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM dbo.NavigationMenu WHERE RouteUrl = '/admin/signage-campaigns')
BEGIN
    DECLARE @v_adminParentId INT = NULL;
    SELECT TOP 1 @v_adminParentId = Id FROM dbo.NavigationMenu WHERE RouteUrl = '/admin' OR Title LIKE '%Admin%' ORDER BY Id ASC;

    INSERT INTO dbo.NavigationMenu (
        ParentId, Title, RouteUrl, IconName, DisplayOrder,
        RequiredPermission, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
    ) VALUES (
        @v_adminParentId, 'Signage & Broadcast', '/admin/signage-campaigns', 'campaign_rounded', 19,
        'ManageSignage', 1, 1, GETDATE(), 1, GETDATE(), 0
    );
END;
GO
