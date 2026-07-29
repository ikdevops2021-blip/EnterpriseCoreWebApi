CREATE OR ALTER PROCEDURE [dbo].[pr_GetThirdPartyApiConfig]
    @Name NVARCHAR(255),
    @TenantId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP 1 * 
    FROM [dbo].[ThirdPartyApiConfig]
    WHERE Name = @Name 
      AND (TenantId = @TenantId OR TenantId IS NULL)
      AND IsActive = 1 
      AND IsDeleted = 0
    ORDER BY CASE WHEN TenantId IS NOT NULL THEN 0 ELSE 1 END ASC;
END
GO

CREATE OR ALTER PROCEDURE [dbo].[pr_InsertIntegrationLog]
    @ConfigId INT,
    @Endpoint NVARCHAR(1000),
    @HttpMethod NVARCHAR(10),
    @RequestBody NVARCHAR(MAX),
    @ResponseBody NVARCHAR(MAX),
    @StatusCode INT,
    @DurationMs INT,
    @ErrorMessage NVARCHAR(MAX),
    @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [dbo].[IntegrationLogs] (
        ConfigId, Endpoint, HttpMethod, RequestBody, ResponseBody, 
        StatusCode, DurationMs, ErrorMessage, CreatedBy, CreatedDate
    )
    VALUES (
        @ConfigId, @Endpoint, @HttpMethod, @RequestBody, @ResponseBody, 
        @StatusCode, @DurationMs, @ErrorMessage, @CreatedBy, GETUTCDATE()
    );
END
GO

CREATE OR ALTER PROCEDURE [dbo].[pr_UpdateOAuthTokens]
    @ConfigId INT,
    @AccessToken NVARCHAR(MAX),
    @RefreshToken NVARCHAR(MAX),
    @TokenExpiry DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [dbo].[ThirdPartyApiConfig]
    SET AccessToken = @AccessToken,
        RefreshToken = @RefreshToken,
        TokenExpiry = @TokenExpiry,
        ModifiedDate = GETUTCDATE()
    WHERE Id = @ConfigId;
END
GO
