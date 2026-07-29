-- ============================================================================================
-- DQMS STAGE 1: ADMIN MASTERS & CONFIGURATION TABLES (MS SQL Server)
-- Script Number: 31_DQMS_Admin_Masters.sql
-- Description: Creates master tables and PR_S_* / PR_IU_* Stored Procedures following 
--              Core Web API enterprise conventions.
-- ============================================================================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Area]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Area](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [AreaCode] [nvarchar](50) NOT NULL,
    [OrganizationId] [int] NOT NULL,
    [LocationId] [int] NOT NULL,
    [AreaName] [nvarchar](100) NOT NULL,
    [Description] [nvarchar](250) NULL,
    [IsActive] [bit] NOT NULL DEFAULT 1,
    [CreatedBy] [int] NOT NULL,
    [CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
    [ModifiedBy] [int] NOT NULL,
    [ModifiedDate] [datetime] NOT NULL DEFAULT GETDATE(),
    [IsDeleted] [bit] NULL DEFAULT 0,
    [DeletedBy] [int] NULL,
    [DeletedDate] [datetime] NULL,
    CONSTRAINT [PK_Area] PRIMARY KEY CLUSTERED ([Id] ASC)
);
CREATE NONCLUSTERED INDEX [IX_Area_Org_Loc] ON [dbo].[Area] ([OrganizationId], [LocationId]);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Counter]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Counter](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [CounterCode] [nvarchar](50) NOT NULL,
    [OrganizationId] [int] NOT NULL,
    [LocationId] [int] NOT NULL,
    [AreaId] [int] NOT NULL,
    [CounterNumber] [nvarchar](20) NOT NULL,
    [CounterName] [nvarchar](100) NOT NULL,
    [CurrentStatus] [int] NOT NULL DEFAULT 0,
    [IsActive] [bit] NOT NULL DEFAULT 1,
    [CreatedBy] [int] NOT NULL,
    [CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
    [ModifiedBy] [int] NOT NULL,
    [ModifiedDate] [datetime] NOT NULL DEFAULT GETDATE(),
    [IsDeleted] [bit] NULL DEFAULT 0,
    [DeletedBy] [int] NULL,
    [DeletedDate] [datetime] NULL,
    CONSTRAINT [PK_Counter] PRIMARY KEY CLUSTERED ([Id] ASC)
);
CREATE NONCLUSTERED INDEX [IX_Counter_Area] ON [dbo].[Counter] ([AreaId]);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Process]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Process](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [ProcessCode] [nvarchar](50) NOT NULL,
    [OrganizationId] [int] NOT NULL,
    [ProcessName] [nvarchar](100) NOT NULL,
    [Prefix] [nvarchar](5) NOT NULL DEFAULT 'A',
    [TargetTATMinutes] [int] NOT NULL DEFAULT 15,
    [AllowSubTokens] [bit] NOT NULL DEFAULT 0,
    [IsActive] [bit] NOT NULL DEFAULT 1,
    [CreatedBy] [int] NOT NULL,
    [CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
    [ModifiedBy] [int] NOT NULL,
    [ModifiedDate] [datetime] NOT NULL DEFAULT GETDATE(),
    [IsDeleted] [bit] NULL DEFAULT 0,
    [DeletedBy] [int] NULL,
    [DeletedDate] [datetime] NULL,
    CONSTRAINT [PK_Process] PRIMARY KEY CLUSTERED ([Id] ASC)
);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcessStep]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ProcessStep](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [ProcessId] [int] NOT NULL,
    [StepOrder] [int] NOT NULL DEFAULT 1,
    [StepName] [nvarchar](100) NOT NULL,
    [TargetTATMinutes] [int] NOT NULL DEFAULT 10,
    [IsActive] [bit] NOT NULL DEFAULT 1,
    [CreatedBy] [int] NOT NULL,
    [CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
    [ModifiedBy] [int] NOT NULL,
    [ModifiedDate] [datetime] NOT NULL DEFAULT GETDATE(),
    [IsDeleted] [bit] NULL DEFAULT 0,
    [DeletedBy] [int] NULL,
    [DeletedDate] [datetime] NULL,
    CONSTRAINT [PK_ProcessStep] PRIMARY KEY CLUSTERED ([Id] ASC)
);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcessBlackoutDay]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ProcessBlackoutDay](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [OrganizationId] [int] NOT NULL,
    [LocationId] [int] NOT NULL,
    [ProcessId] [int] NOT NULL,
    [DayOfWeek] [int] NOT NULL,
    [Reason] [nvarchar](250) NULL,
    [IsActive] [bit] NOT NULL DEFAULT 1,
    [CreatedBy] [int] NOT NULL,
    [CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
    [ModifiedBy] [int] NOT NULL,
    [ModifiedDate] [datetime] NOT NULL DEFAULT GETDATE(),
    [IsDeleted] [bit] NULL DEFAULT 0,
    [DeletedBy] [int] NULL,
    [DeletedDate] [datetime] NULL,
    CONSTRAINT [PK_ProcessBlackoutDay] PRIMARY KEY CLUSTERED ([Id] ASC)
);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DisplayTemplate]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[DisplayTemplate](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [OrganizationId] [int] NOT NULL,
    [TemplateName] [nvarchar](100) NOT NULL,
    [TemplateType] [int] NOT NULL DEFAULT 1,
    [LayoutConfigJson] [nvarchar](max) NULL,
    [IsDefault] [bit] NOT NULL DEFAULT 0,
    [IsActive] [bit] NOT NULL DEFAULT 1,
    [CreatedBy] [int] NOT NULL,
    [CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
    [ModifiedBy] [int] NOT NULL,
    [ModifiedDate] [datetime] NOT NULL DEFAULT GETDATE(),
    [IsDeleted] [bit] NULL DEFAULT 0,
    [DeletedBy] [int] NULL,
    [DeletedDate] [datetime] NULL,
    CONSTRAINT [PK_DisplayTemplate] PRIMARY KEY CLUSTERED ([Id] ASC)
);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcessDisplayMapping]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ProcessDisplayMapping](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [OrganizationId] [int] NOT NULL,
    [LocationId] [int] NOT NULL,
    [AreaId] [int] NULL,
    [ProcessId] [int] NOT NULL,
    [TemplateId] [int] NOT NULL,
    [IsActive] [bit] NOT NULL DEFAULT 1,
    [CreatedBy] [int] NOT NULL,
    [CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
    [ModifiedBy] [int] NOT NULL,
    [ModifiedDate] [datetime] NOT NULL DEFAULT GETDATE(),
    [IsDeleted] [bit] NULL DEFAULT 0,
    [DeletedBy] [int] NULL,
    [DeletedDate] [datetime] NULL,
    CONSTRAINT [PK_ProcessDisplayMapping] PRIMARY KEY CLUSTERED ([Id] ASC)
);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserCounterAssignment]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[UserCounterAssignment](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [OrganizationId] [int] NOT NULL,
    [UserId] [int] NOT NULL,
    [CounterId] [int] NOT NULL,
    [ProcessId] [int] NOT NULL,
    [IsActive] [bit] NOT NULL DEFAULT 1,
    [CreatedBy] [int] NOT NULL,
    [CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
    [ModifiedBy] [int] NOT NULL,
    [ModifiedDate] [datetime] NOT NULL DEFAULT GETDATE(),
    [IsDeleted] [bit] NULL DEFAULT 0,
    [DeletedBy] [int] NULL,
    [DeletedDate] [datetime] NULL,
    CONSTRAINT [PK_UserCounterAssignment] PRIMARY KEY CLUSTERED ([Id] ASC)
);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[NotificationConfig]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[NotificationConfig](
    [Id] [int] IDENTITY(1,1) NOT NULL,
    [OrganizationId] [int] NOT NULL,
    [LocationId] [int] NOT NULL,
    [NotifyBeforePositions] [int] NOT NULL DEFAULT 3,
    [EnableWhatsApp] [bit] NOT NULL DEFAULT 1,
    [EnableSms] [bit] NOT NULL DEFAULT 0,
    [WhatsAppApiKey] [nvarchar](255) NULL,
    [IsActive] [bit] NOT NULL DEFAULT 1,
    [CreatedBy] [int] NOT NULL,
    [CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
    [ModifiedBy] [int] NOT NULL,
    [ModifiedDate] [datetime] NOT NULL DEFAULT GETDATE(),
    [IsDeleted] [bit] NULL DEFAULT 0,
    [DeletedBy] [int] NULL,
    [DeletedDate] [datetime] NULL,
    CONSTRAINT [PK_NotificationConfig] PRIMARY KEY CLUSTERED ([Id] ASC)
);
END
GO

-- ============================================================================
-- STORED PROCEDURES FOR AREA (MSSQL)
-- ============================================================================
IF OBJECT_ID(N'[dbo].[PR_S_Area]', N'P') IS NOT NULL DROP PROCEDURE [dbo].[PR_S_Area];
GO
CREATE PROCEDURE [dbo].[PR_S_Area]
    @p_Id INT = NULL,
    @p_OrganizationId INT = NULL,
    @p_LocationId INT = NULL,
    @p_IsActive SMALLINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM [dbo].[Area]
    WHERE IsDeleted = 0
      AND (ISNULL(@p_Id, -1) = -1 OR Id = @p_Id)
      AND (ISNULL(@p_OrganizationId, -1) = -1 OR OrganizationId = @p_OrganizationId)
      AND (ISNULL(@p_LocationId, -1) = -1 OR LocationId = @p_LocationId)
      AND (ISNULL(@p_IsActive, -1) NOT IN (0, 1) OR IsActive = @p_IsActive)
    ORDER BY AreaName ASC;
END
GO

IF OBJECT_ID(N'[dbo].[PR_IU_Area]', N'P') IS NOT NULL DROP PROCEDURE [dbo].[PR_IU_Area];
GO
CREATE PROCEDURE [dbo].[PR_IU_Area]
    @p_Id INT = NULL,
    @p_AreaCode NVARCHAR(50),
    @p_OrganizationId INT,
    @p_LocationId INT,
    @p_AreaName NVARCHAR(100),
    @p_Description NVARCHAR(250) = NULL,
    @p_IsActive BIT = 1,
    @p_UID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_err INT = 0;
    DECLARE @v_rowscount INT = 0;
    DECLARE @v_errMsg NVARCHAR(300) = '';
    DECLARE @v_errLine INT = 0;
    DECLARE @v_duplicateID INT = 0;

    IF EXISTS(SELECT 1 FROM [dbo].[Area] WHERE OrganizationId = @p_OrganizationId AND LocationId = @p_LocationId AND AreaName = LTRIM(RTRIM(@p_AreaName)) AND IsDeleted = 0 AND (ISNULL(@p_Id, 0) <= 0 OR Id <> @p_Id))
    BEGIN
        SELECT TOP 1 @v_duplicateID = Id FROM [dbo].[Area] WHERE OrganizationId = @p_OrganizationId AND LocationId = @p_LocationId AND AreaName = LTRIM(RTRIM(@p_AreaName)) AND IsDeleted = 0 AND (ISNULL(@p_Id, 0) <= 0 OR Id <> @p_Id);
        SET @v_err = 51;
        SET @v_errMsg = CONCAT('Duplicate Area Name! Already exists with ID ', @v_duplicateID);
        SELECT ISNULL(@p_Id, 0) AS ID, @v_err AS ErrNo, 0 AS RowsCount, @v_errMsg AS ErrMsg, 0 AS ErrLine;
        RETURN;
    END

    IF ISNULL(@p_Id, 0) <= 0
    BEGIN
        INSERT INTO [dbo].[Area] (
            AreaCode, OrganizationId, LocationId, AreaName, Description, IsActive,
            CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
        ) VALUES (
            LTRIM(RTRIM(@p_AreaCode)), @p_OrganizationId, @p_LocationId, LTRIM(RTRIM(@p_AreaName)), LTRIM(RTRIM(@p_Description)), ISNULL(@p_IsActive, 1),
            @p_UID, GETDATE(), @p_UID, GETDATE(), 0
        );
        SET @p_Id = SCOPE_IDENTITY();
        SET @v_rowscount = @@ROWCOUNT;
    END
    ELSE
    BEGIN
        UPDATE [dbo].[Area]
        SET AreaCode = LTRIM(RTRIM(@p_AreaCode)),
            AreaName = LTRIM(RTRIM(@p_AreaName)),
            Description = LTRIM(RTRIM(@p_Description)),
            IsActive = ISNULL(@p_IsActive, IsActive),
            ModifiedBy = @p_UID,
            ModifiedDate = GETDATE()
        WHERE Id = @p_Id AND IsDeleted = 0;
        SET @v_rowscount = @@ROWCOUNT;
    END

    SELECT ISNULL(@p_Id, 0) AS ID, @v_err AS ErrNo, @v_rowscount AS RowsCount, @v_errMsg AS ErrMsg, 0 AS ErrLine;
END
GO
