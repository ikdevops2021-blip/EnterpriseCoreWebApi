CREATE TABLE EmailQueue (
    QueueId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    CenterId INT NOT NULL,
    RecipientTo NVARCHAR(MAX) NOT NULL,
    RecipientCc NVARCHAR(MAX) NULL,
    RecipientBcc NVARCHAR(MAX) NULL,
    Subject NVARCHAR(500) NULL,
    Body NVARCHAR(MAX) NULL,
    IsHtml BIT DEFAULT 1,
    Status SMALLINT DEFAULT 0, -- 0:Pending, 1:Sent, 2:Failed
    ErrorDescription NVARCHAR(MAX) NULL,
    Priority INT DEFAULT 0,
    RetryCount INT DEFAULT 0,
    MaxRetryCount INT DEFAULT 3,

    CreatedBy INT NOT NULL,
    CreateDate DATETIME DEFAULT GETDATE(),
    ModifiedBy INT NOT NULL,
    ModifyDate DATETIME DEFAULT GETDATE(),
    IsDeleted BIT DEFAULT 0,
    DeletedBy INT NULL,
    DeletedDate DATETIME NULL
);

CREATE INDEX IX_EmailQueue_Status_Priority 
ON EmailQueue(Status, Priority DESC, CreateDate ASC) 
WHERE IsDeleted = 0 AND Status = 0;
