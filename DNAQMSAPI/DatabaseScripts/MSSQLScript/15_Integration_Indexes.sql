CREATE INDEX IX_ThirdPartyApiConfig_Tenant_Name ON [ThirdPartyApiConfig]([TenantId], [Name]);
CREATE INDEX IX_ThirdPartyApiConfig_IsGlobal ON [ThirdPartyApiConfig]([IsGlobal]);
CREATE INDEX IX_IntegrationLog_ConfigName ON [IntegrationLog]([ConfigName]);
CREATE INDEX IX_IntegrationLog_TenantId ON [IntegrationLog]([TenantId]);
GO
