IF OBJECT_ID('dbo.PR_S_ConfigCategory', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_S_ConfigCategory;
GO
CREATE PROCEDURE dbo.PR_S_ConfigCategory
    @p_CategoryID         INT = -1,
    @p_CategoryCode       NVARCHAR(50) = '',
    @p_CategoryName       NVARCHAR(100) = '',
    @p_Active             SMALLINT = -1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT * 
    FROM ConfigCategory WITH(NOLOCK)
    WHERE IsDeleted = 0
      AND (ISNULL(@p_CategoryID, -1) = -1 OR CategoryID = @p_CategoryID)
      AND (ISNULL(@p_CategoryCode, '') = '' OR CategoryCode = @p_CategoryCode)
      AND (ISNULL(@p_CategoryName, '') = '' OR CategoryName = @p_CategoryName)
      AND (ISNULL(@p_Active, -1) NOT IN (0, 1) OR Active = @p_Active)
    ORDER BY Priority ASC, CategoryName ASC;
END
GO

IF OBJECT_ID('dbo.PR_S_ConfigParameters', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_S_ConfigParameters;
GO
CREATE PROCEDURE dbo.PR_S_ConfigParameters
    @p_ParameterID        INT = -1,
    @p_CategoryID         INT = -1,
    @p_CategoryCode       NVARCHAR(50) = '',
    @p_ParameterCode       NVARCHAR(50) = '',
    @p_ParameterName       NVARCHAR(200) = '',
    @p_IsActive           SMALLINT = -1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        cp.*, 
        cc.CategoryCode, 
        cc.CategoryName
    FROM ConfigParameters cp WITH(NOLOCK)
    INNER JOIN ConfigCategory cc WITH(NOLOCK) ON cc.CategoryID = cp.CategoryID
    WHERE cp.IsDeleted = 0 
      AND cc.IsDeleted = 0
      AND (ISNULL(@p_ParameterID, -1) = -1 OR cp.ParameterID = @p_ParameterID)
      AND (ISNULL(@p_CategoryID, -1) = -1 OR cp.CategoryID = @p_CategoryID)
      AND (ISNULL(@p_CategoryCode, '') = '' OR cc.CategoryCode = @p_CategoryCode OR cc.CategoryName = @p_CategoryCode)
      AND (ISNULL(@p_ParameterCode, '') = '' OR cp.ParameterCode = @p_ParameterCode)
      AND (ISNULL(@p_ParameterName, '') = '' OR cp.ParameterName = @p_ParameterName)
      AND (ISNULL(@p_IsActive, -1) NOT IN (0, 1) OR cp.IsActive = @p_IsActive)
    ORDER BY cp.CategoryID ASC, cp.Priority ASC, cp.ParameterName ASC;
END
GO

IF OBJECT_ID('dbo.PR_IU_ConfigCategory', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_IU_ConfigCategory;
GO
CREATE PROCEDURE dbo.PR_IU_ConfigCategory
    @p_CategoryID           INT = 0 OUTPUT,
    @p_CategoryCode         NVARCHAR(50),
    @p_CategoryName         NVARCHAR(100),
    @p_Description          NVARCHAR(MAX) = NULL,
    @p_Priority             INT = 1,
    @p_Active               BIT = 1,
    @p_AllowModify          BIT = 1,
    @p_ParentCategoryID     INT = NULL,
    @p_CategoryExternalID   NVARCHAR(20) = NULL,
    @p_CategoryExternalName NVARCHAR(200) = NULL,
    @p_CategoryExternalCode NVARCHAR(20) = NULL,
    @p_CategoryColor        NVARCHAR(20) = NULL,
    @p_CategoryIcon         NVARCHAR(200) = NULL,
    @p_CategoryImage        NVARCHAR(200) = NULL,
    @p_Attribute1           NVARCHAR(100) = NULL,
    @p_Attribute2           NVARCHAR(100) = NULL,
    @p_Attribute3           NVARCHAR(100) = NULL,
    @p_UID                  INT = -1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err INT = 0, @rowscount INT = 0, @errMsg VARCHAR(300) = '', @errLine INT = 0;
    DECLARE @duplicateID INT = 0;

    BEGIN TRY
        -- ====================================================================
        --/S/---------------- [Validation Section] ---------------------------
        -- ====================================================================
        IF EXISTS(SELECT 1 FROM ConfigCategory WITH(NOLOCK) WHERE CategoryID <> ISNULL(@p_CategoryID, -1) AND CategoryName = LTRIM(RTRIM(@p_CategoryName)) AND IsDeleted = 0)
        BEGIN
            SELECT TOP 1 @duplicateID = CategoryID FROM ConfigCategory WITH(NOLOCK) WHERE CategoryID <> ISNULL(@p_CategoryID, -1) AND CategoryName = LTRIM(RTRIM(@p_CategoryName)) AND IsDeleted = 0;
            SELECT @err = 51, @errMsg = 'Duplicate Parameter Category Name! Already exists with ID ' + CAST(@duplicateID AS VARCHAR(10));
            GOTO ExResult;
        END

        IF EXISTS(SELECT 1 FROM ConfigCategory WITH(NOLOCK) WHERE CategoryID <> ISNULL(@p_CategoryID, -1) AND CategoryCode = LTRIM(RTRIM(@p_CategoryCode)) AND IsDeleted = 0)
        BEGIN
            SELECT TOP 1 @duplicateID = CategoryID FROM ConfigCategory WITH(NOLOCK) WHERE CategoryID <> ISNULL(@p_CategoryID, -1) AND CategoryCode = LTRIM(RTRIM(@p_CategoryCode)) AND IsDeleted = 0;
            SELECT @err = 52, @errMsg = 'Duplicate Parameter Category Code! Already exists with ID ' + CAST(@duplicateID AS VARCHAR(10));
            GOTO ExResult;
        END

        -- Custom business validation logic can be added here
        --/E/---------------- [Validation Section] ---------------------------

        BEGIN TRANSACTION;

        IF NOT EXISTS(SELECT 1 FROM ConfigCategory WITH(NOLOCK) WHERE CategoryID = @p_CategoryID AND IsDeleted = 0) OR ISNULL(@p_CategoryID, 0) <= 0
        BEGIN
            INSERT INTO ConfigCategory (
                CategoryCode, CategoryName, Description, Priority, Active, AllowModify, ParentCategoryID,
                CategoryExternalID, CategoryExternalName, CategoryExternalCode, CategoryColor, CategoryIcon, CategoryImage,
                Attribute1, Attribute2, Attribute3,
                CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
            ) VALUES (
                LTRIM(RTRIM(@p_CategoryCode)), LTRIM(RTRIM(@p_CategoryName)), @p_Description, ISNULL(@p_Priority, 1), ISNULL(@p_Active, 1), ISNULL(@p_AllowModify, 1), @p_ParentCategoryID,
                @p_CategoryExternalID, @p_CategoryExternalName, @p_CategoryExternalCode, @p_CategoryColor, @p_CategoryIcon, @p_CategoryImage,
                @p_Attribute1, @p_Attribute2, @p_Attribute3,
                @p_UID, GETDATE(), @p_UID, GETDATE(), 0
            );

            SET @p_CategoryID = SCOPE_IDENTITY();
            SELECT @rowscount = @@ROWCOUNT;
        END
        ELSE
        BEGIN
            UPDATE ConfigCategory
            SET CategoryCode         = LTRIM(RTRIM(@p_CategoryCode)),
                CategoryName         = LTRIM(RTRIM(@p_CategoryName)),
                Description          = @p_Description,
                Priority             = ISNULL(@p_Priority, Priority),
                Active               = ISNULL(@p_Active, Active),
                AllowModify          = ISNULL(@p_AllowModify, AllowModify),
                ParentCategoryID     = @p_ParentCategoryID,
                CategoryExternalID   = @p_CategoryExternalID,
                CategoryExternalName = @p_CategoryExternalName,
                CategoryExternalCode = @p_CategoryExternalCode,
                CategoryColor        = @p_CategoryColor,
                CategoryIcon         = @p_CategoryIcon,
                CategoryImage        = @p_CategoryImage,
                Attribute1           = @p_Attribute1,
                Attribute2           = @p_Attribute2,
                Attribute3           = @p_Attribute3,
                ModifiedBy           = @p_UID,
                ModifiedDate         = GETDATE()
            WHERE CategoryID = @p_CategoryID AND IsDeleted = 0;

            SELECT @rowscount = @@ROWCOUNT;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT @p_CategoryID = 0, @err = ISNULL(ERROR_NUMBER(), 50000), @errMsg = ISNULL(ERROR_MESSAGE(), ''), @errLine = ISNULL(ERROR_LINE(), 0);
    END CATCH

ExResult:
    SELECT ISNULL(@p_CategoryID, 0) AS ID, ISNULL(@err, 0) AS ErrNo, ISNULL(@rowscount, 0) AS RowsCount, ISNULL(@errMsg, '') AS ErrMsg, ISNULL(@errLine, 0) AS ErrLine;
END
GO

IF OBJECT_ID('dbo.PR_IU_ConfigParameters', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_IU_ConfigParameters;
GO
CREATE PROCEDURE dbo.PR_IU_ConfigParameters
    @p_ParameterID          INT = 0 OUTPUT,
    @p_CategoryID           INT,
    @p_ParameterCode         NVARCHAR(50),
    @p_ParameterName         NVARCHAR(200),
    @p_Priority             TINYINT = 1,
    @p_IsDefault            BIT = NULL,
    @p_IsActive             BIT = 1,
    @p_ParameterExternalID   NVARCHAR(20) = NULL,
    @p_ParameterExternalName NVARCHAR(200) = NULL,
    @p_ParameterExternalCode NVARCHAR(20) = NULL,
    @p_ParameterColor        NVARCHAR(20) = NULL,
    @p_ParameterIcon         NVARCHAR(200) = NULL,
    @p_ParameterImage        NVARCHAR(200) = NULL,
    @p_Attribute1           NVARCHAR(100) = NULL,
    @p_Attribute2           NVARCHAR(100) = NULL,
    @p_Attribute3           NVARCHAR(100) = NULL,
    @p_UID                  INT = -1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err INT = 0, @rowscount INT = 0, @errMsg VARCHAR(300) = '', @errLine INT = 0;
    DECLARE @duplicateID INT = 0;

    BEGIN TRY
        -- ====================================================================
        --/S/---------------- [Validation Section] ---------------------------
        -- ====================================================================
        IF EXISTS(SELECT 1 FROM ConfigParameters WITH(NOLOCK) WHERE ParameterID <> ISNULL(@p_ParameterID, -1) AND CategoryID = @p_CategoryID AND ParameterName = LTRIM(RTRIM(@p_ParameterName)) AND IsDeleted = 0)
        BEGIN
            SELECT TOP 1 @duplicateID = ParameterID FROM ConfigParameters WITH(NOLOCK) WHERE ParameterID <> ISNULL(@p_ParameterID, -1) AND CategoryID = @p_CategoryID AND ParameterName = LTRIM(RTRIM(@p_ParameterName)) AND IsDeleted = 0;
            SELECT @err = 51, @errMsg = 'Duplicate Parameter Name in Category! Already exists with ID ' + CAST(@duplicateID AS VARCHAR(10));
            GOTO ExResult;
        END

        IF EXISTS(SELECT 1 FROM ConfigParameters WITH(NOLOCK) WHERE ParameterID <> ISNULL(@p_ParameterID, -1) AND CategoryID = @p_CategoryID AND ParameterCode = LTRIM(RTRIM(@p_ParameterCode)) AND IsDeleted = 0)
        BEGIN
            SELECT TOP 1 @duplicateID = ParameterID FROM ConfigParameters WITH(NOLOCK) WHERE ParameterID <> ISNULL(@p_ParameterID, -1) AND CategoryID = @p_CategoryID AND ParameterCode = LTRIM(RTRIM(@p_ParameterCode)) AND IsDeleted = 0;
            SELECT @err = 52, @errMsg = 'Duplicate Parameter Code in Category! Already exists with ID ' + CAST(@duplicateID AS VARCHAR(10));
            GOTO ExResult;
        END

        -- Custom business validation logic can be added here
        --/E/---------------- [Validation Section] ---------------------------

        BEGIN TRANSACTION;

        IF NOT EXISTS(SELECT 1 FROM ConfigParameters WITH(NOLOCK) WHERE ParameterID = @p_ParameterID AND IsDeleted = 0) OR ISNULL(@p_ParameterID, 0) <= 0
        BEGIN
            INSERT INTO ConfigParameters (
                CategoryID, ParameterCode, ParameterName, Priority, IsDefault, IsActive,
                ParameterExternalID, ParameterExternalName, ParameterExternalCode, ParameterColor, ParameterIcon, ParameterImage,
                Attribute1, Attribute2, Attribute3,
                CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
            ) VALUES (
                @p_CategoryID, LTRIM(RTRIM(@p_ParameterCode)), LTRIM(RTRIM(@p_ParameterName)), ISNULL(@p_Priority, 1), @p_IsDefault, ISNULL(@p_IsActive, 1),
                @p_ParameterExternalID, @p_ParameterExternalName, @p_ParameterExternalCode, @p_ParameterColor, @p_ParameterIcon, @p_ParameterImage,
                @p_Attribute1, @p_Attribute2, @p_Attribute3,
                @p_UID, GETDATE(), @p_UID, GETDATE(), 0
            );

            SET @p_ParameterID = SCOPE_IDENTITY();
            SELECT @rowscount = @@ROWCOUNT;
        END
        ELSE
        BEGIN
            UPDATE ConfigParameters
            SET CategoryID            = @p_CategoryID,
                ParameterCode         = LTRIM(RTRIM(@p_ParameterCode)),
                ParameterName         = LTRIM(RTRIM(@p_ParameterName)),
                Priority              = ISNULL(@p_Priority, Priority),
                IsDefault             = @p_IsDefault,
                IsActive              = ISNULL(@p_IsActive, IsActive),
                ParameterExternalID   = @p_ParameterExternalID,
                ParameterExternalName = @p_ParameterExternalName,
                ParameterExternalCode = @p_ParameterExternalCode,
                ParameterColor        = @p_ParameterColor,
                ParameterIcon         = @p_ParameterIcon,
                ParameterImage        = @p_ParameterImage,
                Attribute1            = @p_Attribute1,
                Attribute2            = @p_Attribute2,
                Attribute3            = @p_Attribute3,
                ModifiedBy            = @p_UID,
                ModifiedDate          = GETDATE()
            WHERE ParameterID = @p_ParameterID AND IsDeleted = 0;

            SELECT @rowscount = @@ROWCOUNT;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT @p_ParameterID = 0, @err = ISNULL(ERROR_NUMBER(), 50000), @errMsg = ISNULL(ERROR_MESSAGE(), ''), @errLine = ISNULL(ERROR_LINE(), 0);
    END CATCH

ExResult:
    SELECT ISNULL(@p_ParameterID, 0) AS ID, ISNULL(@err, 0) AS ErrNo, ISNULL(@rowscount, 0) AS RowsCount, ISNULL(@errMsg, '') AS ErrMsg, ISNULL(@errLine, 0) AS ErrLine;
END
GO

IF OBJECT_ID('dbo.sp_GetConfigCategories', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetConfigCategories;
GO
CREATE PROCEDURE dbo.sp_GetConfigCategories
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.PR_S_ConfigCategory -1, '', '', 1;
END
GO

IF OBJECT_ID('dbo.sp_GetConfigCategoryById', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetConfigCategoryById;
GO
CREATE PROCEDURE dbo.sp_GetConfigCategoryById
    @p_CategoryID INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.PR_S_ConfigCategory @p_CategoryID, '', '', -1;
END
GO

IF OBJECT_ID('dbo.sp_GetConfigCategoryByCode', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetConfigCategoryByCode;
GO
CREATE PROCEDURE dbo.sp_GetConfigCategoryByCode
    @p_CategoryCode NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.PR_S_ConfigCategory -1, @p_CategoryCode, '', 1;
END
GO

IF OBJECT_ID('dbo.sp_GetConfigParametersByCategory', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetConfigParametersByCategory;
GO
CREATE PROCEDURE dbo.sp_GetConfigParametersByCategory
    @p_CategoryID INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.PR_S_ConfigParameters -1, @p_CategoryID, '', '', '', 1;
END
GO

IF OBJECT_ID('dbo.sp_GetConfigParametersByCategoryCode', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetConfigParametersByCategoryCode;
GO
CREATE PROCEDURE dbo.sp_GetConfigParametersByCategoryCode
    @p_CategoryCode NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.PR_S_ConfigParameters -1, -1, @p_CategoryCode, '', '', 1;
END
GO

IF OBJECT_ID('dbo.sp_GetConfigParameterById', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetConfigParameterById;
GO
CREATE PROCEDURE dbo.sp_GetConfigParameterById
    @p_ParameterID INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.PR_S_ConfigParameters @p_ParameterID, -1, '', '', '', -1;
END
GO

IF OBJECT_ID('dbo.PR_S_SystemConfigurationKeys', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_S_SystemConfigurationKeys;
GO
CREATE PROCEDURE dbo.PR_S_SystemConfigurationKeys
    @p_SystemConfigurationKeyID INT = -1,
    @p_Key                       NVARCHAR(250) = '',
    @p_Active                    SMALLINT = -1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        sk.*,
        cp.ParameterCode AS DataTypeCode,
        cp.ParameterName AS DataTypeName,
        cp.CategoryID AS DataTypeCategoryID
    FROM SystemConfigurationKeys sk WITH(NOLOCK)
    INNER JOIN ConfigParameters cp WITH(NOLOCK) ON cp.ParameterID = sk.DataTypeID
    WHERE sk.IsDeleted = 0
      AND (ISNULL(@p_SystemConfigurationKeyID, -1) = -1 OR sk.SystemConfigurationKeyID = @p_SystemConfigurationKeyID)
      AND (ISNULL(@p_Key, '') = '' OR sk.[Key] = @p_Key)
      AND (ISNULL(@p_Active, -1) NOT IN (0, 1) OR sk.Active = @p_Active)
    ORDER BY sk.[Key] ASC;
END
GO

IF OBJECT_ID('dbo.PR_IU_SystemConfigurationKeys', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_IU_SystemConfigurationKeys;
GO
CREATE PROCEDURE dbo.PR_IU_SystemConfigurationKeys
    @p_SystemConfigurationKeyID INT = 0 OUTPUT,
    @p_Key                      NVARCHAR(250),
    @p_Value                    NVARCHAR(MAX),
    @p_Description              NVARCHAR(MAX) = NULL,
    @p_AcceptedValues           NVARCHAR(MAX) = NULL,
    @p_DataTypeID               INT,
    @p_AllowEdit                BIT = 1,
    @p_Active                   BIT = 1,
    @p_UID                      INT = -1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err INT = 0, @rowscount INT = 0, @errMsg VARCHAR(300) = '', @errLine INT = 0;
    DECLARE @duplicateID INT = 0;
    DECLARE @AllowEditExisting BIT;

    BEGIN TRY
        -- ====================================================================
        --/S/---------------- [Validation Section] ---------------------------
        -- ====================================================================
        IF EXISTS(SELECT 1 FROM SystemConfigurationKeys WITH(NOLOCK) WHERE SystemConfigurationKeyID <> ISNULL(@p_SystemConfigurationKeyID, -1) AND [Key] = LTRIM(RTRIM(@p_Key)) AND IsDeleted = 0)
        BEGIN
            SELECT TOP 1 @duplicateID = SystemConfigurationKeyID FROM SystemConfigurationKeys WITH(NOLOCK) WHERE SystemConfigurationKeyID <> ISNULL(@p_SystemConfigurationKeyID, -1) AND [Key] = LTRIM(RTRIM(@p_Key)) AND IsDeleted = 0;
            SELECT @err = 51, @errMsg = 'Duplicate System Configuration Key! Already exists with ID ' + CAST(@duplicateID AS VARCHAR(10));
            GOTO ExResult;
        END

        IF ISNULL(@p_SystemConfigurationKeyID, 0) > 0
        BEGIN
            SELECT TOP 1 @AllowEditExisting = AllowEdit FROM SystemConfigurationKeys WITH(NOLOCK) WHERE SystemConfigurationKeyID = @p_SystemConfigurationKeyID AND IsDeleted = 0;
            IF @AllowEditExisting = 0
            BEGIN
                SELECT @err = 52, @errMsg = 'Configuration key is system locked and does not allow editing.';
                GOTO ExResult;
            END
        END

        -- Custom business validation logic can be added here
        --/E/---------------- [Validation Section] ---------------------------

        BEGIN TRANSACTION;

        IF NOT EXISTS(SELECT 1 FROM SystemConfigurationKeys WITH(NOLOCK) WHERE SystemConfigurationKeyID = @p_SystemConfigurationKeyID AND IsDeleted = 0) OR ISNULL(@p_SystemConfigurationKeyID, 0) <= 0
        BEGIN
            INSERT INTO SystemConfigurationKeys (
                [Key], Value, Description, AcceptedValues, DataTypeID, AllowEdit, Active,
                CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
            ) VALUES (
                LTRIM(RTRIM(@p_Key)), @p_Value, @p_Description, @p_AcceptedValues, @p_DataTypeID, ISNULL(@p_AllowEdit, 1), ISNULL(@p_Active, 1),
                @p_UID, GETDATE(), @p_UID, GETDATE(), 0
            );

            SET @p_SystemConfigurationKeyID = SCOPE_IDENTITY();
            SELECT @rowscount = @@ROWCOUNT;
        END
        ELSE
        BEGIN
            UPDATE SystemConfigurationKeys
            SET [Key]           = LTRIM(RTRIM(@p_Key)),
                Value           = @p_Value,
                Description     = @p_Description,
                AcceptedValues  = @p_AcceptedValues,
                DataTypeID      = @p_DataTypeID,
                AllowEdit       = ISNULL(@p_AllowEdit, AllowEdit),
                Active          = ISNULL(@p_Active, Active),
                ModifiedBy      = @p_UID,
                ModifiedDate    = GETDATE()
            WHERE SystemConfigurationKeyID = @p_SystemConfigurationKeyID AND IsDeleted = 0;

            SELECT @rowscount = @@ROWCOUNT;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT @p_SystemConfigurationKeyID = 0, @err = ISNULL(ERROR_NUMBER(), 50000), @errMsg = ISNULL(ERROR_MESSAGE(), ''), @errLine = ISNULL(ERROR_LINE(), 0);
    END CATCH

ExResult:
    SELECT ISNULL(@p_SystemConfigurationKeyID, 0) AS ID, ISNULL(@err, 0) AS ErrNo, ISNULL(@rowscount, 0) AS RowsCount, ISNULL(@errMsg, '') AS ErrMsg, ISNULL(@errLine, 0) AS ErrLine;
END
GO

IF OBJECT_ID('dbo.sp_UpdateSystemConfiguration', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_UpdateSystemConfiguration;
GO
CREATE PROCEDURE dbo.sp_UpdateSystemConfiguration
    @p_Key NVARCHAR(250),
    @p_Value NVARCHAR(MAX),
    @p_ModUID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_ID INT = 0;
    SELECT TOP 1 @v_ID = SystemConfigurationKeyID FROM SystemConfigurationKeys WITH(NOLOCK) WHERE [Key] = @p_Key AND IsDeleted = 0;
    
    IF ISNULL(@v_ID, 0) = 0
    BEGIN
        RAISERROR('Configuration key not found or is deleted.', 16, 1);
    END
    ELSE
    BEGIN
        EXEC dbo.PR_IU_SystemConfigurationKeys @p_SystemConfigurationKeyID = @v_ID, @p_Key = @p_Key, @p_Value = @p_Value, @p_DataTypeID = 15001, @p_UID = @p_ModUID;
    END
END
GO

IF OBJECT_ID('dbo.sp_GetSystemConfigurations', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetSystemConfigurations;
GO
CREATE PROCEDURE dbo.sp_GetSystemConfigurations
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.PR_S_SystemConfigurationKeys -1, '', 1;
END
GO

IF OBJECT_ID('dbo.sp_GetSystemConfigurationByKey', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetSystemConfigurationByKey;
GO
CREATE PROCEDURE dbo.sp_GetSystemConfigurationByKey
    @p_Key NVARCHAR(250)
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.PR_S_SystemConfigurationKeys -1, @p_Key, 1;
END
GO

-- ============================================================================
-- View: vw_ConfigCategoryParameters
-- ============================================================================
IF OBJECT_ID('dbo.vw_ConfigCategoryParameters', 'V') IS NOT NULL DROP VIEW dbo.vw_ConfigCategoryParameters;
GO
CREATE VIEW dbo.vw_ConfigCategoryParameters AS
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
GO
