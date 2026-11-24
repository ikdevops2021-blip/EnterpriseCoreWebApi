class EdgeNodeRegistration {
  final int id;
  final String nodeId;
  final String nodeName;
  final int organizationId;
  final int locationId;
  final String? macAddress;
  final String? ipAddress;
  final String? softwareVersion;
  final bool isActive;
  final DateTime? lastHeartbeatAt;
  final DateTime? lastSyncAt;
  final int pendingJournalCount;
  final DateTime createdDate;
  final DateTime modifiedDate;

  EdgeNodeRegistration({
    required this.id,
    required this.nodeId,
    required this.nodeName,
    required this.organizationId,
    required this.locationId,
    this.macAddress,
    this.ipAddress,
    this.softwareVersion = '1.0.0',
    this.isActive = true,
    this.lastHeartbeatAt,
    this.lastSyncAt,
    this.pendingJournalCount = 0,
    DateTime? createdDate,
    DateTime? modifiedDate,
  })  : createdDate = createdDate ?? DateTime.now(),
        modifiedDate = modifiedDate ?? DateTime.now();

  factory EdgeNodeRegistration.fromJson(Map<String, dynamic> json) {
    return EdgeNodeRegistration(
      id: json['id'] ?? json['Id'] ?? 0,
      nodeId: json['nodeId'] ?? json['NodeId'] ?? '',
      nodeName: json['nodeName'] ?? json['NodeName'] ?? '',
      organizationId: json['organizationId'] ?? json['OrganizationId'] ?? 1,
      locationId: json['locationId'] ?? json['LocationId'] ?? 1,
      macAddress: json['macAddress'] ?? json['MacAddress'],
      ipAddress: json['ipAddress'] ?? json['IpAddress'],
      softwareVersion: json['softwareVersion'] ?? json['SoftwareVersion'] ?? '1.0.0',
      isActive: json['isActive'] ?? json['IsActive'] ?? true,
      lastHeartbeatAt: json['lastHeartbeatAt'] != null || json['LastHeartbeatAt'] != null
          ? DateTime.tryParse(json['lastHeartbeatAt'] ?? json['LastHeartbeatAt'])
          : null,
      lastSyncAt: json['lastSyncAt'] != null || json['LastSyncAt'] != null
          ? DateTime.tryParse(json['lastSyncAt'] ?? json['LastSyncAt'])
          : null,
      pendingJournalCount: json['pendingJournalCount'] ?? json['PendingJournalCount'] ?? 0,
      createdDate: json['createdDate'] != null || json['CreatedDate'] != null
          ? DateTime.tryParse(json['createdDate'] ?? json['CreatedDate'])
          : null,
      modifiedDate: json['modifiedDate'] != null || json['ModifiedDate'] != null
          ? DateTime.tryParse(json['modifiedDate'] ?? json['ModifiedDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nodeId': nodeId,
        'nodeName': nodeName,
        'organizationId': organizationId,
        'locationId': locationId,
        'macAddress': macAddress,
        'ipAddress': ipAddress,
        'softwareVersion': softwareVersion,
        'isActive': isActive,
      };

  bool get isOnline {
    if (lastHeartbeatAt == null) return false;
    final diff = DateTime.now().toUtc().difference(lastHeartbeatAt!.toUtc());
    return diff.inSeconds <= 60;
  }
}

class EdgeSyncAuditLog {
  final int id;
  final String batchId;
  final String nodeId;
  final int organizationId;
  final int locationId;
  final int recordsCount;
  final int conflictsResolved;
  final int durationMs;
  final String status;
  final String? errorMessage;
  final DateTime createdDate;

  EdgeSyncAuditLog({
    required this.id,
    required this.batchId,
    required this.nodeId,
    required this.organizationId,
    required this.locationId,
    this.recordsCount = 0,
    this.conflictsResolved = 0,
    this.durationMs = 0,
    this.status = 'Success',
    this.errorMessage,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now();

  factory EdgeSyncAuditLog.fromJson(Map<String, dynamic> json) {
    return EdgeSyncAuditLog(
      id: json['id'] ?? json['Id'] ?? 0,
      batchId: json['batchId'] ?? json['BatchId'] ?? '',
      nodeId: json['nodeId'] ?? json['NodeId'] ?? '',
      organizationId: json['organizationId'] ?? json['OrganizationId'] ?? 1,
      locationId: json['locationId'] ?? json['LocationId'] ?? 1,
      recordsCount: json['recordsCount'] ?? json['RecordsCount'] ?? 0,
      conflictsResolved: json['conflictsResolved'] ?? json['ConflictsResolved'] ?? 0,
      durationMs: json['durationMs'] ?? json['DurationMs'] ?? 0,
      status: json['status'] ?? json['Status'] ?? 'Success',
      errorMessage: json['errorMessage'] ?? json['ErrorMessage'],
      createdDate: json['createdDate'] != null || json['CreatedDate'] != null
          ? DateTime.tryParse(json['createdDate'] ?? json['CreatedDate'])
          : null,
    );
  }
}

class EdgeSyncResult {
  final String batchId;
  final int recordsIngested;
  final int conflictsResolved;
  final int durationMs;
  final String status;
  final String? errorMessage;

  EdgeSyncResult({
    required this.batchId,
    required this.recordsIngested,
    required this.conflictsResolved,
    required this.durationMs,
    required this.status,
    this.errorMessage,
  });

  factory EdgeSyncResult.fromJson(Map<String, dynamic> json) {
    return EdgeSyncResult(
      batchId: json['batchId'] ?? json['BatchId'] ?? '',
      recordsIngested: json['recordsIngested'] ?? json['RecordsIngested'] ?? 0,
      conflictsResolved: json['conflictsResolved'] ?? json['ConflictsResolved'] ?? 0,
      durationMs: json['durationMs'] ?? json['DurationMs'] ?? 0,
      status: json['status'] ?? json['Status'] ?? 'Success',
      errorMessage: json['errorMessage'] ?? json['ErrorMessage'],
    );
  }
}
