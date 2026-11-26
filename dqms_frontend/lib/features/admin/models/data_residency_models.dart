// ============================================================================
// Data Residency & GDPR Domain Models
// ============================================================================

class OrganizationDataResidency {
  final int id;
  final int organizationId;
  final String dataRegion;
  final String jurisdiction;
  final String? kmsKeyArn;
  final int dataRetentionDays;
  final bool autoAnonymizeOnComplete;
  final bool enableBlindIndexing;
  final bool allowCrossBorderDiagnostics;
  final DateTime? createdDate;
  final DateTime? modifiedDate;

  const OrganizationDataResidency({
    required this.id,
    required this.organizationId,
    required this.dataRegion,
    required this.jurisdiction,
    this.kmsKeyArn,
    required this.dataRetentionDays,
    required this.autoAnonymizeOnComplete,
    required this.enableBlindIndexing,
    required this.allowCrossBorderDiagnostics,
    this.createdDate,
    this.modifiedDate,
  });

  factory OrganizationDataResidency.fromJson(Map<String, dynamic> json) {
    return OrganizationDataResidency(
      id: json['id'] ?? json['Id'] ?? 0,
      organizationId: json['organizationId'] ?? json['OrganizationId'] ?? 1,
      dataRegion: json['dataRegion'] ?? json['DataRegion'] ?? 'eu-central-1',
      jurisdiction: json['jurisdiction'] ?? json['Jurisdiction'] ?? 'GDPR',
      kmsKeyArn: json['kmsKeyArn'] ?? json['KmsKeyArn'],
      dataRetentionDays: json['dataRetentionDays'] ?? json['DataRetentionDays'] ?? 90,
      autoAnonymizeOnComplete: json['autoAnonymizeOnComplete'] ?? json['AutoAnonymizeOnComplete'] ?? false,
      enableBlindIndexing: json['enableBlindIndexing'] ?? json['EnableBlindIndexing'] ?? true,
      allowCrossBorderDiagnostics: json['allowCrossBorderDiagnostics'] ?? json['AllowCrossBorderDiagnostics'] ?? false,
      createdDate: json['createdDate'] != null ? DateTime.tryParse(json['createdDate'].toString()) : null,
      modifiedDate: json['modifiedDate'] != null ? DateTime.tryParse(json['modifiedDate'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'organizationId': organizationId,
    'dataRegion': dataRegion,
    'jurisdiction': jurisdiction,
    'kmsKeyArn': kmsKeyArn,
    'dataRetentionDays': dataRetentionDays,
    'autoAnonymizeOnComplete': autoAnonymizeOnComplete,
    'enableBlindIndexing': enableBlindIndexing,
    'allowCrossBorderDiagnostics': allowCrossBorderDiagnostics,
  };
}

class GdprRightToBeForgottenResult {
  final bool success;
  final int organizationId;
  final int affectedRecordsCount;
  final String message;
  final DateTime executionTimestamp;

  const GdprRightToBeForgottenResult({
    required this.success,
    required this.organizationId,
    required this.affectedRecordsCount,
    required this.message,
    required this.executionTimestamp,
  });

  factory GdprRightToBeForgottenResult.fromJson(Map<String, dynamic> json) {
    return GdprRightToBeForgottenResult(
      success: json['success'] ?? json['Success'] ?? false,
      organizationId: json['organizationId'] ?? json['OrganizationId'] ?? 0,
      affectedRecordsCount: json['affectedRecordsCount'] ?? json['AffectedRecordsCount'] ?? 0,
      message: json['message'] ?? json['Message'] ?? '',
      executionTimestamp: json['executionTimestamp'] != null 
          ? DateTime.tryParse(json['executionTimestamp'].toString()) ?? DateTime.now() 
          : DateTime.now(),
    );
  }
}

class CustomerDataExport {
  final int organizationId;
  final String customerPhoneNumber;
  final DateTime exportGeneratedAt;
  final List<CustomerVisitExportItem> visits;

  const CustomerDataExport({
    required this.organizationId,
    required this.customerPhoneNumber,
    required this.exportGeneratedAt,
    required this.visits,
  });

  factory CustomerDataExport.fromJson(Map<String, dynamic> json) {
    final visitsRaw = json['visits'] ?? json['Visits'] as List? ?? [];
    return CustomerDataExport(
      organizationId: json['organizationId'] ?? json['OrganizationId'] ?? 0,
      customerPhoneNumber: json['customerPhoneNumber'] ?? json['CustomerPhoneNumber'] ?? '',
      exportGeneratedAt: json['exportGeneratedAt'] != null
          ? DateTime.tryParse(json['exportGeneratedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      visits: (visitsRaw as List)
          .map<CustomerVisitExportItem>((v) => CustomerVisitExportItem.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList(),
    );
  }
}

class CustomerVisitExportItem {
  final int tokenId;
  final String tokenNumber;
  final String? processName;
  final String? counterName;
  final int tokenStatus;
  final DateTime? issuedTime;
  final DateTime? completedTime;
  final int waitDurationSeconds;
  final int serviceDurationSeconds;

  const CustomerVisitExportItem({
    required this.tokenId,
    required this.tokenNumber,
    this.processName,
    this.counterName,
    required this.tokenStatus,
    this.issuedTime,
    this.completedTime,
    required this.waitDurationSeconds,
    required this.serviceDurationSeconds,
  });

  factory CustomerVisitExportItem.fromJson(Map<String, dynamic> json) {
    return CustomerVisitExportItem(
      tokenId: json['tokenId'] ?? json['TokenId'] ?? 0,
      tokenNumber: json['tokenNumber'] ?? json['TokenNumber'] ?? '',
      processName: json['processName'] ?? json['ProcessName'],
      counterName: json['counterName'] ?? json['CounterName'],
      tokenStatus: json['tokenStatus'] ?? json['TokenStatus'] ?? 0,
      issuedTime: json['issuedTime'] != null ? DateTime.tryParse(json['issuedTime'].toString()) : null,
      completedTime: json['completedTime'] != null ? DateTime.tryParse(json['completedTime'].toString()) : null,
      waitDurationSeconds: json['waitDurationSeconds'] ?? json['WaitDurationSeconds'] ?? 0,
      serviceDurationSeconds: json['serviceDurationSeconds'] ?? json['ServiceDurationSeconds'] ?? 0,
    );
  }
}

class GdprAuditLog {
  final int id;
  final int organizationId;
  final String actionType;
  final int recordsAffected;
  final int requestedByUserId;
  final String? auditReason;
  final DateTime executionTime;

  const GdprAuditLog({
    required this.id,
    required this.organizationId,
    required this.actionType,
    required this.recordsAffected,
    required this.requestedByUserId,
    this.auditReason,
    required this.executionTime,
  });

  factory GdprAuditLog.fromJson(Map<String, dynamic> json) {
    return GdprAuditLog(
      id: json['id'] ?? json['Id'] ?? 0,
      organizationId: json['organizationId'] ?? json['OrganizationId'] ?? 0,
      actionType: json['actionType'] ?? json['ActionType'] ?? '',
      recordsAffected: json['recordsAffected'] ?? json['RecordsAffected'] ?? 0,
      requestedByUserId: json['requestedByUserId'] ?? json['RequestedByUserId'] ?? 1,
      auditReason: json['auditReason'] ?? json['AuditReason'],
      executionTime: json['executionTime'] != null
          ? DateTime.tryParse(json['executionTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
