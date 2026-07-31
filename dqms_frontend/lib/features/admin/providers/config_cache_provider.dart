import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/features/admin/widgets/system_config_view.dart';
import 'package:dqms_frontend/features/admin/widgets/config_category_parameters_view.dart';

/// System Configurations Cache State
class SystemConfigCacheState {
  final List<SystemConfigModel> items;
  final DateTime? lastUpdated;
  final bool isLoading;

  const SystemConfigCacheState({
    this.items = const [],
    this.lastUpdated,
    this.isLoading = false,
  });

  SystemConfigCacheState copyWith({
    List<SystemConfigModel>? items,
    DateTime? lastUpdated,
    bool? isLoading,
  }) {
    return SystemConfigCacheState(
      items: items ?? this.items,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SystemConfigCacheNotifier extends StateNotifier<SystemConfigCacheState> {
  SystemConfigCacheNotifier() : super(const SystemConfigCacheState());

  void setCache(List<SystemConfigModel> items) {
    state = SystemConfigCacheState(
      items: items,
      lastUpdated: DateTime.now(),
      isLoading: false,
    );
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void invalidate() {
    state = const SystemConfigCacheState();
  }
}

final systemConfigCacheProvider = StateNotifierProvider<SystemConfigCacheNotifier, SystemConfigCacheState>((ref) {
  return SystemConfigCacheNotifier();
});

/// Category Parameters Cache State
class CategoryParametersCacheState {
  final List<ConfigCategoryModel> categories;
  final Map<int, List<ConfigParameterModel>> parametersByCategory;
  final DateTime? lastUpdated;

  const CategoryParametersCacheState({
    this.categories = const [],
    this.parametersByCategory = const {},
    this.lastUpdated,
  });

  CategoryParametersCacheState copyWith({
    List<ConfigCategoryModel>? categories,
    Map<int, List<ConfigParameterModel>>? parametersByCategory,
    DateTime? lastUpdated,
  }) {
    return CategoryParametersCacheState(
      categories: categories ?? this.categories,
      parametersByCategory: parametersByCategory ?? this.parametersByCategory,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class CategoryParametersCacheNotifier extends StateNotifier<CategoryParametersCacheState> {
  CategoryParametersCacheNotifier() : super(const CategoryParametersCacheState());

  void setCategories(List<ConfigCategoryModel> categories) {
    state = state.copyWith(
      categories: categories,
      lastUpdated: DateTime.now(),
    );
  }

  void setCategoryParameters(int categoryId, List<ConfigParameterModel> params) {
    final updated = Map<int, List<ConfigParameterModel>>.from(state.parametersByCategory);
    updated[categoryId] = params;
    state = state.copyWith(
      parametersByCategory: updated,
      lastUpdated: DateTime.now(),
    );
  }

  void invalidate() {
    state = const CategoryParametersCacheState();
  }
}

final categoryParametersCacheProvider = StateNotifierProvider<CategoryParametersCacheNotifier, CategoryParametersCacheState>((ref) {
  return CategoryParametersCacheNotifier();
});
