// ignore_for_file: dangling_library_doc_comments
/// ============================================================================
/// DQMS Admin Master DTO Models
/// Maps to C# DqmsAdminModels.cs in Shared Core
/// ============================================================================

class AreaDto {
  final int id;
  final String areaCode;
  final int organizationId;
  final int locationId;
  final String areaName;
  final String? description;
  final bool isActive;

  AreaDto({
    required this.id,
    required this.areaCode,
    required this.organizationId,
    required this.locationId,
    required this.areaName,
    this.description,
    required this.isActive,
  });

  factory AreaDto.fromJson(Map<String, dynamic> json) {
    return AreaDto(
      id: json['id'] ?? 0,
      areaCode: json['areaCode'] ?? '',
      organizationId: json['organizationId'] ?? 0,
      locationId: json['locationId'] ?? 0,
      areaName: json['areaName'] ?? '',
      description: json['description'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'areaCode': areaCode,
        'organizationId': organizationId,
        'locationId': locationId,
        'areaName': areaName,
        'description': description,
        'isActive': isActive,
      };
}

class ProcessDto {
  final int id;
  final String processCode;
  final int organizationId;
  final String processName;
  final String prefix;
  final int targetTATMinutes;
  final bool allowSubTokens;
  final bool isActive;

  ProcessDto({
    required this.id,
    required this.processCode,
    required this.organizationId,
    required this.processName,
    required this.prefix,
    required this.targetTATMinutes,
    required this.allowSubTokens,
    required this.isActive,
  });

  factory ProcessDto.fromJson(Map<String, dynamic> json) {
    return ProcessDto(
      id: json['id'] ?? 0,
      processCode: json['processCode'] ?? '',
      organizationId: json['organizationId'] ?? 0,
      processName: json['processName'] ?? '',
      prefix: json['prefix'] ?? 'A',
      targetTATMinutes: json['targetTATMinutes'] ?? 15,
      allowSubTokens: json['allowSubTokens'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'processCode': processCode,
        'organizationId': organizationId,
        'processName': processName,
        'prefix': prefix,
        'targetTATMinutes': targetTATMinutes,
        'allowSubTokens': allowSubTokens,
        'isActive': isActive,
      };
}

class CounterDto {
  final int id;
  final String counterCode;
  final int organizationId;
  final int locationId;
  final int areaId;
  final String counterNumber;
  final String counterName;
  final int currentStatus;
  final bool isActive;

  CounterDto({
    required this.id,
    required this.counterCode,
    required this.organizationId,
    required this.locationId,
    required this.areaId,
    required this.counterNumber,
    required this.counterName,
    required this.currentStatus,
    required this.isActive,
  });

  factory CounterDto.fromJson(Map<String, dynamic> json) {
    return CounterDto(
      id: json['id'] ?? 0,
      counterCode: json['counterCode'] ?? '',
      organizationId: json['organizationId'] ?? 0,
      locationId: json['locationId'] ?? 0,
      areaId: json['areaId'] ?? 0,
      counterNumber: json['counterNumber'] ?? '',
      counterName: json['counterName'] ?? '',
      currentStatus: json['currentStatus'] ?? 20001,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'counterCode': counterCode,
        'organizationId': organizationId,
        'locationId': locationId,
        'areaId': areaId,
        'counterNumber': counterNumber,
        'counterName': counterName,
        'currentStatus': currentStatus,
        'isActive': isActive,
      };
}

class DisplayTemplateDto {
  final int id;
  final int organizationId;
  final String templateName;
  final int templateType;
  final String? layoutConfigJson;
  final bool isDefault;
  final bool isActive;

  DisplayTemplateDto({
    required this.id,
    required this.organizationId,
    required this.templateName,
    required this.templateType,
    this.layoutConfigJson,
    required this.isDefault,
    required this.isActive,
  });

  factory DisplayTemplateDto.fromJson(Map<String, dynamic> json) {
    return DisplayTemplateDto(
      id: json['id'] ?? 0,
      organizationId: json['organizationId'] ?? 0,
      templateName: json['templateName'] ?? '',
      templateType: json['templateType'] ?? 21001,
      layoutConfigJson: json['layoutConfigJson'],
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'organizationId': organizationId,
        'templateName': templateName,
        'templateType': templateType,
        'layoutConfigJson': layoutConfigJson,
        'isDefault': isDefault,
        'isActive': isActive,
      };
}
