-- Dummy Data for ThirdPartyApiConfig
INSERT INTO [ThirdPartyApiConfig] (
    [Name], [TenantId], [BaseUrl], [AuthType], [ApiKey], [IsGlobal], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate]
) VALUES (
    'Dummy SMS Provider', NULL, 'https://api.dummysms.com/v1/', 0, 'dummy_api_key_123', 1, 1, 0, GETUTCDATE(), 0, GETUTCDATE()
);
GO
