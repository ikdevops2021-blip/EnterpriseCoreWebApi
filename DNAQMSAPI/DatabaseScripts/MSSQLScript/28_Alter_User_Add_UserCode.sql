-- ===================================================================================
-- DNAQMS API - ALTER USER TABLE: Add UserCode & DisplayName (MS SQL Server)
-- File Path: DNAQMSAPI/DatabaseScripts/MSSQLScript/28_Alter_User_Add_UserCode.sql
-- 
-- Safe, non-destructive migration for existing databases.
-- Idempotent: can be run multiple times without error.
-- ===================================================================================

USE [dnaqms];
GO

-- ─────────────────────────────────────────────────────────────────────────────
-- Step 1: Add UserCode column (with temporary default to satisfy NOT NULL)
-- ─────────────────────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[User]') AND name = 'UserCode')
BEGIN
    ALTER TABLE [dbo].[User] ADD [UserCode] NVARCHAR(50) NOT NULL
        CONSTRAINT [DF_User_UserCode_Temp] DEFAULT ('');
    PRINT 'Column [UserCode] added to [User] table.';
END
GO

-- ─────────────────────────────────────────────────────────────────────────────
-- Step 2: Add DisplayName column
-- ─────────────────────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[User]') AND name = 'DisplayName')
BEGIN
    ALTER TABLE [dbo].[User] ADD [DisplayName] NVARCHAR(250) NULL;
    PRINT 'Column [DisplayName] added to [User] table.';
END
GO

-- ─────────────────────────────────────────────────────────────────────────────
-- Step 3: Populate existing rows — UserCode = Email, DisplayName = FirstName + LastName
-- ─────────────────────────────────────────────────────────────────────────────
UPDATE [dbo].[User]
SET [UserCode]    = [Email],
    [DisplayName] = LTRIM(RTRIM([FirstName] + ' ' + [LastName]))
WHERE [UserCode] = '' OR [UserCode] IS NULL;
GO

-- ─────────────────────────────────────────────────────────────────────────────
-- Step 4: Create filtered unique index on UserCode (idempotent)
-- ─────────────────────────────────────────────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_Users_UserCode' AND object_id = OBJECT_ID(N'[dbo].[User]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_Users_UserCode]
        ON [dbo].[User] ([UserCode])
        WHERE [IsDeleted] = 0;
    PRINT 'Index [UX_Users_UserCode] created on [User] table.';
END
GO

-- ─────────────────────────────────────────────────────────────────────────────
-- Step 5: Drop the temporary default constraint
-- ─────────────────────────────────────────────────────────────────────────────
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_User_UserCode_Temp')
BEGIN
    ALTER TABLE [dbo].[User] DROP CONSTRAINT [DF_User_UserCode_Temp];
    PRINT 'Temporary default constraint [DF_User_UserCode_Temp] dropped.';
END
GO

PRINT '✅ Migration 28_Alter_User_Add_UserCode completed successfully.';
GO
