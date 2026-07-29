-- ============================================================================================
-- DQMS STAGE 1: ADMIN MASTERS & CONFIGURATION TABLES (MS SQL Server)
-- Script Number: 31_DQMS_Admin_Masters.sql
-- Description: Creates master tables for Location, Area, Counter, Process Pipeline, 
--              Display Templates, Blackout Days, and Staff Counter Assignments.
-- ============================================================================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Area]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Area](
    [AreaId] [nvarchar](50) NOT NULL,
    [OrganizationId] [nvarchar](50) NOT NULL,
    [LocationId] [nvarchar](50) NOT NULL,
    [AreaName] [nvarchar](100) NOT NULL,
    [AreaCode] [nvarchar](20) NOT NULL,
    [Description] [nvarchar](255) NULL,
    [IsActive] [bit] NOT NULL DEFAULT 1,
    [CreatedBy] [nvarchar](50) NOT NULL,
    [CreatedOn] [datetime] NOT NULL DEFAULT GETDATE(),
    [UpdatedBy] [nvarchar](50) NULL,
    [UpdatedOn] [datetime] NULL,
    CONSTRAINT [PK_Area] PRIMARY KEY CLUSTERED ([AreaId] ASC)
);
CREATE NONCLUSTERED INDEX [IX_Area_Org_Loc] ON [dbo].[Area] ([OrganizationId], [LocationId]);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Counter]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Counter](
    [CounterId] [nvarchar](50) NOT NULL,
    [OrganizationId] [nvarchar](50) NOT NULL,
    [LocationId] [nvarchar](50) NOT NULL,
    [AreaId] [nvarchar](50) NOT NULL,
    [CounterNumber] [nvarchar](20) NOT NULL,
    [CounterName] [nvarchar](100) NOT NULL,
    [IsActive] [bit] NOT NULL DEFAULT 1,
    [CurrentStatus] [int] NOT NULL DEFAULT 0,
    [CreatedBy] [nvarchar](50) NOT NULL,
    [CreatedOn] [datetime] NOT NULL DEFAULT GETDATE(),
    [UpdatedBy] [nvarchar](50) NULL,
    [UpdatedOn] [datetime] NULL,
    CONSTRAINT [PK_Counter] PRIMARY KEY CLUSTERED ([CounterId] ASC)
);
CREATE NONCLUSTERED INDEX [IX_Counter_Area] ON [dbo].[Counter] ([AreaId]);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Process]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Process](
    [ProcessId] [nvarchar](50) NOT NULL,
    [OrganizationId] [nvarchar](50) NOT NULL,
    [ProcessName] [nvarchar](100) NOT NULL,
    [ProcessCode] [nvarchar](20) NOT NULL,
    [Prefix] [nvarchar](5) NOT NULL DEFAULT 'A',
    [TargetTATMinutes] [int] NOT NULL DEFAULT 15,
    [AllowSubTokens] [bit] NOT NULL DEFAULT 0,
    [IsActive] [bit] NOT NULL DEFAULT 1,
    [CreatedBy] [nvarchar](50) NOT NULL,
    [CreatedOn] [datetime] NOT NULL DEFAULT GETDATE(),
    [UpdatedBy] [nvarchar](50) NULL,
    [UpdatedOn] [datetime] NULL,
    CONSTRAINT [PK_Process] PRIMARY KEY CLUSTERED ([ProcessId] ASC)
);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcessStep]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ProcessStep](
    [StepId] [nvarchar](50) NOT NULL,
    [ProcessId] [nvarchar](50) NOT NULL,
    [StepOrder] [int] NOT NULL DEFAULT 1,
    [StepName] [nvarchar](100) NOT NULL,
    [TargetTATMinutes] [int] NOT NULL DEFAULT 10,
    [IsActive] [bit] NOT NULL DEFAULT 1,
    CONSTRAINT [PK_ProcessStep] PRIMARY KEY CLUSTERED ([StepId] ASC)
);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcessBlackoutDay]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ProcessBlackoutDay](
    [BlackoutId] [nvarchar](50) NOT NULL,
    [OrganizationId] [nvarchar](50) NOT NULL,
    [LocationId] [nvarchar](50) NOT NULL,
    [ProcessId] [nvarchar](50) NOT NULL,
    [DayOfWeek] [int] NOT NULL,
    [Reason] [nvarchar](255) NULL,
    [IsActive] [bit] NOT NULL DEFAULT 1,
    CONSTRAINT [PK_ProcessBlackoutDay] PRIMARY KEY CLUSTERED ([BlackoutId] ASC)
);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DisplayTemplate]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[DisplayTemplate](
    [TemplateId] [nvarchar](50) NOT NULL,
    [OrganizationId] [nvarchar](50) NOT NULL,
    [TemplateName] [nvarchar](100) NOT NULL,
    [TemplateType] [int] NOT NULL DEFAULT 1,
    [LayoutConfigJson] [nvarchar](max) NULL,
    [IsDefault] [bit] NOT NULL DEFAULT 0,
    [IsActive] [bit] NOT NULL DEFAULT 1,
    [CreatedBy] [nvarchar](50) NOT NULL,
    [CreatedOn] [datetime] NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [PK_DisplayTemplate] PRIMARY KEY CLUSTERED ([TemplateId] ASC)
);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProcessDisplayMapping]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ProcessDisplayMapping](
    [MappingId] [nvarchar](50) NOT NULL,
    [OrganizationId] [nvarchar](50) NOT NULL,
    [LocationId] [nvarchar](50) NOT NULL,
    [AreaId] [nvarchar](50) NULL,
    [ProcessId] [nvarchar](50) NOT NULL,
    [TemplateId] [nvarchar](50) NOT NULL,
    CONSTRAINT [PK_ProcessDisplayMapping] PRIMARY KEY CLUSTERED ([MappingId] ASC)
);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserCounterAssignment]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[UserCounterAssignment](
    [AssignmentId] [nvarchar](50) NOT NULL,
    [OrganizationId] [nvarchar](50) NOT NULL,
    [UserId] [nvarchar](50) NOT NULL,
    [CounterId] [nvarchar](50) NOT NULL,
    [ProcessId] [nvarchar](50) NOT NULL,
    [AssignedOn] [datetime] NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [PK_UserCounterAssignment] PRIMARY KEY CLUSTERED ([AssignmentId] ASC)
);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[NotificationConfig]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[NotificationConfig](
    [ConfigId] [nvarchar](50) NOT NULL,
    [OrganizationId] [nvarchar](50) NOT NULL,
    [LocationId] [nvarchar](50) NOT NULL,
    [NotifyBeforePositions] [int] NOT NULL DEFAULT 3,
    [EnableWhatsApp] [bit] NOT NULL DEFAULT 1,
    [EnableSms] [bit] NOT NULL DEFAULT 0,
    [WhatsAppApiKey] [nvarchar](255) NULL,
    [CreatedOn] [datetime] NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [PK_NotificationConfig] PRIMARY KEY CLUSTERED ([ConfigId] ASC)
);
END
GO
