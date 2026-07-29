-- ============================================================================================
-- DQMS STAGE 2: STAFF OPERATIONS & TOKEN QUEUE MANAGEMENT (MSSQL)
-- Script Number: 33_DQMS_Staff_Operations.sql
-- Description: Token transaction tables, audit logs, and high-performance PR_IU_* / PR_S_* 
--              Stored Procedures for operator counter stations.
-- ============================================================================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TokenTransaction')
BEGIN
    CREATE TABLE dbo.TokenTransaction (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        TokenNumber NVARCHAR(20) NOT NULL,
        OrganizationId INT NOT NULL,
        LocationId INT NOT NULL,
        AreaId INT NOT NULL,
        ProcessId INT NOT NULL,
        CounterId INT NULL,
        UserId INT NULL,
        PriorityTier INT NOT NULL DEFAULT 19001,
        TokenStatus INT NOT NULL DEFAULT 18001,
        QueuePosition INT NOT NULL DEFAULT 1,
        CustomerName NVARCHAR(100) NULL,
        CustomerPhone NVARCHAR(20) NULL,
        Notes NVARCHAR(250) NULL,
        IssuedTime DATETIME NOT NULL DEFAULT GETDATE(),
        CalledTime DATETIME NULL,
        ServedTime DATETIME NULL,
        CompletedTime DATETIME NULL,
        CreatedBy INT NOT NULL,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
        ModifiedBy INT NOT NULL,
        ModifiedDate DATETIME NOT NULL DEFAULT GETDATE(),
        IsDeleted BIT NULL DEFAULT 0,
        DeletedBy INT NULL,
        DeletedDate DATETIME NULL
    );
END;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TokenAuditLog')
BEGIN
    CREATE TABLE dbo.TokenAuditLog (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        TokenId INT NOT NULL,
        PreviousStatus INT NOT NULL,
        NewStatus INT NOT NULL,
        ActionByUserId INT NOT NULL,
        ActionTime DATETIME NOT NULL DEFAULT GETDATE(),
        ActionReason NVARCHAR(250) NULL
    );
END;
GO

-- ============================================================================
-- STORED PROCEDURE: ISSUE NEW TOKEN (MSSQL)
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.PR_IU_IssueToken
    @p_OrganizationId INT,
    @p_LocationId INT,
    @p_AreaId INT,
    @p_ProcessId INT,
    @p_PriorityTier INT,
    @p_CustomerName NVARCHAR(100),
    @p_CustomerPhone NVARCHAR(20),
    @p_UID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_prefix NVARCHAR(5) = 'A';
    DECLARE @v_nextSeq INT = 1;
    DECLARE @v_tokenNum NVARCHAR(20);

    SELECT TOP 1 @v_prefix = Prefix FROM dbo.Process WHERE Id = @p_ProcessId AND IsDeleted = 0;
    IF @v_prefix IS NULL SET @v_prefix = 'A';

    SELECT @v_nextSeq = ISNULL(MAX(CAST(RIGHT(TokenNumber, 3) AS INT)), 0) + 1
    FROM dbo.TokenTransaction
    WHERE ProcessId = @p_ProcessId 
      AND CAST(IssuedTime AS DATE) = CAST(GETDATE() AS DATE);

    SET @v_tokenNum = @v_prefix + '-' + RIGHT('000' + CAST(@v_nextSeq AS NVARCHAR(10)), 3);

    INSERT INTO dbo.TokenTransaction (
        TokenNumber, OrganizationId, LocationId, AreaId, ProcessId, PriorityTier, TokenStatus,
        CustomerName, CustomerPhone, IssuedTime, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
    ) VALUES (
        @v_tokenNum, @p_OrganizationId, @p_LocationId, @p_AreaId, @p_ProcessId, ISNULL(@p_PriorityTier, 19001), 18001,
        TRIM(@p_CustomerName), TRIM(@p_CustomerPhone), GETDATE(), @p_UID, GETDATE(), @p_UID, GETDATE(), 0
    );

    SELECT SCOPE_IDENTITY() AS ID, 0 AS ErrNo, 1 AS RowsCount, 'Token issued successfully' AS ErrMsg, @v_tokenNum AS TokenNumber;
END;
GO

-- ============================================================================
-- STORED PROCEDURE: CALL NEXT TOKEN (MSSQL)
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.PR_IU_CallNextToken
    @p_OrganizationId INT,
    @p_LocationId INT,
    @p_CounterId INT,
    @p_ProcessId INT,
    @p_UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_tokenId INT = 0;
    DECLARE @v_tokenNum NVARCHAR(20) = '';

    SELECT TOP 1 @v_tokenId = Id, @v_tokenNum = TokenNumber
    FROM dbo.TokenTransaction
    WHERE OrganizationId = @p_OrganizationId 
      AND LocationId = @p_LocationId
      AND ProcessId = @p_ProcessId
      AND TokenStatus IN (18001, 18002)
      AND IsDeleted = 0
    ORDER BY PriorityTier DESC, IssuedTime ASC;

    IF @v_tokenId > 0
    BEGIN
        UPDATE dbo.TokenTransaction
        SET TokenStatus  = 18003, -- Calling
            CounterId    = @p_CounterId,
            UserId       = @p_UserId,
            CalledTime   = GETDATE(),
            ModifiedBy   = @p_UserId,
            ModifiedDate = GETDATE()
        WHERE Id = @v_tokenId;

        INSERT INTO dbo.TokenAuditLog (TokenId, PreviousStatus, NewStatus, ActionByUserId, ActionTime, ActionReason)
        VALUES (@v_tokenId, 18001, 18003, @p_UserId, GETDATE(), 'Token called by counter operator');

        SELECT @v_tokenId AS ID, 0 AS ErrNo, 1 AS RowsCount, 'Next token called' AS ErrMsg, @v_tokenNum AS TokenNumber;
    END
    ELSE
    BEGIN
        SELECT 0 AS ID, 100 AS ErrNo, 0 AS RowsCount, 'No tokens currently waiting in queue' AS ErrMsg, '' AS TokenNumber;
    END
END;
GO
