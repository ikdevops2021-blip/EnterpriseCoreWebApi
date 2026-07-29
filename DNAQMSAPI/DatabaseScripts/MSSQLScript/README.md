# MS SQL Database Scripts

This folder contains the table schema creations and dummy data seeding scripts for MS SQL Server.

## Execution Sequence

To properly create the relational layout, execute the scripts in the numerical order corresponding to their prefix. The logical sequence respects hierarchical constraints and domain dependencies.

1. **`01_Organization.sql`**: Root multi-tenant organizational unit. Other tables rely on `OrganizationId`.
2. **`02_User.sql`**: Main authenticated identity table. Includes `UserCode` (custom user handle, unique among active users) and `DisplayName` columns.
3. **`03_Role.sql`**: RBAC role definitions (can be global or tied to a `Organization`).
4. **`04_Permission.sql`**: Extensible list of permissions (e.g. `users.read`).
5. **`05_UserOrganization.sql`**: Joining logic mapping which `User` belongs to which `Organization`.
6. **`06_UserRole.sql`**: Maps a `User` to a `Role`, optionally scoped to a `Organization`.
7. **`07_ApiKey.sql`**: Server-to-server API access keys tied to users.
8. **`08_UserSession.sql`**: Refresh tokens and session control for authentication.
9. **`09_UserDevice.sql`**: Trusted devices for users (useful for MFA, notifications).
10. **`10_OrganizationStorageConfig.sql`**: Cloud file storage configurations specific to a `Organization`.
11. **`11_OrganizationPaymentProvider.sql`**: Payment gateway credentials configured per `Organization`.
12. **`12_StoredFile.sql`**: Cloud metadata for uploaded documents (receipts, avatars, docs).
13. **`13_PaymentTransaction.sql`**: Payment records associated with users and target organizations.
14. **`14_Integration_Tables.sql`**: Core configuration definition and robust logging specifically for third-party API integration.
15. **`15_Integration_Indexes.sql`**: High-performance tracking indexes mapped over Base URLs and API configurations.
16. **`17_NexusCore_Config.sql`**: NexusCore configuration tables for category hierarchy, parameter catalog, and system configuration keys. `SystemConfigurationKeys.DataTypeID` maps to `ConfigParameters.ParameterID`.
17. **`18_NexusCore_Config_StoredProcs.sql`**: Stored procedures for reading and updating system configuration values.
18. **`19_NexusCore_ID_Generator.sql`**: Key-based ID generator support table and stored procedure.
19. **`21_NexusCore_SeedData.sql`**: Starter NexusCore seed data for categories, data types, and system configuration keys.
20. **`99_DummyData.sql`**: Starter seed file containing initial System Admin, Roles, and initial configuration mockups.
21. **`100_Integration_SeedData.sql`**: Base starter mocks ensuring the integration environment launches completely seamlessly.
22. **`101_CreateUserAuthAndPermissions.sql`**: Complete script to create user, organization, role, permissions, and API key.
23. **`102_ProvisionApiKeysAllUsers.sql`**: Provisions API keys and resets passwords to `Welc0me@555` for existing users without API keys.
24. **`22_UserContactAndAddress.sql`**: Location master tables (`Country`, `State`, `City`), `UserAddresses`, and `UserContacts` tables with `StateCode`, `CityCode`, and `IsEmergency` flags.
25. **`23_WorldLocationSeedData.sql`**: Consolidated world dataset seeding script (250 Countries, 5,308 States with `StateCode`, and 152,970 Cities with official IATA `CityCode`).
27. **`27_Location_And_UserProfile_StoredProcs.sql`**: Stored procedures for Location (Country, State, City) and User Profile (Address, Contact) CRUD operations.
28. **`28_Alter_User_Add_UserCode.sql`**: Non-destructive migration to add `UserCode` and `DisplayName` columns to existing `User` tables. Populates existing rows with Email as UserCode and FirstName+LastName as DisplayName. Creates filtered unique index `UX_Users_UserCode`.
29. **`18_User_StoredProcs.sql`**: Stored procedures for User CRUD, lookup, and UserCode/DisplayName operations.
30. **`29_Notification_Tables.sql`**: Tables for `NotificationTemplate` (with `EventId` referencing `ConfigParameters` Category 17 `C_NOTIFICATION_EVENT`), `UserNotification` (In-App Bell Feed), and `SmsQueue`.
31. **`30_Notification_StoredProcs.sql`**: Stored procedures for notification dispatching, template resolution, In-App bell feed, and read status management.
32. **`Email/001_EmailSettings.sql`**: Table to store SMTP configuration per Organization.
33. **`Email/002_EmailQueue.sql`**: Table for high-performance mail dispatch queue.
34. **`Email/003_EmailSignatures.sql`**: Table to store reusable HTML signature templates.
35. **`Email/004_EmailViews.sql`**: View to provide daily mail health reports.
36. **`Email/005_EmailDummyData.sql`**: Seed data for EmailSettings, EmailSignatures, and EmailQueue testing.

## Table Details and Purpose
- **Audit Columns**: Every table universally contains standardized audit columns: `CreatedBy`, `CreatedDate`, `ModifiedBy`, `ModifiedDate`, `IsDeleted`, `DeletedBy`, `DeletedDate`. This enforces soft-delete operations and strict tracking for QMS (Quality Management Systems) compliance.
- **Guid Primary Keys**: Most tables use `UNIQUEIDENTIFIER` (`Guid`) for the primary key. This is useful for distributed systems and API uniqueness, preventing primary key enumeration attacks.
- **IsActive vs IsDeleted**: `IsActive` acts as a configurable toggle for the entity, while `IsDeleted` marks the record as soft-deleted to preserve history without breaking foreign keys in reporting datasets.
- **NexusCore Usage**: `ConfigCategory`, `ConfigParameters`, and `SystemConfigurationKeys` are now consumed by `ConfigurationController` for catalog lookup and system configuration updates.
