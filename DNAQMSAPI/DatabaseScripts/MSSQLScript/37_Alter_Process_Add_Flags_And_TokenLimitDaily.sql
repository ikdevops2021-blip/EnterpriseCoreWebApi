-- ============================================================================================
-- DQMS STAGE 1: ADD NOTIFICATION & FEEDBACK FLAGS AND DAILY TOKEN LIMIT (MSSQL)
-- Script Number: 37_Alter_Process_Add_Flags_And_TokenLimitDaily.sql
-- Description: Alters Process table to add IsSMS, IsWhatsApp, IsEmail, IsFeedBack, 
--              and TokenLimitDaily columns without data loss.
-- ============================================================================================

SET NOCOUNT ON;

-- 1. Add IsSMS Column
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Process]') AND name = 'IsSMS')
BEGIN
    ALTER TABLE [dbo].[Process] ADD [IsSMS] BIT NOT NULL DEFAULT 1;
END;
GO

-- 2. Add IsWhatsApp Column
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Process]') AND name = 'IsWhatsApp')
BEGIN
    ALTER TABLE [dbo].[Process] ADD [IsWhatsApp] BIT NOT NULL DEFAULT 1;
END;
GO

-- 3. Add IsEmail Column
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Process]') AND name = 'IsEmail')
BEGIN
    ALTER TABLE [dbo].[Process] ADD [IsEmail] BIT NOT NULL DEFAULT 1;
END;
GO

-- 4. Add IsFeedBack Column
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Process]') AND name = 'IsFeedBack')
BEGIN
    ALTER TABLE [dbo].[Process] ADD [IsFeedBack] BIT NOT NULL DEFAULT 1;
END;
GO

-- 5. Add TokenLimitDaily Column
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Process]') AND name = 'TokenLimitDaily')
BEGIN
    ALTER TABLE [dbo].[Process] ADD [TokenLimitDaily] INT NULL DEFAULT 0;
END;
GO
