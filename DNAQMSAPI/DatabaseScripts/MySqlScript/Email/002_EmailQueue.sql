CREATE TABLE EmailQueue (
    QueueId CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    OrganizationId INT NOT NULL,
    RecipientTo TEXT NOT NULL,
    RecipientCc TEXT NULL,
    RecipientBcc TEXT NULL,
    Subject VARCHAR(500) NULL,
    Body TEXT NULL,
    IsHtml TINYINT(1) DEFAULT 1,
    Status SMALLINT DEFAULT 0, -- 0:Pending, 1:Sent, 2:Failed
    ErrorDescription TEXT NULL,
    Priority INT DEFAULT 0,
    RetryCount INT DEFAULT 0,
    MaxRetryCount INT DEFAULT 3,

    CreatedBy INT NOT NULL,
    CreateDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    ModifiedBy INT NOT NULL,
    ModifyDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsDeleted TINYINT(1) DEFAULT 0,
    DeletedBy INT NULL,
    DeletedDate DATETIME NULL
);

CREATE INDEX IX_EmailQueue_Status_Priority 
ON EmailQueue(Status, Priority DESC, CreateDate ASC);
