-- ============================================================================
-- N-LEVEL PIPELINE WORKFLOWS MIGRATION (MySQL)
-- Script Number: 38_DQMS_NLevel_Pipeline_Workflows.sql
-- Supports: Multi-step process pipelines, Step-to-Step forwarding,
--           Branching across services, and Linked Sub-Token generation.
-- ============================================================================

USE dnaqms;

-- 1. Add Pipeline & Sub-Token tracking columns to TokenTransaction if not present
SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS 
    WHERE TABLE_SCHEMA = 'dnaqms' AND TABLE_NAME = 'tokentransaction' AND COLUMN_NAME = 'ParentTokenId');
SET @sql = IF(@col_exists = 0, 
    'ALTER TABLE tokentransaction ADD COLUMN ParentTokenId INT NULL AFTER CounterId, ADD INDEX IX_Token_ParentTokenId (ParentTokenId);', 
    'SELECT "ParentTokenId already exists";');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS 
    WHERE TABLE_SCHEMA = 'dnaqms' AND TABLE_NAME = 'tokentransaction' AND COLUMN_NAME = 'StepOrder');
SET @sql = IF(@col_exists = 0, 
    'ALTER TABLE tokentransaction ADD COLUMN StepOrder INT NOT NULL DEFAULT 1 AFTER PriorityTier, ADD INDEX IX_Token_StepOrder (ProcessId, StepOrder);', 
    'SELECT "StepOrder already exists";');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM information_schema.COLUMNS 
    WHERE TABLE_SCHEMA = 'dnaqms' AND TABLE_NAME = 'tokentransaction' AND COLUMN_NAME = 'SubTokenSequence');
SET @sql = IF(@col_exists = 0, 
    'ALTER TABLE tokentransaction ADD COLUMN SubTokenSequence INT NOT NULL DEFAULT 0 AFTER StepOrder;', 
    'SELECT "SubTokenSequence already exists";');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 2. Seed Complete Steps for All Processes (1 to 5)
INSERT INTO processstep (ProcessId, StepOrder, StepName, TargetTATMinutes, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted)
SELECT 3, 1, 'Step 1: Document & Invoice Verification', 5, 1, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, 0
WHERE NOT EXISTS (SELECT 1 FROM processstep WHERE ProcessId = 3 AND StepOrder = 1);

INSERT INTO processstep (ProcessId, StepOrder, StepName, TargetTATMinutes, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted)
SELECT 3, 2, 'Step 2: Payment Processing & Official Receipt', 5, 1, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, 0
WHERE NOT EXISTS (SELECT 1 FROM processstep WHERE ProcessId = 3 AND StepOrder = 2);

INSERT INTO processstep (ProcessId, StepOrder, StepName, TargetTATMinutes, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted)
SELECT 4, 1, 'Step 1: Executive Nurse Vitals & History Check', 10, 1, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, 0
WHERE NOT EXISTS (SELECT 1 FROM processstep WHERE ProcessId = 4 AND StepOrder = 1);

INSERT INTO processstep (ProcessId, StepOrder, StepName, TargetTATMinutes, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted)
SELECT 4, 2, 'Step 2: Senior Consultant Doctor Examination', 20, 1, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, 0
WHERE NOT EXISTS (SELECT 1 FROM processstep WHERE ProcessId = 4 AND StepOrder = 2);

INSERT INTO processstep (ProcessId, StepOrder, StepName, TargetTATMinutes, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted)
SELECT 4, 3, 'Step 3: Specialist Treatment Protocol & Care Plan', 15, 1, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, 0
WHERE NOT EXISTS (SELECT 1 FROM processstep WHERE ProcessId = 4 AND StepOrder = 3);

INSERT INTO processstep (ProcessId, StepOrder, StepName, TargetTATMinutes, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted)
SELECT 5, 1, 'Step 1: Clinical Prescription Intake & Verification', 5, 1, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, 0
WHERE NOT EXISTS (SELECT 1 FROM processstep WHERE ProcessId = 5 AND StepOrder = 1);

INSERT INTO processstep (ProcessId, StepOrder, StepName, TargetTATMinutes, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted)
SELECT 5, 2, 'Step 2: Medication Compounding & Packaging', 10, 1, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, 0
WHERE NOT EXISTS (SELECT 1 FROM processstep WHERE ProcessId = 5 AND StepOrder = 2);

INSERT INTO processstep (ProcessId, StepOrder, StepName, TargetTATMinutes, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted)
SELECT 5, 3, 'Step 3: Pharmacist Consultation & Patient Advisory', 5, 1, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, 0
WHERE NOT EXISTS (SELECT 1 FROM processstep WHERE ProcessId = 5 AND StepOrder = 3);

-- 3. Stored Procedure: PR_S_ProcessSteps
DROP PROCEDURE IF EXISTS PR_S_ProcessSteps;
DELIMITER $$
CREATE PROCEDURE PR_S_ProcessSteps(
    IN p_ProcessId INT
)
BEGIN
    SELECT 
        ps.Id,
        ps.ProcessId,
        p.ProcessName,
        p.ProcessCode,
        ps.StepOrder,
        ps.StepName,
        ps.TargetTATMinutes,
        ps.IsActive
    FROM processstep ps
    INNER JOIN process p ON p.Id = ps.ProcessId
    WHERE (COALESCE(p_ProcessId, 0) = 0 OR ps.ProcessId = p_ProcessId)
      AND ps.IsDeleted = 0
      AND ps.IsActive = 1
    ORDER BY ps.ProcessId ASC, ps.StepOrder ASC;
END$$
DELIMITER ;

-- 4. Stored Procedure: PR_IU_ForwardToken
DROP PROCEDURE IF EXISTS PR_IU_ForwardToken;
DELIMITER $$
CREATE PROCEDURE PR_IU_ForwardToken(
    IN p_TokenId           INT,
    IN p_TargetProcessId   INT,
    IN p_TargetCounterId   INT,
    IN p_IsSubToken        TINYINT,
    IN p_Reason            VARCHAR(250),
    IN p_UserId            INT
)
proc_body: BEGIN
    DECLARE v_origTokenNumber VARCHAR(20);
    DECLARE v_orgId INT;
    DECLARE v_locId INT;
    DECLARE v_areaId INT;
    DECLARE v_origProcessId INT;
    DECLARE v_origPriority INT;
    DECLARE v_custName VARCHAR(100);
    DECLARE v_custPhone VARCHAR(20);
    DECLARE v_currentStepOrder INT;
    DECLARE v_rootTokenId INT;
    DECLARE v_nextStepOrder INT;
    DECLARE v_effectiveProcessId INT;
    DECLARE v_subSeq INT DEFAULT 0;
    DECLARE v_newTokenNumber VARCHAR(25);
    DECLARE v_newTokenId INT;
    DECLARE v_stepName VARCHAR(100);

    -- Retrieve existing token details
    SELECT 
        TokenNumber, OrganizationId, LocationId, AreaId, ProcessId, PriorityTier,
        CustomerName, CustomerPhone, COALESCE(StepOrder, 1), COALESCE(ParentTokenId, Id)
    INTO 
        v_origTokenNumber, v_orgId, v_locId, v_areaId, v_origProcessId, v_origPriority,
        v_custName, v_custPhone, v_currentStepOrder, v_rootTokenId
    FROM tokentransaction
    WHERE Id = p_TokenId AND IsDeleted = 0
    LIMIT 1;

    IF v_origTokenNumber IS NULL THEN
        SELECT 0 AS ID, 100 AS ErrNo, 0 AS RowsCount, 'Token not found.' AS ErrMsg, '' AS TokenNumber, 0 AS ProcessId, 0 AS StepOrder, '' AS StepName;
        LEAVE proc_body;
    END IF;

    -- Guard against infinite loop (> 20 steps)
    IF v_currentStepOrder >= 20 AND COALESCE(p_IsSubToken, 0) = 0 THEN
        SELECT 0 AS ID, 104 AS ErrNo, 0 AS RowsCount, 'Maximum pipeline step limit (20) reached. Cannot forward further.' AS ErrMsg, v_origTokenNumber AS TokenNumber, v_origProcessId AS ProcessId, v_currentStepOrder AS StepOrder, '' AS StepName;
        LEAVE proc_body;
    END IF;

    -- CASE 1: GENERATE LINKED SUB-TOKEN (Parallel Branching, e.g. Doctor -> Lab)
    IF COALESCE(p_IsSubToken, 0) = 1 THEN
        SELECT COALESCE(MAX(SubTokenSequence), 0) + 1 INTO v_subSeq
        FROM tokentransaction
        WHERE ParentTokenId = v_rootTokenId;

        SET v_newTokenNumber = CONCAT(v_origTokenNumber, '-', v_subSeq);
        SET v_effectiveProcessId = COALESCE(p_TargetProcessId, v_origProcessId);

        INSERT INTO tokentransaction (
            TokenNumber, OrganizationId, LocationId, AreaId, ProcessId, CounterId,
            PriorityTier, StepOrder, SubTokenSequence, ParentTokenId, TokenStatus,
            CustomerName, CustomerPhone, Notes, IssuedTime,
            CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
        ) VALUES (
            v_newTokenNumber, v_orgId, v_locId, v_areaId, v_effectiveProcessId, 
            IF(COALESCE(p_TargetCounterId, 0) > 0, p_TargetCounterId, NULL),
            v_origPriority, 1, v_subSeq, v_rootTokenId, 18001,
            v_custName, v_custPhone, CONCAT('Sub-token: ', TRIM(COALESCE(p_Reason, 'Parallel workflow branch'))),
            CURRENT_TIMESTAMP, p_UserId, CURRENT_TIMESTAMP, p_UserId, CURRENT_TIMESTAMP, 0
        );
        SET v_newTokenId = LAST_INSERT_ID();

        -- Audit Log for Parent Token
        INSERT INTO tokenauditlog (TokenId, PreviousStatus, NewStatus, ActionByUserId, ActionTime, ActionReason)
        VALUES (p_TokenId, 18004, 18004, p_UserId, CURRENT_TIMESTAMP, 
                CONCAT('Spawned sub-token ', v_newTokenNumber, ' (ID: ', v_newTokenId, ') for Process ', v_effectiveProcessId));

        -- Audit Log for Child Sub-Token
        INSERT INTO tokenauditlog (TokenId, PreviousStatus, NewStatus, ActionByUserId, ActionTime, ActionReason)
        VALUES (v_newTokenId, 0, 18001, p_UserId, CURRENT_TIMESTAMP, 
                CONCAT('Sub-token issued from parent ', v_origTokenNumber));

        SELECT 
            v_newTokenId AS ID, 
            0 AS ErrNo, 
            1 AS RowsCount, 
            CONCAT('Sub-token ', v_newTokenNumber, ' successfully dispatched.') AS ErrMsg,
            v_newTokenNumber AS TokenNumber,
            v_effectiveProcessId AS ProcessId,
            1 AS StepOrder,
            'Sub-Token Branch' AS StepName;
        LEAVE proc_body;
    END IF;

    -- CASE 2: SEQUENTIAL N-LEVEL FORWARDING (Step N -> Step N+1 OR Cross-Process Handoff)
    UPDATE tokentransaction
    SET TokenStatus = 18008,
        CompletedTime = CURRENT_TIMESTAMP,
        Notes = CONCAT(COALESCE(Notes, ''), ' | Forwarded: ', TRIM(COALESCE(p_Reason, 'Advanced to next pipeline step'))),
        ModifiedBy = p_UserId,
        ModifiedDate = CURRENT_TIMESTAMP
    WHERE Id = p_TokenId;

    IF p_TargetProcessId IS NOT NULL AND p_TargetProcessId > 0 AND p_TargetProcessId <> v_origProcessId THEN
        SET v_effectiveProcessId = p_TargetProcessId;
        SET v_nextStepOrder = 1;
    ELSE
        SET v_effectiveProcessId = v_origProcessId;
        SET v_nextStepOrder = v_currentStepOrder + 1;
    END IF;

    SELECT StepName INTO v_stepName
    FROM processstep
    WHERE ProcessId = v_effectiveProcessId AND StepOrder = v_nextStepOrder AND IsDeleted = 0
    LIMIT 1;

    IF v_stepName IS NULL THEN
        SET v_stepName = CONCAT('Pipeline Step ', v_nextStepOrder);
    END IF;

    INSERT INTO tokentransaction (
        TokenNumber, OrganizationId, LocationId, AreaId, ProcessId, CounterId,
        PriorityTier, StepOrder, SubTokenSequence, ParentTokenId, TokenStatus,
        CustomerName, CustomerPhone, Notes, IssuedTime,
        CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
    ) VALUES (
        v_origTokenNumber, v_orgId, v_locId, v_areaId, v_effectiveProcessId,
        IF(COALESCE(p_TargetCounterId, 0) > 0, p_TargetCounterId, NULL),
        v_origPriority, v_nextStepOrder, 0, v_rootTokenId, 18001,
        v_custName, v_custPhone, 
        CONCAT('Forwarded to ', v_stepName, ': ', TRIM(COALESCE(p_Reason, 'Standard pipeline handoff'))),
        CURRENT_TIMESTAMP, p_UserId, CURRENT_TIMESTAMP, p_UserId, CURRENT_TIMESTAMP, 0
    );
    SET v_newTokenId = LAST_INSERT_ID();

    INSERT INTO tokenauditlog (TokenId, PreviousStatus, NewStatus, ActionByUserId, ActionTime, ActionReason)
    VALUES (p_TokenId, 18004, 18008, p_UserId, CURRENT_TIMESTAMP, 
            CONCAT('Forwarded to ', v_stepName, ' (Next Token ID: ', v_newTokenId, ')'));

    INSERT INTO tokenauditlog (TokenId, PreviousStatus, NewStatus, ActionByUserId, ActionTime, ActionReason)
    VALUES (v_newTokenId, 0, 18001, p_UserId, CURRENT_TIMESTAMP, 
            CONCAT('Enqueued at Step ', v_nextStepOrder, ' (', v_stepName, ') from Token ', p_TokenId));

    SELECT 
        v_newTokenId AS ID, 
        0 AS ErrNo, 
        1 AS RowsCount, 
        CONCAT('Token ', v_origTokenNumber, ' successfully forwarded to ', v_stepName) AS ErrMsg,
        v_origTokenNumber AS TokenNumber,
        v_effectiveProcessId AS ProcessId,
        v_nextStepOrder AS StepOrder,
        v_stepName AS StepName;
END$$
DELIMITER ;

-- 5. Stored Procedure: PR_S_TokenWorkflowHistory
DROP PROCEDURE IF EXISTS PR_S_TokenWorkflowHistory;
DELIMITER $$
CREATE PROCEDURE PR_S_TokenWorkflowHistory(
    IN p_TokenId INT,
    IN p_TokenNumber VARCHAR(20)
)
BEGIN
    DECLARE v_rootId INT;
    DECLARE v_tokenNum VARCHAR(20);

    IF p_TokenId > 0 THEN
        SELECT COALESCE(ParentTokenId, Id), TokenNumber INTO v_rootId, v_tokenNum
        FROM tokentransaction WHERE Id = p_TokenId LIMIT 1;
    ELSE
        SELECT COALESCE(ParentTokenId, Id), TokenNumber INTO v_rootId, v_tokenNum
        FROM tokentransaction WHERE TokenNumber = p_TokenNumber AND IsDeleted = 0 
        ORDER BY Id DESC LIMIT 1;
    END IF;

    -- Grid 1: Root Journey Header
    SELECT 
        t.Id AS RootTokenId,
        t.TokenNumber,
        t.OrganizationId,
        t.LocationId,
        t.ProcessId,
        p.ProcessName,
        p.ProcessCode,
        t.CustomerName,
        t.CustomerPhone,
        t.PriorityTier,
        t.IssuedTime,
        (SELECT COUNT(*) FROM processstep WHERE ProcessId = t.ProcessId AND IsDeleted = 0) AS TotalConfiguredSteps,
        (SELECT MAX(StepOrder) FROM tokentransaction WHERE (ParentTokenId = v_rootId OR Id = v_rootId) AND SubTokenSequence = 0) AS CurrentStepOrder
    FROM tokentransaction t
    INNER JOIN process p ON p.Id = t.ProcessId
    WHERE t.Id = v_rootId;

    -- Grid 2: All Sequential Execution Steps for this token
    SELECT 
        t.Id AS TransactionId,
        t.TokenNumber,
        t.StepOrder,
        COALESCE(ps.StepName, CONCAT('Step ', t.StepOrder)) AS StepName,
        COALESCE(ps.TargetTATMinutes, 10) AS TargetTATMinutes,
        t.ProcessId,
        p.ProcessName,
        t.CounterId,
        c.CounterNumber,
        c.CounterName,
        t.TokenStatus,
        COALESCE(cp.ParameterName, 'Unknown') AS StatusName,
        t.IssuedTime,
        t.CalledTime,
        t.ServedTime,
        t.CompletedTime,
        TIMESTAMPDIFF(SECOND, COALESCE(t.ServedTime, t.CalledTime, t.IssuedTime), COALESCE(t.CompletedTime, CURRENT_TIMESTAMP)) AS DurationSeconds,
        t.Notes
    FROM tokentransaction t
    INNER JOIN process p ON p.Id = t.ProcessId
    LEFT JOIN processstep ps ON ps.ProcessId = t.ProcessId AND ps.StepOrder = t.StepOrder AND ps.IsDeleted = 0
    LEFT JOIN counter c ON c.Id = t.CounterId
    LEFT JOIN configparameters cp ON cp.ParameterID = t.TokenStatus AND cp.CategoryID = 18
    WHERE (t.ParentTokenId = v_rootId OR t.Id = v_rootId)
      AND t.SubTokenSequence = 0
      AND t.IsDeleted = 0
    ORDER BY t.StepOrder ASC, t.Id ASC;

    -- Grid 3: Branching Sub-Tokens
    SELECT 
        st.Id AS SubTokenId,
        st.TokenNumber,
        st.SubTokenSequence,
        st.ProcessId,
        p.ProcessName,
        st.CounterId,
        c.CounterNumber,
        st.TokenStatus,
        COALESCE(cp.ParameterName, 'Unknown') AS StatusName,
        st.IssuedTime,
        st.ServedTime,
        st.CompletedTime,
        st.Notes
    FROM tokentransaction st
    INNER JOIN process p ON p.Id = st.ProcessId
    LEFT JOIN counter c ON c.Id = st.CounterId
    LEFT JOIN configparameters cp ON cp.ParameterID = st.TokenStatus AND cp.CategoryID = 18
    WHERE st.ParentTokenId = v_rootId
      AND st.SubTokenSequence > 0
      AND st.IsDeleted = 0
    ORDER BY st.SubTokenSequence ASC, st.Id ASC;
END$$
DELIMITER ;
