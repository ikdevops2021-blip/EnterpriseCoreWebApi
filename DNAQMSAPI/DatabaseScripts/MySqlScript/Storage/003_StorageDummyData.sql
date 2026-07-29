-- Dummy Data for OrganizationStorageConfig

-- Insert default configurations (OrganizationId = 0 means global/fallback config)
INSERT INTO `OrganizationStorageConfig` (OrganizationId, ProviderName, ConfigurationJson, IsActive, CreatedBy, ModifiedBy)
VALUES 
(0, 'Local', '{"BasePath": "App_Data/Uploads"}', 1, 1, 1),
(0, 'AWS', '{"AccessKey": "mock_access_key", "SecretKey": "mock_secret_key", "BucketName": "mock-bucket"}', 1, 1, 1),
(0, 'Azure', '{"ConnectionString": "UseDevelopmentStorage=true", "ContainerName": "mock-container"}', 1, 1, 1),
(0, 'GoogleDrive', '{"ClientId": "mock_client_id", "ClientSecret": "mock_client_secret"}', 1, 1, 1);

-- Insert organization-specific configuration (OrganizationId = 1)
INSERT INTO `OrganizationStorageConfig` (OrganizationId, ProviderName, ConfigurationJson, IsActive, CreatedBy, ModifiedBy)
VALUES 
(1, 'AWS', '{"AccessKey": "org1_access_key", "SecretKey": "org1_secret_key", "BucketName": "org1-bucket"}', 1, 1, 1);
