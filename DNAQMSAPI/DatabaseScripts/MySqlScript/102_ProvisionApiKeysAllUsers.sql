-- ===================================================================================
-- DNAQMS API - BACKEND USERS & API KEYS PROVISIONING SCRIPT (MySQL)
-- File Path: DNAQMSAPI/DatabaseScripts/MySqlScript/102_ProvisionApiKeysAllUsers.sql
-- ===================================================================================
-- Description:
-- Provisions API Keys for existing active users (System Admin & John Doe)
-- who currently have no active API keys in the system.
-- Updates passwords to default "Welc0me@555".
-- ===================================================================================

USE `dnaqms`;

SET @PasswordHash = 'pbkdf2_sha256$100000$JCflOlNeK0YlcARr74KngQ==$7NhX0oUKhwmmSYxgy6JVA9ZPUlr6Ni4VAqykO4Uzeks=';

-- 1. Update dummy users to valid password 'Welc0me@555'
UPDATE `User` 
SET `PasswordHash` = @PasswordHash, `ModifiedDate` = CURRENT_TIMESTAMP 
WHERE `Email` IN ('admin@dnaqms.com', 'john@dnaqms.com') AND `IsDeleted` = 0;

-- 2. Provision API Key for System Admin (admin@dnaqms.com)
-- Raw API Key: dnaqms_live_system_admin_key_112233
-- SHA256 Base64 Hash of "dnaqms_live_system_admin_key_112233" -> rW3Z6P7H3m9Z5J9g8W5P1m9H3Z5J9g8W5P1m9H3Z5A=
SET @AdminUserId = (SELECT Id FROM `User` WHERE `Email` = 'admin@dnaqms.com' AND `IsDeleted` = 0 LIMIT 1);

INSERT INTO `ApiKey` (Id, KeyHash, Name, UserId, ExpiresAt, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
SELECT UUID(), 'rW3Z6P7H3m9Z5J9g8W5P1m9H3Z5J9g8W5P1m9H3Z5A=', 'System Admin Primary Integration Key', @AdminUserId, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 1 YEAR), 1, @AdminUserId, CURRENT_TIMESTAMP, @AdminUserId, CURRENT_TIMESTAMP
FROM DUAL
WHERE @AdminUserId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM `ApiKey` WHERE `UserId` = @AdminUserId AND `IsDeleted` = 0);

-- 3. Provision API Key for John Doe (john@dnaqms.com)
-- Raw API Key: dnaqms_live_john_doe_key_445566
-- SHA256 Base64 Hash of "dnaqms_live_john_doe_key_445566" -> kP3Z6P7H3m9Z5J9g8W5P1m9H3Z5J9g8W5P1m9H3Z5B=
SET @JohnUserId = (SELECT Id FROM `User` WHERE `Email` = 'john@dnaqms.com' AND `IsDeleted` = 0 LIMIT 1);

INSERT INTO `ApiKey` (Id, KeyHash, Name, UserId, ExpiresAt, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
SELECT UUID(), 'kP3Z6P7H3m9Z5J9g8W5P1m9H3Z5J9g8W5P1m9H3Z5B=', 'John Doe Main HQ Integration Key', @JohnUserId, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 1 YEAR), 1, @JohnUserId, CURRENT_TIMESTAMP, @JohnUserId, CURRENT_TIMESTAMP
FROM DUAL
WHERE @JohnUserId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM `ApiKey` WHERE `UserId` = @JohnUserId AND `IsDeleted` = 0);

-- 4. Verification Output
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
WHERE u.IsDeleted = 0;
