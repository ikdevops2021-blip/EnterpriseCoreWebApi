import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:dqms_frontend/core/config/app_config.dart';

/// ============================================================================
/// PHASE 4 ADMINISTRATION UI — MOCK DATA MODELS & PROVIDERS
/// Structured domain models for all 8 administrative workspace modules
/// ============================================================================

/// 1. Areas & Zones Model
class AreaZoneModel {
  final int areaId;
  final String areaCode;
  final String areaName;
  final String description;
  final int targetSlaMins;
  final bool isActive;

  const AreaZoneModel({
    required this.areaId,
    required this.areaCode,
    required this.areaName,
    required this.description,
    required this.targetSlaMins,
    required this.isActive,
  });

  factory AreaZoneModel.fromJson(Map<String, dynamic> json) {
    return AreaZoneModel(
      areaId: json['id'] ?? json['Id'] ?? json['areaId'] ?? 0,
      areaCode: json['areaCode'] ?? json['AreaCode'] ?? 'AZ-01',
      areaName: json['areaName'] ?? json['AreaName'] ?? 'Service Zone',
      description: json['description'] ?? json['Description'] ?? '',
      targetSlaMins: json['targetSLA'] ?? json['targetSlaMins'] ?? 15,
      isActive: json['isActive'] ?? json['IsActive'] ?? true,
    );
  }
}

/// 2. Process Pipelines Model
class ProcessModel {
  final int processId;
  final int areaId;
  final String areaName;
  final String processCode;
  final String processName;
  final int targetSlaMins;
  final bool allowSubTokens;
  final String priorityLevel; // 'High', 'Standard', 'VIP'
  final bool isActive;

  const ProcessModel({
    required this.processId,
    required this.areaId,
    required this.areaName,
    required this.processCode,
    required this.processName,
    required this.targetSlaMins,
    required this.allowSubTokens,
    required this.priorityLevel,
    required this.isActive,
  });

  factory ProcessModel.fromJson(Map<String, dynamic> json) {
    return ProcessModel(
      processId: json['id'] ?? json['Id'] ?? json['processId'] ?? 0,
      areaId: json['areaId'] ?? json['AreaId'] ?? 1,
      areaName: json['areaName'] ?? json['AreaName'] ?? 'Main Hall A',
      processCode: json['processCode'] ?? json['ProcessCode'] ?? 'PROC-101',
      processName: json['processName'] ?? json['ProcessName'] ?? 'Process Pipeline',
      targetSlaMins: json['targetTATMinutes'] ?? json['targetSlaMins'] ?? 15,
      allowSubTokens: json['allowSubTokens'] ?? json['AllowSubTokens'] ?? false,
      priorityLevel: json['priorityLevel'] ?? json['PriorityLevel'] ?? 'Standard',
      isActive: json['isActive'] ?? json['IsActive'] ?? true,
    );
  }
}

/// 3. Counter Stations Model
class CounterModel {
  final int counterId;
  final int areaId;
  final String areaName;
  final String counterNumber;
  final String counterName;
  final String mode; // 'SingleProcess', 'MultiProcess'
  final String assignedStaffName;
  final String status; // 'Active', 'Idle', 'Maintenance', 'Closed'
  final bool isVoiceEnabled;

  const CounterModel({
    required this.counterId,
    required this.areaId,
    required this.areaName,
    required this.counterNumber,
    required this.counterName,
    required this.mode,
    required this.assignedStaffName,
    required this.status,
    required this.isVoiceEnabled,
  });

  factory CounterModel.fromJson(Map<String, dynamic> json) {
    return CounterModel(
      counterId: json['id'] ?? json['Id'] ?? json['counterId'] ?? 0,
      areaId: json['areaId'] ?? json['AreaId'] ?? 1,
      areaName: json['areaName'] ?? json['AreaName'] ?? 'Main Hall A',
      counterNumber: json['counterNumber'] ?? json['CounterNumber'] ?? 'C-01',
      counterName: json['counterName'] ?? json['CounterName'] ?? 'Counter Station',
      mode: json['mode'] ?? json['Mode'] ?? 'SingleProcess',
      assignedStaffName: json['assignedStaffName'] ?? json['AssignedStaffName'] ?? 'Staff',
      status: json['status'] ?? json['Status'] ?? 'Active',
      isVoiceEnabled: json['isVoiceEnabled'] ?? json['IsVoiceEnabled'] ?? true,
    );
  }
}

/// 4. Display Templates Model
class DisplayTemplateModel {
  final int templateId;
  final String templateName;
  final String layoutType; // 'GridView (21001)', 'SplitView (21002)', 'HeaderTicker (21003)'
  final String audioChime; // 'DigitalBell', 'ChimeVoice', 'Silent'
  final String scrollSpeed; // 'Normal', 'Fast', 'Slow'
  final String tickerText;
  final bool isActive;

  const DisplayTemplateModel({
    required this.templateId,
    required this.templateName,
    required this.layoutType,
    required this.audioChime,
    required this.scrollSpeed,
    required this.tickerText,
    required this.isActive,
  });

  factory DisplayTemplateModel.fromJson(Map<String, dynamic> json) {
    return DisplayTemplateModel(
      templateId: json['id'] ?? json['Id'] ?? json['templateId'] ?? 0,
      templateName: json['templateName'] ?? json['TemplateName'] ?? 'Main Lobby TV Grid',
      layoutType: json['layoutType'] ?? json['LayoutType'] ?? 'GridView (21001)',
      audioChime: json['audioChime'] ?? json['AudioChime'] ?? 'DigitalBell',
      scrollSpeed: json['scrollSpeed'] ?? json['ScrollSpeed'] ?? 'Normal',
      tickerText: json['tickerText'] ?? json['TickerText'] ?? 'Welcome to DQMS Medical Center.',
      isActive: json['isActive'] ?? json['IsActive'] ?? true,
    );
  }
}

/// 5. Staff & Roles Model
class StaffRoleModel {
  final int staffId;
  final String staffCode;
  final String fullName;
  final String email;
  final String roleName; // 'SuperAdmin', 'BranchManager', 'CounterOperator', 'Receptionist'
  final String assignedCounterNumber;
  final String status; // 'Active', 'OnBreak', 'Offline'

  const StaffRoleModel({
    required this.staffId,
    required this.staffCode,
    required this.fullName,
    required this.email,
    required this.roleName,
    required this.assignedCounterNumber,
    required this.status,
  });
}

/// 6. System Configuration Model (ConfigCategory & ConfigParameters)
class SystemConfigModel {
  final int configId;
  final String categoryName;
  final String paramKey;
  final String paramValue;
  final String valueDataType; // 'String', 'Int', 'Boolean', 'Json'
  final String description;

  const SystemConfigModel({
    required this.configId,
    required this.categoryName,
    required this.paramKey,
    required this.paramValue,
    required this.valueDataType,
    required this.description,
  });
}

/// 7. Notification Configuration Model
class NotificationConfigModel {
  final int channelId;
  final String channelName; // 'SMS Gateway', 'Audio Speech Synthesizer', 'WebHook Event Dispatcher', 'Push Notification Service'
  final String providerName;
  final bool isEnabled;
  final int retryLimit;
  final String configDetails;

  const NotificationConfigModel({
    required this.channelId,
    required this.channelName,
    required this.providerName,
    required this.isEnabled,
    required this.retryLimit,
    required this.configDetails,
  });
}

/// 8. Analytics Report Entry Model
class AnalyticsReportEntryModel {
  final String reportId;
  final String reportName;
  final String category; // 'SLA Compliance', 'Queue Traffic', 'Operator Performance', 'Bottleneck Analysis'
  final String format; // 'PDF', 'CSV', 'Excel'
  final String lastGeneratedTime;
  final int totalRecords;

  const AnalyticsReportEntryModel({
    required this.reportId,
    required this.reportName,
    required this.category,
    required this.format,
    required this.lastGeneratedTime,
    required this.totalRecords,
  });
}

/// Master Admin State DTO
class AdminWorkspaceState {
  final List<AreaZoneModel> areas;
  final List<ProcessModel> processes;
  final List<CounterModel> counters;
  final List<DisplayTemplateModel> displayTemplates;
  final List<StaffRoleModel> staffMembers;
  final List<SystemConfigModel> systemConfigs;
  final List<NotificationConfigModel> notificationConfigs;
  final List<AnalyticsReportEntryModel> analyticsReports;

  const AdminWorkspaceState({
    required this.areas,
    required this.processes,
    required this.counters,
    required this.displayTemplates,
    required this.staffMembers,
    required this.systemConfigs,
    required this.notificationConfigs,
    required this.analyticsReports,
  });

  factory AdminWorkspaceState.demo() {
    return const AdminWorkspaceState(
      areas: [
        AreaZoneModel(areaId: 1, areaCode: 'AZ-01', areaName: 'Main Service Hall A', description: 'Primary patient registration & triage area', targetSlaMins: 15, isActive: true),
        AreaZoneModel(areaId: 2, areaCode: 'AZ-02', areaName: 'Priority Wing B', description: 'Elderly, disabled, and pregnancy assist wing', targetSlaMins: 10, isActive: true),
        AreaZoneModel(areaId: 3, areaCode: 'AZ-03', areaName: 'Express Desk C', description: 'Quick inquiry & fast-track document collection', targetSlaMins: 5, isActive: true),
        AreaZoneModel(areaId: 4, areaCode: 'AZ-04', areaName: 'VIP Lounge D', description: 'Executive & VIP private consultation lounge', targetSlaMins: 8, isActive: true),
        AreaZoneModel(areaId: 5, areaCode: 'AZ-05', areaName: 'Pharmacy Outpatient E', description: 'Medication dispensing and consultation windows', targetSlaMins: 12, isActive: true),
      ],
      processes: [
        ProcessModel(processId: 101, areaId: 1, areaName: 'Main Service Hall A', processCode: 'PROC-101', processName: 'Patient Registration & Check-in', targetSlaMins: 10, allowSubTokens: false, priorityLevel: 'Standard', isActive: true),
        ProcessModel(processId: 102, areaId: 1, areaName: 'Main Service Hall A', processCode: 'PROC-102', processName: 'General Clinical Triage', targetSlaMins: 15, allowSubTokens: true, priorityLevel: 'Standard', isActive: true),
        ProcessModel(processId: 103, areaId: 2, areaName: 'Priority Wing B', processCode: 'PROC-201', processName: 'Priority Medical Screening', targetSlaMins: 8, allowSubTokens: false, priorityLevel: 'High', isActive: true),
        ProcessModel(processId: 104, areaId: 3, areaName: 'Express Desk C', processCode: 'PROC-301', processName: 'Fast-Track Billing & Cashier', targetSlaMins: 5, allowSubTokens: false, priorityLevel: 'Standard', isActive: true),
        ProcessModel(processId: 105, areaId: 5, areaName: 'Pharmacy Outpatient E', processCode: 'PROC-501', processName: 'Prescription Dispensing & Advisory', targetSlaMins: 12, allowSubTokens: true, priorityLevel: 'Standard', isActive: true),
      ],
      counters: [
        CounterModel(counterId: 1, areaId: 1, areaName: 'Main Service Hall A', counterNumber: 'C-01', counterName: 'Registration Station 1', mode: 'SingleProcess', assignedStaffName: 'Alex Rivera', status: 'Active', isVoiceEnabled: true),
        CounterModel(counterId: 2, areaId: 1, areaName: 'Main Service Hall A', counterNumber: 'C-02', counterName: 'Registration Station 2', mode: 'SingleProcess', assignedStaffName: 'Maria Chen', status: 'Active', isVoiceEnabled: true),
        CounterModel(counterId: 3, areaId: 1, areaName: 'Main Service Hall A', counterNumber: 'C-03', counterName: 'Registration Station 3', mode: 'MultiProcess', assignedStaffName: 'John Smith', status: 'Active', isVoiceEnabled: true),
        CounterModel(counterId: 4, areaId: 2, areaName: 'Priority Wing B', counterNumber: 'C-04', counterName: 'Priority Station 1', mode: 'SingleProcess', assignedStaffName: 'Sarah Jenkins', status: 'Active', isVoiceEnabled: true),
        CounterModel(counterId: 5, areaId: 2, areaName: 'Priority Wing B', counterNumber: 'C-05', counterName: 'Priority Station 2', mode: 'SingleProcess', assignedStaffName: 'David Kim', status: 'Idle', isVoiceEnabled: false),
        CounterModel(counterId: 6, areaId: 3, areaName: 'Express Desk C', counterNumber: 'C-06', counterName: 'Express Cashier 1', mode: 'SingleProcess', assignedStaffName: 'Elena Rostova', status: 'Active', isVoiceEnabled: true),
        CounterModel(counterId: 7, areaId: 5, areaName: 'Pharmacy Outpatient E', counterNumber: 'C-08', counterName: 'Pharmacy Window 1', mode: 'SingleProcess', assignedStaffName: 'Priya Patel', status: 'Active', isVoiceEnabled: true),
      ],
      displayTemplates: [
        DisplayTemplateModel(templateId: 1, templateName: 'Main Lobby TV Grid (Default)', layoutType: 'GridView (21001)', audioChime: 'DigitalBell', scrollSpeed: 'Normal', tickerText: 'Welcome to DQMS Medical Center. Please keep your ticket until called.', isActive: true),
        DisplayTemplateModel(templateId: 2, templateName: 'Priority Hall Split Layout', layoutType: 'SplitView (21002)', audioChime: 'ChimeVoice', scrollSpeed: 'Slow', tickerText: 'Priority Wing B — Elderly & Assist Tokens Called First.', isActive: true),
        DisplayTemplateModel(templateId: 3, templateName: 'Pharmacy Header Ticker', layoutType: 'HeaderTicker (21003)', audioChime: 'Silent', scrollSpeed: 'Fast', tickerText: 'Prescription Dispensing — Check your ticket status on your phone.', isActive: false),
      ],
      staffMembers: [
        StaffRoleModel(staffId: 501, staffCode: 'STF-01', fullName: 'Alex Rivera', email: 'alex.rivera@dqms.org', roleName: 'CounterOperator', assignedCounterNumber: 'C-01', status: 'Active'),
        StaffRoleModel(staffId: 502, staffCode: 'STF-02', fullName: 'Maria Chen', email: 'maria.chen@dqms.org', roleName: 'CounterOperator', assignedCounterNumber: 'C-02', status: 'Active'),
        StaffRoleModel(staffId: 503, staffCode: 'STF-03', fullName: 'John Smith', email: 'john.smith@dqms.org', roleName: 'CounterOperator', assignedCounterNumber: 'C-03', status: 'Active'),
        StaffRoleModel(staffId: 504, staffCode: 'STF-04', fullName: 'Sarah Jenkins', email: 'sarah.j@dqms.org', roleName: 'CounterOperator', assignedCounterNumber: 'C-04', status: 'Active'),
        StaffRoleModel(staffId: 505, staffCode: 'STF-05', fullName: 'David Kim', email: 'david.kim@dqms.org', roleName: 'CounterOperator', assignedCounterNumber: 'C-05', status: 'OnBreak'),
        StaffRoleModel(staffId: 506, staffCode: 'STF-06', fullName: 'Dr. Robert Vance', email: 'robert.vance@dqms.org', roleName: 'BranchManager', assignedCounterNumber: 'N/A', status: 'Active'),
        StaffRoleModel(staffId: 507, staffCode: 'STF-07', fullName: 'System Admin', email: 'admin@dqms.org', roleName: 'SuperAdmin', assignedCounterNumber: 'N/A', status: 'Active'),
      ],
      systemConfigs: [
        SystemConfigModel(configId: 1, categoryName: 'General', paramKey: 'SystemTenantName', paramValue: 'DQMS Medical Center HQ', valueDataType: 'String', description: 'Enterprise Organization Master Name'),
        SystemConfigModel(configId: 2, categoryName: 'QueueThresholds', paramKey: 'MaxWaitSlaMinutes', paramValue: '15', valueDataType: 'Int', description: 'Global SLA Warning Alert Threshold in Minutes'),
        SystemConfigModel(configId: 3, categoryName: 'QueueThresholds', paramKey: 'RecallMaxAttempts', paramValue: '3', valueDataType: 'Int', description: 'Maximum Token Recall Attempts Before No-Show Auto-Cancel'),
        SystemConfigModel(configId: 4, categoryName: 'DisplayEngine', paramKey: 'TvAutoRefreshIntervalSeconds', paramValue: '5', valueDataType: 'Int', description: 'TV Display WebSocket Polling Fallback Interval'),
        SystemConfigModel(configId: 5, categoryName: 'AudioSynthesizer', paramKey: 'VoiceLanguageCode', paramValue: 'en-US', valueDataType: 'String', description: 'Text-to-Speech Engine Locale Code'),
      ],
      notificationConfigs: [
        NotificationConfigModel(channelId: 1, channelName: 'Audio Speech Synthesizer', providerName: 'Google Cloud TTS', isEnabled: true, retryLimit: 3, configDetails: 'Voice: en-US-Wavenet-F, Speed: 1.0x, Volume: 100%'),
        NotificationConfigModel(channelId: 2, channelName: 'SMS Gateway Provider', providerName: 'Twilio SMS Enterprise', isEnabled: true, retryLimit: 2, configDetails: 'Sender ID: DQMS-MED, Webhook Callback: Active'),
        NotificationConfigModel(channelId: 3, channelName: 'WebHook Event Dispatcher', providerName: 'Enterprise EventHub', isEnabled: true, retryLimit: 5, configDetails: 'Endpoint: https://api.dqms.org/events/queue-v1'),
        NotificationConfigModel(channelId: 4, channelName: 'Push Notification Service', providerName: 'Firebase FCM', isEnabled: false, retryLimit: 3, configDetails: 'Topic: dqms-mobile-updates'),
      ],
      analyticsReports: [
        AnalyticsReportEntryModel(reportId: 'REP-101', reportName: 'Monthly SLA Compliance Report', category: 'SLA Compliance', format: 'PDF', lastGeneratedTime: '2026-07-30 08:00', totalRecords: 1420),
        AnalyticsReportEntryModel(reportId: 'REP-102', reportName: 'Daily Hourly Queue Traffic Log', category: 'Queue Traffic', format: 'CSV', lastGeneratedTime: '2026-07-30 14:00', totalRecords: 850),
        AnalyticsReportEntryModel(reportId: 'REP-103', reportName: 'Staff Handling TAT Performance Audit', category: 'Operator Performance', format: 'Excel', lastGeneratedTime: '2026-07-30 12:30', totalRecords: 342),
        AnalyticsReportEntryModel(reportId: 'REP-104', reportName: 'Bottleneck Incident Summary', category: 'Bottleneck Analysis', format: 'PDF', lastGeneratedTime: '2026-07-29 18:00', totalRecords: 48),
      ],
    );
  }
}

/// Riverpod StateNotifier for Admin Workspace
class AdminWorkspaceNotifier extends StateNotifier<AdminWorkspaceState> {
  AdminWorkspaceNotifier() : super(AdminWorkspaceState.demo());

  void refresh() {
    state = AdminWorkspaceState.demo();
  }

  Future<void> fetchApiData(Dio dio) async {
    try {
      final areasRes = await dio.get('${AppConfig.adminApiBase}/areas');
      List<AreaZoneModel> fetchedAreas = state.areas;
      if (areasRes.statusCode == 200 && areasRes.data != null && areasRes.data['data'] != null) {
        final List items = areasRes.data['data'];
        if (items.isNotEmpty) {
          fetchedAreas = items.map((j) => AreaZoneModel.fromJson(j)).toList();
        }
      }

      final procRes = await dio.get('${AppConfig.adminApiBase}/processes');
      List<ProcessModel> fetchedProcesses = state.processes;
      if (procRes.statusCode == 200 && procRes.data != null && procRes.data['data'] != null) {
        final List items = procRes.data['data'];
        if (items.isNotEmpty) {
          fetchedProcesses = items.map((j) => ProcessModel.fromJson(j)).toList();
        }
      }

      final cntRes = await dio.get('${AppConfig.adminApiBase}/counters');
      List<CounterModel> fetchedCounters = state.counters;
      if (cntRes.statusCode == 200 && cntRes.data != null && cntRes.data['data'] != null) {
        final List items = cntRes.data['data'];
        if (items.isNotEmpty) {
          fetchedCounters = items.map((j) => CounterModel.fromJson(j)).toList();
        }
      }

      final tmplRes = await dio.get('${AppConfig.adminApiBase}/templates');
      List<DisplayTemplateModel> fetchedTemplates = state.displayTemplates;
      if (tmplRes.statusCode == 200 && tmplRes.data != null && tmplRes.data['data'] != null) {
        final List items = tmplRes.data['data'];
        if (items.isNotEmpty) {
          fetchedTemplates = items.map((j) => DisplayTemplateModel.fromJson(j)).toList();
        }
      }

      state = AdminWorkspaceState(
        areas: fetchedAreas,
        processes: fetchedProcesses,
        counters: fetchedCounters,
        displayTemplates: fetchedTemplates,
        staffMembers: state.staffMembers,
        systemConfigs: state.systemConfigs,
        notificationConfigs: state.notificationConfigs,
        analyticsReports: state.analyticsReports,
      );
    } catch (_) {
      // Seamless fallback to demo state if offline
    }
  }
}

final adminWorkspaceStateProvider = StateNotifierProvider<AdminWorkspaceNotifier, AdminWorkspaceState>((ref) {
  return AdminWorkspaceNotifier();
});
