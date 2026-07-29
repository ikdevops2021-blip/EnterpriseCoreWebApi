-- Dummy Data for Organization
DECLARE @SystemOrganizationId INT;
DECLARE @MainOrganizationId INT;

INSERT INTO [Organization] (RegistrationKey, Name, ParentOrganizationId, Priority, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES (NEWID(), 'System Global', NULL, 1, 1, 0, GETDATE(), 0, GETDATE());
SET @SystemOrganizationId = SCOPE_IDENTITY();

INSERT INTO [Organization] (RegistrationKey, Name, ParentOrganizationId, Priority, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES (NEWID(), 'Main HQ Organization', NULL, 1, 1, 0, GETDATE(), 0, GETDATE());
SET @MainOrganizationId = SCOPE_IDENTITY();

-- Dummy Data for User
DECLARE @AdminUserId INT;
DECLARE @RegularUserId INT;

INSERT INTO [User] (UserCode, FirstName, LastName, DisplayName, Email, PasswordHash, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES ('admin@dnaqms.com', 'System', 'Admin', 'System Admin', 'admin@dnaqms.com', 'hashed_pwd_here', 1, 0, GETDATE(), 0, GETDATE());
SET @AdminUserId = SCOPE_IDENTITY();

INSERT INTO [User] (UserCode, FirstName, LastName, DisplayName, Email, PasswordHash, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES ('john@dnaqms.com', 'John', 'Doe', 'John Doe', 'john@dnaqms.com', 'hashed_pwd_here', 1, 0, GETDATE(), 0, GETDATE());
SET @RegularUserId = SCOPE_IDENTITY();

-- Dummy Data for Role
DECLARE @GlobalAdminRoleId INT;
DECLARE @OrganizationAdminRoleId INT;

INSERT INTO [Role] (Name, Description, Priority, OrganizationId, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES ('Global Admin', 'Has access to everything', 1, NULL, 1, 0, GETDATE(), 0, GETDATE());
SET @GlobalAdminRoleId = SCOPE_IDENTITY();

INSERT INTO [Role] (Name, Description, Priority, OrganizationId, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES ('Organization Admin', 'Admin for a specific organization', 1, @MainOrganizationId, 1, 0, GETDATE(), 0, GETDATE());
SET @OrganizationAdminRoleId = SCOPE_IDENTITY();

-- Dummy Data for UserOrganization
INSERT INTO [UserOrganization] (UserId, OrganizationId, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES 
(@AdminUserId, @SystemOrganizationId, 0, GETDATE(), 0, GETDATE()),
(@RegularUserId, @MainOrganizationId, 0, GETDATE(), 0, GETDATE());

-- Dummy Data for UserRole
INSERT INTO [UserRole] (UserId, RoleId, OrganizationId, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES 
(@AdminUserId, @GlobalAdminRoleId, NULL, 0, GETDATE(), 0, GETDATE()),
(@RegularUserId, @OrganizationAdminRoleId, @MainOrganizationId, 0, GETDATE(), 0, GETDATE());

-- Dummy Data for OrganizationStorageConfig
INSERT INTO [OrganizationStorageConfig] (OrganizationId, ProviderName, ConfigurationJson, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES 
(@SystemOrganizationId, 'GoogleDrive', '{"BucketName":"dnaqms-global-bucket"}', 1, 0, GETDATE(), 0, GETDATE());

-- Dummy Data for OrganizationPaymentProvider
INSERT INTO [OrganizationPaymentProvider] (OrganizationId, ProviderName, ConfigurationJson, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES 
(@MainOrganizationId, 'Stripe', '{"ApiKey":"sk_test_1234dummy"}', 1, 0, GETDATE(), 0, GETDATE());
GO
