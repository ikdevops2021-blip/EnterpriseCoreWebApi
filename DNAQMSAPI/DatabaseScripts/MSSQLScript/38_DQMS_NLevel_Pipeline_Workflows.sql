-- ============================================================================================
-- DQMS STAGE 2: N-LEVEL PIPELINE WORKFLOWS & SUB-TOKENS (MSSQL)
-- Script Number: 38_DQMS_NLevel_Pipeline_Workflows.sql
-- Description: Adds ParentTokenId, StepOrder, SubTokenSequence to TokenTransaction.
--              Implements PR_S_ProcessSteps, PR_IU_ForwardToken, and PR_S_TokenWorkflowHistory.
-- ============================================================================================

USE [dnaqms];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Add Pipeline & Sub-Token tracking columns to TokenTransaction if not present
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[TokenTransaction]') AND name = 'ParentTokenId')
BEGIN
    ALTER TABLE [dbo].[TokenTransaction] ADD [ParentTokenId] INT NULL;
    CREATE NONCLUSTERED INDEX [IX_TokenTransaction_ParentTokenId] ON [dbo].[TokenTransaction] ([ParentTokenId]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[TokenTransaction]') AND name = 'StepOrder')
BEGIN
    ALTER TABLE [dbo].[TokenTransaction] ADD [StepOrder] INT NOT NULL CONSTRAINT [DF_TokenTransaction_StepOrder] DEFAULT 1;
    CREATE NONCLUSTERED INDEX [IX_TokenTransaction_StepOrder] ON [dbo].[TokenTransaction] ([ProcessId], [StepOrder]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[TokenTransaction]') AND name = 'SubTokenSequence')
BEGIN
    ALTER TABLE [dbo].[TokenTransaction] ADD [SubTokenSequence] INT NOT NULL CONSTRAINT [DF_TokenTransaction_SubTokenSequence] DEFAULT 0;
END
GO

-- 2. Seed Complete Steps for All Processes (1 to 5)
IF EXISTS (SELECT 1 FROM [dbo].[Process] WHERE [Id] = 3) AND NOT EXISTS (SELECT 1 FROM [dbo].[ProcessStep] WHERE [ProcessId] = 3 AND [StepOrder] = 1)
BEGIN
    INSERT INTO [dbo].[ProcessStep] ([ProcessId], [StepOrder], [StepName], [TargetTATMinutes], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsDeleted])
    VALUES 
    (3, 1, 'Step 1: Document & Invoice Verification', 5, 1, 1, GETDATE(), 1, GETDATE(), 0),
    (3, 2, 'Step 2: Payment Processing & Official Receipt', 5, 1, 1, GETDATE(), 1, GETDATE(), 0);
END
GO

IF EXISTS (SELECT 1 FROM [dbo].[Process] WHERE [Id] = 4) AND NOT EXISTS (SELECT 1 FROM [dbo].[ProcessStep] WHERE [ProcessId] = 4 AND [StepOrder] = 1)
BEGIN
    INSERT INTO [dbo].[ProcessStep] ([ProcessId], [StepOrder], [StepName], [TargetTATMinutes], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsDeleted])
    VALUES 
    (4, 1, 'Step 1: Executive Nurse Vitals & History Check', 10, 1, 1, GETDATE(), 1, GETDATE(), 0),
    (4, 2, 'Step 2: Senior Consultant Doctor Examination', 20, 1, 1, GETDATE(), 1, GETDATE(), 0),
    (4, 3, 'Step 3: Specialist Treatment Protocol & Care Plan', 15, 1, 1, GETDATE(), 1, GETDATE(), 0);
END
GO

IF EXISTS (SELECT 1 FROM [dbo].[Process] WHERE [Id] = 5) AND NOT EXISTS (SELECT 1 FROM [dbo].[ProcessStep] WHERE [ProcessId] = 5 AND [StepOrder] = 1)
BEGIN
    INSERT INTO [dbo].[ProcessStep] ([ProcessId], [StepOrder], [StepName], [TargetTATMinutes], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsDeleted])
    VALUES 
    (5, 1, 'Step 1: Clinical Prescription Intake & Verification', 5, 1, 1, GETDATE(), 1, GETDATE(), 0),
    (5, 2, 'Step 2: Medication Compounding & Packaging', 10, 1, 1, GETDATE(), 1, GETDATE(), 0),
    (5, 3, 'Step 3: Pharmacist Consultation & Patient Advisory', 5, 1, 1, GETDATE(), 1, GETDATE(), 0);
END
GO

-- 3. Stored Procedure: PR_S_ProcessSteps (MSSQL)
CREATE OR ALTER PROCEDURE [dbo].[PR_S_ProcessSteps]
    @p_ProcessId INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        ps.[Id],
        ps.[ProcessId],
        p.[ProcessName],
        p.[ProcessCode],
        ps.[StepOrder],
        ps.[StepName],
        ps.[TargetTATMinutes],
        ps.[IsActive]
    FROM [dbo].[ProcessStep] ps
    INNER JOIN [dbo].[Process] p ON p.[Id] = ps.[ProcessId]
    WHERE (ISNULL(@p_ProcessId, 0) = 0 OR ps.[ProcessId] = @p_ProcessId)
      AND ps.[IsDeleted] = 0
      AND ps.[IsActive] = 1
    ORDER BY ps.[ProcessId] ASC, ps.[StepOrder] ASC;
END;
GO

-- 4. Stored Procedure: PR_IU_ForwardToken (MSSQL)
-- Supports:
--   A) Forward to Next Step (Step N -> Step N+1 in current process)
--   B) Branching forward to a different Process
--   C) Sub-Token generation (Parent remains active; child token created e.g. A-010-1)
--   D) Guard against infinite forwarding loops (> 20 steps)
CREATE OR ALTER PROCEDURE [dbo].[PR_IU_ForwardToken]
    @p_TokenId           INT,
    @p_TargetProcessId   INT = NULL,
    @p_TargetCounterId   INT = NULL,
    @p_IsSubToken        TINYINT = 0,
    @p_Reason            NVARCHAR(250) = NULL,
    @p_UserId            INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_origTokenNumber NVARCHAR(20);
    DECLARE @v_orgId INT;
    DECLARE @v_locId INT;
    DECLARE @v_areaId INT;
    DECLARE @v_origProcessId INT;
    DECLARE @v_origPriority INT;
    DECLARE @v_custName NVARCHAR(100);
    DECLARE @v_custPhone NVARCHAR(20);
    DECLARE @v_currentStepOrder INT;
    DECLARE @v_rootTokenId INT;
    DECLARE @v_nextStepOrder INT;
    DECLARE @v_effectiveProcessId INT;
    DECLARE @v_subSeq INT = 0;
    DECLARE @v_newTokenNumber NVARCHAR(25);
    DECLARE @v_newTokenId INT;
    DECLARE @v_stepName NVARCHAR(100);

    -- 1. Retrieve existing token details
    SELECT TOP 1
        @v_origTokenNumber   = [TokenNumber],
        @v_orgId             = [OrganizationId],
        @v_locId             = [LocationId],
        @v_areaId            = [AreaId],
        @v_origProcessId     = [ProcessId],
        @v_origPriority      = [PriorityTier],
        @v_custName          = [CustomerName],
        @v_custPhone         = [CustomerPhone],
        @v_currentStepOrder  = ISNULL([StepOrder], 1),
        @v_rootTokenId       = ISNULL([ParentTokenId], [Id])
    FROM [dbo].[TokenTransaction]
    WHERE [Id] = @p_TokenId AND [IsDeleted] = 0;

    IF @v_origTokenNumber IS NULL
    BEGIN
        SELECT 0 AS [ID], 100 AS [ErrNo], 0 AS [RowsCount], 'Token not found.' AS [ErrMsg], '' AS [TokenNumber], 0 AS [ProcessId], 0 AS [StepOrder], '' AS [StepName];
        RETURN;
    END

    -- 2. Guard against infinite loop (> 20 steps)
    IF @v_currentStepOrder >= 20 AND ISNULL(@p_IsSubToken, 0) = 0
    BEGIN
        SELECT 0 AS [ID], 104 AS [ErrNo], 0 AS [RowsCount], 'Maximum pipeline step limit (20) reached. Cannot forward further.' AS [ErrMsg], @v_origTokenNumber AS [TokenNumber], @v_origProcessId AS [ProcessId], @v_currentStepOrder AS [StepOrder], '' AS [StepName];
        RETURN;
    END

    -- CASE 1: GENERATE LINKED SUB-TOKEN (Parallel Branching, e.g. Doctor -> Lab)
    IF ISNULL(@p_IsSubToken, 0) = 1
    BEGIN
        SELECT @v_subSeq = ISNULL(MAX([SubTokenSequence]), 0) + 1
        FROM [dbo].[TokenTransaction]
        WHERE [ParentTokenId] = @v_rootTokenId;

        SET @v_newTokenNumber = @v_origTokenNumber + '-' + CAST(@v_subSeq AS NVARCHAR(10));
        SET @v_effectiveProcessId = ISNULL(@p_TargetProcessId, @v_origProcessId);

        INSERT INTO [dbo].[TokenTransaction] (
            [TokenNumber], [OrganizationId], [LocationId], [AreaId], [ProcessId], [CounterId],
            [PriorityTier], [StepOrder], [SubTokenSequence], [ParentTokenId], [TokenStatus],
            [CustomerName], [CustomerPhone], [Notes], [IssuedTime],
            [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsDeleted]
        ) VALUES (
            @v_newTokenNumber, @v_orgId, @v_locId, @v_areaId, @v_effectiveProcessId,
            CASE WHEN @p_TargetCounterId > 0 THEN @p_TargetCounterId ELSE NULL END,
            @v_origPriority, 1, @v_subSeq, @v_rootTokenId, 18001,
            @v_custName, @v_custPhone, CONCAT('Sub-token: ', LTRIM(RTRIM(ISNULL(@p_Reason, 'Parallel workflow branch')))),
            GETDATE(), @p_UserId, GETDATE(), @p_UserId, GETDATE(), 0
        );

        SET @v_newTokenId = SCOPE_IDENTITY();

        -- Audit Log for Parent Token
        INSERT INTO [dbo].[TokenAuditLog] ([TokenId], [PreviousStatus], [NewStatus], [ActionByUserId], [ActionTime], [ActionReason])
        VALUES (@p_TokenId, 18004, 18004, @p_UserId, GETDATE(), 
                CONCAT('Spawned sub-token ', @v_newTokenNumber, ' (ID: ', @v_newTokenId, ') for Process ', @v_effectiveProcessId));

        -- Audit Log for Child Sub-Token
        INSERT INTO [dbo].[TokenAuditLog] ([TokenId], [PreviousStatus], [NewStatus], [ActionByUserId], [ActionTime], [ActionReason])
        VALUES (@v_newTokenId, 0, 18001, @p_UserId, GETDATE(), 
                CONCAT('Sub-token issued from parent ', @v_origTokenNumber));

        SELECT 
            @v_newTokenId AS [ID], 
            0 AS [ErrNo], 
            1 AS [RowsCount], 
            CONCAT('Sub-token ', @v_newTokenNumber, ' successfully dispatched.') AS [ErrMsg],
            @v_newTokenNumber AS [TokenNumber],
            @v_effectiveProcessId AS [ProcessId],
            1 AS [StepOrder],
            'Sub-Token Branch' AS [StepName];
        RETURN;
    END

    -- CASE 2: SEQUENTIAL N-LEVEL FORWARDING (Step N -> Step N+1 OR Cross-Process Handoff)
    UPDATE [dbo].[TokenTransaction]
    SET [TokenStatus]   = 18008, -- Forwarded
        [CompletedTime] = GETDATE(),
        [Notes]         = CONCAT(ISNULL([Notes], ''), ' | Forwarded: ', LTRIM(RTRIM(ISNULL(@p_Reason, 'Advanced to next pipeline step')))),
        [ModifiedBy]    = @p_UserId,
        [ModifiedDate]  = GETDATE()
    WHERE [Id] = @p_TokenId;

    IF @p_TargetProcessId IS NOT NULL AND @p_TargetProcessId > 0 AND @p_TargetProcessId <> @v_origProcessId
    BEGIN
        SET @v_effectiveProcessId = @p_TargetProcessId;
        SET @v_nextStepOrder = 1;
    END
    ELSE
    BEGIN
        SET @v_effectiveProcessId = @v_origProcessId;
        SET @v_nextStepOrder = @v_currentStepOrder + 1;
    END

    SELECT TOP 1 @v_stepName = [StepName]
    FROM [dbo].[ProcessStep]
    WHERE [ProcessId] = @v_effectiveProcessId AND [StepOrder] = @v_nextStepOrder AND [IsDeleted] = 0;

    IF @v_stepName IS NULL
    BEGIN
        SET @v_stepName = CONCAT('Pipeline Step ', @v_nextStepOrder);
    END

    INSERT INTO [dbo].[TokenTransaction] (
        [TokenNumber], [OrganizationId], [LocationId], [AreaId], [ProcessId], [CounterId],
        [PriorityTier], [StepOrder], [SubTokenSequence], [ParentTokenId], [TokenStatus],
        [CustomerName], [CustomerPhone], [Notes], [IssuedTime],
        [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [IsDeleted]
    ) VALUES (
        @v_origTokenNumber, @v_orgId, @v_locId, @v_areaId, @v_effectiveProcessId,
        CASE WHEN ISNULL(@p_TargetCounterId, 0) > 0 THEN @p_TargetCounterId ELSE NULL END,
        @v_origPriority, @v_nextStepOrder, 0, @v_rootTokenId, 18001,
        @v_custName, @v_custPhone, 
        CONCAT('Forwarded to ', @v_stepName, ': ', LTRIM(RTRIM(ISNULL(@p_Reason, 'Standard pipeline handoff')))),
        GETDATE(), @p_UserId, GETDATE(), @p_UserId, GETDATE(), 0
    );

    SET @v_newTokenId = SCOPE_IDENTITY();

    INSERT INTO [dbo].[TokenAuditLog] ([TokenId], [PreviousStatus], [NewStatus], [ActionByUserId], [ActionTime], [ActionReason])
    VALUES (@p_TokenId, 18004, 18008, @p_UserId, GETDATE(), 
            CONCAT('Forwarded to ', @v_stepName, ' (Next Token ID: ', @v_newTokenId, ')'));

    INSERT INTO [dbo].[TokenAuditLog] ([TokenId], [PreviousStatus], [NewStatus], [ActionByUserId], [ActionTime], [ActionReason])
    VALUES (@v_newTokenId, 0, 18001, @p_UserId, GETDATE(), 
            CONCAT('Enqueued at Step ', @v_nextStepOrder, ' (', @v_stepName, ') from Token ', @p_TokenId));

    SELECT 
        @v_newTokenId AS [ID], 
        0 AS [ErrNo], 
        1 AS [RowsCount], 
        CONCAT('Token ', @v_origTokenNumber, ' successfully forwarded to ', @v_stepName) AS [ErrMsg],
        @v_origTokenNumber AS [TokenNumber],
        @v_effectiveProcessId AS [ProcessId],
        @v_nextStepOrder AS [StepOrder],
        @v_stepName AS [StepName];
END;
GO

-- 5. Stored Procedure: PR_S_TokenWorkflowHistory (MSSQL)
CREATE OR ALTER PROCEDURE [dbo].[PR_S_TokenWorkflowHistory]
    @p_TokenId INT = 0,
    @p_TokenNumber NVARCHAR(20) = ''
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_rootId INT;
    DECLARE @v_tokenNum NVARCHAR(20);

    IF @p_TokenId > 0
    BEGIN
        SELECT TOP 1 @v_rootId = ISNULL([ParentTokenId], [Id]), @v_tokenNum = [TokenNumber]
        FROM [dbo].[TokenTransaction] WHERE [Id] = @p_TokenId;
    END
    ELSE
    BEGIN
        SELECT TOP 1 @v_rootId = ISNULL([ParentTokenId], [Id]), @v_tokenNum = [TokenNumber]
        FROM [dbo].[TokenTransaction] WHERE [TokenNumber] = @p_TokenNumber AND [IsDeleted] = 0 
        ORDER BY [Id] DESC;
    END

    -- Grid 1: Root Journey Header
    SELECT TOP 1
        t.[Id] AS [RootTokenId],
        t.[TokenNumber],
        t.[OrganizationId],
        t.[LocationId],
        t.[ProcessId],
        p.[ProcessName],
        p.[ProcessCode],
        t.[CustomerName],
        t.[CustomerPhone],
        t.[PriorityTier],
        t.[IssuedTime],
        (SELECT COUNT(1) FROM [dbo].[ProcessStep] WHERE [ProcessId] = t.[ProcessId] AND [IsDeleted] = 0) AS [TotalConfiguredSteps],
        (SELECT ISNULL(MAX([StepOrder]), 1) FROM [dbo].[TokenTransaction] WHERE ([ParentTokenId] = @v_rootId OR [Id] = @v_rootId) AND [SubTokenSequence] = 0) AS [CurrentStepOrder]
    FROM [dbo].[TokenTransaction] t
    INNER JOIN [dbo].[Process] p ON p.[Id] = t.[ProcessId]
    WHERE t.[Id] = @v_rootId;

    -- Grid 2: All Sequential Execution Steps for this token
    SELECT 
        t.[Id] AS [TransactionId],
        t.[TokenNumber],
        t.[StepOrder],
        ISNULL(ps.[StepName], CONCAT('Step ', t.[StepOrder])) AS [StepName],
        ISNULL(ps.[TargetTATMinutes], 10) AS [TargetTATMinutes],
        t.[ProcessId],
        p.[ProcessName],
        t.[CounterId],
        c.[CounterNumber],
        c.[CounterName],
        t.[TokenStatus],
        ISNULL(cp.[ParameterName], 'Unknown') AS [StatusName],
        t.[IssuedTime],
        t.[CalledTime],
        t.[ServedTime],
        t.[CompletedTime],
        DATEDIFF(SECOND, ISNULL(t.[ServedTime], ISNULL(t.[CalledTime], t.[IssuedTime])), ISNULL(t.[CompletedTime], GETDATE())) AS [DurationSeconds],
        t.[Notes]
    FROM [dbo].[TokenTransaction] t
    INNER JOIN [dbo].[Process] p ON p.[Id] = t.[ProcessId]
    LEFT JOIN [dbo].[ProcessStep] ps ON ps.[ProcessId] = t.[ProcessId] AND ps.[StepOrder] = t.[StepOrder] AND ps.[IsDeleted] = 0
    LEFT JOIN [dbo].[Counter] c ON c.[Id] = t.[CounterId]
    LEFT JOIN [dbo].[ConfigParameters] cp ON cp.[ParameterID] = t.[TokenStatus] AND cp.[CategoryID] = 18
    WHERE (t.[ParentTokenId] = @v_rootId OR t.[Id] = @v_rootId)
      AND t.[SubTokenSequence] = 0
      AND t.[IsDeleted] = 0
    ORDER BY t.[StepOrder] ASC, t.[Id] ASC;

    -- Grid 3: Branching Sub-Tokens
    SELECT 
        st.[Id] AS [SubTokenId],
        st.[TokenNumber],
        st.[SubTokenSequence],
        st.[ProcessId],
        p.[ProcessName],
        st.[CounterId],
        c.[CounterNumber],
        st.[TokenStatus],
        ISNULL(cp.[ParameterName], 'Unknown') AS [StatusName],
        st.[IssuedTime],
        st.[ServedTime],
        st.[CompletedTime],
        st.[Notes]
    FROM [dbo].[TokenTransaction] st
    INNER JOIN [dbo].[Process] p ON p.[Id] = st.[ProcessId]
    LEFT JOIN [dbo].[Counter] c ON c.[Id] = st.[CounterId]
    LEFT JOIN [dbo].[ConfigParameters] cp ON cp.[ParameterID] = st.[TokenStatus] AND cp.[CategoryID] = 18
    WHERE st.[ParentTokenId] = @v_rootId
      AND st.[SubTokenSequence] > 0
      AND st.[IsDeleted] = 0
    ORDER BY st.[SubTokenSequence] ASC, st.[Id] ASC;
END;
GO
