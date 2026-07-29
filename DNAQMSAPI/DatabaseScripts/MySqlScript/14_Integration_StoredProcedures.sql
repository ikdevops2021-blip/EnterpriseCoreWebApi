DELIMITER //

-- ============================================================================
-- 1. PR_S_APIIntegrations: Select Integration by ProviderName / TenantId
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_S_APIIntegrations //
CREATE PROCEDURE PR_S_APIIntegrations(
    IN p_IntegrationID INT,
    IN p_ProviderName VARCHAR(50),
    IN p_TenantId INT
)
BEGIN
    SELECT * 
    FROM APIIntegrations 
    WHERE IsDeleted = 0
      AND (COALESCE(p_IntegrationID, 0) = 0 OR IntegrationID = p_IntegrationID)
      AND (COALESCE(p_ProviderName, '') = '' OR ProviderName = p_ProviderName)
      AND (COALESCE(p_TenantId, 0) = 0 OR TenantId = p_TenantId OR TenantId IS NULL)
      AND Active = 1
    ORDER BY TenantId DESC, IntegrationID DESC;
END //

-- ============================================================================
-- 2. PR_IU_APIIntegrations: Insert / Update API Integration Config
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_IU_APIIntegrations //
CREATE PROCEDURE PR_IU_APIIntegrations(
    IN p_IntegrationID INT,
    IN p_TenantId INT,
    IN p_ProviderName VARCHAR(50),
    IN p_Description VARCHAR(255),
    IN p_BaseUrl VARCHAR(255),
    IN p_Active TINYINT(1),
    IN p_AuditLevel INT,
    IN p_AuthType INT,
    IN p_ApiKey LONGTEXT,
    IN p_ApiUsername VARCHAR(100),
    IN p_ApiPassword LONGTEXT,
    IN p_TokenUrl LONGTEXT,
    IN p_ClientID LONGTEXT,
    IN p_ClientSecret LONGTEXT,
    IN p_HMACSecretKey LONGTEXT,
    IN p_HMACHeaderName LONGTEXT,
    IN p_CreatedBy INT,
    OUT p_OutID INT,
    OUT p_ErrNo INT,
    OUT p_ErrMsg VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 p_ErrNo = MYSQL_ERRNO, p_ErrMsg = MESSAGE_TEXT;
        SET p_OutID = 0;
    END;

    SET p_ErrNo = 0;
    SET p_ErrMsg = 'SUCCESS';

    IF p_IntegrationID IS NULL OR p_IntegrationID = 0 THEN
        INSERT INTO APIIntegrations (
            TenantId, ProviderName, Description, BaseUrl, Active, AuditLevel, AuthType,
            ApiKey, ApiUsername, ApiPassword, TokenUrl, ClientID, ClientSecret,
            HMACSecretKey, HMACHeaderName, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate
        ) VALUES (
            p_TenantId, p_ProviderName, p_Description, p_BaseUrl, COALESCE(p_Active, 1), COALESCE(p_AuditLevel, 1), COALESCE(p_AuthType, 1),
            p_ApiKey, p_ApiUsername, p_ApiPassword, p_TokenUrl, p_ClientID, p_ClientSecret,
            p_HMACSecretKey, p_HMACHeaderName, p_CreatedBy, CURRENT_TIMESTAMP, p_CreatedBy, CURRENT_TIMESTAMP
        );
        SET p_OutID = LAST_INSERT_ID();
    ELSE
        UPDATE APIIntegrations
        SET TenantId = p_TenantId,
            ProviderName = p_ProviderName,
            Description = p_Description,
            BaseUrl = p_BaseUrl,
            Active = COALESCE(p_Active, Active),
            AuditLevel = COALESCE(p_AuditLevel, AuditLevel),
            AuthType = COALESCE(p_AuthType, AuthType),
            ApiKey = p_ApiKey,
            ApiUsername = p_ApiUsername,
            ApiPassword = p_ApiPassword,
            TokenUrl = p_TokenUrl,
            ClientID = p_ClientID,
            ClientSecret = p_ClientSecret,
            HMACSecretKey = p_HMACSecretKey,
            HMACHeaderName = p_HMACHeaderName,
            ModifiedBy = p_CreatedBy,
            ModifiedDate = CURRENT_TIMESTAMP
        WHERE IntegrationID = p_IntegrationID AND IsDeleted = 0;

        SET p_OutID = p_IntegrationID;
    END IF;
END //

-- ============================================================================
-- 3. PR_S_ApiEndpoints: Select Endpoint by IntegrationID / ActionName
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_S_ApiEndpoints //
CREATE PROCEDURE PR_S_ApiEndpoints(
    IN p_EndpointID INT,
    IN p_IntegrationID INT,
    IN p_ActionName VARCHAR(50)
)
BEGIN
    SELECT e.*, i.ProviderName, i.BaseUrl, i.AuthType
    FROM ApiEndpoints e
    INNER JOIN APIIntegrations i ON e.IntegrationID = i.IntegrationID
    WHERE e.IsDeleted = 0 AND i.IsDeleted = 0
      AND (COALESCE(p_EndpointID, 0) = 0 OR e.EndpointID = p_EndpointID)
      AND (COALESCE(p_IntegrationID, 0) = 0 OR e.IntegrationID = p_IntegrationID)
      AND (COALESCE(p_ActionName, '') = '' OR e.ActionName = p_ActionName)
      AND e.Active = 1 AND i.Active = 1;
END //

-- ============================================================================
-- 4. PR_IU_ApiEndpoints: Insert / Update Endpoint Registry
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_IU_ApiEndpoints //
CREATE PROCEDURE PR_IU_ApiEndpoints(
    IN p_EndpointID INT,
    IN p_IntegrationID INT,
    IN p_ActionName VARCHAR(50),
    IN p_RelativePath VARCHAR(255),
    IN p_HttpMethod VARCHAR(10),
    IN p_Description VARCHAR(255),
    IN p_Active TINYINT(1),
    IN p_SampleAPIRequest LONGTEXT,
    IN p_SampleAPIResponse LONGTEXT,
    IN p_CreatedBy INT,
    OUT p_OutID INT,
    OUT p_ErrNo INT,
    OUT p_ErrMsg VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 p_ErrNo = MYSQL_ERRNO, p_ErrMsg = MESSAGE_TEXT;
        SET p_OutID = 0;
    END;

    SET p_ErrNo = 0;
    SET p_ErrMsg = 'SUCCESS';

    IF p_EndpointID IS NULL OR p_EndpointID = 0 THEN
        INSERT INTO ApiEndpoints (
            IntegrationID, ActionName, RelativePath, HttpMethod, Description, Active,
            SampleAPIRequest, SampleAPIResponse, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate
        ) VALUES (
            p_IntegrationID, p_ActionName, p_RelativePath, p_HttpMethod, p_Description, COALESCE(p_Active, 1),
            p_SampleAPIRequest, p_SampleAPIResponse, p_CreatedBy, CURRENT_TIMESTAMP, p_CreatedBy, CURRENT_TIMESTAMP
        );
        SET p_OutID = LAST_INSERT_ID();
    ELSE
        UPDATE ApiEndpoints
        SET IntegrationID = p_IntegrationID,
            ActionName = p_ActionName,
            RelativePath = p_RelativePath,
            HttpMethod = p_HttpMethod,
            Description = p_Description,
            Active = COALESCE(p_Active, Active),
            SampleAPIRequest = p_SampleAPIRequest,
            SampleAPIResponse = p_SampleAPIResponse,
            ModifiedBy = p_CreatedBy,
            ModifiedDate = CURRENT_TIMESTAMP
        WHERE EndpointID = p_EndpointID AND IsDeleted = 0;

        SET p_OutID = p_EndpointID;
    END IF;
END //

-- ============================================================================
-- 5. PR_I_APIAuditLogs: Insert API Audit Log Entry
-- ============================================================================
DROP PROCEDURE IF EXISTS PR_I_APIAuditLogs //
CREATE PROCEDURE PR_I_APIAuditLogs(
    IN p_IntegrationID INT,
    IN p_ActionName VARCHAR(50),
    IN p_RequestUrl LONGTEXT,
    IN p_HttpMethod VARCHAR(10),
    IN p_RequestBody LONGTEXT,
    IN p_ResponseBody LONGTEXT,
    IN p_StatusCode INT,
    IN p_DurationMs INT,
    IN p_ErrorMessage LONGTEXT,
    IN p_CreatedBy INT
)
BEGIN
    INSERT INTO APIAuditLogs (
        IntegrationID, ActionName, RequestUrl, HttpMethod, RequestBody, ResponseBody,
        StatusCode, DurationMs, ErrorMessage, CreatedBy, CreatedDate
    ) VALUES (
        p_IntegrationID, p_ActionName, p_RequestUrl, p_HttpMethod, p_RequestBody, p_ResponseBody,
        p_StatusCode, p_DurationMs, p_ErrorMessage, p_CreatedBy, CURRENT_TIMESTAMP
    );
END //

DELIMITER ;
