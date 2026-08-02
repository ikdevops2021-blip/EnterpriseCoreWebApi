CREATE INDEX IX_ThirdPartyApiConfig_Tenant_Name ON [ThirdPartyApiConfig]([TenantId], [Name]);
CREATE INDEX IX_ThirdPartyApiConfig_IsGlobal ON [ThirdPartyApiConfig]([IsGlobal]);
CREATE INDEX IX_IntegrationLog_ConfigId ON [IntegrationLogs]([ConfigId]);
CREATE INDEX IX_IntegrationLog_CreatedBy ON [IntegrationLogs]([CreatedBy]);
GO
