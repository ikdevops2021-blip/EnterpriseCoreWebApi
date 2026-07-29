DELIMITER //

-- ============================================================================
-- Procedure: PR_S_ConfigCategory
-- Description: Unified search procedure for ConfigCategory
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_S_ConfigCategory //
CREATE PROCEDURE PR_S_ConfigCategory (
    IN p_CategoryID         INT,
    IN p_CategoryCode       VARCHAR(50),
    IN p_CategoryName       VARCHAR(100),
    IN p_Active             SMALLINT
)
BEGIN
    SELECT * 
    FROM ConfigCategory 
    WHERE IsDeleted = 0
      AND (COALESCE(p_CategoryID, -1) = -1 OR CategoryID = p_CategoryID)
      AND (COALESCE(p_CategoryCode, '') = '' OR CategoryCode = p_CategoryCode)
      AND (COALESCE(p_CategoryName, '') = '' OR CategoryName = p_CategoryName)
      AND (COALESCE(p_Active, -1) NOT IN (0, 1) OR Active = p_Active)
    ORDER BY Priority ASC, CategoryName ASC;
END //

-- ============================================================================
-- Procedure: PR_S_ConfigParameters
-- Description: Unified search procedure for ConfigParameters
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_S_ConfigParameters //
CREATE PROCEDURE PR_S_ConfigParameters (
    IN p_ParameterID        INT,
    IN p_CategoryID         INT,
    IN p_CategoryCode       VARCHAR(50),
    IN p_ParameterCode       VARCHAR(50),
    IN p_ParameterName       VARCHAR(200),
    IN p_IsActive           SMALLINT
)
BEGIN
    SELECT 
        cp.*, 
        cc.CategoryCode, 
        cc.CategoryName
    FROM ConfigParameters cp
    INNER JOIN ConfigCategory cc ON cc.CategoryID = cp.CategoryID
    WHERE cp.IsDeleted = 0 
      AND cc.IsDeleted = 0
      AND (COALESCE(p_ParameterID, -1) = -1 OR cp.ParameterID = p_ParameterID)
      AND (COALESCE(p_CategoryID, -1) = -1 OR cp.CategoryID = p_CategoryID)
      AND (COALESCE(p_CategoryCode, '') = '' OR cc.CategoryCode = p_CategoryCode OR cc.CategoryName = p_CategoryCode)
      AND (COALESCE(p_ParameterCode, '') = '' OR cp.ParameterCode = p_ParameterCode)
      AND (COALESCE(p_ParameterName, '') = '' OR cp.ParameterName = p_ParameterName)
      AND (COALESCE(p_IsActive, -1) NOT IN (0, 1) OR cp.IsActive = p_IsActive)
    ORDER BY cp.CategoryID ASC, cp.Priority ASC, cp.ParameterName ASC;
END //

-- ============================================================================
-- Procedure: PR_IU_ConfigCategory
-- Description: Unified Insert/Update procedure for ConfigCategory with meta return
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_IU_ConfigCategory //
CREATE PROCEDURE PR_IU_ConfigCategory (
    IN p_CategoryID           INT,
    IN p_CategoryCode         VARCHAR(50),
    IN p_CategoryName         VARCHAR(100),
    IN p_Description          LONGTEXT,
    IN p_Priority             INT,
    IN p_Active               TINYINT(1),
    IN p_AllowModify          TINYINT(1),
    IN p_ParentCategoryID     INT,
    IN p_CategoryExternalID   VARCHAR(20),
    IN p_CategoryExternalName VARCHAR(200),
    IN p_CategoryExternalCode VARCHAR(20),
    IN p_CategoryColor        VARCHAR(20),
    IN p_CategoryIcon         VARCHAR(200),
    IN p_CategoryImage        VARCHAR(200),
    IN p_Attribute1           VARCHAR(100),
    IN p_Attribute2           VARCHAR(100),
    IN p_Attribute3           VARCHAR(100),
    IN p_UID                  INT
)
proc_body: BEGIN
    DECLARE v_err INT DEFAULT 0;
    DECLARE v_rowscount INT DEFAULT 0;
    DECLARE v_errMsg VARCHAR(300) DEFAULT '';
    DECLARE v_errLine INT DEFAULT 0;
    DECLARE v_duplicateID INT DEFAULT 0;

    -- ========================================================================
    --/S/---------------- [Validation Section] -------------------------------
    -- ========================================================================
    IF EXISTS(SELECT 1 FROM ConfigCategory WHERE CategoryID <> COALESCE(p_CategoryID, -1) AND CategoryName = TRIM(p_CategoryName) AND IsDeleted = 0) THEN
        SELECT CategoryID INTO v_duplicateID FROM ConfigCategory WHERE CategoryID <> COALESCE(p_CategoryID, -1) AND CategoryName = TRIM(p_CategoryName) AND IsDeleted = 0 LIMIT 1;
        SET v_err = 51;
        SET v_errMsg = CONCAT('Duplicate Parameter Category Name! Already exists with ID ', v_duplicateID);
        LEAVE proc_body;
    END IF;

    IF EXISTS(SELECT 1 FROM ConfigCategory WHERE CategoryID <> COALESCE(p_CategoryID, -1) AND CategoryCode = TRIM(p_CategoryCode) AND IsDeleted = 0) THEN
        SELECT CategoryID INTO v_duplicateID FROM ConfigCategory WHERE CategoryID <> COALESCE(p_CategoryID, -1) AND CategoryCode = TRIM(p_CategoryCode) AND IsDeleted = 0 LIMIT 1;
        SET v_err = 52;
        SET v_errMsg = CONCAT('Duplicate Parameter Category Code! Already exists with ID ', v_duplicateID);
        LEAVE proc_body;
    END IF;

    -- Custom business validation logic can be added here
    --/E/---------------- [Validation Section] -------------------------------

    IF COALESCE(p_CategoryID, 0) <= 0 THEN
        INSERT INTO ConfigCategory (
            CategoryCode, CategoryName, Description, Priority, Active, AllowModify, ParentCategoryID,
            CategoryExternalID, CategoryExternalName, CategoryExternalCode, CategoryColor, CategoryIcon, CategoryImage,
            Attribute1, Attribute2, Attribute3,
            CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
        ) VALUES (
            TRIM(p_CategoryCode), TRIM(p_CategoryName), p_Description, COALESCE(p_Priority, 1), COALESCE(p_Active, 1), COALESCE(p_AllowModify, 1), p_ParentCategoryID,
            p_CategoryExternalID, p_CategoryExternalName, p_CategoryExternalCode, p_CategoryColor, p_CategoryIcon, p_CategoryImage,
            p_Attribute1, p_Attribute2, p_Attribute3,
            p_UID, CURRENT_TIMESTAMP, p_UID, CURRENT_TIMESTAMP, 0
        );
        SET p_CategoryID = LAST_INSERT_ID();
        SET v_rowscount = ROW_COUNT();
    ELSE
        UPDATE ConfigCategory
        SET CategoryCode         = TRIM(p_CategoryCode),
            CategoryName         = TRIM(p_CategoryName),
            Description          = p_Description,
            Priority             = COALESCE(p_Priority, Priority),
            Active               = COALESCE(p_Active, Active),
            AllowModify          = COALESCE(p_AllowModify, AllowModify),
            ParentCategoryID     = p_ParentCategoryID,
            CategoryExternalID   = p_CategoryExternalID,
            CategoryExternalName = p_CategoryExternalName,
            CategoryExternalCode = p_CategoryExternalCode,
            CategoryColor        = p_CategoryColor,
            CategoryIcon         = p_CategoryIcon,
            CategoryImage        = p_CategoryImage,
            Attribute1           = p_Attribute1,
            Attribute2           = p_Attribute2,
            Attribute3           = p_Attribute3,
            ModifiedBy           = p_UID,
            ModifiedDate         = CURRENT_TIMESTAMP
        WHERE CategoryID = p_CategoryID AND IsDeleted = 0;
        SET v_rowscount = ROW_COUNT();
    END IF;

    -- Return execution metadata set
    SELECT COALESCE(p_CategoryID, 0) AS ID, COALESCE(v_err, 0) AS ErrNo, COALESCE(v_rowscount, 0) AS RowsCount, COALESCE(v_errMsg, '') AS ErrMsg, COALESCE(v_errLine, 0) AS ErrLine;
END //

-- ============================================================================
-- Procedure: PR_IU_ConfigParameters
-- Description: Unified Insert/Update procedure for ConfigParameters with meta return
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_IU_ConfigParameters //
CREATE PROCEDURE PR_IU_ConfigParameters (
    IN p_ParameterID          INT,
    IN p_CategoryID           INT,
    IN p_ParameterCode         VARCHAR(50),
    IN p_ParameterName         VARCHAR(200),
    IN p_Priority             TINYINT,
    IN p_IsDefault            TINYINT(1),
    IN p_IsActive             TINYINT(1),
    IN p_ParameterExternalID   VARCHAR(20),
    IN p_ParameterExternalName VARCHAR(200),
    IN p_ParameterExternalCode VARCHAR(20),
    IN p_ParameterColor        VARCHAR(20),
    IN p_ParameterIcon         VARCHAR(200),
    IN p_ParameterImage        VARCHAR(200),
    IN p_Attribute1           VARCHAR(100),
    IN p_Attribute2           VARCHAR(100),
    IN p_Attribute3           VARCHAR(100),
    IN p_UID                  INT
)
proc_body: BEGIN
    DECLARE v_err INT DEFAULT 0;
    DECLARE v_rowscount INT DEFAULT 0;
    DECLARE v_errMsg VARCHAR(300) DEFAULT '';
    DECLARE v_errLine INT DEFAULT 0;
    DECLARE v_duplicateID INT DEFAULT 0;

    -- ========================================================================
    --/S/---------------- [Validation Section] -------------------------------
    -- ========================================================================
    IF EXISTS(SELECT 1 FROM ConfigParameters WHERE ParameterID <> COALESCE(p_ParameterID, -1) AND CategoryID = p_CategoryID AND ParameterName = TRIM(p_ParameterName) AND IsDeleted = 0) THEN
        SELECT ParameterID INTO v_duplicateID FROM ConfigParameters WHERE ParameterID <> COALESCE(p_ParameterID, -1) AND CategoryID = p_CategoryID AND ParameterName = TRIM(p_ParameterName) AND IsDeleted = 0 LIMIT 1;
        SET v_err = 51;
        SET v_errMsg = CONCAT('Duplicate Parameter Name in Category! Already exists with ID ', v_duplicateID);
        LEAVE proc_body;
    END IF;

    IF EXISTS(SELECT 1 FROM ConfigParameters WHERE ParameterID <> COALESCE(p_ParameterID, -1) AND CategoryID = p_CategoryID AND ParameterCode = TRIM(p_ParameterCode) AND IsDeleted = 0) THEN
        SELECT ParameterID INTO v_duplicateID FROM ConfigParameters WHERE ParameterID <> COALESCE(p_ParameterID, -1) AND CategoryID = p_CategoryID AND ParameterCode = TRIM(p_ParameterCode) AND IsDeleted = 0 LIMIT 1;
        SET v_err = 52;
        SET v_errMsg = CONCAT('Duplicate Parameter Code in Category! Already exists with ID ', v_duplicateID);
        LEAVE proc_body;
    END IF;

    -- Custom business validation logic can be added here
    --/E/---------------- [Validation Section] -------------------------------

    IF COALESCE(p_ParameterID, 0) <= 0 THEN
        INSERT INTO ConfigParameters (
            CategoryID, ParameterCode, ParameterName, Priority, IsDefault, IsActive,
            ParameterExternalID, ParameterExternalName, ParameterExternalCode, ParameterColor, ParameterIcon, ParameterImage,
            Attribute1, Attribute2, Attribute3,
            CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
        ) VALUES (
            p_CategoryID, TRIM(p_ParameterCode), TRIM(p_ParameterName), COALESCE(p_Priority, 1), p_IsDefault, COALESCE(p_IsActive, 1),
            p_ParameterExternalID, p_ParameterExternalName, p_ParameterExternalCode, p_ParameterColor, p_ParameterIcon, p_ParameterImage,
            p_Attribute1, p_Attribute2, p_Attribute3,
            p_UID, CURRENT_TIMESTAMP, p_UID, CURRENT_TIMESTAMP, 0
        );
        SET p_ParameterID = LAST_INSERT_ID();
        SET v_rowscount = ROW_COUNT();
    ELSE
        UPDATE ConfigParameters
        SET CategoryID            = p_CategoryID,
            ParameterCode         = TRIM(p_ParameterCode),
            ParameterName         = TRIM(p_ParameterName),
            Priority              = COALESCE(p_Priority, Priority),
            IsDefault             = p_IsDefault,
            IsActive              = COALESCE(p_IsActive, IsActive),
            ParameterExternalID   = p_ParameterExternalID,
            ParameterExternalName = p_ParameterExternalName,
            ParameterExternalCode = p_ParameterExternalCode,
            ParameterColor        = p_ParameterColor,
            ParameterIcon         = p_ParameterIcon,
            ParameterImage        = p_ParameterImage,
            Attribute1            = p_Attribute1,
            Attribute2            = p_Attribute2,
            Attribute3            = p_Attribute3,
            ModifiedBy            = p_UID,
            ModifiedDate          = CURRENT_TIMESTAMP
        WHERE ParameterID = p_ParameterID AND IsDeleted = 0;
        SET v_rowscount = ROW_COUNT();
    END IF;

    -- Return execution metadata set
    SELECT COALESCE(p_ParameterID, 0) AS ID, COALESCE(v_err, 0) AS ErrNo, COALESCE(v_rowscount, 0) AS RowsCount, COALESCE(v_errMsg, '') AS ErrMsg, COALESCE(v_errLine, 0) AS ErrLine;
END //

DROP PROCEDURE IF EXISTS sp_GetConfigCategories //
CREATE PROCEDURE sp_GetConfigCategories ()
BEGIN
    CALL PR_S_ConfigCategory(-1, '', '', 1);
END //

DROP PROCEDURE IF EXISTS sp_GetConfigCategoryById //
CREATE PROCEDURE sp_GetConfigCategoryById (
    IN p_CategoryID INT
)
BEGIN
    CALL PR_S_ConfigCategory(p_CategoryID, '', '', -1);
END //

DROP PROCEDURE IF EXISTS sp_GetConfigCategoryByCode //
CREATE PROCEDURE sp_GetConfigCategoryByCode (
    IN p_CategoryCode VARCHAR(50)
)
BEGIN
    CALL PR_S_ConfigCategory(-1, p_CategoryCode, '', 1);
END //

DROP PROCEDURE IF EXISTS sp_GetConfigParametersByCategory //
CREATE PROCEDURE sp_GetConfigParametersByCategory (
    IN p_CategoryID INT
)
BEGIN
    CALL PR_S_ConfigParameters(-1, p_CategoryID, '', '', '', 1);
END //

DROP PROCEDURE IF EXISTS sp_GetConfigParametersByCategoryCode //
CREATE PROCEDURE sp_GetConfigParametersByCategoryCode (
    IN p_CategoryCode VARCHAR(50)
)
BEGIN
    CALL PR_S_ConfigParameters(-1, -1, p_CategoryCode, '', '', 1);
END //

DROP PROCEDURE IF EXISTS sp_GetConfigParameterById //
CREATE PROCEDURE sp_GetConfigParameterById (
    IN p_ParameterID INT
)
BEGIN
    CALL PR_S_ConfigParameters(p_ParameterID, -1, '', '', '', -1);
END //

DROP PROCEDURE IF EXISTS PR_S_SystemConfigurationKeys //
CREATE PROCEDURE PR_S_SystemConfigurationKeys (
    IN p_SystemConfigurationKeyID INT,
    IN p_Key VARCHAR(250),
    IN p_Active SMALLINT
)
BEGIN
    SELECT 
        sk.*,
        cp.ParameterCode AS DataTypeCode,
        cp.ParameterName AS DataTypeName,
        cp.CategoryID AS DataTypeCategoryID
    FROM SystemConfigurationKeys sk
    INNER JOIN ConfigParameters cp ON cp.ParameterID = sk.DataTypeID
    WHERE sk.IsDeleted = 0
      AND (COALESCE(p_SystemConfigurationKeyID, -1) = -1 OR sk.SystemConfigurationKeyID = p_SystemConfigurationKeyID)
      AND (COALESCE(p_Key, '') = '' OR sk.`Key` = p_Key)
      AND (COALESCE(p_Active, -1) NOT IN (0, 1) OR sk.Active = p_Active)
    ORDER BY sk.`Key` ASC;
END //

DROP PROCEDURE IF EXISTS PR_IU_SystemConfigurationKeys //
CREATE PROCEDURE PR_IU_SystemConfigurationKeys (
    IN p_SystemConfigurationKeyID INT,
    IN p_Key                      VARCHAR(250),
    IN p_Value                    LONGTEXT,
    IN p_Description              LONGTEXT,
    IN p_AcceptedValues           LONGTEXT,
    IN p_DataTypeID               INT,
    IN p_AllowEdit                TINYINT(1),
    IN p_Active                   TINYINT(1),
    IN p_UID                      INT
)
proc_body: BEGIN
    DECLARE v_err INT DEFAULT 0;
    DECLARE v_rowscount INT DEFAULT 0;
    DECLARE v_errMsg VARCHAR(300) DEFAULT '';
    DECLARE v_errLine INT DEFAULT 0;
    DECLARE v_duplicateID INT DEFAULT 0;
    DECLARE v_AllowEditExisting TINYINT(1);

    -- ========================================================================
    --/S/---------------- [Validation Section] -------------------------------
    -- ========================================================================
    IF EXISTS(SELECT 1 FROM SystemConfigurationKeys WHERE SystemConfigurationKeyID <> COALESCE(p_SystemConfigurationKeyID, -1) AND `Key` = TRIM(p_Key) AND IsDeleted = 0) THEN
        SELECT SystemConfigurationKeyID INTO v_duplicateID FROM SystemConfigurationKeys WHERE SystemConfigurationKeyID <> COALESCE(p_SystemConfigurationKeyID, -1) AND `Key` = TRIM(p_Key) AND IsDeleted = 0 LIMIT 1;
        SET v_err = 51;
        SET v_errMsg = CONCAT('Duplicate System Configuration Key! Already exists with ID ', v_duplicateID);
        LEAVE proc_body;
    END IF;

    IF COALESCE(p_SystemConfigurationKeyID, 0) > 0 THEN
        SELECT AllowEdit INTO v_AllowEditExisting FROM SystemConfigurationKeys WHERE SystemConfigurationKeyID = p_SystemConfigurationKeyID AND IsDeleted = 0 LIMIT 1;
        IF v_AllowEditExisting = 0 THEN
            SET v_err = 52;
            SET v_errMsg = 'Configuration key is system locked and does not allow editing.';
            LEAVE proc_body;
        END IF;
    END IF;

    -- Custom business validation logic can be added here
    --/E/---------------- [Validation Section] -------------------------------

    IF COALESCE(p_SystemConfigurationKeyID, 0) <= 0 THEN
        INSERT INTO SystemConfigurationKeys (
            `Key`, `Value`, Description, AcceptedValues, DataTypeID, AllowEdit, Active,
            CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
        ) VALUES (
            TRIM(p_Key), p_Value, p_Description, p_AcceptedValues, p_DataTypeID, COALESCE(p_AllowEdit, 1), COALESCE(p_Active, 1),
            p_UID, CURRENT_TIMESTAMP, p_UID, CURRENT_TIMESTAMP, 0
        );

        SET p_SystemConfigurationKeyID = LAST_INSERT_ID();
        SET v_rowscount = ROW_COUNT();
    ELSE
        UPDATE SystemConfigurationKeys
        SET `Key`           = TRIM(p_Key),
            `Value`         = p_Value,
            Description     = p_Description,
            AcceptedValues  = p_AcceptedValues,
            DataTypeID      = p_DataTypeID,
            AllowEdit       = COALESCE(p_AllowEdit, AllowEdit),
            Active          = COALESCE(p_Active, Active),
            ModifiedBy      = p_UID,
            ModifiedDate    = CURRENT_TIMESTAMP
        WHERE SystemConfigurationKeyID = p_SystemConfigurationKeyID AND IsDeleted = 0;

        SET v_rowscount = ROW_COUNT();
    END IF;

    SELECT COALESCE(p_SystemConfigurationKeyID, 0) AS ID, COALESCE(v_err, 0) AS ErrNo, COALESCE(v_rowscount, 0) AS RowsCount, COALESCE(v_errMsg, '') AS ErrMsg, COALESCE(v_errLine, 0) AS ErrLine;
END //

DROP PROCEDURE IF EXISTS sp_UpdateSystemConfiguration //
CREATE PROCEDURE sp_UpdateSystemConfiguration (
    IN p_Key VARCHAR(250),
    IN p_Value LONGTEXT,
    IN p_ModUID INT
)
BEGIN
    DECLARE v_ID INT DEFAULT 0;
    SELECT SystemConfigurationKeyID INTO v_ID FROM SystemConfigurationKeys WHERE `Key` = p_Key AND IsDeleted = 0 LIMIT 1;
    
    IF COALESCE(v_ID, 0) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Configuration key not found or is deleted.';
    ELSE
        CALL PR_IU_SystemConfigurationKeys(v_ID, p_Key, p_Value, NULL, NULL, 15001, 1, 1, p_ModUID);
    END IF;
END //

DROP PROCEDURE IF EXISTS sp_GetSystemConfigurations //
CREATE PROCEDURE sp_GetSystemConfigurations ()
BEGIN
    CALL PR_S_SystemConfigurationKeys(-1, '', 1);
END //

DROP PROCEDURE IF EXISTS sp_GetSystemConfigurationByKey //
CREATE PROCEDURE sp_GetSystemConfigurationByKey (
    IN p_Key VARCHAR(250)
)
BEGIN
    CALL PR_S_SystemConfigurationKeys(-1, p_Key, 1);
END //

DELIMITER ;

-- ============================================================================
-- View: vw_ConfigCategoryParameters
-- ============================================================================
CREATE OR REPLACE VIEW vw_ConfigCategoryParameters AS
SELECT 
    c.CategoryID, 
    c.ParentCategoryID, 
    c.CategoryName, 
    c.Active AS CategoryActive, 
    p.ParameterID, 
    p.ParameterCode, 
    p.ParameterName, 
    p.Priority AS ParameterPriority, 
    p.IsDefault, 
    p.IsActive AS ParameterIsActive, 
    p.IsDeleted AS ParameterIsDeleted
FROM ConfigCategory c
INNER JOIN ConfigParameters p ON p.CategoryID = c.CategoryID;
