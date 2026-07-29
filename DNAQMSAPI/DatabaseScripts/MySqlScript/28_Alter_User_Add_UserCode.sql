-- ===================================================================================
-- DNAQMS API - ALTER USER TABLE: Add UserCode & DisplayName (MySQL)
-- File Path: DNAQMSAPI/DatabaseScripts/MySqlScript/28_Alter_User_Add_UserCode.sql
-- 
-- Safe, non-destructive migration for existing databases.
-- Idempotent: checks column existence before ALTER.
-- ===================================================================================

USE `dnaqms`;

-- ─────────────────────────────────────────────────────────────────────────────
-- Step 1: Add UserCode column (with temporary default to satisfy NOT NULL)
-- ─────────────────────────────────────────────────────────────────────────────
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'dnaqms' AND TABLE_NAME = 'User' AND COLUMN_NAME = 'UserCode');

SET @sql = IF(@col_exists = 0, 
    'ALTER TABLE `User` ADD COLUMN `UserCode` VARCHAR(50) NOT NULL DEFAULT \'\' AFTER `Id`', 
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ─────────────────────────────────────────────────────────────────────────────
-- Step 2: Add DisplayName column
-- ─────────────────────────────────────────────────────────────────────────────
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'dnaqms' AND TABLE_NAME = 'User' AND COLUMN_NAME = 'DisplayName');

SET @sql = IF(@col_exists = 0, 
    'ALTER TABLE `User` ADD COLUMN `DisplayName` VARCHAR(250) NULL AFTER `LastName`', 
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ─────────────────────────────────────────────────────────────────────────────
-- Step 3: Populate existing rows — UserCode = Email, DisplayName = FirstName + LastName
-- ─────────────────────────────────────────────────────────────────────────────
UPDATE `User`
SET `UserCode`    = `Email`,
    `DisplayName` = TRIM(CONCAT(`FirstName`, ' ', `LastName`))
WHERE `UserCode` = '' OR `UserCode` IS NULL;

-- ─────────────────────────────────────────────────────────────────────────────
-- Step 4: Create unique index on UserCode (idempotent — DROP IF EXISTS + CREATE)
-- Note: MySQL does not support filtered indexes. Uniqueness among active users
-- is enforced at the stored procedure level.
-- ─────────────────────────────────────────────────────────────────────────────
SET @idx_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS 
    WHERE TABLE_SCHEMA = 'dnaqms' AND TABLE_NAME = 'User' AND INDEX_NAME = 'UX_Users_UserCode');

SET @sql = IF(@idx_exists = 0, 
    'CREATE UNIQUE INDEX `UX_Users_UserCode` ON `User` (`UserCode`)', 
    'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ─────────────────────────────────────────────────────────────────────────────
-- Step 5: Remove the temporary default on UserCode
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE `User` ALTER COLUMN `UserCode` DROP DEFAULT;

-- ✅ Migration 28_Alter_User_Add_UserCode completed successfully.
