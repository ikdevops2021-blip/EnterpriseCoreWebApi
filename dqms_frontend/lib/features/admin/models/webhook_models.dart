class WebhookSubscription {
  final int id;
  final int organizationId;
  final int? locationId;
  final String name;
  final String endpointUrl;
  final String secretKey;
  final String subscribedEvents;
  final bool isActive;
  final int maxRetryAttempts;
  final int timeoutSeconds;
  final int consecutiveFailures;
  final DateTime? circuitBreakerUntil;
  final int createdBy;
  final DateTime createdDate;
  final int modifiedBy;
  final DateTime modifiedDate;
  final String? lastDeliveryStatus;
  final int? lastResponseStatusCode;
  final DateTime? lastDeliveryDate;

  WebhookSubscription({
    required this.id,
    required this.organizationId,
    this.locationId,
    required this.name,
    required this.endpointUrl,
    required this.secretKey,
    required this.subscribedEvents,
    required this.isActive,
    this.maxRetryAttempts = 3,
    this.timeoutSeconds = 10,
    this.consecutiveFailures = 0,
    this.circuitBreakerUntil,
    this.createdBy = 0,
    DateTime? createdDate,
    this.modifiedBy = 0,
    DateTime? modifiedDate,
    this.lastDeliveryStatus,
    this.lastResponseStatusCode,
    this.lastDeliveryDate,
  })  : createdDate = createdDate ?? DateTime.now(),
        modifiedDate = modifiedDate ?? DateTime.now();

  factory WebhookSubscription.fromJson(Map<String, dynamic> json) {
    return WebhookSubscription(
      id: json['id'] ?? json['Id'] ?? 0,
      organizationId: json['organizationId'] ?? json['OrganizationId'] ?? 1,
      locationId: json['locationId'] ?? json['LocationId'],
      name: json['name'] ?? json['Name'] ?? '',
      endpointUrl: json['endpointUrl'] ?? json['EndpointUrl'] ?? '',
      secretKey: json['secretKey'] ?? json['SecretKey'] ?? '',
      subscribedEvents: json['subscribedEvents'] ?? json['SubscribedEvents'] ?? '',
      isActive: json['isActive'] ?? json['IsActive'] ?? true,
      maxRetryAttempts: json['maxRetryAttempts'] ?? json['MaxRetryAttempts'] ?? 3,
      timeoutSeconds: json['timeoutSeconds'] ?? json['TimeoutSeconds'] ?? 10,
      consecutiveFailures: json['consecutiveFailures'] ?? json['ConsecutiveFailures'] ?? 0,
      circuitBreakerUntil: json['circuitBreakerUntil'] != null || json['CircuitBreakerUntil'] != null
          ? DateTime.tryParse(json['circuitBreakerUntil'] ?? json['CircuitBreakerUntil'])
          : null,
      createdBy: json['createdBy'] ?? json['CreatedBy'] ?? 0,
      createdDate: json['createdDate'] != null || json['CreatedDate'] != null
          ? DateTime.tryParse(json['createdDate'] ?? json['CreatedDate'])
          : null,
      modifiedBy: json['modifiedBy'] ?? json['ModifiedBy'] ?? 0,
      modifiedDate: json['modifiedDate'] != null || json['ModifiedDate'] != null
          ? DateTime.tryParse(json['modifiedDate'] ?? json['ModifiedDate'])
          : null,
      lastDeliveryStatus: json['lastDeliveryStatus'] ?? json['LastDeliveryStatus'],
      lastResponseStatusCode: json['lastResponseStatusCode'] ?? json['LastResponseStatusCode'],
      lastDeliveryDate: json['lastDeliveryDate'] != null || json['LastDeliveryDate'] != null
          ? DateTime.tryParse(json['lastDeliveryDate'] ?? json['LastDeliveryDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'organizationId': organizationId,
        'locationId': locationId,
        'name': name,
        'endpointUrl': endpointUrl,
        'secretKey': secretKey,
        'subscribedEvents': subscribedEvents,
        'isActive': isActive,
        'maxRetryAttempts': maxRetryAttempts,
        'timeoutSeconds': timeoutSeconds,
      };

  List<String> get eventList => subscribedEvents
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

class WebhookDeliveryLog {
  final int id;
  final String deliveryId;
  final int webhookSubscriptionId;
  final String? subscriptionName;
  final int organizationId;
  final String eventCode;
  final String payloadJson;
  final int? responseStatusCode;
  final String? responseBody;
  final int durationMs;
  final int attemptCount;
  final String deliveryStatus;
  final DateTime? nextRetryTime;
  final DateTime createdDate;

  WebhookDeliveryLog({
    required this.id,
    required this.deliveryId,
    required this.webhookSubscriptionId,
    this.subscriptionName,
    required this.organizationId,
    required this.eventCode,
    required this.payloadJson,
    this.responseStatusCode,
    this.responseBody,
    this.durationMs = 0,
    this.attemptCount = 1,
    this.deliveryStatus = 'Success',
    this.nextRetryTime,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now();

  factory WebhookDeliveryLog.fromJson(Map<String, dynamic> json) {
    return WebhookDeliveryLog(
      id: json['id'] ?? json['Id'] ?? 0,
      deliveryId: json['deliveryId'] ?? json['DeliveryId'] ?? '',
      webhookSubscriptionId: json['webhookSubscriptionId'] ?? json['WebhookSubscriptionId'] ?? 0,
      subscriptionName: json['subscriptionName'] ?? json['SubscriptionName'],
      organizationId: json['organizationId'] ?? json['OrganizationId'] ?? 1,
      eventCode: json['eventCode'] ?? json['EventCode'] ?? '',
      payloadJson: json['payloadJson'] ?? json['PayloadJson'] ?? '',
      responseStatusCode: json['responseStatusCode'] ?? json['ResponseStatusCode'],
      responseBody: json['responseBody'] ?? json['ResponseBody'],
      durationMs: json['durationMs'] ?? json['DurationMs'] ?? 0,
      attemptCount: json['attemptCount'] ?? json['AttemptCount'] ?? 1,
      deliveryStatus: json['deliveryStatus'] ?? json['DeliveryStatus'] ?? 'Success',
      nextRetryTime: json['nextRetryTime'] != null || json['NextRetryTime'] != null
          ? DateTime.tryParse(json['nextRetryTime'] ?? json['NextRetryTime'])
          : null,
      createdDate: json['createdDate'] != null || json['CreatedDate'] != null
          ? DateTime.tryParse(json['createdDate'] ?? json['CreatedDate'])
          : null,
    );
  }
}

class WebhookTestResult {
  final bool isSuccess;
  final int statusCode;
  final int latencyMs;
  final String? responseBody;
  final String message;
  final String? computedSignature;
  final String? sentPayload;

  WebhookTestResult({
    required this.isSuccess,
    required this.statusCode,
    required this.latencyMs,
    this.responseBody,
    required this.message,
    this.computedSignature,
    this.sentPayload,
  });

  factory WebhookTestResult.fromJson(Map<String, dynamic> json) {
    return WebhookTestResult(
      isSuccess: json['isSuccess'] ?? json['IsSuccess'] ?? false,
      statusCode: json['statusCode'] ?? json['StatusCode'] ?? 0,
      latencyMs: json['latencyMs'] ?? json['LatencyMs'] ?? 0,
      responseBody: json['responseBody'] ?? json['ResponseBody'],
      message: json['message'] ?? json['Message'] ?? '',
      computedSignature: json['computedSignature'] ?? json['ComputedSignature'],
      sentPayload: json['sentPayload'] ?? json['SentPayload'],
    );
  }
}
