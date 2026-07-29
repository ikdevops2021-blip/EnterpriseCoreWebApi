-- ============================================================================
-- STORED PROCEDURES: LOCATION MASTERS, USER ADDRESSES & USER CONTACTS (MS SQL)
-- File Path: DNAQMSAPI/DatabaseScripts/MSSQLScript/27_Location_And_UserProfile_StoredProcs.sql
-- ============================================================================

USE [dnaqms];
GO

SET NOCOUNT ON;

-- ----------------------------------------------------------------------------
-- 1. COUNTRY SEARCH & SAVE PROCEDURES
-- ----------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[PR_S_Country]', N'P') IS NOT NULL DROP PROCEDURE [dbo].[PR_S_Country];
GO
CREATE PROCEDURE [dbo].[PR_S_Country]
    @p_CountryId          INT = -1,
    @p_Search             VARCHAR(100) = '',
    @p_IsActive           SMALLINT = -1
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * 
    FROM [dbo].[Country] 
    WHERE [IsDeleted] = 0
      AND (@p_CountryId = -1 OR [CountryId] = @p_CountryId)
      AND (@p_Search = '' OR [CountryName] LIKE '%' + @p_Search + '%' OR [CountryCode] = @p_Search OR [InternationalDialing] LIKE '%' + @p_Search + '%')
      AND (@p_IsActive NOT IN (0, 1) OR [IsActive] = @p_IsActive)
    ORDER BY [CountryName] ASC;
END;
GO

IF OBJECT_ID(N'[dbo].[PR_IU_Country]', N'P') IS NOT NULL DROP PROCEDURE [dbo].[PR_IU_Country];
GO
CREATE PROCEDURE [dbo].[PR_IU_Country]
    @p_CountryId            INT = 0,
    @p_CountryName          VARCHAR(100),
    @p_CountryCode          VARCHAR(5),
    @p_InternationalDialing   VARCHAR(10) = NULL,
    @p_Attribute1           VARCHAR(100) = NULL,
    @p_Attribute2           VARCHAR(100) = NULL,
    @p_Attribute3           VARCHAR(100) = NULL,
    @p_IsActive             BIT = 1,
    @p_UID                  INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_ErrNo INT = 0;
    DECLARE @v_ErrMsg VARCHAR(255) = '';
    DECLARE @v_RowsCount INT = 0;
    DECLARE @v_NewId INT = 0;

    IF EXISTS (
        SELECT 1 FROM [dbo].[Country] 
        WHERE [IsDeleted] = 0 
          AND ([CountryName] = LTRIM(RTRIM(@p_CountryName)) OR [CountryCode] = UPPER(LTRIM(RTRIM(@p_CountryCode))))
          AND (@p_CountryId <= 0 OR [CountryId] != @p_CountryId)
    )
    BEGIN
        SET @v_ErrNo = 1001;
        SET @v_ErrMsg = 'Country name or code already exists.';
        SELECT 0 AS ID, @v_ErrNo AS ErrNo, 0 AS RowsCount, @v_ErrMsg AS ErrMsg, 0 AS ErrLine;
        RETURN;
    END

    IF @p_CountryId <= 0
    BEGIN
        INSERT INTO [dbo].[Country] (
            [CountryName], [CountryCode], [InternationalDialing], 
            [Attribute1], [Attribute2], [Attribute3], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsDeleted]
        ) VALUES (
            LTRIM(RTRIM(@p_CountryName)), UPPER(LTRIM(RTRIM(@p_CountryCode))), @p_InternationalDialing,
            @p_Attribute1, @p_Attribute2, @p_Attribute3, @p_IsActive, @p_UID, GETDATE(), @p_UID, GETDATE(), 0
        );
        SET @v_NewId = SCOPE_IDENTITY();
        SET @v_RowsCount = 1;
    END
    ELSE
    BEGIN
        UPDATE [dbo].[Country] SET
            [CountryName] = LTRIM(RTRIM(@p_CountryName)),
            [CountryCode] = UPPER(LTRIM(RTRIM(@p_CountryCode))),
            [InternationalDialing] = @p_InternationalDialing,
            [Attribute1] = @p_Attribute1,
            [Attribute2] = @p_Attribute2,
            [Attribute3] = @p_Attribute3,
            [IsActive] = @p_IsActive,
            [ModifiedBy] = @p_UID,
            [ModifiedDate] = GETDATE()
        WHERE [CountryId] = @p_CountryId AND [IsDeleted] = 0;
        SET @v_NewId = @p_CountryId;
        SET @v_RowsCount = @@ROWCOUNT;
    END

    SELECT @v_NewId AS ID, 0 AS ErrNo, @v_RowsCount AS RowsCount, 'SUCCESS' AS ErrMsg, 0 AS ErrLine;
END;
GO

-- ----------------------------------------------------------------------------
-- 2. STATE SEARCH & SAVE PROCEDURES
-- ----------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[PR_S_State]', N'P') IS NOT NULL DROP PROCEDURE [dbo].[PR_S_State];
GO
CREATE PROCEDURE [dbo].[PR_S_State]
    @p_StateId            INT = -1,
    @p_CountryId          INT = -1,
    @p_Search             VARCHAR(100) = '',
    @p_IsActive           SMALLINT = -1
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        s.*,
        c.[CountryName],
        c.[CountryCode]
    FROM [dbo].[State] s
    INNER JOIN [dbo].[Country] c ON s.[CountryId] = c.[CountryId]
    WHERE s.[IsDeleted] = 0 AND c.[IsDeleted] = 0
      AND (@p_StateId = -1 OR s.[StateId] = @p_StateId)
      AND (@p_CountryId = -1 OR s.[CountryId] = @p_CountryId)
      AND (@p_Search = '' OR s.[StateName] LIKE '%' + @p_Search + '%' OR s.[StateCode] = @p_Search)
      AND (@p_IsActive NOT IN (0, 1) OR s.[IsActive] = @p_IsActive)
    ORDER BY c.[CountryName] ASC, s.[StateName] ASC;
END;
GO

IF OBJECT_ID(N'[dbo].[PR_IU_State]', N'P') IS NOT NULL DROP PROCEDURE [dbo].[PR_IU_State];
GO
CREATE PROCEDURE [dbo].[PR_IU_State]
    @p_StateId            INT = 0,
    @p_CountryId          INT,
    @p_StateName          VARCHAR(100),
    @p_StateCode          VARCHAR(10) = NULL,
    @p_Attribute1         VARCHAR(100) = NULL,
    @p_Attribute2         VARCHAR(100) = NULL,
    @p_Attribute3         VARCHAR(100) = NULL,
    @p_IsActive           BIT = 1,
    @p_UID                INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_NewId INT = 0;
    DECLARE @v_RowsCount INT = 0;

    IF @p_StateId <= 0
    BEGIN
        INSERT INTO [dbo].[State] (
            [CountryId], [StateName], [StateCode],
            [Attribute1], [Attribute2], [Attribute3], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsDeleted]
        ) VALUES (
            @p_CountryId, LTRIM(RTRIM(@p_StateName)), UPPER(LTRIM(RTRIM(@p_StateCode))),
            @p_Attribute1, @p_Attribute2, @p_Attribute3, @p_IsActive, @p_UID, GETDATE(), @p_UID, GETDATE(), 0
        );
        SET @v_NewId = SCOPE_IDENTITY();
        SET @v_RowsCount = 1;
    END
    ELSE
    BEGIN
        UPDATE [dbo].[State] SET
            [CountryId] = @p_CountryId,
            [StateName] = LTRIM(RTRIM(@p_StateName)),
            [StateCode] = UPPER(LTRIM(RTRIM(@p_StateCode))),
            [Attribute1] = @p_Attribute1,
            [Attribute2] = @p_Attribute2,
            [Attribute3] = @p_Attribute3,
            [IsActive] = @p_IsActive,
            [ModifiedBy] = @p_UID,
            [ModifiedDate] = GETDATE()
        WHERE [StateId] = @p_StateId AND [IsDeleted] = 0;
        SET @v_NewId = @p_StateId;
        SET @v_RowsCount = @@ROWCOUNT;
    END

    SELECT @v_NewId AS ID, 0 AS ErrNo, @v_RowsCount AS RowsCount, 'SUCCESS' AS ErrMsg, 0 AS ErrLine;
END;
GO

-- ----------------------------------------------------------------------------
-- 3. CITY SEARCH & SAVE PROCEDURES
-- ----------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[PR_S_City]', N'P') IS NOT NULL DROP PROCEDURE [dbo].[PR_S_City];
GO
CREATE PROCEDURE [dbo].[PR_S_City]
    @p_CityId             INT = -1,
    @p_StateId            INT = -1,
    @p_CountryId          INT = -1,
    @p_Search             VARCHAR(100) = '',
    @p_IsActive           SMALLINT = -1
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ct.*,
        s.[StateName],
        s.[StateCode],
        s.[CountryId],
        c.[CountryName],
        c.[CountryCode]
    FROM [dbo].[City] ct
    INNER JOIN [dbo].[State] s ON ct.[StateId] = s.[StateId]
    INNER JOIN [dbo].[Country] c ON s.[CountryId] = c.[CountryId]
    WHERE ct.[IsDeleted] = 0 AND s.[IsDeleted] = 0 AND c.[IsDeleted] = 0
      AND (@p_CityId = -1 OR ct.[CityId] = @p_CityId)
      AND (@p_StateId = -1 OR ct.[StateId] = @p_StateId)
      AND (@p_CountryId = -1 OR s.[CountryId] = @p_CountryId)
      AND (@p_Search = '' OR ct.[CityName] LIKE '%' + @p_Search + '%' OR ct.[CityCode] = @p_Search)
      AND (@p_IsActive NOT IN (0, 1) OR ct.[IsActive] = @p_IsActive)
    ORDER BY c.[CountryName] ASC, s.[StateName] ASC, ct.[CityName] ASC;
END;
GO

IF OBJECT_ID(N'[dbo].[PR_IU_City]', N'P') IS NOT NULL DROP PROCEDURE [dbo].[PR_IU_City];
GO
CREATE PROCEDURE [dbo].[PR_IU_City]
    @p_CityId             INT = 0,
    @p_StateId            INT,
    @p_CityName           VARCHAR(100),
    @p_CityCode           VARCHAR(10) = NULL,
    @p_Attribute1         VARCHAR(100) = NULL,
    @p_Attribute2         VARCHAR(100) = NULL,
    @p_Attribute3         VARCHAR(100) = NULL,
    @p_IsActive           BIT = 1,
    @p_UID                INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_NewId INT = 0;
    DECLARE @v_RowsCount INT = 0;

    IF @p_CityId <= 0
    BEGIN
        INSERT INTO [dbo].[City] (
            [StateId], [CityName], [CityCode],
            [Attribute1], [Attribute2], [Attribute3], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsDeleted]
        ) VALUES (
            @p_StateId, LTRIM(RTRIM(@p_CityName)), UPPER(LTRIM(RTRIM(@p_CityCode))),
            @p_Attribute1, @p_Attribute2, @p_Attribute3, @p_IsActive, @p_UID, GETDATE(), @p_UID, GETDATE(), 0
        );
        SET @v_NewId = SCOPE_IDENTITY();
        SET @v_RowsCount = 1;
    END
    ELSE
    BEGIN
        UPDATE [dbo].[City] SET
            [StateId] = @p_StateId,
            [CityName] = LTRIM(RTRIM(@p_CityName)),
            [CityCode] = UPPER(LTRIM(RTRIM(@p_CityCode))),
            [Attribute1] = @p_Attribute1,
            [Attribute2] = @p_Attribute2,
            [Attribute3] = @p_Attribute3,
            [IsActive] = @p_IsActive,
            [ModifiedBy] = @p_UID,
            [ModifiedDate] = GETDATE()
        WHERE [CityId] = @p_CityId AND [IsDeleted] = 0;
        SET @v_NewId = @p_CityId;
        SET @v_RowsCount = @@ROWCOUNT;
    END

    SELECT @v_NewId AS ID, 0 AS ErrNo, @v_RowsCount AS RowsCount, 'SUCCESS' AS ErrMsg, 0 AS ErrLine;
END;
GO

-- ----------------------------------------------------------------------------
-- 4. USER ADDRESSES SEARCH & SAVE PROCEDURES
-- ----------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[PR_S_UserAddresses]', N'P') IS NOT NULL DROP PROCEDURE [dbo].[PR_S_UserAddresses];
GO
CREATE PROCEDURE [dbo].[PR_S_UserAddresses]
    @p_AddressId          BIGINT = -1,
    @p_UserId             INT = -1
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ua.*,
        cp.[ParameterName] AS AddressTypeName,
        cp.[ParameterCode] AS AddressTypeCode,
        c.[CountryName],
        c.[CountryCode],
        s.[StateName],
        s.[StateCode],
        ct.[CityName],
        ct.[CityCode]
    FROM [dbo].[UserAddresses] ua
    INNER JOIN [dbo].[ConfigParameters] cp ON ua.[AddressTypeId] = cp.[ParameterID]
    INNER JOIN [dbo].[Country] c ON ua.[CountryId] = c.[CountryId]
    INNER JOIN [dbo].[State] s ON ua.[StateId] = s.[StateId]
    INNER JOIN [dbo].[City] ct ON ua.[CityId] = ct.[CityId]
    WHERE ua.[IsDeleted] = 0
      AND (@p_AddressId = -1 OR ua.[AddressId] = @p_AddressId)
      AND (@p_UserId = -1 OR ua.[UserId] = @p_UserId)
    ORDER BY ua.[IsPrimary] DESC, ua.[AddressId] DESC;
END;
GO

IF OBJECT_ID(N'[dbo].[PR_IU_UserAddresses]', N'P') IS NOT NULL DROP PROCEDURE [dbo].[PR_IU_UserAddresses];
GO
CREATE PROCEDURE [dbo].[PR_IU_UserAddresses]
    @p_AddressId          BIGINT = 0,
    @p_UserId             INT,
    @p_AddressTypeId      INT,
    @p_AddressLine1       VARCHAR(255),
    @p_AddressLine2       VARCHAR(255) = NULL,
    @p_PostalCode         VARCHAR(20),
    @p_CountryId          INT,
    @p_StateId            INT,
    @p_CityId             INT,
    @p_Latitude           DECIMAL(9,6) = NULL,
    @p_Longitude          DECIMAL(9,6) = NULL,
    @p_IsPrimary          BIT = 0,
    @p_IsActive           BIT = 1,
    @p_UID                INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_NewId BIGINT = 0;
    DECLARE @v_RowsCount INT = 0;

    IF @p_IsPrimary = 1
    BEGIN
        UPDATE [dbo].[UserAddresses] SET [IsPrimary] = 0 WHERE [UserId] = @p_UserId AND [IsDeleted] = 0;
    END

    IF @p_AddressId <= 0
    BEGIN
        INSERT INTO [dbo].[UserAddresses] (
            [UserId], [AddressTypeId], [AddressLine1], [AddressLine2], [PostalCode],
            [CountryId], [StateId], [CityId], [Latitude], [Longitude], [IsPrimary], [IsActive],
            [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsDeleted]
        ) VALUES (
            @p_UserId, @p_AddressTypeId, @p_AddressLine1, @p_AddressLine2, @p_PostalCode,
            @p_CountryId, @p_StateId, @p_CityId, @p_Latitude, @p_Longitude, @p_IsPrimary, @p_IsActive,
            @p_UID, GETDATE(), @p_UID, GETDATE(), 0
        );
        SET @v_NewId = SCOPE_IDENTITY();
        SET @v_RowsCount = 1;
    END
    ELSE
    BEGIN
        UPDATE [dbo].[UserAddresses] SET
            [UserId] = @p_UserId,
            [AddressTypeId] = @p_AddressTypeId,
            [AddressLine1] = @p_AddressLine1,
            [AddressLine2] = @p_AddressLine2,
            [PostalCode] = @p_PostalCode,
            [CountryId] = @p_CountryId,
            [StateId] = @p_StateId,
            [CityId] = @p_CityId,
            [Latitude] = @p_Latitude,
            [Longitude] = @p_Longitude,
            [IsPrimary] = @p_IsPrimary,
            [IsActive] = @p_IsActive,
            [ModifiedBy] = @p_UID,
            [ModifiedDate] = GETDATE()
        WHERE [AddressId] = @p_AddressId AND [IsDeleted] = 0;
        SET @v_NewId = @p_AddressId;
        SET @v_RowsCount = @@ROWCOUNT;
    END

    SELECT @v_NewId AS ID, 0 AS ErrNo, @v_RowsCount AS RowsCount, 'SUCCESS' AS ErrMsg, 0 AS ErrLine;
END;
GO

-- ----------------------------------------------------------------------------
-- 5. USER CONTACTS SEARCH & SAVE PROCEDURES
-- ----------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[PR_S_UserContacts]', N'P') IS NOT NULL DROP PROCEDURE [dbo].[PR_S_UserContacts];
GO
CREATE PROCEDURE [dbo].[PR_S_UserContacts]
    @p_ContactId          BIGINT = -1,
    @p_UserId             INT = -1,
    @p_EmergencyOnly      SMALLINT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        uc.*,
        cpt.[ParameterName] AS ContactTypeName,
        cpt.[ParameterCode] AS ContactTypeCode,
        cpr.[ParameterName] AS RelationshipTypeName,
        cpr.[ParameterCode] AS RelationshipTypeCode
    FROM [dbo].[UserContacts] uc
    INNER JOIN [dbo].[ConfigParameters] cpt ON uc.[ContactTypeId] = cpt.[ParameterID]
    INNER JOIN [dbo].[ConfigParameters] cpr ON uc.[RelationshipTypeId] = cpr.[ParameterID]
    WHERE uc.[IsDeleted] = 0
      AND (@p_ContactId = -1 OR uc.[ContactId] = @p_ContactId)
      AND (@p_UserId = -1 OR uc.[UserId] = @p_UserId)
      AND (@p_EmergencyOnly = 0 OR uc.[IsEmergency] = 1)
    ORDER BY uc.[IsPrimary] DESC, uc.[IsEmergency] DESC, uc.[ContactId] DESC;
END;
GO

IF OBJECT_ID(N'[dbo].[PR_IU_UserContacts]', N'P') IS NOT NULL DROP PROCEDURE [dbo].[PR_IU_UserContacts];
GO
CREATE PROCEDURE [dbo].[PR_IU_UserContacts]
    @p_ContactId          BIGINT = 0,
    @p_UserId             INT,
    @p_ContactTypeId      INT,
    @p_RelationshipTypeId INT,
    @p_ContactValue       VARCHAR(255),
    @p_CountryCode        VARCHAR(5) = NULL,
    @p_IsPrimary          BIT = 0,
    @p_IsEmergency        BIT = 0,
    @p_IsVerified         BIT = 0,
    @p_IsActive           BIT = 1,
    @p_UID                INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_NewId BIGINT = 0;
    DECLARE @v_RowsCount INT = 0;

    IF @p_IsPrimary = 1
    BEGIN
        UPDATE [dbo].[UserContacts] 
        SET [IsPrimary] = 0 
        WHERE [UserId] = @p_UserId AND [ContactTypeId] = @p_ContactTypeId AND [IsDeleted] = 0;
    END

    IF @p_ContactId <= 0
    BEGIN
        INSERT INTO [dbo].[UserContacts] (
            [UserId], [ContactTypeId], [RelationshipTypeId], [ContactValue], [CountryCode],
            [IsPrimary], [IsEmergency], [IsVerified], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsDeleted]
        ) VALUES (
            @p_UserId, @p_ContactTypeId, @p_RelationshipTypeId, LTRIM(RTRIM(@p_ContactValue)), @p_CountryCode,
            @p_IsPrimary, @p_IsEmergency, @p_IsVerified, @p_IsActive, @p_UID, GETDATE(), @p_UID, GETDATE(), 0
        );
        SET @v_NewId = SCOPE_IDENTITY();
        SET @v_RowsCount = 1;
    END
    ELSE
    BEGIN
        UPDATE [dbo].[UserContacts] SET
            [UserId] = @p_UserId,
            [ContactTypeId] = @p_ContactTypeId,
            [RelationshipTypeId] = @p_RelationshipTypeId,
            [ContactValue] = LTRIM(RTRIM(@p_ContactValue)),
            [CountryCode] = @p_CountryCode,
            [IsPrimary] = @p_IsPrimary,
            [IsEmergency] = @p_IsEmergency,
            [IsVerified] = @p_IsVerified,
            [IsActive] = @p_IsActive,
            [ModifiedBy] = @p_UID,
            [ModifiedDate] = GETDATE()
        WHERE [ContactId] = @p_ContactId AND [IsDeleted] = 0;
        SET @v_NewId = @p_ContactId;
        SET @v_RowsCount = @@ROWCOUNT;
    END

    SELECT @v_NewId AS ID, 0 AS ErrNo, @v_RowsCount AS RowsCount, 'SUCCESS' AS ErrMsg, 0 AS ErrLine;
END;
GO
