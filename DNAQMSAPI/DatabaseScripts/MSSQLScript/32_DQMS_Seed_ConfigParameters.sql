-- ============================================================================================
-- DQMS STAGE 1: CONFIGURATION CATEGORIES & PARAMETERS SEED DATA (MS SQL Server)
-- Script Number: 32_DQMS_Seed_ConfigParameters.sql
-- Description: Adds Token Status, Priority Tiers, Counter Status, and Display Template Types
--              to ConfigCategory and ConfigParameters tables following the 1,000-Item range strategy.
-- ============================================================================================

-- 1. Ensure Categories Exist in ConfigCategory
IF NOT EXISTS (SELECT 1 FROM [dbo].[ConfigCategory] WHERE CategoryID = 18)
    INSERT INTO [dbo].[ConfigCategory] (CategoryID, CategoryCode, CategoryName, Description, Priority, Active, AllowModify, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted)
    VALUES (18, 'TOKEN_STATUS', 'C_TOKEN_STATUS', 'Master token lifecycle status states.', 18, 1, 1, 0, GETDATE(), 0, GETDATE(), 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[ConfigCategory] WHERE CategoryID = 19)
    INSERT INTO [dbo].[ConfigCategory] (CategoryID, CategoryCode, CategoryName, Description, Priority, Active, AllowModify, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted)
    VALUES (19, 'PRIORITY_TIER', 'C_PRIORITY_TIER', 'Customer token priority tiers for queue interleaving.', 19, 1, 1, 0, GETDATE(), 0, GETDATE(), 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[ConfigCategory] WHERE CategoryID = 20)
    INSERT INTO [dbo].[ConfigCategory] (CategoryID, CategoryCode, CategoryName, Description, Priority, Active, AllowModify, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted)
    VALUES (20, 'COUNTER_STATUS', 'C_COUNTER_STATUS', 'Real-time operational status of counter stations.', 20, 1, 1, 0, GETDATE(), 0, GETDATE(), 0);

IF NOT EXISTS (SELECT 1 FROM [dbo].[ConfigCategory] WHERE CategoryID = 21)
    INSERT INTO [dbo].[ConfigCategory] (CategoryID, CategoryCode, CategoryName, Description, Priority, Active, AllowModify, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted)
    VALUES (21, 'DISPLAY_TYPE', 'C_DISPLAY_TEMPLATE_TYPE', 'Waiting area TV display template layout types.', 21, 1, 1, 0, GETDATE(), 0, GETDATE(), 0);

-- 2. Insert ConfigParameters (1,000-Item Incremental Ranges)

-- Category 18: C_TOKEN_STATUS (Range: 18001 - 18999)
IF NOT EXISTS (SELECT 1 FROM [dbo].[ConfigParameters] WHERE ParameterID = 18001)
    INSERT INTO [dbo].[ConfigParameters] (ParameterID, CategoryID, ParameterCode, ParameterName, Priority, IsDefault, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted) VALUES
    (18001, 18, '0', 'Queued', 1, 1, 1, 0, GETDATE(), 0, GETDATE(), 0),
    (18002, 18, '1', 'Waiting', 2, 0, 1, 0, GETDATE(), 0, GETDATE(), 0),
    (18003, 18, '2', 'Calling', 3, 0, 1, 0, GETDATE(), 0, GETDATE(), 0),
    (18004, 18, '3', 'Active', 4, 0, 1, 0, GETDATE(), 0, GETDATE(), 0),
    (18005, 18, '4', 'Hold', 5, 0, 1, 0, GETDATE(), 0, GETDATE(), 0),
    (18006, 18, '5', 'Canceled', 6, 0, 1, 0, GETDATE(), 0, GETDATE(), 0),
    (18007, 18, '6', 'Completed', 7, 0, 1, 0, GETDATE(), 0, GETDATE(), 0),
    (18008, 18, '7', 'Forwarded', 8, 0, 1, 0, GETDATE(), 0, GETDATE(), 0);

-- Category 19: C_PRIORITY_TIER (Range: 19001 - 19999)
IF NOT EXISTS (SELECT 1 FROM [dbo].[ConfigParameters] WHERE ParameterID = 19001)
    INSERT INTO [dbo].[ConfigParameters] (ParameterID, CategoryID, ParameterCode, ParameterName, Priority, IsDefault, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted) VALUES
    (19001, 19, 'STD', 'Standard', 1, 1, 1, 0, GETDATE(), 0, GETDATE(), 0),
    (19002, 19, 'SEN', 'Senior Citizen', 2, 0, 1, 0, GETDATE(), 0, GETDATE(), 0),
    (19003, 19, 'DIS', 'Disabled', 3, 0, 1, 0, GETDATE(), 0, GETDATE(), 0),
    (19004, 19, 'EMG', 'Emergency', 4, 0, 1, 0, GETDATE(), 0, GETDATE(), 0),
    (19005, 19, 'VIP', 'VIP Customer', 5, 0, 1, 0, GETDATE(), 0, GETDATE(), 0);

-- Category 20: C_COUNTER_STATUS (Range: 20001 - 20999)
IF NOT EXISTS (SELECT 1 FROM [dbo].[ConfigParameters] WHERE ParameterID = 20001)
    INSERT INTO [dbo].[ConfigParameters] (ParameterID, CategoryID, ParameterCode, ParameterName, Priority, IsDefault, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted) VALUES
    (20001, 20, 'IDLE', 'Idle', 1, 1, 1, 0, GETDATE(), 0, GETDATE(), 0),
    (20002, 20, 'SERVING', 'Serving', 2, 0, 1, 0, GETDATE(), 0, GETDATE(), 0),
    (20003, 20, 'BREAK', 'Break', 3, 0, 1, 0, GETDATE(), 0, GETDATE(), 0),
    (20004, 20, 'OFFLINE', 'Offline', 4, 0, 1, 0, GETDATE(), 0, GETDATE(), 0);

-- Category 21: C_DISPLAY_TEMPLATE_TYPE (Range: 21001 - 21999)
IF NOT EXISTS (SELECT 1 FROM [dbo].[ConfigParameters] WHERE ParameterID = 21001)
    INSERT INTO [dbo].[ConfigParameters] (ParameterID, CategoryID, ParameterCode, ParameterName, Priority, IsDefault, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted) VALUES
    (21001, 21, 'GRID', 'Grid View', 1, 1, 1, 0, GETDATE(), 0, GETDATE(), 0),
    (21002, 21, 'SPLIT', 'Split-Screen Video/Token', 2, 0, 1, 0, GETDATE(), 0, GETDATE(), 0),
    (21003, 21, 'LIST', 'High-Density List', 3, 0, 1, 0, GETDATE(), 0, GETDATE(), 0),
    (21004, 21, 'BANNER', 'Audio-Visual Banner', 4, 0, 1, 0, GETDATE(), 0, GETDATE(), 0);
