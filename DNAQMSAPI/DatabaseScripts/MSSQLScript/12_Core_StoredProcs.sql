IF OBJECT_ID('dbo.PR_S_ApiKey', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_S_ApiKey;
GO
CREATE PROCEDURE dbo.PR_S_ApiKey
    @p_Id        NVARCHAR(36) = '',
    @p_KeyHash   NVARCHAR(255) = '',
    @p_UserId    INT = -1,
    @p_IsActive  SMALLINT = -1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT * 
    FROM ApiKey WITH(NOLOCK)
    WHERE IsDeleted = 0
      AND (ISNULL(@p_Id, '') = '' OR Id = @p_Id)
      AND (ISNULL(@p_KeyHash, '') = '' OR KeyHash = @p_KeyHash)
      AND (ISNULL(@p_UserId, -1) = -1 OR UserId = @p_UserId)
      AND (ISNULL(@p_IsActive, -1) NOT IN (0, 1) OR IsActive = @p_IsActive)
    ORDER BY CreatedDate DESC;
END
GO

IF OBJECT_ID('dbo.PR_IU_ApiKey', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_IU_ApiKey;
GO
CREATE PROCEDURE dbo.PR_IU_ApiKey
    @p_Id        NVARCHAR(36) = '' OUTPUT,
    @p_KeyHash   NVARCHAR(255),
    @p_Name      NVARCHAR(100),
    @p_UserId    INT,
    @p_ExpiresAt DATETIME = NULL,
    @p_IsActive  BIT = 1,
    @p_UID       INT = -1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err INT = 0, @rowscount INT = 0, @errMsg VARCHAR(300) = '', @errLine INT = 0;
    DECLARE @duplicateId NVARCHAR(36) = '';

    BEGIN TRY
        -- ====================================================================
        --/S/---------------- [Validation Section] ---------------------------
        -- ====================================================================
        IF EXISTS(SELECT 1 FROM ApiKey WITH(NOLOCK) WHERE KeyHash = LTRIM(RTRIM(@p_KeyHash)) AND IsDeleted = 0 AND (ISNULL(@p_Id, '') = '' OR Id <> @p_Id))
        BEGIN
            SELECT TOP 1 @duplicateId = Id FROM ApiKey WITH(NOLOCK) WHERE KeyHash = LTRIM(RTRIM(@p_KeyHash)) AND IsDeleted = 0 AND (ISNULL(@p_Id, '') = '' OR Id <> @p_Id);
            SELECT @err = 51, @errMsg = 'Duplicate ApiKey Hash! Already exists with Id ' + @duplicateId;
            GOTO ExResult;
        END
        --/E/---------------- [Validation Section] ---------------------------

        BEGIN TRANSACTION;

        IF ISNULL(@p_Id, '') = ''
        BEGIN
            SET @p_Id = NEWID();
            INSERT INTO ApiKey (
                Id, KeyHash, Name, UserId, ExpiresAt, IsActive,
                CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
            ) VALUES (
                @p_Id, LTRIM(RTRIM(@p_KeyHash)), LTRIM(RTRIM(@p_Name)), @p_UserId, @p_ExpiresAt, ISNULL(@p_IsActive, 1),
                @p_UID, GETDATE(), @p_UID, GETDATE(), 0
            );

            SELECT @rowscount = @@ROWCOUNT;
        END
        ELSE
        BEGIN
            UPDATE ApiKey
            SET KeyHash      = LTRIM(RTRIM(@p_KeyHash)),
                Name         = LTRIM(RTRIM(@p_Name)),
                UserId       = @p_UserId,
                ExpiresAt    = @p_ExpiresAt,
                IsActive     = ISNULL(@p_IsActive, IsActive),
                ModifiedBy   = @p_UID,
                ModifiedDate = GETDATE()
            WHERE Id = @p_Id AND IsDeleted = 0;

            SELECT @rowscount = @@ROWCOUNT;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT @p_Id = '', @err = ISNULL(ERROR_NUMBER(), 50000), @errMsg = ISNULL(ERROR_MESSAGE(), ''), @errLine = ISNULL(ERROR_LINE(), 0);
    END CATCH

ExResult:
    SELECT ISNULL(@p_Id, '') AS ID, ISNULL(@err, 0) AS ErrNo, ISNULL(@rowscount, 0) AS RowsCount, ISNULL(@errMsg, '') AS ErrMsg, ISNULL(@errLine, 0) AS ErrLine;
END
GO

IF OBJECT_ID('dbo.PR_S_Organization', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_S_Organization;
GO
CREATE PROCEDURE dbo.PR_S_Organization
    @p_Id                   INT = -1,
    @p_RegistrationKey      NVARCHAR(36) = '',
    @p_ParentOrganizationId INT = -1,
    @p_IsActive             SMALLINT = -1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT * 
    FROM Organization WITH(NOLOCK)
    WHERE IsDeleted = 0
      AND (ISNULL(@p_Id, -1) = -1 OR Id = @p_Id)
      AND (ISNULL(@p_RegistrationKey, '') = '' OR RegistrationKey = @p_RegistrationKey)
      AND (ISNULL(@p_ParentOrganizationId, -1) = -1 OR ParentOrganizationId = @p_ParentOrganizationId)
      AND (ISNULL(@p_IsActive, -1) NOT IN (0, 1) OR IsActive = @p_IsActive)
    ORDER BY Name ASC;
END
GO

IF OBJECT_ID('dbo.PR_IU_Organization', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_IU_Organization;
GO
CREATE PROCEDURE dbo.PR_IU_Organization
    @p_Id                   INT = 0 OUTPUT,
    @p_RegistrationKey      NVARCHAR(36) = '',
    @p_Name                 NVARCHAR(255),
    @p_ParentOrganizationId INT = NULL,
    @p_Priority             INT = 1,
    @p_IsActive             BIT = 1,
    @p_UID                  INT = -1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err INT = 0, @rowscount INT = 0, @errMsg VARCHAR(300) = '', @errLine INT = 0;
    DECLARE @duplicateID INT = 0;

    BEGIN TRY
        -- ====================================================================
        --/S/---------------- [Validation Section] ---------------------------
        -- ====================================================================
        IF EXISTS(SELECT 1 FROM Organization WITH(NOLOCK) WHERE Name = LTRIM(RTRIM(@p_Name)) AND IsDeleted = 0 AND (ISNULL(@p_Id, 0) <= 0 OR Id <> @p_Id))
        BEGIN
            SELECT TOP 1 @duplicateID = Id FROM Organization WITH(NOLOCK) WHERE Name = LTRIM(RTRIM(@p_Name)) AND IsDeleted = 0 AND (ISNULL(@p_Id, 0) <= 0 OR Id <> @p_Id);
            SELECT @err = 51, @errMsg = 'Duplicate Organization Name! Already exists with ID ' + CAST(@duplicateID AS VARCHAR(10));
            GOTO ExResult;
        END
        --/E/---------------- [Validation Section] ---------------------------

        BEGIN TRANSACTION;

        IF ISNULL(@p_Id, 0) <= 0
        BEGIN
            IF ISNULL(@p_RegistrationKey, '') = ''
            BEGIN
                SET @p_RegistrationKey = NEWID();
            END

            INSERT INTO Organization (
                RegistrationKey, Name, ParentOrganizationId, Priority, IsActive,
                CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
            ) VALUES (
                @p_RegistrationKey, LTRIM(RTRIM(@p_Name)), @p_ParentOrganizationId, ISNULL(@p_Priority, 1), ISNULL(@p_IsActive, 1),
                @p_UID, GETDATE(), @p_UID, GETDATE(), 0
            );

            SET @p_Id = SCOPE_IDENTITY();
            SELECT @rowscount = @@ROWCOUNT;
        END
        ELSE
        BEGIN
            UPDATE Organization
            SET Name                 = LTRIM(RTRIM(@p_Name)),
                ParentOrganizationId = @p_ParentOrganizationId,
                Priority             = ISNULL(@p_Priority, Priority),
                IsActive             = ISNULL(@p_IsActive, IsActive),
                ModifiedBy           = @p_UID,
                ModifiedDate         = GETDATE()
            WHERE Id = @p_Id AND IsDeleted = 0;

            SELECT @rowscount = @@ROWCOUNT;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT @p_Id = 0, @err = ISNULL(ERROR_NUMBER(), 50000), @errMsg = ISNULL(ERROR_MESSAGE(), ''), @errLine = ISNULL(ERROR_LINE(), 0);
    END CATCH

ExResult:
    SELECT ISNULL(@p_Id, 0) AS ID, ISNULL(@err, 0) AS ErrNo, ISNULL(@rowscount, 0) AS RowsCount, ISNULL(@errMsg, '') AS ErrMsg, ISNULL(@errLine, 0) AS ErrLine;
END
GO

IF OBJECT_ID('dbo.PR_S_User', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_S_User;
GO
CREATE PROCEDURE dbo.PR_S_User
    @p_Id       INT = -1,
    @p_Email    NVARCHAR(255) = '',    -- Also matches UserCode (unified lookup)
    @p_UserCode NVARCHAR(50) = '',     -- Exact UserCode lookup
    @p_IsActive SMALLINT = -1
AS
BEGIN
    SET NOCOUNT ON;

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
    FROM [User] u WITH(NOLOCK)
    LEFT JOIN ConfigParameters t WITH(NOLOCK) ON u.TitleId = t.ParameterID AND t.IsDeleted = 0
    LEFT JOIN ConfigParameters g WITH(NOLOCK) ON u.GenderId = g.ParameterID AND g.IsDeleted = 0
    WHERE u.IsDeleted = 0
      AND (ISNULL(@p_Id, -1) = -1 OR u.Id = @p_Id)
      AND (ISNULL(@p_Email, '') = '' OR u.Email = @p_Email OR u.UserCode = @p_Email)
      AND (ISNULL(@p_UserCode, '') = '' OR u.UserCode = @p_UserCode)
      AND (ISNULL(@p_IsActive, -1) NOT IN (0, 1) OR u.IsActive = @p_IsActive)
    ORDER BY u.Id ASC;
END
GO

IF OBJECT_ID('dbo.PR_IU_User', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_IU_User;
GO
CREATE PROCEDURE dbo.PR_IU_User
    @p_Id              INT = 0 OUTPUT,
    @p_UserCode        NVARCHAR(50) = NULL,
    @p_TitleId         INT = NULL,
    @p_FirstName       NVARCHAR(250),
    @p_LastName        NVARCHAR(250),
    @p_DisplayName     NVARCHAR(250) = NULL,
    @p_GenderId        INT = NULL,
    @p_ProfileImageUrl NVARCHAR(500) = NULL,
    @p_Email           NVARCHAR(255),
    @p_PasswordHash    NVARCHAR(MAX) = NULL,
    @p_IsActive        BIT = 1,
    @p_UID             INT = -1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err INT = 0, @rowscount INT = 0, @errMsg VARCHAR(300) = '', @errLine INT = 0;
    DECLARE @duplicateID INT = 0;

    BEGIN TRY
        -- ====================================================================
        -- Auto-generate UserCode & DisplayName if not provided
        -- ====================================================================
        IF ISNULL(@p_UserCode, '') = ''
            SET @p_UserCode = LTRIM(RTRIM(@p_Email));

        IF @p_DisplayName IS NULL
            SET @p_DisplayName = LTRIM(RTRIM(@p_FirstName + ' ' + @p_LastName));

        -- ====================================================================
        --/S/---------------- [Validation Section] ---------------------------
        -- ====================================================================
        IF EXISTS(SELECT 1 FROM [User] WITH(NOLOCK) WHERE Email = LTRIM(RTRIM(@p_Email)) AND IsDeleted = 0 AND (ISNULL(@p_Id, 0) <= 0 OR Id <> @p_Id))
        BEGIN
            SELECT TOP 1 @duplicateID = Id FROM [User] WITH(NOLOCK) WHERE Email = LTRIM(RTRIM(@p_Email)) AND IsDeleted = 0 AND (ISNULL(@p_Id, 0) <= 0 OR Id <> @p_Id);
            SELECT @err = 51, @errMsg = 'Duplicate Email! Already exists with User ID ' + CAST(@duplicateID AS VARCHAR(10));
            GOTO ExResult;
        END

        IF EXISTS(SELECT 1 FROM [User] WITH(NOLOCK) WHERE UserCode = LTRIM(RTRIM(@p_UserCode)) AND IsDeleted = 0 AND (ISNULL(@p_Id, 0) <= 0 OR Id <> @p_Id))
        BEGIN
            SELECT TOP 1 @duplicateID = Id FROM [User] WITH(NOLOCK) WHERE UserCode = LTRIM(RTRIM(@p_UserCode)) AND IsDeleted = 0 AND (ISNULL(@p_Id, 0) <= 0 OR Id <> @p_Id);
            SELECT @err = 54, @errMsg = 'Duplicate UserCode! Already exists with User ID ' + CAST(@duplicateID AS VARCHAR(10));
            GOTO ExResult;
        END

        IF @p_TitleId IS NOT NULL AND NOT EXISTS(SELECT 1 FROM ConfigParameters WITH(NOLOCK) WHERE ParameterID = @p_TitleId AND CategoryID = 2 AND IsDeleted = 0)
        BEGIN
            SELECT @err = 52, @errMsg = 'Invalid TitleId ' + CAST(@p_TitleId AS VARCHAR(10)) + '! Must be a valid C_TITLE parameter.';
            GOTO ExResult;
        END

        IF @p_GenderId IS NOT NULL AND NOT EXISTS(SELECT 1 FROM ConfigParameters WITH(NOLOCK) WHERE ParameterID = @p_GenderId AND CategoryID = 1 AND IsDeleted = 0)
        BEGIN
            SELECT @err = 53, @errMsg = 'Invalid GenderId ' + CAST(@p_GenderId AS VARCHAR(10)) + '! Must be a valid C_GENDER parameter.';
            GOTO ExResult;
        END
        --/E/---------------- [Validation Section] ---------------------------

        BEGIN TRANSACTION;

        IF ISNULL(@p_Id, 0) <= 0
        BEGIN
            INSERT INTO [User] (
                UserCode, TitleId, FirstName, LastName, DisplayName, GenderId, ProfileImageUrl, Email, PasswordHash, IsActive,
                CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted
            ) VALUES (
                LTRIM(RTRIM(@p_UserCode)), @p_TitleId, LTRIM(RTRIM(@p_FirstName)), LTRIM(RTRIM(@p_LastName)), LTRIM(RTRIM(@p_DisplayName)), @p_GenderId, LTRIM(RTRIM(@p_ProfileImageUrl)), LTRIM(RTRIM(@p_Email)), @p_PasswordHash, ISNULL(@p_IsActive, 1),
                @p_UID, GETDATE(), @p_UID, GETDATE(), 0
            );

            SET @p_Id = SCOPE_IDENTITY();
            SELECT @rowscount = @@ROWCOUNT;
        END
        ELSE
        BEGIN
            UPDATE [User]
            SET UserCode        = LTRIM(RTRIM(@p_UserCode)),
                TitleId         = @p_TitleId,
                FirstName       = LTRIM(RTRIM(@p_FirstName)),
                LastName        = LTRIM(RTRIM(@p_LastName)),
                DisplayName     = LTRIM(RTRIM(@p_DisplayName)),
                GenderId        = @p_GenderId,
                ProfileImageUrl = LTRIM(RTRIM(@p_ProfileImageUrl)),
                Email           = LTRIM(RTRIM(@p_Email)),
                PasswordHash    = ISNULL(@p_PasswordHash, PasswordHash),
                IsActive        = ISNULL(@p_IsActive, IsActive),
                ModifiedBy      = @p_UID,
                ModifiedDate    = GETDATE()
            WHERE Id = @p_Id AND IsDeleted = 0;

            SELECT @rowscount = @@ROWCOUNT;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT @p_Id = 0, @err = ISNULL(ERROR_NUMBER(), 50000), @errMsg = ISNULL(ERROR_MESSAGE(), ''), @errLine = ISNULL(ERROR_LINE(), 0);
    END CATCH

ExResult:
    SELECT ISNULL(@p_Id, 0) AS ID, ISNULL(@err, 0) AS ErrNo, ISNULL(@rowscount, 0) AS RowsCount, ISNULL(@errMsg, '') AS ErrMsg, ISNULL(@errLine, 0) AS ErrLine;
END
GO

IF OBJECT_ID('dbo.PR_S_TaxCalculation', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_S_TaxCalculation;
GO
CREATE PROCEDURE dbo.PR_S_TaxCalculation
    @p_CountryCode NVARCHAR(10),
    @p_StateCode   NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT tr.TaxRuleId AS RuleId, tr.TaxTypeId, tr.Priority, tr.ConditionText AS [Condition], 
           t.CalculationType, t.ApplicationType, r.Rate
    FROM TaxRules tr WITH(NOLOCK)
    JOIN TaxTypes t WITH(NOLOCK) ON tr.TaxTypeId = t.TaxTypeId
    JOIN TaxRates r WITH(NOLOCK) ON tr.TaxTypeId = r.TaxTypeId
    WHERE r.CountryCode = @p_CountryCode 
      AND (r.StateCode = @p_StateCode OR r.StateCode IS NULL)
      AND (r.EffectiveTo IS NULL OR r.EffectiveTo >= GETDATE())
      AND r.IsActive = 1 AND tr.IsActive = 1 AND t.IsActive = 1
    ORDER BY tr.Priority ASC;
END
GO

IF OBJECT_ID('dbo.PR_S_InvoiceDetails', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_S_InvoiceDetails;
GO
CREATE PROCEDURE dbo.PR_S_InvoiceDetails
    @p_InvoiceId NVARCHAR(36)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
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
    FROM BillingHistory b WITH(NOLOCK)
    LEFT JOIN InvoiceMetadata m WITH(NOLOCK) ON b.BillingHistoryId = m.InvoiceId
    WHERE b.BillingHistoryId = @p_InvoiceId;
END
GO

IF OBJECT_ID('dbo.PR_S_MonthlyTaxSummary', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_S_MonthlyTaxSummary;
GO
CREATE PROCEDURE dbo.PR_S_MonthlyTaxSummary
    @p_Year INT = -1
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM vw_monthlytaxsummary
    WHERE (ISNULL(@p_Year, -1) = -1 OR TaxYear = @p_Year);
END
GO

IF OBJECT_ID('dbo.PR_S_PaymentAnalytics', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_S_PaymentAnalytics;
GO
CREATE PROCEDURE dbo.PR_S_PaymentAnalytics
    @p_Year INT = -1
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM vw_paymentanalytics
    WHERE (ISNULL(@p_Year, -1) = -1 OR PaymentYear = @p_Year);
END
GO

IF OBJECT_ID('dbo.PR_S_RevenueAnalytics', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_S_RevenueAnalytics;
GO
CREATE PROCEDURE dbo.PR_S_RevenueAnalytics
    @p_Year INT = -1
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM vw_revenueanalytics
    WHERE (ISNULL(@p_Year, -1) = -1 OR RevenueYear = @p_Year);
END
GO

IF OBJECT_ID('dbo.PR_S_SaaSMetrics', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_S_SaaSMetrics;
GO
CREATE PROCEDURE dbo.PR_S_SaaSMetrics
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM vw_saas_metrics;
END
GO

IF OBJECT_ID('dbo.PR_S_TenantSubscription', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_S_TenantSubscription;
GO
CREATE PROCEDURE dbo.PR_S_TenantSubscription
    @p_TenantId NVARCHAR(36),
    @p_Status   INT = -1
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1 SubscriptionId, TenantId, PlanId, Status, StartDate, ExpiryDate,
           TrialEndDate, AutoRenew, GracePeriodEnd, CreatedDate, ModifiedDate
    FROM TenantSubscriptions WITH(NOLOCK)
    WHERE TenantId = @p_TenantId
      AND (ISNULL(@p_Status, -1) = -1 OR Status = @p_Status)
    ORDER BY CreatedDate DESC;
END
GO

IF OBJECT_ID('dbo.PR_IU_TenantSubscription', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_IU_TenantSubscription;
GO
CREATE PROCEDURE dbo.PR_IU_TenantSubscription
    @p_SubscriptionId NVARCHAR(36) = '' OUTPUT,
    @p_TenantId       NVARCHAR(36),
    @p_PlanId         INT,
    @p_Status         SMALLINT,
    @p_StartDate      DATETIME,
    @p_ExpiryDate     DATETIME,
    @p_AutoRenew      BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @err INT = 0, @rowscount INT = 0, @errMsg VARCHAR(300) = '', @errLine INT = 0;

    IF ISNULL(@p_SubscriptionId, '') = ''
    BEGIN
        SET @p_SubscriptionId = NEWID();
        INSERT INTO TenantSubscriptions (
            SubscriptionId, TenantId, PlanId, Status, StartDate, ExpiryDate, AutoRenew, CreatedDate, ModifiedDate
        ) VALUES (
            @p_SubscriptionId, @p_TenantId, @p_PlanId, @p_Status, @p_StartDate, @p_ExpiryDate, ISNULL(@p_AutoRenew, 1), GETDATE(), GETDATE()
        );
        SELECT @rowscount = @@ROWCOUNT;
    END
    ELSE
    BEGIN
        UPDATE TenantSubscriptions
        SET Status       = ISNULL(@p_Status, Status),
            ModifiedDate = GETDATE()
        WHERE SubscriptionId = @p_SubscriptionId;
        SELECT @rowscount = @@ROWCOUNT;
    END

    SELECT ISNULL(@p_SubscriptionId, '') AS ID, ISNULL(@err, 0) AS ErrNo, ISNULL(@rowscount, 0) AS RowsCount, ISNULL(@errMsg, '') AS ErrMsg, ISNULL(@errLine, 0) AS ErrLine;
END
GO

IF OBJECT_ID('dbo.PR_S_PlanFeatureLimit', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_S_PlanFeatureLimit;
GO
CREATE PROCEDURE dbo.PR_S_PlanFeatureLimit
    @p_PlanId     INT,
    @p_FeatureKey NVARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1 FeatureValue FROM PlanFeatures WITH(NOLOCK)
    WHERE PlanId = @p_PlanId AND FeatureKey = @p_FeatureKey;
END
GO

IF OBJECT_ID('dbo.PR_S_CurrentUsage', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_S_CurrentUsage;
GO
CREATE PROCEDURE dbo.PR_S_CurrentUsage
    @p_TenantId   NVARCHAR(36),
    @p_FeatureKey  NVARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1 UsageCount FROM UsageTracking WITH(NOLOCK)
    WHERE TenantId = @p_TenantId AND FeatureKey = @p_FeatureKey 
      AND PeriodStart <= GETDATE() AND PeriodEnd >= GETDATE();
END
GO

IF OBJECT_ID('dbo.PR_IU_UsageTracking', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_IU_UsageTracking;
GO
CREATE PROCEDURE dbo.PR_IU_UsageTracking
    @p_TenantId   NVARCHAR(36),
    @p_FeatureKey  NVARCHAR(150),
    @p_Quantity    BIGINT,
    @p_PeriodStart DATETIME,
    @p_PeriodEnd   DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @usageId NVARCHAR(36);

    SELECT TOP 1 @usageId = UsageId FROM UsageTracking WITH(NOLOCK)
    WHERE TenantId = @p_TenantId AND FeatureKey = @p_FeatureKey 
      AND PeriodStart = @p_PeriodStart AND PeriodEnd = @p_PeriodEnd;

    IF @usageId IS NOT NULL
    BEGIN
        UPDATE UsageTracking SET UsageCount = UsageCount + @p_Quantity WHERE UsageId = @usageId;
    END
    ELSE
    BEGIN
        INSERT INTO UsageTracking (UsageId, TenantId, FeatureKey, UsageCount, PeriodStart, PeriodEnd)
        VALUES (NEWID(), @p_TenantId, @p_FeatureKey, @p_Quantity, @p_PeriodStart, @p_PeriodEnd);
    END

    SELECT 1 AS ID, 0 AS ErrNo, @@ROWCOUNT AS RowsCount, '' AS ErrMsg, 0 AS ErrLine;
END
GO

IF OBJECT_ID('dbo.PR_IU_BillingInvoice', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_IU_BillingInvoice;
GO
CREATE PROCEDURE dbo.PR_IU_BillingInvoice
    @p_BillingHistoryId NVARCHAR(36),
    @p_SubscriptionId   NVARCHAR(36),
    @p_NetAmount        DECIMAL(18,2),
    @p_TotalTax         DECIMAL(18,2),
    @p_GrossAmount      DECIMAL(18,2),
    @p_InvoiceUrl       NVARCHAR(500),
    @p_Status           INT,
    @p_CustomerVat      NVARCHAR(100),
    @p_TenantVat        NVARCHAR(100),
    @p_IsReverseCharge  BIT,
    @p_CountryData      NVARCHAR(MAX),
    @p_UID              INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    INSERT INTO BillingHistory (
        BillingHistoryId, SubscriptionId, BillingDate, 
        NetAmount, TotalTax, GrossAmount, 
        InvoiceUrl, Status, CreatedBy
    ) VALUES (
        @p_BillingHistoryId, @p_SubscriptionId, GETDATE(),
        @p_NetAmount, @p_TotalTax, @p_GrossAmount,
        @p_InvoiceUrl, @p_Status, @p_UID
    );

    INSERT INTO InvoiceMetadata (
        InvoiceId, CustomerVatNumber, TenantVatNumber, IsReverseCharge, CountrySpecificData, CreatedBy
    ) VALUES (
        @p_BillingHistoryId, @p_CustomerVat, @p_TenantVat, @p_IsReverseCharge, @p_CountryData, @p_UID
    );

    COMMIT TRANSACTION;

    SELECT @p_BillingHistoryId AS ID, 0 AS ErrNo, @@ROWCOUNT AS RowsCount, '' AS ErrMsg, 0 AS ErrLine;
END
GO

IF OBJECT_ID('dbo.PR_IU_EmailQueue', 'P') IS NOT NULL DROP PROCEDURE dbo.PR_IU_EmailQueue;
GO
CREATE PROCEDURE dbo.PR_IU_EmailQueue
    @p_QueueId      NVARCHAR(36),
    @p_CenterId     INT,
    @p_RecipientTo  NVARCHAR(MAX),
    @p_RecipientCc  NVARCHAR(MAX) = NULL,
    @p_RecipientBcc NVARCHAR(MAX) = NULL,
    @p_Subject      NVARCHAR(500),
    @p_Body         NVARCHAR(MAX),
    @p_IsHtml       BIT,
    @p_Priority     INT,
    @p_UID          INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO EmailQueue (
        QueueId, CenterId, RecipientTo, RecipientCc, RecipientBcc, Subject, Body, IsHtml,
        Status, Priority, RetryCount, MaxRetryCount, CreatedBy, CreateDate, ModifiedBy, ModifyDate, IsDeleted
    ) VALUES (
        @p_QueueId, @p_CenterId, @p_RecipientTo, @p_RecipientCc, @p_RecipientBcc, @p_Subject, @p_Body, @p_IsHtml,
        0, @p_Priority, 0, 3, @p_UID, GETDATE(), @p_UID, GETDATE(), 0
    );

    SELECT @p_QueueId AS ID, 0 AS ErrNo, @@ROWCOUNT AS RowsCount, '' AS ErrMsg, 0 AS ErrLine;
END
GO
