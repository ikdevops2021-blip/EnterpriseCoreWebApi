-- ============================================================================================
-- DQMS STAGE 1: ADD NOTIFICATION & FEEDBACK FLAGS AND DAILY TOKEN LIMIT (MySQL)
-- Script Number: 37_Alter_Process_Add_Flags_And_TokenLimitDaily.sql
-- Description: Alters Process table to add IsSMS, IsWhatsApp, IsEmail, IsFeedBack, 
--              and TokenLimitDaily columns safely without data loss.
-- ============================================================================================

-- Procedure to safely add column if not exists in MySQL
DROP PROCEDURE IF EXISTS AddProcessColumnsIfNotExists;
DELIMITER //
CREATE PROCEDURE AddProcessColumnsIfNotExists()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Process' AND COLUMN_NAME = 'IsSMS'
    ) THEN
        ALTER TABLE `Process` ADD COLUMN `IsSMS` TINYINT(1) NOT NULL DEFAULT 1;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Process' AND COLUMN_NAME = 'IsWhatsApp'
    ) THEN
        ALTER TABLE `Process` ADD COLUMN `IsWhatsApp` TINYINT(1) NOT NULL DEFAULT 1;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Process' AND COLUMN_NAME = 'IsEmail'
    ) THEN
        ALTER TABLE `Process` ADD COLUMN `IsEmail` TINYINT(1) NOT NULL DEFAULT 1;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Process' AND COLUMN_NAME = 'IsFeedBack'
    ) THEN
        ALTER TABLE `Process` ADD COLUMN `IsFeedBack` TINYINT(1) NOT NULL DEFAULT 1;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Process' AND COLUMN_NAME = 'TokenLimitDaily'
    ) THEN
        ALTER TABLE `Process` ADD COLUMN `TokenLimitDaily` INT NULL DEFAULT 0;
    END IF;
END //
DELIMITER ;

CALL AddProcessColumnsIfNotExists();
DROP PROCEDURE IF EXISTS AddProcessColumnsIfNotExists;
