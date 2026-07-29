-- ============================================================================================
-- DQMS STAGE 3: CUSTOMER & PUBLIC DISPLAY MANAGEMENT (MSSQL)
-- Script Number: 34_DQMS_Customer_Display.sql
-- Description: Overhead display queries, mobile web tracking, and WhatsApp threshold trigger.
-- ============================================================================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DisplaySession')
BEGIN
    CREATE TABLE dbo.DisplaySession (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        OrganizationId INT NOT NULL,
        LocationId INT NOT NULL,
        TemplateId INT NOT NULL,
        IpAddress NVARCHAR(45) NULL,
        DeviceName NVARCHAR(100) NULL,
        LastPulseTime DATETIME NOT NULL DEFAULT GETDATE(),
        IsActive BIT NOT NULL DEFAULT 1,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CustomerNotificationQueue')
BEGIN
    CREATE TABLE dbo.CustomerNotificationQueue (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        TokenId INT NOT NULL,
        CustomerPhone NVARCHAR(20) NOT NULL,
        MessageText NVARCHAR(500) NOT NULL,
        NotificationType INT NOT NULL DEFAULT 1,
        Status INT NOT NULL DEFAULT 0,
        SentTime DATETIME NULL,
        RetryCount INT NOT NULL DEFAULT 0,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
    );
END;
GO

-- ============================================================================
-- STORED PROCEDURE: PUBLIC OVERHEAD TV DISPLAY BOARD DATA (MSSQL)
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.PR_S_PublicDisplayBoard
    @p_OrganizationId INT,
    @p_LocationId INT,
    @p_AreaId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Now Calling / Flash Alert Tokens
    SELECT 
        T.Id,
        T.TokenNumber,
        T.ProcessId,
        P.ProcessName,
        P.Prefix,
        T.CounterId,
        C.CounterNumber,
        C.CounterName,
        T.TokenStatus,
        T.CalledTime,
        CASE WHEN DATEDIFF(SECOND, T.CalledTime, GETDATE()) <= 30 THEN 1 ELSE 0 END AS FlashAlert
    FROM dbo.TokenTransaction T
    INNER JOIN dbo.Process P ON T.ProcessId = P.Id
    INNER JOIN dbo.Counter C ON T.CounterId = C.Id
    WHERE T.OrganizationId = @p_OrganizationId
      AND T.LocationId = @p_LocationId
      AND (ISNULL(@p_AreaId, -1) = -1 OR T.AreaId = @p_AreaId)
      AND T.TokenStatus IN (18003, 18004)
      AND T.IsDeleted = 0
    ORDER BY T.CalledTime DESC;

    -- 2. Currently Waiting Count Summary per Process
    SELECT 
        P.Id AS ProcessId,
        P.ProcessName,
        P.Prefix,
        COUNT(T.Id) AS WaitingCount
    FROM dbo.Process P
    LEFT JOIN dbo.TokenTransaction T ON P.Id = T.ProcessId AND T.TokenStatus IN (18001, 18002) AND T.IsDeleted = 0
    WHERE P.OrganizationId = @p_OrganizationId AND P.IsActive = 1 AND P.IsDeleted = 0
    GROUP BY P.Id, P.ProcessName, P.Prefix
    ORDER BY P.ProcessName ASC;
END;
GO

-- ============================================================================
-- STORED PROCEDURE: PUBLIC MOBILE WEB TOKEN STATUS TRACKER (MSSQL)
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.PR_S_PublicTokenStatus
    @p_TokenId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_processId INT = 0;
    DECLARE @v_issuedTime DATETIME;
    DECLARE @v_priority INT = 19001;
    DECLARE @v_status INT = 18001;
    DECLARE @v_aheadCount INT = 0;
    DECLARE @v_targetTAT INT = 15;

    SELECT @v_processId = ProcessId, @v_issuedTime = IssuedTime, @v_priority = PriorityTier, @v_status = TokenStatus
    FROM dbo.TokenTransaction
    WHERE Id = @p_TokenId AND IsDeleted = 0;

    IF @v_processId > 0
    BEGIN
        SELECT @v_targetTAT = TargetTATMinutes FROM dbo.Process WHERE Id = @v_processId;

        SELECT @v_aheadCount = COUNT(Id)
        FROM dbo.TokenTransaction
        WHERE ProcessId = @v_processId
          AND TokenStatus IN (18001, 18002)
          AND IsDeleted = 0
          AND (PriorityTier > @v_priority OR (PriorityTier = @v_priority AND IssuedTime < @v_issuedTime));

        SELECT 
            T.Id,
            T.TokenNumber,
            P.ProcessName,
            T.TokenStatus,
            @v_aheadCount AS CustomersAhead,
            (@v_aheadCount + 1) * ISNULL(@v_targetTAT, 15) AS EstimatedWaitMinutes,
            C.CounterNumber,
            C.CounterName
        FROM dbo.TokenTransaction T
        INNER JOIN dbo.Process P ON T.ProcessId = P.Id
        LEFT JOIN dbo.Counter C ON T.CounterId = C.Id
        WHERE T.Id = @p_TokenId;
    END
END;
GO
