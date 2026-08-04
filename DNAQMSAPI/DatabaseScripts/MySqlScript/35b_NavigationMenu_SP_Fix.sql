-- Fix: Recreate NavigationMenu SPs with explicit utf8mb4_general_ci collation
-- to match the Ampps MySQL server configuration

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;

DELIMITER //

DROP PROCEDURE IF EXISTS PR_S_NavigationMenu //
CREATE PROCEDURE PR_S_NavigationMenu (
    IN p_Id         INT,
    IN p_RoutePath  VARCHAR(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
    IN p_IsActive   SMALLINT
)
BEGIN
    SELECT * FROM NavigationMenu
    WHERE IsDeleted = 0
      AND (COALESCE(p_Id, -1) = -1 OR Id = p_Id)
      AND (p_RoutePath IS NULL OR p_RoutePath = '' OR RoutePath = p_RoutePath)
      AND (COALESCE(p_IsActive, -1) NOT IN (0, 1) OR IsActive = p_IsActive)
    ORDER BY SortOrder ASC, Title ASC;
END //

DROP PROCEDURE IF EXISTS PR_IU_NavigationMenu //
CREATE PROCEDURE PR_IU_NavigationMenu (
    IN p_Id                 INT,
    IN p_Title              VARCHAR(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
    IN p_IconName           VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
    IN p_RoutePath          VARCHAR(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
    IN p_SortOrder          INT,
    IN p_ParentId           INT,
    IN p_RequiredPermission VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
    IN p_IsActive           TINYINT(1),
    IN p_UID                INT
)
proc_body: BEGIN
    DECLARE v_err INT DEFAULT 0;
    DECLARE v_rowscount INT DEFAULT 0;
    DECLARE v_errMsg VARCHAR(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT '';
    DECLARE v_errLine INT DEFAULT 0;
    DECLARE v_duplicateID INT DEFAULT 0;

    IF EXISTS(
        SELECT 1 FROM NavigationMenu
        WHERE RoutePath = TRIM(p_RoutePath)
          AND IsDeleted = 0
          AND (COALESCE(p_Id, 0) <= 0 OR Id <> p_Id)
    ) THEN
        SELECT Id INTO v_duplicateID FROM NavigationMenu
        WHERE RoutePath = TRIM(p_RoutePath) AND IsDeleted = 0
          AND (COALESCE(p_Id, 0) <= 0 OR Id <> p_Id) LIMIT 1;
        SET v_err = 51;
        SET v_errMsg = CONCAT('Duplicate RoutePath! Already registered with Menu ID ', v_duplicateID);
        SELECT COALESCE(p_Id, 0) AS ID, v_err AS ErrNo, 0 AS RowsCount, v_errMsg AS ErrMsg, v_errLine AS ErrLine;
        LEAVE proc_body;
    END IF;

    IF COALESCE(p_Id, 0) <= 0 THEN
        INSERT INTO NavigationMenu (
            Title, IconName, RoutePath, SortOrder, ParentId, RequiredPermission, IsActive,
            CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
        ) VALUES (
            TRIM(p_Title), TRIM(p_IconName), TRIM(p_RoutePath),
            COALESCE(p_SortOrder, 99), p_ParentId, p_RequiredPermission,
            COALESCE(p_IsActive, 1),
            p_UID, CURRENT_TIMESTAMP, p_UID, CURRENT_TIMESTAMP, 0
        );
        SET p_Id = LAST_INSERT_ID();
        SET v_rowscount = ROW_COUNT();
    ELSE
        UPDATE NavigationMenu
        SET Title               = COALESCE(NULLIF(TRIM(p_Title), ''), Title),
            IconName            = COALESCE(NULLIF(TRIM(p_IconName), ''), IconName),
            RoutePath           = COALESCE(NULLIF(TRIM(p_RoutePath), ''), RoutePath),
            SortOrder           = COALESCE(p_SortOrder, SortOrder),
            ParentId            = p_ParentId,
            RequiredPermission  = p_RequiredPermission,
            IsActive            = COALESCE(p_IsActive, IsActive),
            ModifiedBy          = p_UID,
            ModifiedDate        = CURRENT_TIMESTAMP
        WHERE Id = p_Id AND IsDeleted = 0;
        SET v_rowscount = ROW_COUNT();
    END IF;

    SELECT COALESCE(p_Id, 0) AS ID, COALESCE(v_err, 0) AS ErrNo,
           COALESCE(v_rowscount, 0) AS RowsCount, COALESCE(v_errMsg, '') AS ErrMsg, COALESCE(v_errLine, 0) AS ErrLine;
END //

DELIMITER ;
