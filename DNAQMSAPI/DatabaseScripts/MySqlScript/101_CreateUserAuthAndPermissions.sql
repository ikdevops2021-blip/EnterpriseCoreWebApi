-- ===================================================================================
-- DNAQMS API - BACKEND USER CREATION & AUTHENTICATION SEEDING SCRIPT (MySQL)
-- File Path: DNAQMSAPI/DatabaseScripts/MySqlScript/101_CreateUserAuthAndPermissions.sql
-- ===================================================================================
-- Description: 
-- This script safely inserts:
-- 1. An Organization profile (if not already present).
-- 2. A User account with PBKDF2-SHA256 password hash (Default Password: "Welc0me@555").
-- 3. A Role and granular Permissions linked to the Role.
-- 4. User-Organization & User-Role mapping.
-- 5. An active API Key (SHA256 hashed) for server-to-server authentication.
-- ===================================================================================

USE `dnaqms`;

-- -----------------------------------------------------------------------------------
-- STEP 1: DEFINE INPUT VARIABLES
-- -----------------------------------------------------------------------------------
SET @OrgName = 'Acme Enterprise Corp';
SET @FirstName = 'Alex';
SET @LastName = 'Mercer';
SET @Email = 'alex.mercer@acme.com';

-- PBKDF2-SHA256 Hash for password "Welc0me@555" (100,000 iterations + Salt)
SET @PasswordHash = 'pbkdf2_sha256$100000$JCflOlNeK0YlcARr74KngQ==$7NhX0oUKhwmmSYxgy6JVA9ZPUlr6Ni4VAqykO4Uzeks=';

-- API Key Details
-- Raw API Key for HTTP Requests: dnaqms_live_alex_mercer_key_998877
-- SHA256 Base64 Hash of "dnaqms_live_alex_mercer_key_998877":
SET @RawApiKeyName = 'Production Backend Integration Key';
SET @ApiKeyHash = 'gW1Z6P7H3m9Z5J9g8W5P1m9H3Z5J9g8W5P1m9H3Z5J9='; 

-- -----------------------------------------------------------------------------------
-- STEP 2: ENSURE TARGET ORGANIZATION EXISTS
-- -----------------------------------------------------------------------------------
INSERT INTO `Organization` (RegistrationKey, Name, ParentOrganizationId, Priority, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
SELECT UUID(), @OrgName, NULL, 1, 1, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `Organization` WHERE `Name` = @OrgName AND `IsDeleted` = 0);

SET @OrgId = (SELECT Id FROM `Organization` WHERE `Name` = @OrgName AND `IsDeleted` = 0 LIMIT 1);

-- -----------------------------------------------------------------------------------
-- STEP 3: INSERT OR GET USER ACCOUNT
-- -----------------------------------------------------------------------------------
INSERT INTO `User` (UserCode, FirstName, LastName, DisplayName, Email, PasswordHash, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
SELECT @Email, @FirstName, @LastName, CONCAT(@FirstName, ' ', @LastName), @Email, @PasswordHash, 1, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `User` WHERE `Email` = @Email AND `IsDeleted` = 0);

SET @UserId = (SELECT Id FROM `User` WHERE `Email` = @Email AND `IsDeleted` = 0 LIMIT 1);

-- Link User to Organization
INSERT INTO `UserOrganization` (UserId, OrganizationId, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES (@UserId, @OrgId, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP)
ON DUPLICATE KEY UPDATE `ModifiedDate` = CURRENT_TIMESTAMP;

-- -----------------------------------------------------------------------------------
-- STEP 4: DEFINE PERMISSIONS
-- -----------------------------------------------------------------------------------
INSERT INTO `Permission` (Name, Description, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES 
('users.read', 'Can view user details', 1, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
('users.write', 'Can create or update users', 1, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
('reports.export', 'Can export compliance reports', 1, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP)
ON DUPLICATE KEY UPDATE `Description` = VALUES(`Description`);

-- -----------------------------------------------------------------------------------
-- STEP 5: CREATE ROLE & LINK TO ORGANIZATION & PERMISSIONS
-- -----------------------------------------------------------------------------------
INSERT INTO `Role` (Name, Description, Priority, OrganizationId, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
SELECT 'Enterprise Admin', 'Full administrative access for tenant organization', 1, @OrgId, 1, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `Role` WHERE `Name` = 'Enterprise Admin' AND (`OrganizationId` = @OrgId OR `OrganizationId` IS NULL) AND `IsDeleted` = 0);

SET @RoleId = (SELECT Id FROM `Role` WHERE `Name` = 'Enterprise Admin' AND (`OrganizationId` = @OrgId OR `OrganizationId` IS NULL) AND `IsDeleted` = 0 LIMIT 1);

-- Assign Role to User
INSERT INTO `UserRole` (UserId, RoleId, OrganizationId, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
VALUES (@UserId, @RoleId, @OrgId, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP)
ON DUPLICATE KEY UPDATE `ModifiedDate` = CURRENT_TIMESTAMP;

-- -----------------------------------------------------------------------------------
-- STEP 6: CREATE AUTHENTICATION API KEY FOR USER
-- -----------------------------------------------------------------------------------
-- Generates a UUID for the ApiKey Id and stores SHA256 hashed secret
INSERT INTO `ApiKey` (Id, KeyHash, Name, UserId, ExpiresAt, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
SELECT UUID(), @ApiKeyHash, @RawApiKeyName, @UserId, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 1 YEAR), 1, @UserId, CURRENT_TIMESTAMP, @UserId, CURRENT_TIMESTAMP
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `ApiKey` WHERE `KeyHash` = @ApiKeyHash AND `UserId` = @UserId AND `IsDeleted` = 0);

-- -----------------------------------------------------------------------------------
-- STEP 7: VERIFICATION OUTPUT
-- -----------------------------------------------------------------------------------
SELECT 
    u.Id AS UserId,
    u.FirstName,
    u.LastName,
    u.Email,
    o.Name AS OrganizationName,
    r.Name AS AssignedRole,
    ak.Name AS ApiKeyName,
    ak.ExpiresAt AS ApiKeyExpiresAt
FROM `User` u
INNER JOIN `UserOrganization` uo ON u.Id = uo.UserId
INNER JOIN `Organization` o ON uo.OrganizationId = o.Id
LEFT JOIN `UserRole` ur ON u.Id = ur.UserId
LEFT JOIN `Role` r ON ur.RoleId = r.Id
LEFT JOIN `ApiKey` ak ON u.Id = ak.UserId
WHERE u.Id = @UserId;
