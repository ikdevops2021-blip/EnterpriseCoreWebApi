-- ============================================================================================
-- DQMS NAVIGATION MENU: Dynamic Plug-and-Play Navigation Menu System (MySQL)
-- Script Number: 35_NavigationMenu.sql
-- Description: Creates NavigationMenu table, PR_S_NavigationMenu, PR_IU_NavigationMenu
--              stored procedures, and seeds all 14 admin workspace modules.
-- NOTE: Run with --default-character-set=utf8mb4 to avoid collation mismatch on Ampps MySQL
-- ============================================================================================

SET NAMES utf8mb4 COLLATE utf8mb4_general_ci;

-- ============================================================================
-- NavigationMenu Master Table
-- ============================================================================
CREATE TABLE IF NOT EXISTS `NavigationMenu` (
    `Id`                INT AUTO_INCREMENT PRIMARY KEY,
    `Title`             VARCHAR(150) NOT NULL    COMMENT 'Display label in the sidebar',
    `IconName`          VARCHAR(100) NOT NULL    COMMENT 'Material icon name string (e.g. grid_view_rounded)',
    `RoutePath`         VARCHAR(200) NOT NULL    COMMENT 'GoRouter path (e.g. /admin/areas)',
    `SortOrder`         INT NOT NULL DEFAULT 1   COMMENT 'Sidebar display order (ascending)',
    `ParentId`          INT NULL                 COMMENT 'Nullable: future nested menus',
    `RequiredPermission` VARCHAR(100) NULL       COMMENT 'Permission code to filter by role (future use)',
    `IsActive`          TINYINT(1) NOT NULL DEFAULT 1,
    `CreatedBy`         INT NOT NULL DEFAULT 0,
    `CreatedDate`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `ModifiedBy`        INT NOT NULL DEFAULT 0,
    `ModifiedDate`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `IsDeleted`         TINYINT(1) NOT NULL DEFAULT 0,
    `DeletedBy`         INT NULL,
    `DeletedDate`       DATETIME NULL,
    UNIQUE KEY `UQ_NavigationMenu_RoutePath` (`RoutePath`),
    INDEX `IX_NavigationMenu_Sort` (`SortOrder`, `IsActive`, `IsDeleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Dynamic plug-and-play navigation menu definitions';

DELIMITER //

-- ============================================================================
-- PR_S_NavigationMenu: Search / Select Stored Procedure
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_S_NavigationMenu //
CREATE PROCEDURE PR_S_NavigationMenu (
    IN p_Id         INT,
    IN p_RoutePath  VARCHAR(200),
    IN p_IsActive   SMALLINT
)
BEGIN
    SELECT * FROM NavigationMenu
    WHERE IsDeleted = 0
      AND (COALESCE(p_Id, -1) = -1 OR Id = p_Id)
      AND (COALESCE(p_RoutePath, '') = '' OR RoutePath = p_RoutePath)
      AND (COALESCE(p_IsActive, -1) NOT IN (0, 1) OR IsActive = p_IsActive)
    ORDER BY SortOrder ASC, Title ASC;
END //

-- ============================================================================
-- PR_IU_NavigationMenu: Insert / Update (Upsert) Stored Procedure
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_IU_NavigationMenu //
CREATE PROCEDURE PR_IU_NavigationMenu (
    IN p_Id                 INT,
    IN p_Title              VARCHAR(150),
    IN p_IconName           VARCHAR(100),
    IN p_RoutePath          VARCHAR(200),
    IN p_SortOrder          INT,
    IN p_ParentId           INT,
    IN p_RequiredPermission VARCHAR(100),
    IN p_IsActive           TINYINT(1),
    IN p_UID                INT
)
proc_body: BEGIN
    DECLARE v_err INT DEFAULT 0;
    DECLARE v_rowscount INT DEFAULT 0;
    DECLARE v_errMsg VARCHAR(300) DEFAULT '';
    DECLARE v_errLine INT DEFAULT 0;
    DECLARE v_duplicateID INT DEFAULT 0;

    -- /S/---------------- [Validation Section] ----------------
    -- Duplicate RoutePath check
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
        SET Title               = TRIM(p_Title),
            IconName            = TRIM(p_IconName),
            RoutePath           = TRIM(p_RoutePath),
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

-- ============================================================================
-- Seed Data: All 13 DQMS Admin Workspace Modules
-- ============================================================================
INSERT IGNORE INTO NavigationMenu (Id, Title, IconName, RoutePath, SortOrder, RequiredPermission, IsActive, CreatedBy, ModifiedBy)
VALUES
    (1,  'Areas & Zones',                 'grid_view_rounded',              '/admin/areas',             1,  'areas.read',       1, 0, 0),
    (2,  'Process Pipelines',             'account_tree_rounded',           '/admin/processes',         2,  'processes.read',   1, 0, 0),
    (3,  'Counter Stations',              'desk_rounded',                   '/admin/counters',          3,  'counters.read',    1, 0, 0),
    (4,  'Display Templates',             'tv_rounded',                     '/admin/display-templates', 4,  'templates.read',   1, 0, 0),
    (5,  'Staff & Roles',                 'badge_rounded',                  '/admin/staff',             5,  'staff.read',       1, 0, 0),
    (6,  'User Profiles & Add/Edit',      'person_search_rounded',          '/admin/user-profiles',     6,  'users.read',       1, 0, 0),
    (7,  'Tenant / Organization Master',  'business_rounded',               '/admin/tenants',           7,  'tenants.read',     1, 0, 0),
    (8,  'Config Categories & Params',    'category_rounded',               '/admin/config-categories', 8,  'config.read',      1, 0, 0),
    (9,  'System Config Keys',            'settings_suggest_rounded',       '/admin/system-config',     9,  'sysconfig.read',   1, 0, 0),
    (10, 'Notification Channels',         'notifications_active_rounded',   '/admin/notifications',     10, 'notif.read',       1, 0, 0),
    (11, 'Email Gateway Setup',           'mark_email_read_rounded',        '/admin/email',             11, 'email.read',       1, 0, 0),
    (12, 'Analytics Hub',                 'analytics_rounded',              '/admin/analytics',         12, 'analytics.read',   1, 0, 0),
    (13, 'Application & Audit Logs',      'terminal_rounded',               '/admin/logs',              13, 'logs.read',        1, 0, 0),
    (14, 'Navigation Menu Manager',       'menu_rounded',                   '/admin/navigation-menu',   14, 'navmenu.admin',    1, 0, 0);
