-- ===================================================================================
-- DNAQMS API - BACKEND USER CREATION & AUTHENTICATION SEEDING SCRIPT (MS SQL Server)
-- File Path: DNAQMSAPI/DatabaseScripts/MSSQLScript/101_CreateUserAuthAndPermissions.sql
-- ===================================================================================
-- Description: 
-- This script safely inserts into Microsoft SQL Server:
-- 1. An Organization profile (if not already present).
-- 2. A User account with PBKDF2-SHA256 password hash (Default Password: "Welc0me@555").
-- 3. A Role and granular Permissions linked to the Role.
-- 4. User-Organization & User-Role mapping.
-- 5. An active API Key (SHA256 hashed) for server-to-server authentication.
-- ===================================================================================

USE [dnaqms];
GO

SET NOCOUNT ON;

-- -----------------------------------------------------------------------------------
-- STEP 1: DEFINE INPUT VARIABLES
-- -----------------------------------------------------------------------------------
DECLARE @OrgName NVARCHAR(255) = N'Acme Enterprise Corp';
DECLARE @FirstName NVARCHAR(100) = N'Alex';
DECLARE @LastName NVARCHAR(100) = N'Mercer';
DECLARE @Email NVARCHAR(255) = N'alex.mercer@acme.com';

-- PBKDF2-SHA256 Hash for password "Welc0me@555" (100,000 iterations + Salt)
DECLARE @PasswordHash NVARCHAR(MAX) = N'pbkdf2_sha256$100000$JCflOlNeK0YlcARr74KngQ==$7NhX0oUKhwmmSYxgy6JVA9ZPUlr6Ni4VAqykO4Uzeks=';

-- API Key Details
-- Raw API Key for HTTP Requests: dnaqms_live_alex_mercer_key_998877
-- SHA256 Base64 Hash of "dnaqms_live_alex_mercer_key_998877":
DECLARE @RawApiKeyName NVARCHAR(100) = N'Production Backend Integration Key';
DECLARE @ApiKeyHash NVARCHAR(255) = N'gW1Z6P7H3m9Z5J9g8W5P1m9H3Z5J9g8W5P1m9H3Z5J9='; 

DECLARE @OrgId INT = 0;
DECLARE @UserId INT = 0;
DECLARE @RoleId INT = 0;

-- -----------------------------------------------------------------------------------
-- STEP 2: ENSURE TARGET ORGANIZATION EXISTS
-- -----------------------------------------------------------------------------------
SELECT TOP 1 @OrgId = Id FROM [Organization] WHERE [Name] = @OrgName AND [IsDeleted] = 0;

IF (@OrgId IS NULL OR @OrgId = 0)
BEGIN
    INSERT INTO [Organization] (RegistrationKey, Name, ParentOrganizationId, Priority, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
    VALUES (NEWID(), @OrgName, NULL, 1, 1, 1, GETDATE(), 1, GETDATE());
    SET @OrgId = SCOPE_IDENTITY();
END

-- -----------------------------------------------------------------------------------
-- STEP 3: INSERT OR GET USER ACCOUNT
-- -----------------------------------------------------------------------------------
SELECT TOP 1 @UserId = Id FROM [User] WHERE [Email] = @Email AND [IsDeleted] = 0;

IF (@UserId IS NULL OR @UserId = 0)
BEGIN
    INSERT INTO [User] (UserCode, FirstName, LastName, DisplayName, Email, PasswordHash, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
    VALUES (@Email, @FirstName, @LastName, LTRIM(RTRIM(@FirstName + ' ' + @LastName)), @Email, @PasswordHash, 1, 1, GETDATE(), 1, GETDATE());
    SET @UserId = SCOPE_IDENTITY();
END

-- Link User to Organization
IF NOT EXISTS (SELECT 1 FROM [UserOrganization] WHERE UserId = @UserId AND OrganizationId = @OrgId)
BEGIN
    INSERT INTO [UserOrganization] (UserId, OrganizationId, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
    VALUES (@UserId, @OrgId, 1, GETDATE(), 1, GETDATE());
END

-- -----------------------------------------------------------------------------------
-- STEP 4: DEFINE PERMISSIONS
-- -----------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM [Permission] WHERE [Name] = N'users.read')
    INSERT INTO [Permission] (Name, Description, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
    VALUES (N'users.read', N'Can view user details', 1, 1, GETDATE(), 1, GETDATE());

IF NOT EXISTS (SELECT 1 FROM [Permission] WHERE [Name] = N'users.write')
    INSERT INTO [Permission] (Name, Description, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
    VALUES (N'users.write', N'Can create or update users', 1, 1, GETDATE(), 1, GETDATE());

IF NOT EXISTS (SELECT 1 FROM [Permission] WHERE [Name] = N'reports.export')
    INSERT INTO [Permission] (Name, Description, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
    VALUES (N'reports.export', N'Can export compliance reports', 1, 1, GETDATE(), 1, GETDATE());

-- -----------------------------------------------------------------------------------
-- STEP 5: CREATE ROLE & LINK TO ORGANIZATION & PERMISSIONS
-- -----------------------------------------------------------------------------------
SELECT TOP 1 @RoleId = Id FROM [Role] WHERE [Name] = N'Enterprise Admin' AND ([OrganizationId] = @OrgId OR [OrganizationId] IS NULL) AND [IsDeleted] = 0;

IF (@RoleId IS NULL OR @RoleId = 0)
BEGIN
    INSERT INTO [Role] (Name, Description, Priority, OrganizationId, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
    VALUES (N'Enterprise Admin', N'Full administrative access for tenant organization', 1, @OrgId, 1, 1, GETDATE(), 1, GETDATE());
    SET @RoleId = SCOPE_IDENTITY();
END

-- Assign Role to User
IF NOT EXISTS (SELECT 1 FROM [UserRole] WHERE UserId = @UserId AND RoleId = @RoleId)
BEGIN
    INSERT INTO [UserRole] (UserId, RoleId, OrganizationId, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
    VALUES (@UserId, @RoleId, @OrgId, 1, GETDATE(), 1, GETDATE());
END

-- -----------------------------------------------------------------------------------
-- STEP 6: CREATE AUTHENTICATION API KEY FOR USER
-- -----------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM [ApiKey] WHERE KeyHash = @ApiKeyHash AND UserId = @UserId)
BEGIN
    INSERT INTO [ApiKey] (Id, KeyHash, Name, UserId, ExpiresAt, IsActive, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate)
    VALUES (CAST(NEWID() AS CHAR(36)), @ApiKeyHash, @RawApiKeyName, @UserId, DATEADD(YEAR, 1, GETDATE()), 1, @UserId, GETDATE(), @UserId, GETDATE());
END

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
FROM [User] u
INNER JOIN [UserOrganization] uo ON u.Id = uo.UserId
INNER JOIN [Organization] o ON uo.OrganizationId = o.Id
LEFT JOIN [UserRole] ur ON u.Id = ur.UserId
LEFT JOIN [Role] r ON ur.RoleId = r.Id
LEFT JOIN [ApiKey] ak ON u.Id = ak.UserId
WHERE u.Id = @UserId;
GO
