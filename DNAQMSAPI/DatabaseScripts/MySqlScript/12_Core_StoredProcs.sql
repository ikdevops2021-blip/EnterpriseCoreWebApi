DELIMITER //

-- ============================================================================
-- Stored Procedures for ApiKey
-- ============================================================================

DROP PROCEDURE IF EXISTS PR_S_ApiKey //
CREATE PROCEDURE PR_S_ApiKey (
    IN p_Id        VARCHAR(36),
    IN p_KeyHash   VARCHAR(255),
    IN p_UserId    INT,
    IN p_IsActive  SMALLINT
)
BEGIN
    SELECT * 
    FROM ApiKey 
    WHERE IsDeleted = 0
      AND (COALESCE(p_Id, '') = '' OR Id = p_Id)
      AND (COALESCE(p_KeyHash, '') = '' OR KeyHash = p_KeyHash)
      AND (COALESCE(p_UserId, -1) = -1 OR UserId = p_UserId)
      AND (COALESCE(p_IsActive, -1) NOT IN (0, 1) OR IsActive = p_IsActive)
    ORDER BY CreatedDate DESC;
END //

DROP PROCEDURE IF EXISTS PR_IU_ApiKey //
CREATE PROCEDURE PR_IU_ApiKey (
    IN p_Id        VARCHAR(36),
    IN p_KeyHash   VARCHAR(255),
    IN p_Name      VARCHAR(100),
    IN p_UserId    INT,
    IN p_ExpiresAt DATETIME,
    IN p_IsActive  TINYINT(1),
    IN p_UID       INT
)
proc_body: BEGIN
    DECLARE v_err INT DEFAULT 0;
    DECLARE v_rowscount INT DEFAULT 0;
    DECLARE v_errMsg VARCHAR(300) DEFAULT '';
    DECLARE v_errLine INT DEFAULT 0;
    DECLARE v_duplicateId VARCHAR(36) DEFAULT '';

    -- ========================================================================
    --/S/---------------- [Validation Section] -------------------------------
    -- ========================================================================
    IF EXISTS(SELECT 1 FROM ApiKey WHERE KeyHash = TRIM(p_KeyHash) AND IsDeleted = 0 AND (COALESCE(p_Id, '') = '' OR Id <> p_Id)) THEN
        SELECT Id INTO v_duplicateId FROM ApiKey WHERE KeyHash = TRIM(p_KeyHash) AND IsDeleted = 0 AND (COALESCE(p_Id, '') = '' OR Id <> p_Id) LIMIT 1;
        SET v_err = 51;
        SET v_errMsg = CONCAT('Duplicate ApiKey Hash! Already exists with Id ', v_duplicateId);
        LEAVE proc_body;
    END IF;
    --/E/---------------- [Validation Section] -------------------------------

    IF COALESCE(p_Id, '') = '' THEN
        SET p_Id = UUID();
        INSERT INTO ApiKey (
            Id, KeyHash, Name, UserId, ExpiresAt, IsActive,
            CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
        ) VALUES (
            p_Id, TRIM(p_KeyHash), TRIM(p_Name), p_UserId, p_ExpiresAt, COALESCE(p_IsActive, 1),
            p_UID, CURRENT_TIMESTAMP, p_UID, CURRENT_TIMESTAMP, 0
        );
        SET v_rowscount = ROW_COUNT();
    ELSE
        UPDATE ApiKey
        SET KeyHash      = TRIM(p_KeyHash),
            Name         = TRIM(p_Name),
            UserId       = p_UserId,
            ExpiresAt    = p_ExpiresAt,
            IsActive     = COALESCE(p_IsActive, IsActive),
            ModifiedBy   = p_UID,
            ModifiedDate = CURRENT_TIMESTAMP
        WHERE Id = p_Id AND IsDeleted = 0;
        SET v_rowscount = ROW_COUNT();
    END IF;

    SELECT p_Id AS ID, COALESCE(v_err, 0) AS ErrNo, COALESCE(v_rowscount, 0) AS RowsCount, COALESCE(v_errMsg, '') AS ErrMsg, COALESCE(v_errLine, 0) AS ErrLine;
END //

-- ============================================================================
-- Stored Procedures for Organization
-- ============================================================================

DROP PROCEDURE IF EXISTS PR_S_Organization //
CREATE PROCEDURE PR_S_Organization (
    IN p_Id                   INT,
    IN p_RegistrationKey      VARCHAR(36),
    IN p_ParentOrganizationId INT,
    IN p_IsActive             SMALLINT
)
BEGIN
    SELECT * 
    FROM Organization 
    WHERE IsDeleted = 0
      AND (COALESCE(p_Id, -1) = -1 OR Id = p_Id)
      AND (COALESCE(p_RegistrationKey, '') = '' OR RegistrationKey = p_RegistrationKey)
      AND (COALESCE(p_ParentOrganizationId, -1) = -1 OR ParentOrganizationId = p_ParentOrganizationId)
      AND (COALESCE(p_IsActive, -1) NOT IN (0, 1) OR IsActive = p_IsActive)
    ORDER BY Name ASC;
END //

DROP PROCEDURE IF EXISTS PR_IU_Organization //
CREATE PROCEDURE PR_IU_Organization (
    IN p_Id                   INT,
    IN p_RegistrationKey      VARCHAR(36),
    IN p_Name                 VARCHAR(255),
    IN p_ParentOrganizationId INT,
    IN p_Priority             INT,
    IN p_IsActive             TINYINT(1),
    IN p_UID                  INT
)
proc_body: BEGIN
    DECLARE v_err INT DEFAULT 0;
    DECLARE v_rowscount INT DEFAULT 0;
    DECLARE v_errMsg VARCHAR(300) DEFAULT '';
    DECLARE v_errLine INT DEFAULT 0;
    DECLARE v_duplicateID INT DEFAULT 0;

    -- ========================================================================
    --/S/---------------- [Validation Section] -------------------------------
    -- ========================================================================
    IF EXISTS(SELECT 1 FROM Organization WHERE Name = TRIM(p_Name) AND IsDeleted = 0 AND (COALESCE(p_Id, 0) <= 0 OR Id <> p_Id)) THEN
        SELECT Id INTO v_duplicateID FROM Organization WHERE Name = TRIM(p_Name) AND IsDeleted = 0 AND (COALESCE(p_Id, 0) <= 0 OR Id <> p_Id) LIMIT 1;
        SET v_err = 51;
        SET v_errMsg = CONCAT('Duplicate Organization Name! Already exists with ID ', v_duplicateID);
        LEAVE proc_body;
    END IF;
    --/E/---------------- [Validation Section] -------------------------------

    IF COALESCE(p_Id, 0) <= 0 THEN
        IF COALESCE(p_RegistrationKey, '') = '' THEN
            SET p_RegistrationKey = UUID();
        END IF;

        INSERT INTO Organization (
            RegistrationKey, Name, ParentOrganizationId, Priority, IsActive,
            CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
        ) VALUES (
            p_RegistrationKey, TRIM(p_Name), p_ParentOrganizationId, COALESCE(p_Priority, 1), COALESCE(p_IsActive, 1),
            p_UID, CURRENT_TIMESTAMP, p_UID, CURRENT_TIMESTAMP, 0
        );
        SET p_Id = LAST_INSERT_ID();
        SET v_rowscount = ROW_COUNT();
    ELSE
        UPDATE Organization
        SET Name                 = TRIM(p_Name),
            ParentOrganizationId = p_ParentOrganizationId,
            Priority             = COALESCE(p_Priority, Priority),
            IsActive             = COALESCE(p_IsActive, IsActive),
            ModifiedBy           = p_UID,
            ModifiedDate         = CURRENT_TIMESTAMP
        WHERE Id = p_Id AND IsDeleted = 0;
        SET v_rowscount = ROW_COUNT();
    END IF;

    SELECT COALESCE(p_Id, 0) AS ID, COALESCE(v_err, 0) AS ErrNo, COALESCE(v_rowscount, 0) AS RowsCount, COALESCE(v_errMsg, '') AS ErrMsg, COALESCE(v_errLine, 0) AS ErrLine;
END //

-- ============================================================================
-- Stored Procedures for User
-- ============================================================================

DROP PROCEDURE IF EXISTS PR_S_User //
CREATE PROCEDURE PR_S_User (
    IN p_Id       INT,
    IN p_Email    VARCHAR(255),       -- Also matches UserCode (unified lookup)
    IN p_UserCode VARCHAR(50),        -- Exact UserCode lookup
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

    -- ========================================================================
    -- Auto-generate UserCode & DisplayName if not provided
    -- ========================================================================
    IF COALESCE(p_UserCode, '') = '' THEN
        SET p_UserCode = TRIM(p_Email);
    END IF;

    IF p_DisplayName IS NULL THEN
        SET p_DisplayName = TRIM(CONCAT(p_FirstName, ' ', p_LastName));
    END IF;

    -- ========================================================================
    --/S/---------------- [Validation Section] -------------------------------
    -- ========================================================================
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
    --/E/---------------- [Validation Section] -------------------------------

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

-- ============================================================================
-- Stored Procedures for Tax Calculation
-- ============================================================================

DROP PROCEDURE IF EXISTS PR_S_TaxCalculation //
CREATE PROCEDURE PR_S_TaxCalculation (
    IN p_CountryCode VARCHAR(10),
    IN p_StateCode   VARCHAR(10)
)
BEGIN
    SELECT tr.TaxRuleId AS RuleId, tr.TaxTypeId, tr.Priority, tr.ConditionText AS `Condition`, 
           t.CalculationType, t.ApplicationType, r.Rate
    FROM TaxRules tr
    JOIN TaxTypes t ON tr.TaxTypeId = t.TaxTypeId
    JOIN TaxRates r ON tr.TaxTypeId = r.TaxTypeId
    WHERE r.CountryCode = p_CountryCode 
      AND (r.StateCode = p_StateCode OR r.StateCode IS NULL)
      AND (r.EffectiveTo IS NULL OR r.EffectiveTo >= CURRENT_DATE())
      AND r.IsActive = 1 AND tr.IsActive = 1 AND t.IsActive = 1
    ORDER BY tr.Priority ASC;
END //

-- ============================================================================
-- Stored Procedures for Invoice
-- ============================================================================

DROP PROCEDURE IF EXISTS PR_S_InvoiceDetails //
CREATE PROCEDURE PR_S_InvoiceDetails (
    IN p_InvoiceId VARCHAR(36)
)
BEGIN
    SELECT 
        b.BillingHistoryId AS InvoiceId,
        b.SubscriptionId,
        b.BillingDate,
        b.NetAmount,
        b.TotalTax,
        b.GrossAmount,
        b.Status,
        m.CustomerVatNumber,
        m.TenantVatNumber,
        m.IsReverseCharge,
        m.CountrySpecificData
    FROM BillingHistory b
    LEFT JOIN InvoiceMetadata m ON b.BillingHistoryId = m.InvoiceId
    WHERE b.BillingHistoryId = p_InvoiceId
    LIMIT 1;
END //

-- ============================================================================
-- Stored Procedures for Financial Reporting
-- ============================================================================

DROP PROCEDURE IF EXISTS PR_S_MonthlyTaxSummary //
CREATE PROCEDURE PR_S_MonthlyTaxSummary (
    IN p_Year INT
)
BEGIN
    SELECT * FROM vw_monthlytaxsummary
    WHERE (COALESCE(p_Year, -1) = -1 OR TaxYear = p_Year);
END //

DROP PROCEDURE IF EXISTS PR_S_PaymentAnalytics //
CREATE PROCEDURE PR_S_PaymentAnalytics (
    IN p_Year INT
)
BEGIN
    SELECT * FROM vw_paymentanalytics
    WHERE (COALESCE(p_Year, -1) = -1 OR PaymentYear = p_Year);
END //

DROP PROCEDURE IF EXISTS PR_S_RevenueAnalytics //
CREATE PROCEDURE PR_S_RevenueAnalytics (
    IN p_Year INT
)
BEGIN
    SELECT * FROM vw_revenueanalytics
    WHERE (COALESCE(p_Year, -1) = -1 OR RevenueYear = p_Year);
END //

DROP PROCEDURE IF EXISTS PR_S_SaaSMetrics //
CREATE PROCEDURE PR_S_SaaSMetrics ()
BEGIN
    SELECT * FROM vw_saas_metrics;
END //

-- ============================================================================
-- Stored Procedures for TenantSubscriptions
-- ============================================================================

DROP PROCEDURE IF EXISTS PR_S_TenantSubscription //
CREATE PROCEDURE PR_S_TenantSubscription (
    IN p_TenantId VARCHAR(36),
    IN p_Status   INT
)
BEGIN
    SELECT SubscriptionId, TenantId, PlanId, Status, StartDate, ExpiryDate, 
           TrialEndDate, AutoRenew, GracePeriodEnd, CreatedDate, ModifiedDate
    FROM TenantSubscriptions
    WHERE TenantId = p_TenantId 
      AND (COALESCE(p_Status, -1) = -1 OR Status = p_Status)
    ORDER BY CreatedDate DESC
    LIMIT 1;
END //

DROP PROCEDURE IF EXISTS PR_IU_TenantSubscription //
CREATE PROCEDURE PR_IU_TenantSubscription (
    IN p_SubscriptionId VARCHAR(36),
    IN p_TenantId       VARCHAR(36),
    IN p_PlanId         INT,
    IN p_Status         SMALLINT,
    IN p_StartDate      DATETIME,
    IN p_ExpiryDate     DATETIME,
    IN p_AutoRenew      TINYINT(1)
)
proc_body: BEGIN
    DECLARE v_err INT DEFAULT 0;
    DECLARE v_rowscount INT DEFAULT 0;
    DECLARE v_errMsg VARCHAR(300) DEFAULT '';
    DECLARE v_errLine INT DEFAULT 0;

    IF COALESCE(p_SubscriptionId, '') = '' THEN
        SET p_SubscriptionId = UUID();
        INSERT INTO TenantSubscriptions (
            SubscriptionId, TenantId, PlanId, Status, StartDate, ExpiryDate, AutoRenew, CreatedDate, ModifiedDate
        ) VALUES (
            p_SubscriptionId, p_TenantId, p_PlanId, p_Status, p_StartDate, p_ExpiryDate, COALESCE(p_AutoRenew, 1), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        );
        SET v_rowscount = ROW_COUNT();
    ELSE
        UPDATE TenantSubscriptions
        SET Status       = COALESCE(p_Status, Status),
            ModifiedDate = CURRENT_TIMESTAMP
        WHERE SubscriptionId = p_SubscriptionId;
        SET v_rowscount = ROW_COUNT();
    END IF;

    SELECT p_SubscriptionId AS ID, COALESCE(v_err, 0) AS ErrNo, COALESCE(v_rowscount, 0) AS RowsCount, COALESCE(v_errMsg, '') AS ErrMsg, COALESCE(v_errLine, 0) AS ErrLine;
END //

-- ============================================================================
-- Stored Procedures for UsageTracking
-- ============================================================================

DROP PROCEDURE IF EXISTS PR_S_PlanFeatureLimit //
CREATE PROCEDURE PR_S_PlanFeatureLimit (
    IN p_PlanId     INT,
    IN p_FeatureKey VARCHAR(150)
)
BEGIN
    SELECT FeatureValue FROM PlanFeatures
    WHERE PlanId = p_PlanId AND FeatureKey = p_FeatureKey
    LIMIT 1;
END //

DROP PROCEDURE IF EXISTS PR_S_CurrentUsage //
CREATE PROCEDURE PR_S_CurrentUsage (
    IN p_TenantId   VARCHAR(36),
    IN p_FeatureKey  VARCHAR(150)
)
BEGIN
    SELECT UsageCount FROM UsageTracking 
    WHERE TenantId = p_TenantId AND FeatureKey = p_FeatureKey 
      AND PeriodStart <= CURRENT_TIMESTAMP AND PeriodEnd >= CURRENT_TIMESTAMP
    LIMIT 1;
END //

DROP PROCEDURE IF EXISTS PR_IU_UsageTracking //
CREATE PROCEDURE PR_IU_UsageTracking (
    IN p_TenantId   VARCHAR(36),
    IN p_FeatureKey  VARCHAR(150),
    IN p_Quantity    BIGINT,
    IN p_PeriodStart DATETIME,
    IN p_PeriodEnd   DATETIME
)
BEGIN
    DECLARE v_usageId VARCHAR(36);

    SELECT UsageId INTO v_usageId FROM UsageTracking 
    WHERE TenantId = p_TenantId AND FeatureKey = p_FeatureKey 
      AND PeriodStart = p_PeriodStart AND PeriodEnd = p_PeriodEnd
    LIMIT 1;

    IF v_usageId IS NOT NULL THEN
        UPDATE UsageTracking SET UsageCount = UsageCount + p_Quantity WHERE UsageId = v_usageId;
    ELSE
        INSERT INTO UsageTracking (UsageId, TenantId, FeatureKey, UsageCount, PeriodStart, PeriodEnd)
        VALUES (UUID(), p_TenantId, p_FeatureKey, p_Quantity, p_PeriodStart, p_PeriodEnd);
    END IF;

    SELECT 1 AS ID, 0 AS ErrNo, ROW_COUNT() AS RowsCount, '' AS ErrMsg, 0 AS ErrLine;
END //

-- ============================================================================
-- Stored Procedures for Billing / Invoice Generation
-- ============================================================================

DROP PROCEDURE IF EXISTS PR_IU_BillingInvoice //
CREATE PROCEDURE PR_IU_BillingInvoice (
    IN p_BillingHistoryId VARCHAR(36),
    IN p_SubscriptionId   VARCHAR(36),
    IN p_NetAmount        DECIMAL(18,2),
    IN p_TotalTax         DECIMAL(18,2),
    IN p_GrossAmount      DECIMAL(18,2),
    IN p_InvoiceUrl       VARCHAR(500),
    IN p_Status           INT,
    IN p_CustomerVat      VARCHAR(100),
    IN p_TenantVat        VARCHAR(100),
    IN p_IsReverseCharge  TINYINT(1),
    IN p_CountryData      TEXT,
    IN p_UID              INT
)
BEGIN
    INSERT INTO BillingHistory (
        BillingHistoryId, SubscriptionId, BillingDate, 
        NetAmount, TotalTax, GrossAmount, 
        InvoiceUrl, Status, CreatedBy
    ) VALUES (
        p_BillingHistoryId, p_SubscriptionId, CURRENT_TIMESTAMP,
        p_NetAmount, p_TotalTax, p_GrossAmount,
        p_InvoiceUrl, p_Status, p_UID
    );

    INSERT INTO InvoiceMetadata (
        InvoiceId, CustomerVatNumber, TenantVatNumber, IsReverseCharge, CountrySpecificData, CreatedBy
    ) VALUES (
        p_BillingHistoryId, p_CustomerVat, p_TenantVat, p_IsReverseCharge, p_CountryData, p_UID
    );

    SELECT p_BillingHistoryId AS ID, 0 AS ErrNo, ROW_COUNT() AS RowsCount, '' AS ErrMsg, 0 AS ErrLine;
END //

-- ============================================================================
-- Stored Procedures for EmailQueue
-- ============================================================================

DROP PROCEDURE IF EXISTS PR_IU_EmailQueue //
CREATE PROCEDURE PR_IU_EmailQueue (
    IN p_QueueId      VARCHAR(36),
    IN p_CenterId     INT,
    IN p_RecipientTo  TEXT,
    IN p_RecipientCc  TEXT,
    IN p_RecipientBcc TEXT,
    IN p_Subject      VARCHAR(500),
    IN p_Body         TEXT,
    IN p_IsHtml       TINYINT(1),
    IN p_Priority     INT,
    IN p_UID          INT
)
BEGIN
    INSERT INTO EmailQueue (
        QueueId, CenterId, RecipientTo, RecipientCc, RecipientBcc, Subject, Body, IsHtml, 
        Status, Priority, RetryCount, MaxRetryCount, CreatedBy, CreateDate, ModifiedBy, ModifyDate, IsDeleted
    ) VALUES (
        p_QueueId, p_CenterId, p_RecipientTo, p_RecipientCc, p_RecipientBcc, p_Subject, p_Body, p_IsHtml,
        0, p_Priority, 0, 3, p_UID, CURRENT_TIMESTAMP, p_UID, CURRENT_TIMESTAMP, 0
    );

    SELECT p_QueueId AS ID, 0 AS ErrNo, ROW_COUNT() AS RowsCount, '' AS ErrMsg, 0 AS ErrLine;
END //

DELIMITER ;

