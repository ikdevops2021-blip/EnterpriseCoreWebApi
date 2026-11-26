using System;
using System.Collections.Generic;

namespace AntiGravity.Enterprise.Shared.Core.Models.DQMS;

public class OrganizationDataResidencyDto
{
    public int Id { get; set; }
    public int OrganizationId { get; set; }
    public string DataRegion { get; set; } = "eu-central-1"; // 'eu-central-1', 'me-central-1', 'us-east-1', 'ap-south-1'
    public string Jurisdiction { get; set; } = "GDPR"; // 'GDPR', 'NESA', 'PDPL', 'HIPAA', 'DPDP'
    public string? KmsKeyArn { get; set; }
    public int DataRetentionDays { get; set; } = 90;
    public bool AutoAnonymizeOnComplete { get; set; } = false;
    public bool EnableBlindIndexing { get; set; } = true;
    public bool AllowCrossBorderDiagnostics { get; set; } = false;
    public DateTime CreatedDate { get; set; }
    public DateTime ModifiedDate { get; set; }
}

public class UpsertDataResidencyRequest
{
    public int OrganizationId { get; set; }
    public string DataRegion { get; set; } = "eu-central-1";
    public string Jurisdiction { get; set; } = "GDPR";
    public string? KmsKeyArn { get; set; }
    public int DataRetentionDays { get; set; } = 90;
    public bool AutoAnonymizeOnComplete { get; set; } = false;
    public bool EnableBlindIndexing { get; set; } = true;
    public bool AllowCrossBorderDiagnostics { get; set; } = false;
}

public class GdprRightToBeForgottenRequest
{
    public int OrganizationId { get; set; }
    public string CustomerPhoneNumber { get; set; } = string.Empty;
    public string? NationalId { get; set; }
    public string Reason { get; set; } = "Customer GDPR Article 17 Erasure Request";
}

public class GdprRightToBeForgottenResultDto
{
    public bool Success { get; set; }
    public int OrganizationId { get; set; }
    public int AffectedRecordsCount { get; set; }
    public string Message { get; set; } = string.Empty;
    public DateTime ExecutionTimestamp { get; set; } = DateTime.UtcNow;
}

public class CustomerDataExportDto
{
    public int OrganizationId { get; set; }
    public string CustomerPhoneNumber { get; set; } = string.Empty;
    public DateTime ExportGeneratedAt { get; set; } = DateTime.UtcNow;
    public List<CustomerTokenVisitExportItem> Visits { get; set; } = new();
}

public class CustomerTokenVisitExportItem
{
    public int TokenId { get; set; }
    public string TokenNumber { get; set; } = string.Empty;
    public string? ProcessName { get; set; }
    public string? CounterName { get; set; }
    public int TokenStatus { get; set; }
    public DateTime IssuedTime { get; set; }
    public DateTime? CalledTime { get; set; }
    public DateTime? CompletedTime { get; set; }
    public int WaitDurationSeconds { get; set; }
    public int ServiceDurationSeconds { get; set; }
}

public class GdprAuditLogDto
{
    public int Id { get; set; }
    public int OrganizationId { get; set; }
    public string ActionType { get; set; } = string.Empty;
    public int RecordsAffected { get; set; }
    public int RequestedByUserId { get; set; }
    public string? AuditReason { get; set; }
    public DateTime ExecutionTime { get; set; }
}

public class TriggerRetentionPurgeRequest
{
    public int OrganizationId { get; set; }
}

public class RetentionPurgeResultDto
{
    public int OrganizationId { get; set; }
    public int PurgedRecordsCount { get; set; }
    public string Message { get; set; } = string.Empty;
    public DateTime ExecutedAt { get; set; } = DateTime.UtcNow;
}
