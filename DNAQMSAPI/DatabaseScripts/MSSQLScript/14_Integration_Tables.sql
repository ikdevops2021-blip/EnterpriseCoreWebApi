-- MSSQL Table Definitions for Integration Module

-- 1. API Integrations
CREATE TABLE [dbo].[APIIntegrations](
	[IntegrationID] [int] IDENTITY(1,1) NOT NULL,
	[TenantId] [int] NOT NULL,
	[ProviderName] [varchar](50) NOT NULL,
	[Description] [varchar](255) NULL,
	[BaseUrl] [varchar](255) NOT NULL,
	[Active] [bit] NULL DEFAULT ((1)),
	[AuditLevel] [int] NOT NULL DEFAULT ((1)),
	[AuthType] [int] NOT NULL DEFAULT ((1)),
	[ApiKey] [varchar](max) NULL,
	[ApiUsername] [varchar](100) NULL,
	[ApiPassword] [varchar](max) NULL,
	[TokenUrl] [varchar](max) NULL,
	[ClientID] [varchar](max) NULL,
	[CurrentToken] [varchar](max) NULL,
	[ClientSecret] [varchar](max) NULL,
	[TokenExpiration] [datetime] NULL,
	[HMACSecretKey] [varchar](max) NULL,
	[HMACHeaderName] [varchar](max) NULL,
	[RequiresCertificate] [bit] NULL DEFAULT ((0)),
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NULL DEFAULT (getdate()),
	[ModifiedBy] [int] NOT NULL,
	[ModifiedDate] [datetime] NULL DEFAULT (getdate()),
	[IsDeleted] [bit] NULL DEFAULT ((0)),
	[DeletedBy] [int] NULL,
	[DeletedDate] [datetime] NULL,
 CONSTRAINT [PK_APIIntegrations] PRIMARY KEY CLUSTERED 
(
	[IntegrationID] ASC
)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0: No Logging, 1: Log Errors Only (StatusCode != 200), 2: Log Everything (All Requests/Responses)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'APIIntegrations', @level2type=N'COLUMN',@level2name=N'AuditLevel';
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0:ApiKey, 1:Bearer, 2:Basic, 3:OAuth2, 4:HMAC_Signing, 5:Anonymous' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'APIIntegrations', @level2type=N'COLUMN',@level2name=N'AuthType';
GO


-- 2. API Endpoints
CREATE TABLE [dbo].[ApiEndpoints](
	[EndpointID] [int] IDENTITY(1,1) NOT NULL,
	[IntegrationID] [int] NULL,
	[ActionName] [nvarchar](50) NOT NULL,
	[RelativePath] [nvarchar](255) NOT NULL,
	[HttpMethod] [nvarchar](10) NOT NULL,
	[Description] [nvarchar](255) NULL,
	[Active] [bit] NULL DEFAULT ((1)),
	[SampleAPIRequest] [nvarchar](max) NULL,
	[SampleAPIResponse] [nvarchar](max) NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NULL DEFAULT (getdate()),
	[ModifiedBy] [int] NOT NULL,
	[ModifiedDate] [datetime] NULL DEFAULT (getdate()),
	[IsDeleted] [bit] NULL DEFAULT ((0)),
	[DeletedBy] [int] NULL,
	[DeletedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[EndpointID] ASC
)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO

ALTER TABLE [dbo].[ApiEndpoints]  WITH CHECK ADD  CONSTRAINT [FK_ApiEndpoints_Integration] FOREIGN KEY([IntegrationID])
REFERENCES [dbo].[APIIntegrations] ([IntegrationID]);
GO

ALTER TABLE [dbo].[ApiEndpoints] CHECK CONSTRAINT [FK_ApiEndpoints_Integration];
GO


-- 3. API Audit Logs
CREATE TABLE [dbo].[APIAuditLogs](
	[AuditID] [bigint] IDENTITY(1,1) NOT NULL,
	[IntegrationID] [int] NOT NULL,
	[ActionName] [nvarchar](50) NOT NULL,
	[RequestUrl] [nvarchar](max) NOT NULL,
	[HttpMethod] [nvarchar](10) NOT NULL,
	[RequestBody] [nvarchar](max) NULL,
	[ResponseBody] [nvarchar](max) NULL,
	[StatusCode] [int] NULL,
	[DurationMs] [int] NOT NULL,
	[ErrorMessage] [nvarchar](max) NULL,
	[CreatedDate] [datetime] NULL DEFAULT (getdate()),
	[CreatedBy] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[AuditID] ASC
)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
