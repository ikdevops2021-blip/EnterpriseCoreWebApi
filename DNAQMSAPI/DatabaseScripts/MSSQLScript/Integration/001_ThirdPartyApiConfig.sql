IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ThirdPartyApiConfig]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[ThirdPartyApiConfig](
        [Id] [int] IDENTITY(1,1) NOT NULL,
        [Name] [nvarchar](255) NOT NULL,
        [TenantId] [int] NULL,
        [BaseUrl] [nvarchar](1000) NOT NULL,
        [AuthType] [int] NOT NULL DEFAULT ((0)),
        [ApiKey] [nvarchar](1000) NULL,
        [Username] [nvarchar](255) NULL,
        [Password] [nvarchar](1000) NULL,
        [ClientId] [nvarchar](500) NULL,
        [ClientSecret] [nvarchar](1000) NULL,
        [TokenEndpoint] [nvarchar](1000) NULL,
        [Scope] [nvarchar](500) NULL,
        [AccessToken] [nvarchar](max) NULL,
        [RefreshToken] [nvarchar](max) NULL,
        [TokenExpiry] [datetime] NULL,
        [IsGlobal] [bit] NOT NULL DEFAULT ((0)),
        [IsActive] [bit] NOT NULL DEFAULT ((1)),
        [CreatedBy] [int] NOT NULL,
        [CreatedDate] [datetime] NOT NULL DEFAULT (getutcdate()),
        [ModifiedBy] [int] NOT NULL,
        [ModifiedDate] [datetime] NOT NULL DEFAULT (getutcdate()),
        [IsDeleted] [bit] NULL DEFAULT ((0)),
        [DeletedBy] [int] NULL,
        [DeletedDate] [datetime] NULL,
        CONSTRAINT [PK_ThirdPartyApiConfig] PRIMARY KEY CLUSTERED ([Id] ASC)
    )
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[IntegrationLogs]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[IntegrationLogs](
        [Id] [int] IDENTITY(1,1) NOT NULL,
        [ConfigId] [int] NOT NULL,
        [Endpoint] [nvarchar](1000) NOT NULL,
        [HttpMethod] [nvarchar](10) NOT NULL,
        [RequestBody] [nvarchar](max) NULL,
        [ResponseBody] [nvarchar](max) NULL,
        [StatusCode] [int] NOT NULL,
        [DurationMs] [int] NOT NULL,
        [ErrorMessage] [nvarchar](max) NULL,
        [CreatedBy] [int] NOT NULL,
        [CreatedDate] [datetime] NOT NULL DEFAULT (getutcdate()),
        CONSTRAINT [PK_IntegrationLogs] PRIMARY KEY CLUSTERED ([Id] ASC)
    )
END
GO
