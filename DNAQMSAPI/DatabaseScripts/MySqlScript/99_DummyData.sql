-- Dummy Data for Organization
SET @SystemOrganizationId = 0;
SET @MainOrganizationId = 0;

INSERT INTO `Organization` (RegistrationKey, Name, ParentOrganizationId, Priority, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES (UUID(), 'System Global', NULL, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP);
SET @SystemOrganizationId = LAST_INSERT_ID();

INSERT INTO `Organization` (RegistrationKey, Name, ParentOrganizationId, Priority, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES (UUID(), 'Main HQ Organization', NULL, 1, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP);
SET @MainOrganizationId = LAST_INSERT_ID();

-- Dummy Data for User
SET @AdminUserId = 0;
SET @RegularUserId = 0;

INSERT INTO `User` (UserCode, FirstName, LastName, DisplayName, Email, PasswordHash, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES ('admin@dnaqms.com', 'System', 'Admin', 'System Admin', 'admin@dnaqms.com', 'AfmujfSre94cxjceo8EavMmDjLywD6GuUKQq+9x28/XvpkBgr+NByUE99VDm/t1+vQ==', 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP);
SET @AdminUserId = LAST_INSERT_ID();

INSERT INTO `User` (UserCode, FirstName, LastName, DisplayName, Email, PasswordHash, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES ('john@dnaqms.com', 'John', 'Doe', 'John Doe', 'john@dnaqms.com', 'AeY7lmJzo/eZfCtWDmIY//plBawcCwZnT7I8zVq3m0N1nAOfjzjwtcCI/vCf9Jd1TQ==', 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP);
SET @RegularUserId = LAST_INSERT_ID();

-- Dummy Data for Role
SET @GlobalAdminRoleId = 0;
SET @OrganizationAdminRoleId = 0;

INSERT INTO `Role` (Name, Description, Priority, OrganizationId, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES ('Global Admin', 'Has access to everything', 1, NULL, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP);
SET @GlobalAdminRoleId = LAST_INSERT_ID();

INSERT INTO `Role` (Name, Description, Priority, OrganizationId, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES ('Organization Admin', 'Admin for a specific organization', 1, @MainOrganizationId, 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP);
SET @OrganizationAdminRoleId = LAST_INSERT_ID();

-- Dummy Data for UserOrganization
INSERT INTO `UserOrganization` (UserId, OrganizationId, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES 
(@AdminUserId, @SystemOrganizationId, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP),
(@RegularUserId, @MainOrganizationId, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP);

-- Dummy Data for UserRole
INSERT INTO `UserRole` (UserId, RoleId, OrganizationId, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES 
(@AdminUserId, @GlobalAdminRoleId, NULL, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP),
(@RegularUserId, @OrganizationAdminRoleId, @MainOrganizationId, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP);

-- Dummy Data for OrganizationStorageConfig
INSERT INTO `OrganizationStorageConfig` (OrganizationId, ProviderName, ConfigurationJson, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES 
(@SystemOrganizationId, 'GoogleDrive', '{"BucketName":"dnaqms-global-bucket"}', 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP);

-- Dummy Data for OrganizationPaymentProvider
INSERT INTO `OrganizationPaymentProvider` (OrganizationId, ProviderName, ConfigurationJson, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES 
(@MainOrganizationId, 'Stripe', '{"ApiKey":"sk_test_1234dummy"}', 1, 0, CURRENT_TIMESTAMP, 0, CURRENT_TIMESTAMP);
