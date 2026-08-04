import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';

/// ============================================================================
/// NavigationMenu Model
/// Mirrors the C# NavigationMenuDto from the WebAPI
/// ============================================================================
class NavigationMenuModel {
  final int id;
  final String title;
  final String iconName;
  final String routePath;
  final int sortOrder;
  final int? parentId;
  final String? requiredPermission;
  final bool isActive;

  const NavigationMenuModel({
    required this.id,
    required this.title,
    required this.iconName,
    required this.routePath,
    required this.sortOrder,
    this.parentId,
    this.requiredPermission,
    required this.isActive,
  });

  factory NavigationMenuModel.fromJson(Map<String, dynamic> json) {
    return NavigationMenuModel(
      id:                 json['id'] ?? 0,
      title:              json['title'] ?? '',
      iconName:           json['iconName'] ?? '',
      routePath:          json['routePath'] ?? '',
      sortOrder:          json['sortOrder'] ?? 99,
      parentId:           json['parentId'],
      requiredPermission: json['requiredPermission'],
      isActive:           json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':                 id,
    'title':              title,
    'iconName':           iconName,
    'routePath':          routePath,
    'sortOrder':          sortOrder,
    'parentId':           parentId,
    'requiredPermission': requiredPermission,
    'isActive':           isActive,
  };

  NavigationMenuModel copyWith({
    int? id,
    String? title,
    String? iconName,
    String? routePath,
    int? sortOrder,
    int? parentId,
    String? requiredPermission,
    bool? isActive,
  }) {
    return NavigationMenuModel(
      id:                 id ?? this.id,
      title:              title ?? this.title,
      iconName:           iconName ?? this.iconName,
      routePath:          routePath ?? this.routePath,
      sortOrder:          sortOrder ?? this.sortOrder,
      parentId:           parentId ?? this.parentId,
      requiredPermission: requiredPermission ?? this.requiredPermission,
      isActive:           isActive ?? this.isActive,
    );
  }
}

/// ============================================================================
/// NavigationMenu Riverpod AsyncNotifier Provider
/// ============================================================================
final navigationMenuProvider =
    AsyncNotifierProvider<NavigationMenuNotifier, List<NavigationMenuModel>>(
        NavigationMenuNotifier.new);

class NavigationMenuNotifier extends AsyncNotifier<List<NavigationMenuModel>> {
  @override
  Future<List<NavigationMenuModel>> build() async => _fetchMenus();

  // -----------------------------------------------------------------------
  // Fetch all active menus from /api/v1/navigation/menus
  // -----------------------------------------------------------------------
  Future<List<NavigationMenuModel>> _fetchMenus({bool activeOnly = true}) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        '/api/v1/navigation/menus',
        queryParameters: {'activeOnly': activeOnly},
      );

      if (response.data != null && response.data is Map) {
        final List raw = response.data['data'] ?? response.data['Data'] ?? [];
        return raw
            .map((item) => NavigationMenuModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return _fallbackMenus; // fallback if API unavailable
    } catch (_) {
      return _fallbackMenus; // graceful fallback to hardcoded list
    }
  }

  // -----------------------------------------------------------------------
  // Upsert (create or update) a menu item
  // -----------------------------------------------------------------------
  Future<bool> saveMenu(NavigationMenuModel model) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/api/v1/navigation/menu', data: model.toJson());
      final success = response.data?['success'] ?? response.data?['Success'] ?? false;
      if (success == true) {
        ref.invalidateSelf();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // -----------------------------------------------------------------------
  // Delete (soft-delete) a menu item
  // -----------------------------------------------------------------------
  Future<bool> deleteMenu(int id) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.delete('/api/v1/navigation/menu/$id');
      final success = response.data?['success'] ?? response.data?['Success'] ?? false;
      if (success == true) {
        ref.invalidateSelf();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // -----------------------------------------------------------------------
  // Refresh provider
  // -----------------------------------------------------------------------
  Future<void> refresh() async => ref.invalidateSelf();

  // -----------------------------------------------------------------------
  // Load all (including inactive) for admin management screen
  // -----------------------------------------------------------------------
  Future<List<NavigationMenuModel>> fetchAll() async => _fetchMenus(activeOnly: false);
}

/// ============================================================================
/// Fallback: Hard-coded list matching seed data — displayed when API is down.
/// This ensures the UI is never broken even without the DB table seeded.
/// ============================================================================
const List<NavigationMenuModel> _fallbackMenus = [
  NavigationMenuModel(id: 1,  title: 'Areas & Zones',                iconName: 'grid_view_rounded',            routePath: '/admin/areas',             sortOrder: 1,  isActive: true),
  NavigationMenuModel(id: 2,  title: 'Process Pipelines',            iconName: 'account_tree_rounded',         routePath: '/admin/processes',          sortOrder: 2,  isActive: true),
  NavigationMenuModel(id: 3,  title: 'Counter Stations',             iconName: 'desk_rounded',                 routePath: '/admin/counters',           sortOrder: 3,  isActive: true),
  NavigationMenuModel(id: 4,  title: 'Display Templates',            iconName: 'tv_rounded',                   routePath: '/admin/display-templates',  sortOrder: 4,  isActive: true),
  NavigationMenuModel(id: 5,  title: 'Staff & Roles',                iconName: 'badge_rounded',                routePath: '/admin/staff',              sortOrder: 5,  isActive: true),
  NavigationMenuModel(id: 6,  title: 'User Profiles & Add/Edit',     iconName: 'person_search_rounded',        routePath: '/admin/user-profiles',      sortOrder: 6,  isActive: true),
  NavigationMenuModel(id: 7,  title: 'Tenant / Organization Master', iconName: 'business_rounded',             routePath: '/admin/tenants',            sortOrder: 7,  isActive: true),
  NavigationMenuModel(id: 8,  title: 'Config Categories & Params',   iconName: 'category_rounded',             routePath: '/admin/config-categories',  sortOrder: 8,  isActive: true),
  NavigationMenuModel(id: 9,  title: 'System Config Keys',           iconName: 'settings_suggest_rounded',     routePath: '/admin/system-config',      sortOrder: 9,  isActive: true),
  NavigationMenuModel(id: 10, title: 'Notification Channels',        iconName: 'notifications_active_rounded', routePath: '/admin/notifications',      sortOrder: 10, isActive: true),
  NavigationMenuModel(id: 11, title: 'Email Gateway Setup',          iconName: 'mark_email_read_rounded',      routePath: '/admin/email',              sortOrder: 11, isActive: true),
  NavigationMenuModel(id: 12, title: 'Analytics Hub',                iconName: 'analytics_rounded',            routePath: '/admin/analytics',          sortOrder: 12, isActive: true),
  NavigationMenuModel(id: 13, title: 'Application & Audit Logs',     iconName: 'terminal_rounded',             routePath: '/admin/logs',               sortOrder: 13, isActive: true),
  NavigationMenuModel(id: 14, title: 'Navigation Menu Manager',      iconName: 'menu_rounded',                 routePath: '/admin/navigation-menu',    sortOrder: 14, isActive: true),
];
