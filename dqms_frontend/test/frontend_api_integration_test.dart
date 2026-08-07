import 'package:flutter_test/flutter_test.dart';
import 'package:dqms_frontend/core/models/admin_models.dart';
import 'package:dqms_frontend/features/admin/providers/admin_mock_providers.dart';
import 'package:dqms_frontend/features/admin/providers/navigation_menu_provider.dart';
import 'package:dqms_frontend/features/dashboard/models/dashboard_dto.dart';
import 'package:dqms_frontend/features/staff/models/staff_dto.dart';

void main() {
  group('QA Test Suite — Frontend API Endpoints Integration & Data Binding', () {
    // -------------------------------------------------------------------------
    // TC-API-01: Navigation Menus API (GET /api/v1/navigation/menus)
    // -------------------------------------------------------------------------
    test('TC-API-01: NavigationMenuModel deserializes payload from GET /api/v1/navigation/menus', () {
      final jsonPayload = {
        'id': 1,
        'title': 'Areas & Zones',
        'routePath': '/admin/areas-zones',
        'iconName': 'location_city_rounded',
        'displayOrder': 1,
        'isActive': true,
      };

      final menu = NavigationMenuModel.fromJson(jsonPayload);

      expect(menu.id, equals(1));
      expect(menu.title, equals('Areas & Zones'));
      expect(menu.routePath, equals('/admin/areas-zones'));
      expect(menu.iconName, equals('location_city_rounded'));
      expect(menu.isActive, isTrue);
    });

    // -------------------------------------------------------------------------
    // TC-API-02: Admin Areas API (GET /api/v1/admin/areas)
    // -------------------------------------------------------------------------
    test('TC-API-02: AreaDto deserializes response payload from GET /api/v1/admin/areas', () {
      final jsonPayload = {
        'id': 101,
        'areaCode': 'AZ-101',
        'organizationId': 1,
        'locationId': 1,
        'areaName': 'Cardiology Wing',
        'description': 'Heart & Vascular Triage',
        'isActive': true,
      };

      final area = AreaDto.fromJson(jsonPayload);

      expect(area.id, equals(101));
      expect(area.areaCode, equals('AZ-101'));
      expect(area.areaName, equals('Cardiology Wing'));
      expect(area.description, equals('Heart & Vascular Triage'));
      expect(area.isActive, isTrue);
    });

    // -------------------------------------------------------------------------
    // TC-API-03: Admin Process Pipelines API (GET /api/v1/admin/processes)
    // -------------------------------------------------------------------------
    test('TC-API-03: ProcessDto deserializes response payload from GET /api/v1/admin/processes', () {
      final jsonPayload = {
        'id': 201,
        'processCode': 'PROC-201',
        'organizationId': 1,
        'processName': 'ECG Triage',
        'prefix': 'E',
        'targetTATMinutes': 10,
        'allowSubTokens': false,
        'isActive': true,
      };

      final process = ProcessDto.fromJson(jsonPayload);

      expect(process.id, equals(201));
      expect(process.processCode, equals('PROC-201'));
      expect(process.processName, equals('ECG Triage'));
      expect(process.targetTATMinutes, equals(10));
      expect(process.prefix, equals('E'));
    });

    // -------------------------------------------------------------------------
    // TC-API-04: Admin Counters API (GET /api/v1/admin/counters)
    // -------------------------------------------------------------------------
    test('TC-API-04: CounterDto deserializes response payload from GET /api/v1/admin/counters', () {
      final jsonPayload = {
        'id': 301,
        'counterCode': 'C-01',
        'organizationId': 1,
        'locationId': 1,
        'areaId': 101,
        'counterNumber': 'C-01',
        'counterName': 'Registration Desk 1',
        'currentStatus': 20001,
        'isActive': true,
      };

      final counter = CounterDto.fromJson(jsonPayload);

      expect(counter.id, equals(301));
      expect(counter.counterNumber, equals('C-01'));
      expect(counter.counterName, equals('Registration Desk 1'));
      expect(counter.currentStatus, equals(20001));
    });

    // -------------------------------------------------------------------------
    // TC-API-05: Display Template API (GET /api/v1/admin/templates)
    // -------------------------------------------------------------------------
    test('TC-API-05: DisplayTemplateDto deserializes response payload from GET /api/v1/admin/templates', () {
      final jsonPayload = {
        'id': 401,
        'organizationId': 1,
        'templateName': 'Main Lobby TV Grid',
        'templateType': 21001,
        'layoutConfigJson': '{"columns": 3}',
        'isDefault': true,
        'isActive': true,
      };

      final template = DisplayTemplateDto.fromJson(jsonPayload);

      expect(template.id, equals(401));
      expect(template.templateName, equals('Main Lobby TV Grid'));
      expect(template.templateType, equals(21001));
      expect(template.isDefault, isTrue);
    });

    // -------------------------------------------------------------------------
    // TC-API-06: Executive Dashboard API (GET /api/v1/dqms/dashboard)
    // -------------------------------------------------------------------------
    test('TC-API-06: DashboardDto deserializes payload from GET /api/v1/dqms/dashboard', () {
      final jsonPayload = {
        'waitingCustomers': 28,
        'currentlyServing': 15,
        'slaBreachesToday': 2,
        'avgWaitTimeMins': 8,
        'avgServiceTimeMins': 6,
        'completedToday': 400,
        'activeCounters': 8,
        'totalCounters': 10,
        'waitingTrend': 'Normal load',
        'counterMatrix': [
          {
            'counterId': 1,
            'counterNumber': 'C-01',
            'counterName': 'Registration Desk 1',
            'processName': 'Check-in',
            'operatorName': 'Jane Doe',
            'status': 'Active',
            'currentTokenNumber': 'A-101',
            'activeSeconds': 120,
          }
        ],
        'processAnalytics': [],
        'queueTrend': [],
        'recentActivities': [],
        'bottlenecks': [],
      };

      final dashboardData = DashboardDto.fromJson(jsonPayload);

      expect(dashboardData.waitingCustomers, equals(28));
      expect(dashboardData.currentlyServing, equals(15));
      expect(dashboardData.completedToday, equals(400));
      expect(dashboardData.counterMatrix.length, equals(1));
      expect(dashboardData.counterMatrix.first.counterNumber, equals('C-01'));
    });

    // -------------------------------------------------------------------------
    // TC-API-07: Staff Operator DTOs (POST /api/v1/staff/*)
    // -------------------------------------------------------------------------
    test('TC-API-07: Staff DTOs correctly serialize JSON requests for /api/v1/staff/*', () {
      const callNextReq = CallNextTokenRequestDto(
        organizationId: 1,
        locationId: 1,
        counterId: 2,
        processId: 101,
      );

      final callNextJson = callNextReq.toJson();
      expect(callNextJson['counterId'], equals(2));
      expect(callNextJson['processId'], equals(101));

      const updateStatusReq = UpdateTokenStatusRequestDto(
        tokenId: 501,
        newStatus: 18007,
        reason: 'Service Completed',
      );

      final updateStatusJson = updateStatusReq.toJson();
      expect(updateStatusJson['tokenId'], equals(501));
      expect(updateStatusJson['newStatus'], equals(18007));

      const issueTokenReq = IssueTokenRequestDto(
        organizationId: 1,
        locationId: 1,
        areaId: 1,
        processId: 101,
        priorityTier: 19001,
        customerName: 'Alice Smith',
      );

      final issueTokenJson = issueTokenReq.toJson();
      expect(issueTokenJson['customerName'], equals('Alice Smith'));
      expect(issueTokenJson['priorityTier'], equals(19001));
    });

    // -------------------------------------------------------------------------
    // TC-API-08: Resilient Offline Fallback State Handling
    // -------------------------------------------------------------------------
    test('TC-API-08: AdminWorkspaceState demo state provides full fallback domain coverage', () {
      final state = AdminWorkspaceState.demo();

      expect(state.areas.length, equals(5));
      expect(state.processes.length, equals(5));
      expect(state.counters.length, equals(7));
      expect(state.displayTemplates.length, equals(3));
      expect(state.staffMembers.length, equals(7));
      expect(state.systemConfigs.length, equals(5));
      expect(state.notificationConfigs.length, equals(4));
      expect(state.analyticsReports.length, equals(4));
    });
  });
}
