CREATE TABLE ConfigCategory (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryCode NVARCHAR(50) NOT NULL,
    CategoryName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    Priority INT NOT NULL DEFAULT 1,
    Active BIT NOT NULL DEFAULT 1,
    AllowModify BIT NOT NULL DEFAULT 0,
    ParentCategoryID INT DEFAULT NULL,
    CreatedBy INT NOT NULL,
    CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ModifiedBy INT NOT NULL,
    ModifiedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IsDeleted BIT NULL DEFAULT 0,
    DeletedBy INT NULL,
    DeletedDate DATETIME NULL,
    CategoryExternalID NVARCHAR(20) NULL,
    CategoryExternalName NVARCHAR(200) NULL,
    CategoryExternalCode NVARCHAR(20) NULL,
    CategoryColor NVARCHAR(20) NULL,
    CategoryIcon NVARCHAR(200) NULL,
    CategoryImage NVARCHAR(200) NULL,
    Attribute1 NVARCHAR(100) NULL,
    Attribute2 NVARCHAR(100) NULL,
    Attribute3 NVARCHAR(100) NULL,
    CONSTRAINT uq_category_name UNIQUE (CategoryName),
    CONSTRAINT fk_category_parent FOREIGN KEY (ParentCategoryID) REFERENCES ConfigCategory(CategoryID)
);
GO

CREATE INDEX idx_category_name ON ConfigCategory(CategoryName);
GO

CREATE TABLE ConfigParameters (
    ParameterID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID INT NOT NULL,
    ParameterCode NVARCHAR(50) NOT NULL,
    ParameterName NVARCHAR(200) NOT NULL,
    Priority TINYINT NOT NULL DEFAULT 1,
    IsDefault BIT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    ParameterExternalID NVARCHAR(20) NULL,
    ParameterExternalName NVARCHAR(200) NULL,
    ParameterExternalCode NVARCHAR(20) NULL,
    ParameterColor NVARCHAR(20) NULL,
    ParameterIcon NVARCHAR(200) NULL,
    ParameterImage NVARCHAR(200) NULL,
    Attribute1 NVARCHAR(100) NULL,
    Attribute2 NVARCHAR(100) NULL,
    Attribute3 NVARCHAR(100) NULL,
    CreatedBy INT NOT NULL,
    CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ModifiedBy INT NOT NULL,
    ModifiedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IsDeleted BIT NULL DEFAULT 0,
    DeletedBy INT NULL,
    DeletedDate DATETIME NULL,
    CONSTRAINT uq_param_category_code UNIQUE (CategoryID, ParameterCode),
    CONSTRAINT uq_param_category_name UNIQUE (CategoryID, ParameterName),
    CONSTRAINT fk_param_category FOREIGN KEY (CategoryID) REFERENCES ConfigCategory(CategoryID) ON DELETE CASCADE
);
GO

CREATE INDEX idx_param_category ON ConfigParameters(CategoryID);
GO

CREATE TABLE SystemConfigurationKeys (
    SystemConfigurationKeyID INT IDENTITY(1,1) PRIMARY KEY,
    
    [Key] NVARCHAR(250) NOT NULL UNIQUE,                                      
    Value NVARCHAR(MAX) NOT NULL,                                           
    Description NVARCHAR(MAX),                                              
    
    AcceptedValues NVARCHAR(MAX),                                           
    DataTypeID INT NOT NULL,
    AllowEdit BIT DEFAULT 0,                                       
    
    Active BIT DEFAULT 1,                                           
    
    CreatedBy INT NOT NULL,
    CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ModifiedBy INT NOT NULL,
    ModifiedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IsDeleted BIT NULL DEFAULT 0,
    DeletedBy INT NULL,
    DeletedDate DATETIME NULL,
    CONSTRAINT fk_sysconfig_datatype FOREIGN KEY (DataTypeID) REFERENCES ConfigParameters(ParameterID)
);
GO

CREATE INDEX idx_sysconfig_key ON SystemConfigurationKeys([Key]);
CREATE INDEX idx_sysconfig_active ON SystemConfigurationKeys(Active, IsDeleted);
CREATE INDEX idx_sysconfig_datatype ON SystemConfigurationKeys(DataTypeID);
GO
