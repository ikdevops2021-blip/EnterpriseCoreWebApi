DELIMITER //

DROP PROCEDURE IF EXISTS PR_S_User //
CREATE PROCEDURE PR_S_User (
    IN p_Id       INT,
    IN p_Email    VARCHAR(255),
    IN p_UserCode VARCHAR(50),
    IN p_IsActive SMALLINT
)
BEGIN
    SELECT 
        u.Id,
        u.UserCode,
        u.TitleId,
        t.ParameterName AS TitleName,
        u.FirstName,
        u.LastName,
        u.DisplayName,
        u.GenderId,
        g.ParameterName AS GenderName,
        u.ProfileImageUrl,
        u.Email,
        u.PasswordHash,
        u.IsActive,
        u.CreatedBy,
        u.CreatedDate,
        u.ModifiedBy,
        u.ModifiedDate,
        u.IsDeleted,
        u.DeletedBy,
        u.DeletedDate
    FROM `User` u
    LEFT JOIN ConfigParameters t ON u.TitleId = t.ParameterID AND t.IsDeleted = 0
    LEFT JOIN ConfigParameters g ON u.GenderId = g.ParameterID AND g.IsDeleted = 0
    WHERE u.IsDeleted = 0
      AND (COALESCE(p_Id, -1) = -1 OR u.Id = p_Id)
      AND (COALESCE(p_Email, '') = '' OR u.Email = p_Email OR u.UserCode = p_Email)
      AND (COALESCE(p_UserCode, '') = '' OR u.UserCode = p_UserCode)
      AND (COALESCE(p_IsActive, -1) NOT IN (0, 1) OR u.IsActive = p_IsActive)
    ORDER BY u.Id ASC;
END //

DROP PROCEDURE IF EXISTS PR_IU_User //
CREATE PROCEDURE PR_IU_User (
    IN p_Id              INT,
    IN p_UserCode        VARCHAR(50),
    IN p_TitleId         INT,
    IN p_FirstName       VARCHAR(250),
    IN p_LastName        VARCHAR(250),
    IN p_DisplayName     VARCHAR(250),
    IN p_GenderId        INT,
    IN p_ProfileImageUrl VARCHAR(500),
    IN p_Email           VARCHAR(255),
    IN p_PasswordHash    TEXT,
    IN p_IsActive        TINYINT(1),
    IN p_UID             INT
)
proc_body: BEGIN
    DECLARE v_err INT DEFAULT 0;
    DECLARE v_rowscount INT DEFAULT 0;
    DECLARE v_errMsg VARCHAR(300) DEFAULT '';
    DECLARE v_errLine INT DEFAULT 0;
    DECLARE v_duplicateID INT DEFAULT 0;

    IF COALESCE(p_UserCode, '') = '' THEN
        SET p_UserCode = TRIM(p_Email);
    END IF;

    IF p_DisplayName IS NULL THEN
        SET p_DisplayName = TRIM(CONCAT(p_FirstName, ' ', p_LastName));
    END IF;

    IF EXISTS(SELECT 1 FROM `User` WHERE Email = TRIM(p_Email) AND IsDeleted = 0 AND (COALESCE(p_Id, 0) <= 0 OR Id <> p_Id)) THEN
        SELECT Id INTO v_duplicateID FROM `User` WHERE Email = TRIM(p_Email) AND IsDeleted = 0 AND (COALESCE(p_Id, 0) <= 0 OR Id <> p_Id) LIMIT 1;
        SET v_err = 51;
        SET v_errMsg = CONCAT('Duplicate Email! Already exists with User ID ', v_duplicateID);
        LEAVE proc_body;
    END IF;

    IF EXISTS(SELECT 1 FROM `User` WHERE UserCode = TRIM(p_UserCode) AND IsDeleted = 0 AND (COALESCE(p_Id, 0) <= 0 OR Id <> p_Id)) THEN
        SELECT Id INTO v_duplicateID FROM `User` WHERE UserCode = TRIM(p_UserCode) AND IsDeleted = 0 AND (COALESCE(p_Id, 0) <= 0 OR Id <> p_Id) LIMIT 1;
        SET v_err = 54;
        SET v_errMsg = CONCAT('Duplicate UserCode! Already exists with User ID ', v_duplicateID);
        LEAVE proc_body;
    END IF;

    IF p_TitleId IS NOT NULL AND NOT EXISTS(SELECT 1 FROM ConfigParameters WHERE ParameterID = p_TitleId AND CategoryID = 2 AND IsDeleted = 0) THEN
        SET v_err = 52;
        SET v_errMsg = CONCAT('Invalid TitleId ', p_TitleId, '! Must be a valid C_TITLE parameter.');
        LEAVE proc_body;
    END IF;

    IF p_GenderId IS NOT NULL AND NOT EXISTS(SELECT 1 FROM ConfigParameters WHERE ParameterID = p_GenderId AND CategoryID = 1 AND IsDeleted = 0) THEN
        SET v_err = 53;
        SET v_errMsg = CONCAT('Invalid GenderId ', p_GenderId, '! Must be a valid C_GENDER parameter.');
        LEAVE proc_body;
    END IF;

    IF COALESCE(p_Id, 0) <= 0 THEN
        INSERT INTO `User` (
            UserCode, TitleId, FirstName, LastName, DisplayName, GenderId, ProfileImageUrl, Email, PasswordHash, IsActive,
            CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
        ) VALUES (
            TRIM(p_UserCode), p_TitleId, TRIM(p_FirstName), TRIM(p_LastName), TRIM(p_DisplayName), p_GenderId, TRIM(p_ProfileImageUrl), TRIM(p_Email), p_PasswordHash, COALESCE(p_IsActive, 1),
            p_UID, CURRENT_TIMESTAMP, p_UID, CURRENT_TIMESTAMP, 0
        );
        SET p_Id = LAST_INSERT_ID();
        SET v_rowscount = ROW_COUNT();
    ELSE
        UPDATE `User`
        SET UserCode        = TRIM(p_UserCode),
            TitleId         = p_TitleId,
            FirstName       = TRIM(p_FirstName),
            LastName        = TRIM(p_LastName),
            DisplayName     = TRIM(p_DisplayName),
            GenderId        = p_GenderId,
            ProfileImageUrl = TRIM(p_ProfileImageUrl),
            Email           = TRIM(p_Email),
            PasswordHash    = COALESCE(p_PasswordHash, PasswordHash),
            IsActive        = COALESCE(p_IsActive, IsActive),
            ModifiedBy      = p_UID,
            ModifiedDate    = CURRENT_TIMESTAMP
        WHERE Id = p_Id AND IsDeleted = 0;
        SET v_rowscount = ROW_COUNT();
    END IF;

    SELECT COALESCE(p_Id, 0) AS ID, COALESCE(v_err, 0) AS ErrNo, COALESCE(v_rowscount, 0) AS RowsCount, COALESCE(v_errMsg, '') AS ErrMsg, COALESCE(v_errLine, 0) AS ErrLine;
END //

DELIMITER ;
