USE dnaqms;
DELETE FROM APIIntegrations WHERE ProviderName = 'Typicode';
INSERT INTO APIIntegrations (CenterID, ProviderName, BaseUrl, Active, AuditLevel, AuthType, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted)
VALUES (1, 'Typicode', 'https://jsonplaceholder.typicode.com', 1, 2, 0, 1, NOW(), 1, NOW(), 0);
SET @IntegrationID = LAST_INSERT_ID();

DELETE FROM ApiEndpoints WHERE ActionName = 'GetTodo';
INSERT INTO ApiEndpoints (IntegrationID, ActionName, RelativePath, HttpMethod, Active, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate, IsDeleted)
VALUES (@IntegrationID, 'GetTodo', '/todos/{id}', 'GET', 1, 1, NOW(), 1, NOW(), 0);
