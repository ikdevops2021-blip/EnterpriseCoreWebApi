-- ===================================================================================
-- DNAQMS API - USER TABLE SCHEMA WITH USERCODE, DISPLAYNAME, TITLE, GENDER & PROFILE IMAGE (MS SQL Server)
-- File Path: DNAQMSAPI/DatabaseScripts/MSSQLScript/02_User.sql
-- ===================================================================================

USE [dnaqms];
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[User]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[User] (
        [Id]                INT IDENTITY(1,1) PRIMARY KEY,
        [UserCode]          NVARCHAR(50) NOT NULL,         -- Custom user identifier (default: Email). Unique among active users.
        [TitleId]           INT NULL,                      -- ConfigParameters Category 2 (C_TITLE: 2001..2009)
        [FirstName]         NVARCHAR(250) NOT NULL,
        [LastName]          NVARCHAR(250) NOT NULL,
        [DisplayName]       NVARCHAR(250) NULL,            -- Auto-generated: FirstName + ' ' + LastName (or custom)
        [GenderId]          INT NULL,                      -- ConfigParameters Category 1 (C_GENDER: 1001..1005)
        [ProfileImageUrl]   NVARCHAR(500) NULL,
        [Email]             NVARCHAR(255) NOT NULL UNIQUE,
        [PasswordHash]      NVARCHAR(MAX) NOT NULL,
        [IsActive]          BIT NOT NULL DEFAULT 1,
        [CreatedBy]         INT NOT NULL,
        [CreatedDate]       DATETIME NOT NULL DEFAULT GETDATE(),
        [ModifiedBy]        INT NOT NULL DEFAULT 0,
        [ModifiedDate]      DATETIME NOT NULL DEFAULT GETDATE(),
        [IsDeleted]         BIT NULL DEFAULT 0,
        [DeletedBy]         INT NULL,
        [DeletedDate]       DATETIME NULL,

        CONSTRAINT [FK_User_Title] 
            FOREIGN KEY ([TitleId]) REFERENCES [dbo].[ConfigParameters]([ParameterID]),

        CONSTRAINT [FK_User_Gender] 
            FOREIGN KEY ([GenderId]) REFERENCES [dbo].[ConfigParameters]([ParameterID])
    );

    -- Filtered unique index: UserCode must be unique among active (non-deleted) users
    CREATE UNIQUE NONCLUSTERED INDEX [UX_Users_UserCode]
        ON [dbo].[User] ([UserCode])
        WHERE [IsDeleted] = 0;
END;
GO
