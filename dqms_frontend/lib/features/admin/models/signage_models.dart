class SignageCampaign {
  final int id;
  final int organizationId;
  final String campaignName;
  final int campaignType; // 1=Promotional, 2=Health Advisory, 3=Corporate
  final int priority;
  final DateTime startDate;
  final DateTime endDate;
  final String? dailyStartTime;
  final String? dailyEndTime;
  final String daysOfWeek;
  final int? locationId;
  final int? areaId;
  final bool isActive;
  final List<SignageMediaItem> mediaItems;

  const SignageCampaign({
    required this.id,
    required this.organizationId,
    required this.campaignName,
    this.campaignType = 1,
    this.priority = 5,
    required this.startDate,
    required this.endDate,
    this.dailyStartTime,
    this.dailyEndTime,
    this.daysOfWeek = '1,2,3,4,5,6,7',
    this.locationId,
    this.areaId,
    this.isActive = true,
    this.mediaItems = const [],
  });

  factory SignageCampaign.fromJson(Map<String, dynamic> json) {
    return SignageCampaign(
      id: json['id'] ?? json['Id'] ?? 0,
      organizationId: json['organizationId'] ?? json['OrganizationId'] ?? 1,
      campaignName: json['campaignName'] ?? json['CampaignName'] ?? '',
      campaignType: json['campaignType'] ?? json['CampaignType'] ?? 1,
      priority: json['priority'] ?? json['Priority'] ?? 5,
      startDate: DateTime.tryParse(json['startDate'] ?? json['StartDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? json['EndDate'] ?? '') ?? DateTime.now().add(const Duration(days: 30)),
      dailyStartTime: json['dailyStartTime'] ?? json['DailyStartTime'],
      dailyEndTime: json['dailyEndTime'] ?? json['DailyEndTime'],
      daysOfWeek: json['daysOfWeek'] ?? json['DaysOfWeek'] ?? '1,2,3,4,5,6,7',
      locationId: json['locationId'] ?? json['LocationId'],
      areaId: json['areaId'] ?? json['AreaId'],
      isActive: json['isActive'] ?? json['IsActive'] ?? true,
      mediaItems: ((json['mediaItems'] ?? json['MediaItems']) as List<dynamic>?)
              ?.map((e) => SignageMediaItem.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const <SignageMediaItem>[],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'organizationId': organizationId,
        'campaignName': campaignName,
        'campaignType': campaignType,
        'priority': priority,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'dailyStartTime': dailyStartTime,
        'dailyEndTime': dailyEndTime,
        'daysOfWeek': daysOfWeek,
        'locationId': locationId,
        'areaId': areaId,
        'isActive': isActive,
        'mediaItems': mediaItems.map((e) => e.toJson()).toList(),
      };
}

class SignageMediaItem {
  final int id;
  final int campaignId;
  final int mediaType; // 1=Image, 2=Video, 3=Html5/Url, 4=TickerText
  final String mediaUrl;
  final String? localCachePath;
  final String title;
  final int durationSeconds;
  final int displayOrder;
  final bool muteAudio;
  final bool isActive;

  const SignageMediaItem({
    required this.id,
    required this.campaignId,
    this.mediaType = 1,
    required this.mediaUrl,
    this.localCachePath,
    required this.title,
    this.durationSeconds = 15,
    this.displayOrder = 1,
    this.muteAudio = true,
    this.isActive = true,
  });

  factory SignageMediaItem.fromJson(Map<String, dynamic> json) {
    return SignageMediaItem(
      id: json['id'] ?? json['Id'] ?? 0,
      campaignId: json['campaignId'] ?? json['CampaignId'] ?? 0,
      mediaType: json['mediaType'] ?? json['MediaType'] ?? 1,
      mediaUrl: json['mediaUrl'] ?? json['MediaUrl'] ?? '',
      localCachePath: json['localCachePath'] ?? json['LocalCachePath'],
      title: json['title'] ?? json['Title'] ?? '',
      durationSeconds: json['durationSeconds'] ?? json['DurationSeconds'] ?? 15,
      displayOrder: json['displayOrder'] ?? json['DisplayOrder'] ?? 1,
      muteAudio: json['muteAudio'] ?? json['MuteAudio'] ?? true,
      isActive: json['isActive'] ?? json['IsActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'campaignId': campaignId,
        'mediaType': mediaType,
        'mediaUrl': mediaUrl,
        'localCachePath': localCachePath,
        'title': title,
        'durationSeconds': durationSeconds,
        'displayOrder': displayOrder,
        'muteAudio': muteAudio,
        'isActive': isActive,
      };
}

class EmergencyBroadcast {
  final int id;
  final int organizationId;
  final int? locationId;
  final int? areaId;
  final String broadcastCode;
  final String title;
  final String messageText;
  final int severity; // 1=Info, 2=Warning, 3=Critical
  final int audioSirenType; // 0=None, 1=Pulse, 2=Wail, 3=Continuous
  final String flashColorHex;
  final bool isActive;
  final DateTime triggeredAt;
  final DateTime? dismissedAt;

  const EmergencyBroadcast({
    required this.id,
    required this.organizationId,
    this.locationId,
    this.areaId,
    this.broadcastCode = 'CODE_RED',
    required this.title,
    required this.messageText,
    this.severity = 3,
    this.audioSirenType = 1,
    this.flashColorHex = '#FF1744',
    this.isActive = true,
    required this.triggeredAt,
    this.dismissedAt,
  });

  factory EmergencyBroadcast.fromJson(Map<String, dynamic> json) {
    return EmergencyBroadcast(
      id: json['id'] ?? json['Id'] ?? 0,
      organizationId: json['organizationId'] ?? json['OrganizationId'] ?? 1,
      locationId: json['locationId'] ?? json['LocationId'],
      areaId: json['areaId'] ?? json['AreaId'],
      broadcastCode: json['broadcastCode'] ?? json['BroadcastCode'] ?? 'CODE_RED',
      title: json['title'] ?? json['Title'] ?? 'EMERGENCY ALERT',
      messageText: json['messageText'] ?? json['MessageText'] ?? '',
      severity: json['severity'] ?? json['Severity'] ?? 3,
      audioSirenType: json['audioSirenType'] ?? json['AudioSirenType'] ?? 1,
      flashColorHex: json['flashColorHex'] ?? json['FlashColorHex'] ?? '#FF1744',
      isActive: json['isActive'] ?? json['IsActive'] ?? true,
      triggeredAt: DateTime.tryParse(json['triggeredAt'] ?? json['TriggeredAt'] ?? '') ?? DateTime.now(),
      dismissedAt: json['dismissedAt'] != null || json['DismissedAt'] != null
          ? DateTime.tryParse(json['dismissedAt'] ?? json['DismissedAt'] ?? '')
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'organizationId': organizationId,
        'locationId': locationId,
        'areaId': areaId,
        'broadcastCode': broadcastCode,
        'title': title,
        'messageText': messageText,
        'severity': severity,
        'audioSirenType': audioSirenType,
        'flashColorHex': flashColorHex,
        'isActive': isActive,
        'triggeredAt': triggeredAt.toIso8601String(),
        'dismissedAt': dismissedAt?.toIso8601String(),
      };
}
