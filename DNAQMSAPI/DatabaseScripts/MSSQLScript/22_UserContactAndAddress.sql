-- ===================================================================================
-- DNAQMS API - LOCATION MASTERS, USER ADDRESSES & USER CONTACTS SCHEMA (MS SQL Server)
-- File Path: DNAQMSAPI/DatabaseScripts/MSSQLScript/22_UserContactAndAddress.sql
-- ===================================================================================

USE [dnaqms];
GO

SET NOCOUNT ON;

-- -----------------------------------------------------------------------------------
-- 1. COUNTRY MASTER TABLE
-- -----------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Country]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Country] (
        [CountryId]             INT IDENTITY(1,1) PRIMARY KEY,
        [CountryName]           VARCHAR(100) NOT NULL,
        [CountryCode]           VARCHAR(5) NOT NULL,
        [InternationalDialing]  VARCHAR(10) NULL,
        
        -- Generic Attributes
        [Attribute1]            VARCHAR(100) NULL,
        [Attribute2]            VARCHAR(100) NULL,
        [Attribute3]            VARCHAR(100) NULL,
        
        -- Audit Metadata
        [IsActive]              BIT NOT NULL DEFAULT 1,
        [CreatedBy]             INT NOT NULL,
        [CreatedDate]           DATETIME NOT NULL DEFAULT GETDATE(),
        [ModifiedBy]            INT NULL,
        [ModifiedDate]          DATETIME NULL,
        [IsDeleted]             BIT NOT NULL DEFAULT 0,
        [DeletedBy]             INT NULL,
        [DeletedDate]           DATETIME NULL
    );
END;
GO

-- -----------------------------------------------------------------------------------
-- 2. STATE MASTER TABLE
-- -----------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[State]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[State] (
        [StateId]               INT IDENTITY(1,1) PRIMARY KEY,
        [CountryId]             INT NOT NULL,
        [StateName]             VARCHAR(100) NOT NULL,
        [StateCode]             VARCHAR(10) NULL,
        
        -- Generic Attributes
        [Attribute1]            VARCHAR(100) NULL,
        [Attribute2]            VARCHAR(100) NULL,
        [Attribute3]            VARCHAR(100) NULL,
        
        -- Audit Metadata
        [IsActive]              BIT NOT NULL DEFAULT 1,
        [CreatedBy]             INT NOT NULL,
        [CreatedDate]           DATETIME NOT NULL DEFAULT GETDATE(),
        [ModifiedBy]            INT NULL,
        [ModifiedDate]          DATETIME NULL,
        [IsDeleted]             BIT NOT NULL DEFAULT 0,
        [DeletedBy]             INT NULL,
        [DeletedDate]           DATETIME NULL,

        CONSTRAINT [FK_State_Country] 
            FOREIGN KEY ([CountryId]) REFERENCES [dbo].[Country]([CountryId])
    );
END;
GO

-- -----------------------------------------------------------------------------------
-- 3. CITY MASTER TABLE
-- -----------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[City]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[City] (
        [CityId]                INT IDENTITY(1,1) PRIMARY KEY,
        [StateId]               INT NOT NULL,
        [CityName]              VARCHAR(100) NOT NULL,
        [CityCode]              VARCHAR(10) NULL,
        
        -- Generic Attributes
        [Attribute1]            VARCHAR(100) NULL,
        [Attribute2]            VARCHAR(100) NULL,
        [Attribute3]            VARCHAR(100) NULL,
        
        -- Audit Metadata
        [IsActive]              BIT NOT NULL DEFAULT 1,
        [CreatedBy]             INT NOT NULL,
        [CreatedDate]           DATETIME NOT NULL DEFAULT GETDATE(),
        [ModifiedBy]            INT NULL,
        [ModifiedDate]          DATETIME NULL,
        [IsDeleted]             BIT NOT NULL DEFAULT 0,
        [DeletedBy]             INT NULL,
        [DeletedDate]           DATETIME NULL,

        CONSTRAINT [FK_City_State] 
            FOREIGN KEY ([StateId]) REFERENCES [dbo].[State]([StateId])
    );
END;
GO

-- -----------------------------------------------------------------------------------
-- 4. USER ADDRESSES TABLE
-- -----------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserAddresses]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[UserAddresses] (
        [AddressId]             BIGINT IDENTITY(1,1) PRIMARY KEY,
        [UserId]                INT NOT NULL,
        [AddressTypeId]         INT NOT NULL,                -- ConfigParameters (4001..4005)
        
        -- Address Attributes
        [AddressLine1]          VARCHAR(255) NOT NULL,
        [AddressLine2]          VARCHAR(255) NULL,
        [PostalCode]            VARCHAR(20) NOT NULL,

        -- Foreign Keys to Location Masters
        [CountryId]             INT NOT NULL,
        [StateId]               INT NOT NULL,
        [CityId]                INT NOT NULL,

        -- Geolocation Attributes
        [Latitude]              DECIMAL(9,6) NULL,
        [Longitude]             DECIMAL(9,6) NULL,
        [GeoLocation]           GEOGRAPHY NULL,
        
        -- Flags
        [IsPrimary]             BIT NOT NULL DEFAULT 0,
        
        -- Audit Metadata
        [IsActive]              BIT NOT NULL DEFAULT 1,
        [CreatedBy]             INT NOT NULL,
        [CreatedDate]           DATETIME NOT NULL DEFAULT GETDATE(),
        [ModifiedBy]            INT NULL,
        [ModifiedDate]          DATETIME NULL,
        [IsDeleted]             BIT NOT NULL DEFAULT 0,
        [DeletedBy]             INT NULL,
        [DeletedDate]           DATETIME NULL,

        -- Foreign Key Constraints
        CONSTRAINT [FK_UserAddresses_User] 
            FOREIGN KEY ([UserId]) REFERENCES [dbo].[User]([Id]) ON DELETE CASCADE,
            
        CONSTRAINT [FK_UserAddresses_Config] 
            FOREIGN KEY ([AddressTypeId]) REFERENCES [dbo].[ConfigParameters]([ParameterID]),

        CONSTRAINT [FK_UserAddresses_Country] 
            FOREIGN KEY ([CountryId]) REFERENCES [dbo].[Country]([CountryId]),

        CONSTRAINT [FK_UserAddresses_State] 
            FOREIGN KEY ([StateId]) REFERENCES [dbo].[State]([StateId]),

        CONSTRAINT [FK_UserAddresses_City] 
            FOREIGN KEY ([CityId]) REFERENCES [dbo].[City]([CityId])
    );
END;
GO

-- -----------------------------------------------------------------------------------
-- 5. USER CONTACTS TABLE
-- -----------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserContacts]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[UserContacts] (
        [ContactId]             BIGINT IDENTITY(1,1) PRIMARY KEY,
        [UserId]                INT NOT NULL,                 -- Primary System User
        [ContactTypeId]         INT NOT NULL,                 -- ConfigParameters Category 5  (5001..5006)
        [RelationshipTypeId]    INT NOT NULL,                 -- ConfigParameters Category 16 (16001..16024)
        
        -- Contact Information
        [ContactValue]          VARCHAR(255) NOT NULL,
        [CountryCode]           VARCHAR(5) NULL,              -- Dialing code (e.g., '+1', '+91')
        
        -- Business Flags
        [IsPrimary]             BIT NOT NULL DEFAULT 0,
        [IsEmergency]           BIT NOT NULL DEFAULT 0,       -- Emergency Contact Flag
        [IsVerified]            BIT NOT NULL DEFAULT 0,
        
        -- Audit Metadata
        [IsActive]              BIT NOT NULL DEFAULT 1,
        [CreatedBy]             INT NOT NULL,
        [CreatedDate]           DATETIME NOT NULL DEFAULT GETDATE(),
        [ModifiedBy]            INT NULL,
        [ModifiedDate]          DATETIME NULL,
        [IsDeleted]             BIT NOT NULL DEFAULT 0,
        [DeletedBy]             INT NULL,
        [DeletedDate]           DATETIME NULL,

        -- Foreign Key Constraints
        CONSTRAINT [FK_UserContacts_User] 
            FOREIGN KEY ([UserId]) REFERENCES [dbo].[User]([Id]) ON DELETE CASCADE,
            
        CONSTRAINT [FK_UserContacts_ContactType] 
            FOREIGN KEY ([ContactTypeId]) REFERENCES [dbo].[ConfigParameters]([ParameterID]),

        CONSTRAINT [FK_UserContacts_RelationshipType] 
            FOREIGN KEY ([RelationshipTypeId]) REFERENCES [dbo].[ConfigParameters]([ParameterID])
    );
END;
GO

-- -----------------------------------------------------------------------------------
-- 6. PERFORMANCE INDEXES
-- -----------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_UserAddresses_User_Locations' AND object_id = OBJECT_ID(N'[dbo].[UserAddresses]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_UserAddresses_User_Locations] 
    ON [dbo].[UserAddresses] ([UserId], [AddressTypeId], [CountryId], [StateId], [CityId])
    WHERE [IsDeleted] = 0 AND [IsActive] = 1;
END;
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_UserContacts_User_Relationship' AND object_id = OBJECT_ID(N'[dbo].[UserContacts]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_UserContacts_User_Relationship] 
    ON [dbo].[UserContacts] ([UserId], [RelationshipTypeId], [ContactTypeId], [IsEmergency])
    WHERE [IsDeleted] = 0 AND [IsActive] = 1;
END;
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = N'IX_UserContacts_ContactValue' AND object_id = OBJECT_ID(N'[dbo].[UserContacts]'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_UserContacts_ContactValue] 
    ON [dbo].[UserContacts] ([ContactValue])
    WHERE [IsDeleted] = 0;
END;
GO
