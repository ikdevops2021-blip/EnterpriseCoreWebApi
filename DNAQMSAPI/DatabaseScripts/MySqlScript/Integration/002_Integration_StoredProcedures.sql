DELIMITER //

DROP PROCEDURE IF EXISTS pr_GetThirdPartyApiConfig //
CREATE PROCEDURE pr_GetThirdPartyApiConfig(
    IN p_Name VARCHAR(255),
    IN p_TenantId INT
)
BEGIN
    -- Try to get tenant-specific config first
    SELECT * FROM ThirdPartyApiConfig 
    WHERE Name = p_Name 
      AND (TenantId = p_TenantId OR TenantId IS NULL)
      AND IsActive = 1 
      AND IsDeleted = 0
    ORDER BY TenantId DESC -- This prioritizes a matching TenantId over NULL (Global)
    LIMIT 1;
END //

DROP PROCEDURE IF EXISTS pr_InsertIntegrationLog //
CREATE PROCEDURE pr_InsertIntegrationLog(
    IN p_ConfigId INT,
    IN p_Endpoint VARCHAR(1000),
    IN p_HttpMethod VARCHAR(10),
    IN p_RequestBody TEXT,
    IN p_ResponseBody TEXT,
    IN p_StatusCode INT,
    IN p_DurationMs INT,
    IN p_ErrorMessage TEXT,
    IN p_CreatedBy INT
)
BEGIN
    INSERT INTO IntegrationLogs (
        ConfigId, Endpoint, HttpMethod, RequestBody, ResponseBody, 
        StatusCode, DurationMs, ErrorMessage, CreatedBy, CreatedDate
    )
    VALUES (
        p_ConfigId, p_Endpoint, p_HttpMethod, p_RequestBody, p_ResponseBody, 
        p_StatusCode, p_DurationMs, p_ErrorMessage, p_CreatedBy, UTC_TIMESTAMP()
    );
END //

DROP PROCEDURE IF EXISTS pr_UpdateOAuthTokens //
CREATE PROCEDURE pr_UpdateOAuthTokens(
    IN p_ConfigId INT,
    IN p_AccessToken TEXT,
    IN p_RefreshToken TEXT,
    IN p_TokenExpiry DATETIME
)
BEGIN
    UPDATE ThirdPartyApiConfig 
    SET AccessToken = p_AccessToken,
        RefreshToken = p_RefreshToken,
        TokenExpiry = p_TokenExpiry,
        ModifiedDate = UTC_TIMESTAMP()
    WHERE Id = p_ConfigId;
END //

DELIMITER ;
