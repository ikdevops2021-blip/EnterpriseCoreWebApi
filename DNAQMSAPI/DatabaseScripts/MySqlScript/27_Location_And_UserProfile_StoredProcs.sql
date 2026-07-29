-- ============================================================================
-- STORED PROCEDURES: LOCATION MASTERS, USER ADDRESSES & USER CONTACTS (MySQL)
-- File Path: DNAQMSAPI/DatabaseScripts/MySqlScript/27_Location_And_UserProfile_StoredProcs.sql
-- ============================================================================

USE `dnaqms`;

DELIMITER //

-- ----------------------------------------------------------------------------
-- 1. COUNTRY SEARCH & SAVE PROCEDURES
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS PR_S_Country //
CREATE PROCEDURE PR_S_Country (
    IN p_CountryId          INT,
    IN p_Search             VARCHAR(100),
    IN p_IsActive           SMALLINT
)
BEGIN
    SELECT * 
    FROM Country 
    WHERE IsDeleted = 0
      AND (COALESCE(p_CountryId, -1) = -1 OR CountryId = p_CountryId)
      AND (COALESCE(p_Search, '') = '' OR CountryName LIKE CONCAT('%', p_Search, '%') OR CountryCode = p_Search OR InternationalDialing LIKE CONCAT('%', p_Search, '%'))
      AND (COALESCE(p_IsActive, -1) NOT IN (0, 1) OR IsActive = p_IsActive)
    ORDER BY CountryName ASC;
END //

DROP PROCEDURE IF EXISTS PR_IU_Country //
CREATE PROCEDURE PR_IU_Country (
    IN p_CountryId          INT,
    IN p_CountryName        VARCHAR(100),
    IN p_CountryCode        VARCHAR(5),
    IN p_InternationalDialing VARCHAR(10),
    IN p_Attribute1         VARCHAR(100),
    IN p_Attribute2         VARCHAR(100),
    IN p_Attribute3         VARCHAR(100),
    IN p_IsActive           TINYINT(1),
    IN p_UID                INT
)
BEGIN
    DECLARE v_ErrNo INT DEFAULT 0;
    DECLARE v_ErrMsg VARCHAR(255) DEFAULT '';
    DECLARE v_RowsCount INT DEFAULT 0;
    DECLARE v_NewId INT DEFAULT 0;

    -- Duplicate Check
    IF EXISTS (
        SELECT 1 FROM Country 
        WHERE IsDeleted = 0 
          AND (CountryName = TRIM(p_CountryName) OR CountryCode = UPPER(TRIM(p_CountryCode)))
          AND (p_CountryId <= 0 OR CountryId != p_CountryId)
    ) THEN
        SET v_ErrNo = 1001;
        SET v_ErrMsg = 'Country name or code already exists.';
        SELECT 0 AS ID, v_ErrNo AS ErrNo, 0 AS RowsCount, v_ErrMsg AS ErrMsg, 0 AS ErrLine;
    ELSE
        IF p_CountryId <= 0 THEN
            INSERT INTO Country (
                CountryName, CountryCode, InternationalDialing, 
                Attribute1, Attribute2, Attribute3, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
            ) VALUES (
                TRIM(p_CountryName), UPPER(TRIM(p_CountryCode)), p_InternationalDialing,
                p_Attribute1, p_Attribute2, p_Attribute3, p_IsActive, p_UID, CURRENT_TIMESTAMP, p_UID, CURRENT_TIMESTAMP, 0
            );
            SET v_NewId = LAST_INSERT_ID();
            SET v_RowsCount = 1;
        ELSE
            UPDATE Country SET
                CountryName = TRIM(p_CountryName),
                CountryCode = UPPER(TRIM(p_CountryCode)),
                InternationalDialing = p_InternationalDialing,
                Attribute1 = p_Attribute1,
                Attribute2 = p_Attribute2,
                Attribute3 = p_Attribute3,
                IsActive = p_IsActive,
                ModifiedBy = p_UID,
                ModifiedDate = CURRENT_TIMESTAMP
            WHERE CountryId = p_CountryId AND IsDeleted = 0;
            SET v_NewId = p_CountryId;
            SET v_RowsCount = ROW_COUNT();
        END IF;

        SELECT v_NewId AS ID, 0 AS ErrNo, v_RowsCount AS RowsCount, 'SUCCESS' AS ErrMsg, 0 AS ErrLine;
    END IF;
END //

-- ----------------------------------------------------------------------------
-- 2. STATE SEARCH & SAVE PROCEDURES
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS PR_S_State //
CREATE PROCEDURE PR_S_State (
    IN p_StateId            INT,
    IN p_CountryId          INT,
    IN p_Search             VARCHAR(100),
    IN p_IsActive           SMALLINT
)
BEGIN
    SELECT 
        s.*,
        c.CountryName,
        c.CountryCode
    FROM State s
    INNER JOIN Country c ON s.CountryId = c.CountryId
    WHERE s.IsDeleted = 0 AND c.IsDeleted = 0
      AND (COALESCE(p_StateId, -1) = -1 OR s.StateId = p_StateId)
      AND (COALESCE(p_CountryId, -1) = -1 OR s.CountryId = p_CountryId)
      AND (COALESCE(p_Search, '') = '' OR s.StateName LIKE CONCAT('%', p_Search, '%') OR s.StateCode = p_Search)
      AND (COALESCE(p_IsActive, -1) NOT IN (0, 1) OR s.IsActive = p_IsActive)
    ORDER BY c.CountryName ASC, s.StateName ASC;
END //

DROP PROCEDURE IF EXISTS PR_IU_State //
CREATE PROCEDURE PR_IU_State (
    IN p_StateId            INT,
    IN p_CountryId          INT,
    IN p_StateName          VARCHAR(100),
    IN p_StateCode          VARCHAR(10),
    IN p_Attribute1         VARCHAR(100),
    IN p_Attribute2         VARCHAR(100),
    IN p_Attribute3         VARCHAR(100),
    IN p_IsActive           TINYINT(1),
    IN p_UID                INT
)
BEGIN
    DECLARE v_NewId INT DEFAULT 0;
    DECLARE v_RowsCount INT DEFAULT 0;

    IF p_StateId <= 0 THEN
        INSERT INTO State (
            CountryId, StateName, StateCode,
            Attribute1, Attribute2, Attribute3, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
        ) VALUES (
            p_CountryId, TRIM(p_StateName), UPPER(TRIM(p_StateCode)),
            p_Attribute1, p_Attribute2, p_Attribute3, p_IsActive, p_UID, CURRENT_TIMESTAMP, p_UID, CURRENT_TIMESTAMP, 0
        );
        SET v_NewId = LAST_INSERT_ID();
        SET v_RowsCount = 1;
    ELSE
        UPDATE State SET
            CountryId = p_CountryId,
            StateName = TRIM(p_StateName),
            StateCode = UPPER(TRIM(p_StateCode)),
            Attribute1 = p_Attribute1,
            Attribute2 = p_Attribute2,
            Attribute3 = p_Attribute3,
            IsActive = p_IsActive,
            ModifiedBy = p_UID,
            ModifiedDate = CURRENT_TIMESTAMP
        WHERE StateId = p_StateId AND IsDeleted = 0;
        SET v_NewId = p_StateId;
        SET v_RowsCount = ROW_COUNT();
    END IF;

    SELECT v_NewId AS ID, 0 AS ErrNo, v_RowsCount AS RowsCount, 'SUCCESS' AS ErrMsg, 0 AS ErrLine;
END //

-- ----------------------------------------------------------------------------
-- 3. CITY SEARCH & SAVE PROCEDURES
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS PR_S_City //
CREATE PROCEDURE PR_S_City (
    IN p_CityId             INT,
    IN p_StateId            INT,
    IN p_CountryId          INT,
    IN p_Search             VARCHAR(100),
    IN p_IsActive           SMALLINT
)
BEGIN
    SELECT 
        ct.*,
        s.StateName,
        s.StateCode,
        s.CountryId,
        c.CountryName,
        c.CountryCode
    FROM City ct
    INNER JOIN State s ON ct.StateId = s.StateId
    INNER JOIN Country c ON s.CountryId = c.CountryId
    WHERE ct.IsDeleted = 0 AND s.IsDeleted = 0 AND c.IsDeleted = 0
      AND (COALESCE(p_CityId, -1) = -1 OR ct.CityId = p_CityId)
      AND (COALESCE(p_StateId, -1) = -1 OR ct.StateId = p_StateId)
      AND (COALESCE(p_CountryId, -1) = -1 OR s.CountryId = p_CountryId)
      AND (COALESCE(p_Search, '') = '' OR ct.CityName LIKE CONCAT('%', p_Search, '%') OR ct.CityCode = p_Search)
      AND (COALESCE(p_IsActive, -1) NOT IN (0, 1) OR ct.IsActive = p_IsActive)
    ORDER BY c.CountryName ASC, s.StateName ASC, ct.CityName ASC;
END //

DROP PROCEDURE IF EXISTS PR_IU_City //
CREATE PROCEDURE PR_IU_City (
    IN p_CityId             INT,
    IN p_StateId            INT,
    IN p_CityName           VARCHAR(100),
    IN p_CityCode           VARCHAR(10),
    IN p_Attribute1         VARCHAR(100),
    IN p_Attribute2         VARCHAR(100),
    IN p_Attribute3         VARCHAR(100),
    IN p_IsActive           TINYINT(1),
    IN p_UID                INT
)
BEGIN
    DECLARE v_NewId INT DEFAULT 0;
    DECLARE v_RowsCount INT DEFAULT 0;

    IF p_CityId <= 0 THEN
        INSERT INTO City (
            StateId, CityName, CityCode,
            Attribute1, Attribute2, Attribute3, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
        ) VALUES (
            p_StateId, TRIM(p_CityName), UPPER(TRIM(p_CityCode)),
            p_Attribute1, p_Attribute2, p_Attribute3, p_IsActive, p_UID, CURRENT_TIMESTAMP, p_UID, CURRENT_TIMESTAMP, 0
        );
        SET v_NewId = LAST_INSERT_ID();
        SET v_RowsCount = 1;
    ELSE
        UPDATE City SET
            StateId = p_StateId,
            CityName = TRIM(p_CityName),
            CityCode = UPPER(TRIM(p_CityCode)),
            Attribute1 = p_Attribute1,
            Attribute2 = p_Attribute2,
            Attribute3 = p_Attribute3,
            IsActive = p_IsActive,
            ModifiedBy = p_UID,
            ModifiedDate = CURRENT_TIMESTAMP
        WHERE CityId = p_CityId AND IsDeleted = 0;
        SET v_NewId = p_CityId;
        SET v_RowsCount = ROW_COUNT();
    END IF;

    SELECT v_NewId AS ID, 0 AS ErrNo, v_RowsCount AS RowsCount, 'SUCCESS' AS ErrMsg, 0 AS ErrLine;
END //

-- ----------------------------------------------------------------------------
-- 4. USER ADDRESSES SEARCH & SAVE PROCEDURES
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS PR_S_UserAddresses //
CREATE PROCEDURE PR_S_UserAddresses (
    IN p_AddressId          BIGINT,
    IN p_UserId             INT
)
BEGIN
    SELECT 
        ua.*,
        cp.ParameterName AS AddressTypeName,
        cp.ParameterCode AS AddressTypeCode,
        c.CountryName,
        c.CountryCode,
        s.StateName,
        s.StateCode,
        ct.CityName,
        ct.CityCode
    FROM UserAddresses ua
    INNER JOIN ConfigParameters cp ON ua.AddressTypeId = cp.ParameterID
    INNER JOIN Country c ON ua.CountryId = c.CountryId
    INNER JOIN State s ON ua.StateId = s.StateId
    INNER JOIN City ct ON ua.CityId = ct.CityId
    WHERE ua.IsDeleted = 0
      AND (COALESCE(p_AddressId, -1) = -1 OR ua.AddressId = p_AddressId)
      AND (COALESCE(p_UserId, -1) = -1 OR ua.UserId = p_UserId)
    ORDER BY ua.IsPrimary DESC, ua.AddressId DESC;
END //

DROP PROCEDURE IF EXISTS PR_IU_UserAddresses //
CREATE PROCEDURE PR_IU_UserAddresses (
    IN p_AddressId          BIGINT,
    IN p_UserId             INT,
    IN p_AddressTypeId      INT,
    IN p_AddressLine1       VARCHAR(255),
    IN p_AddressLine2       VARCHAR(255),
    IN p_PostalCode         VARCHAR(20),
    IN p_CountryId          INT,
    IN p_StateId            INT,
    IN p_CityId             INT,
    IN p_Latitude           DECIMAL(9,6),
    IN p_Longitude          DECIMAL(9,6),
    IN p_IsPrimary          TINYINT(1),
    IN p_IsActive           TINYINT(1),
    IN p_UID                INT
)
BEGIN
    DECLARE v_NewId BIGINT DEFAULT 0;
    DECLARE v_RowsCount INT DEFAULT 0;

    -- Handle Primary Address resetting
    IF p_IsPrimary = 1 THEN
        UPDATE UserAddresses SET IsPrimary = 0 WHERE UserId = p_UserId AND IsDeleted = 0;
    END IF;

    IF p_AddressId <= 0 THEN
        INSERT INTO UserAddresses (
            UserId, AddressTypeId, AddressLine1, AddressLine2, PostalCode,
            CountryId, StateId, CityId, Latitude, Longitude, IsPrimary, IsActive,
            CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
        ) VALUES (
            p_UserId, p_AddressTypeId, p_AddressLine1, p_AddressLine2, p_PostalCode,
            p_CountryId, p_StateId, p_CityId, p_Latitude, p_Longitude, p_IsPrimary, p_IsActive,
            p_UID, CURRENT_TIMESTAMP, p_UID, CURRENT_TIMESTAMP, 0
        );
        SET v_NewId = LAST_INSERT_ID();
        SET v_RowsCount = 1;
    ELSE
        UPDATE UserAddresses SET
            UserId = p_UserId,
            AddressTypeId = p_AddressTypeId,
            AddressLine1 = p_AddressLine1,
            AddressLine2 = p_AddressLine2,
            PostalCode = p_PostalCode,
            CountryId = p_CountryId,
            StateId = p_StateId,
            CityId = p_CityId,
            Latitude = p_Latitude,
            Longitude = p_Longitude,
            IsPrimary = p_IsPrimary,
            IsActive = p_IsActive,
            ModifiedBy = p_UID,
            ModifiedDate = CURRENT_TIMESTAMP
        WHERE AddressId = p_AddressId AND IsDeleted = 0;
        SET v_NewId = p_AddressId;
        SET v_RowsCount = ROW_COUNT();
    END IF;

    SELECT v_NewId AS ID, 0 AS ErrNo, v_RowsCount AS RowsCount, 'SUCCESS' AS ErrMsg, 0 AS ErrLine;
END //

-- ----------------------------------------------------------------------------
-- 5. USER CONTACTS SEARCH & SAVE PROCEDURES
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS PR_S_UserContacts //
CREATE PROCEDURE PR_S_UserContacts (
    IN p_ContactId          BIGINT,
    IN p_UserId             INT,
    IN p_EmergencyOnly      SMALLINT
)
BEGIN
    SELECT 
        uc.*,
        cpt.ParameterName AS ContactTypeName,
        cpt.ParameterCode AS ContactTypeCode,
        cpr.ParameterName AS RelationshipTypeName,
        cpr.ParameterCode AS RelationshipTypeCode
    FROM UserContacts uc
    INNER JOIN ConfigParameters cpt ON uc.ContactTypeId = cpt.ParameterID
    INNER JOIN ConfigParameters cpr ON uc.RelationshipTypeId = cpr.ParameterID
    WHERE uc.IsDeleted = 0
      AND (COALESCE(p_ContactId, -1) = -1 OR uc.ContactId = p_ContactId)
      AND (COALESCE(p_UserId, -1) = -1 OR uc.UserId = p_UserId)
      AND (COALESCE(p_EmergencyOnly, 0) = 0 OR uc.IsEmergency = 1)
    ORDER BY uc.IsPrimary DESC, uc.IsEmergency DESC, uc.ContactId DESC;
END //

DROP PROCEDURE IF EXISTS PR_IU_UserContacts //
CREATE PROCEDURE PR_IU_UserContacts (
    IN p_ContactId          BIGINT,
    IN p_UserId             INT,
    IN p_ContactTypeId      INT,
    IN p_RelationshipTypeId INT,
    IN p_ContactValue       VARCHAR(255),
    IN p_CountryCode        VARCHAR(5),
    IN p_IsPrimary          TINYINT(1),
    IN p_IsEmergency        TINYINT(1),
    IN p_IsVerified         TINYINT(1),
    IN p_IsActive           TINYINT(1),
    IN p_UID                INT
)
BEGIN
    DECLARE v_NewId BIGINT DEFAULT 0;
    DECLARE v_RowsCount INT DEFAULT 0;

    -- Handle Primary Contact resetting for same contact type
    IF p_IsPrimary = 1 THEN
        UPDATE UserContacts 
        SET IsPrimary = 0 
        WHERE UserId = p_UserId AND ContactTypeId = p_ContactTypeId AND IsDeleted = 0;
    END IF;

    IF p_ContactId <= 0 THEN
        INSERT INTO UserContacts (
            UserId, ContactTypeId, RelationshipTypeId, ContactValue, CountryCode,
            IsPrimary, IsEmergency, IsVerified, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
        ) VALUES (
            p_UserId, p_ContactTypeId, p_RelationshipTypeId, TRIM(p_ContactValue), p_CountryCode,
            p_IsPrimary, p_IsEmergency, p_IsVerified, p_IsActive, p_UID, CURRENT_TIMESTAMP, p_UID, CURRENT_TIMESTAMP, 0
        );
        SET v_NewId = LAST_INSERT_ID();
        SET v_RowsCount = 1;
    ELSE
        UPDATE UserContacts SET
            UserId = p_UserId,
            ContactTypeId = p_ContactTypeId,
            RelationshipTypeId = p_RelationshipTypeId,
            ContactValue = TRIM(p_ContactValue),
            CountryCode = p_CountryCode,
            IsPrimary = p_IsPrimary,
            IsEmergency = p_IsEmergency,
            IsVerified = p_IsVerified,
            IsActive = p_IsActive,
            ModifiedBy = p_UID,
            ModifiedDate = CURRENT_TIMESTAMP
        WHERE ContactId = p_ContactId AND IsDeleted = 0;
        SET v_NewId = p_ContactId;
        SET v_RowsCount = ROW_COUNT();
    END IF;

    SELECT v_NewId AS ID, 0 AS ErrNo, v_RowsCount AS RowsCount, 'SUCCESS' AS ErrMsg, 0 AS ErrLine;
END //

DELIMITER ;
