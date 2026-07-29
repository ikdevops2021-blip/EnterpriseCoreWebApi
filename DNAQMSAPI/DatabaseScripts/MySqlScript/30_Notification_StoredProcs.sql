DELIMITER //

-- ============================================================================
-- 1. PR_S_NotificationTemplate: Template lookup joining ConfigParameters (Category 17: C_NOTIFICATION_EVENT)
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_S_NotificationTemplate //
CREATE PROCEDURE PR_S_NotificationTemplate (
    IN p_Id             INT,
    IN p_OrganizationId INT,
    IN p_EventCode      VARCHAR(100),
    IN p_EventId        INT
)
BEGIN
    IF COALESCE(p_Id, -1) > 0 THEN
        SELECT t.*, o.Name AS OrganizationName, cp.ParameterName AS EventName
        FROM NotificationTemplate t
        LEFT JOIN Organization o ON t.OrganizationId = o.Id
        LEFT JOIN ConfigParameters cp ON t.EventId = cp.ParameterID AND cp.IsDeleted = 0
        WHERE t.Id = p_Id AND t.IsDeleted = 0;
    ELSEIF COALESCE(p_EventId, -1) > 0 OR COALESCE(p_EventCode, '') != '' THEN
        -- Try Center-specific template first; fallback to Global (OrganizationId IS NULL)
        SELECT t.*, o.Name AS OrganizationName, cp.ParameterName AS EventName
        FROM NotificationTemplate t
        LEFT JOIN Organization o ON t.OrganizationId = o.Id
        LEFT JOIN ConfigParameters cp ON t.EventId = cp.ParameterID AND cp.IsDeleted = 0
        WHERE ( (COALESCE(p_EventId, -1) > 0 AND t.EventId = p_EventId) OR (COALESCE(p_EventCode, '') != '' AND (t.EventCode = p_EventCode OR cp.ParameterCode = p_EventCode)) )
          AND t.IsDeleted = 0 
          AND t.IsActive = 1
          AND (p_OrganizationId IS NULL OR p_OrganizationId = -1 OR t.OrganizationId = p_OrganizationId OR t.OrganizationId IS NULL)
        ORDER BY t.OrganizationId DESC -- Non-null Center template ranks ahead of NULL global
        LIMIT 1;
    ELSE
        -- List templates
        SELECT t.*, o.Name AS OrganizationName, cp.ParameterName AS EventName
        FROM NotificationTemplate t
        LEFT JOIN Organization o ON t.OrganizationId = o.Id
        LEFT JOIN ConfigParameters cp ON t.EventId = cp.ParameterID AND cp.IsDeleted = 0
        WHERE t.IsDeleted = 0
          AND (p_OrganizationId IS NULL OR p_OrganizationId = -1 OR t.OrganizationId = p_OrganizationId OR t.OrganizationId IS NULL)
        ORDER BY t.EventId ASC, t.OrganizationId DESC;
    END IF;
END //

-- ============================================================================
-- 2. PR_IU_NotificationTemplate: Create or Update Notification Template
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_IU_NotificationTemplate //
CREATE PROCEDURE PR_IU_NotificationTemplate (
    IN p_Id              INT,
    IN p_OrganizationId  INT,
    IN p_EventId         INT,
    IN p_EventCode       VARCHAR(100),
    IN p_CategoryId      INT,
    IN p_SubjectTemplate VARCHAR(255),
    IN p_BodyTemplate     TEXT,
    IN p_SendInApp       TINYINT(1),
    IN p_SendEmail       TINYINT(1),
    IN p_SendSMS         TINYINT(1),
    IN p_IsActive        TINYINT(1),
    IN p_UID             INT
)
proc_body: BEGIN
    DECLARE v_err INT DEFAULT 0;
    DECLARE v_rowscount INT DEFAULT 0;
    DECLARE v_errMsg VARCHAR(300) DEFAULT '';
    DECLARE v_duplicateID INT DEFAULT 0;

    -- Validate EventId from ConfigParameters (Category 17: C_NOTIFICATION_EVENT)
    IF COALESCE(p_EventId, 0) <= 0 AND COALESCE(p_EventCode, '') != '' THEN
        SELECT ParameterID INTO p_EventId FROM ConfigParameters 
        WHERE CategoryID = 17 AND ParameterCode = TRIM(p_EventCode) AND IsDeleted = 0 LIMIT 1;
    END IF;

    IF COALESCE(p_EventId, 0) <= 0 THEN
        SET v_err = 52;
        SET v_errMsg = 'Invalid EventId or EventCode! Event must be registered in ConfigParameters under category C_NOTIFICATION_EVENT (17).';
        LEAVE proc_body;
    END IF;

    IF COALESCE(p_EventCode, '') = '' THEN
        SELECT ParameterCode INTO p_EventCode FROM ConfigParameters WHERE ParameterID = p_EventId LIMIT 1;
    END IF;

    -- Validation: Unique (OrganizationId + EventId)
    IF EXISTS(SELECT 1 FROM NotificationTemplate 
              WHERE EventId = p_EventId
                AND ((p_OrganizationId IS NULL AND OrganizationId IS NULL) OR OrganizationId = p_OrganizationId)
                AND IsDeleted = 0 
                AND (COALESCE(p_Id, 0) <= 0 OR Id <> p_Id)) THEN
        SELECT Id INTO v_duplicateID FROM NotificationTemplate 
        WHERE EventId = p_EventId 
          AND ((p_OrganizationId IS NULL AND OrganizationId IS NULL) OR OrganizationId = p_OrganizationId)
          AND IsDeleted = 0 
          AND (COALESCE(p_Id, 0) <= 0 OR Id <> p_Id) LIMIT 1;
        SET v_err = 51;
        SET v_errMsg = CONCAT('Duplicate Template! EventId ', p_EventId, ' already exists with ID ', v_duplicateID);
        LEAVE proc_body;
    END IF;

    IF COALESCE(p_Id, 0) <= 0 THEN
        INSERT INTO NotificationTemplate (
            OrganizationId, EventId, EventCode, CategoryId, SubjectTemplate, BodyTemplate,
            SendInApp, SendEmail, SendSMS, IsActive,
            CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
        ) VALUES (
            p_OrganizationId, p_EventId, TRIM(p_EventCode), p_CategoryId, TRIM(p_SubjectTemplate), TRIM(p_BodyTemplate),
            COALESCE(p_SendInApp, 1), COALESCE(p_SendEmail, 1), COALESCE(p_SendSMS, 0), COALESCE(p_IsActive, 1),
            p_UID, CURRENT_TIMESTAMP, p_UID, CURRENT_TIMESTAMP, 0
        );
        SET p_Id = LAST_INSERT_ID();
        SET v_rowscount = ROW_COUNT();
    ELSE
        UPDATE NotificationTemplate
        SET OrganizationId  = p_OrganizationId,
            EventId         = p_EventId,
            EventCode       = TRIM(p_EventCode),
            CategoryId      = p_CategoryId,
            SubjectTemplate = TRIM(p_SubjectTemplate),
            BodyTemplate    = TRIM(p_BodyTemplate),
            SendInApp       = COALESCE(p_SendInApp, SendInApp),
            SendEmail       = COALESCE(p_SendEmail, SendEmail),
            SendSMS         = COALESCE(p_SendSMS, SendSMS),
            IsActive        = COALESCE(p_IsActive, IsActive),
            ModifiedBy      = p_UID,
            ModifiedDate    = CURRENT_TIMESTAMP
        WHERE Id = p_Id AND IsDeleted = 0;
        SET v_rowscount = ROW_COUNT();
    END IF;

    SELECT COALESCE(p_Id, 0) AS ID, COALESCE(v_err, 0) AS ErrNo, COALESCE(v_rowscount, 0) AS RowsCount, COALESCE(v_errMsg, '') AS ErrMsg, 0 AS ErrLine;
END //

-- ============================================================================
-- 3. PR_S_UserNotification: Get In-App Notification Bell Feed
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_S_UserNotification //
CREATE PROCEDURE PR_S_UserNotification (
    IN p_UserId         INT,
    IN p_OrganizationId INT,
    IN p_IsRead         SMALLINT, -- -1: All, 0: Unread, 1: Read
    IN p_PageNumber     INT,
    IN p_PageSize       INT
)
BEGIN
    DECLARE v_Offset INT;
    SET p_PageNumber = IF(COALESCE(p_PageNumber, 1) < 1, 1, p_PageNumber);
    SET p_PageSize = IF(COALESCE(p_PageSize, 20) < 1, 20, p_PageSize);
    SET v_Offset = (p_PageNumber - 1) * p_PageSize;

    SELECT 
        n.Id,
        n.OrganizationId,
        o.Name AS OrganizationName,
        n.UserId,
        n.EventId,
        n.EventCode,
        cp.ParameterName AS EventName,
        n.CategoryId,
        n.Title,
        n.Message,
        n.ActionUrl,
        n.IsRead,
        n.ReadDate,
        n.CreatedDate
    FROM UserNotification n
    INNER JOIN Organization o ON n.OrganizationId = o.Id
    LEFT JOIN ConfigParameters cp ON n.EventId = cp.ParameterID AND cp.IsDeleted = 0
    WHERE n.UserId = p_UserId
      AND n.IsDeleted = 0
      AND (COALESCE(p_OrganizationId, -1) = -1 OR n.OrganizationId = p_OrganizationId)
      AND (COALESCE(p_IsRead, -1) NOT IN (0, 1) OR n.IsRead = p_IsRead)
    ORDER BY n.CreatedDate DESC
    LIMIT p_PageSize OFFSET v_Offset;
END //

-- ============================================================================
-- 4. PR_S_UnreadNotificationCount: Get Unread Notification Badge Count
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_S_UnreadNotificationCount //
CREATE PROCEDURE PR_S_UnreadNotificationCount (
    IN p_UserId         INT,
    IN p_OrganizationId INT
)
BEGIN
    SELECT COUNT(*) AS UnreadCount
    FROM UserNotification
    WHERE UserId = p_UserId
      AND IsRead = 0
      AND IsDeleted = 0
      AND (COALESCE(p_OrganizationId, -1) = -1 OR OrganizationId = p_OrganizationId);
END //

-- ============================================================================
-- 5. PR_IU_UserNotification: Insert Notification or Mark Single Read
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_IU_UserNotification //
CREATE PROCEDURE PR_IU_UserNotification (
    IN p_Id             BIGINT,
    IN p_OrganizationId INT,
    IN p_UserId         INT,
    IN p_EventId        INT,
    IN p_EventCode      VARCHAR(100),
    IN p_CategoryId     INT,
    IN p_Title          VARCHAR(255),
    IN p_Message        TEXT,
    IN p_ActionUrl      VARCHAR(500),
    IN p_IsRead         TINYINT(1),
    IN p_UID            INT
)
proc_body: BEGIN
    DECLARE v_err INT DEFAULT 0;
    DECLARE v_rowscount INT DEFAULT 0;
    DECLARE v_errMsg VARCHAR(300) DEFAULT '';

    IF COALESCE(p_EventId, 0) <= 0 AND COALESCE(p_EventCode, '') != '' THEN
        SELECT ParameterID INTO p_EventId FROM ConfigParameters 
        WHERE CategoryID = 17 AND ParameterCode = TRIM(p_EventCode) AND IsDeleted = 0 LIMIT 1;
    END IF;

    IF COALESCE(p_Id, 0) <= 0 THEN
        INSERT INTO UserNotification (
            OrganizationId, UserId, EventId, EventCode, CategoryId, Title, Message, ActionUrl, IsRead,
            CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
        ) VALUES (
            p_OrganizationId, p_UserId, p_EventId, TRIM(p_EventCode), p_CategoryId, TRIM(p_Title), TRIM(p_Message), TRIM(p_ActionUrl), COALESCE(p_IsRead, 0),
            p_UID, CURRENT_TIMESTAMP, p_UID, CURRENT_TIMESTAMP, 0
        );
        SET p_Id = LAST_INSERT_ID();
        SET v_rowscount = ROW_COUNT();
    ELSE
        UPDATE UserNotification
        SET IsRead       = COALESCE(p_IsRead, IsRead),
            ReadDate     = IF(p_IsRead = 1, CURRENT_TIMESTAMP, ReadDate),
            ModifiedBy   = p_UID,
            ModifiedDate = CURRENT_TIMESTAMP
        WHERE Id = p_Id AND UserId = p_UserId AND IsDeleted = 0;
        SET v_rowscount = ROW_COUNT();
    END IF;

    SELECT COALESCE(p_Id, 0) AS ID, v_err AS ErrNo, v_rowscount AS RowsCount, v_errMsg AS ErrMsg, 0 AS ErrLine;
END //

-- ============================================================================
-- 6. PR_U_MarkAllNotificationsRead: Mark all notifications read for user
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_U_MarkAllNotificationsRead //
CREATE PROCEDURE PR_U_MarkAllNotificationsRead (
    IN p_UserId         INT,
    IN p_OrganizationId INT
)
BEGIN
    UPDATE UserNotification
    SET IsRead       = 1,
        ReadDate     = CURRENT_TIMESTAMP,
        ModifiedBy   = p_UserId,
        ModifiedDate = CURRENT_TIMESTAMP
    WHERE UserId = p_UserId
      AND IsRead = 0
      AND IsDeleted = 0
      AND (COALESCE(p_OrganizationId, -1) = -1 OR OrganizationId = p_OrganizationId);

    SELECT ROW_COUNT() AS AffectedRows;
END //

DELIMITER ;
