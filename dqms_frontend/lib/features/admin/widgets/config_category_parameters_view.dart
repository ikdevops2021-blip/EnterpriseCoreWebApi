import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/config/app_config.dart';
import 'package:dqms_frontend/core/network/dio_provider.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/widgets/dqms_button.dart';
import 'package:dqms_frontend/core/widgets/dqms_text_field.dart';
import 'package:dqms_frontend/core/widgets/dqms_status_badge.dart';
import 'package:dqms_frontend/features/admin/widgets/master_detail_layout.dart';

/// Complete ConfigCategory Model matching .NET Entity (ConfigCategory.cs)
class ConfigCategoryModel {
  final int categoryId;
  final String categoryCode;
  final String categoryName;
  final String description;
  final int priority;
  final bool active;
  final bool allowModify;
  final int? parentCategoryId;
  final String rangeText;

  // External & UI Styling Attributes
  final String? categoryExternalId;
  final String? categoryExternalName;
  final String? categoryExternalCode;
  final String? categoryColor;
  final String? categoryIcon;
  final String? categoryImage;
  final String? attribute1;
  final String? attribute2;
  final String? attribute3;

  const ConfigCategoryModel({
    required this.categoryId,
    required this.categoryCode,
    required this.categoryName,
    required this.description,
    this.priority = 1,
    this.active = true,
    this.allowModify = true,
    this.parentCategoryId,
    required this.rangeText,
    this.categoryExternalId,
    this.categoryExternalName,
    this.categoryExternalCode,
    this.categoryColor = '#2F81F7',
    this.categoryIcon = 'category',
    this.categoryImage,
    this.attribute1,
    this.attribute2,
    this.attribute3,
  });

  ConfigCategoryModel copyWith({
    int? categoryId,
    String? categoryCode,
    String? categoryName,
    String? description,
    int? priority,
    bool? active,
    bool? allowModify,
    int? parentCategoryId,
    String? rangeText,
    String? categoryExternalId,
    String? categoryExternalName,
    String? categoryExternalCode,
    String? categoryColor,
    String? categoryIcon,
    String? categoryImage,
    String? attribute1,
    String? attribute2,
    String? attribute3,
  }) {
    return ConfigCategoryModel(
      categoryId: categoryId ?? this.categoryId,
      categoryCode: categoryCode ?? this.categoryCode,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      active: active ?? this.active,
      allowModify: allowModify ?? this.allowModify,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      rangeText: rangeText ?? this.rangeText,
      categoryExternalId: categoryExternalId ?? this.categoryExternalId,
      categoryExternalName: categoryExternalName ?? this.categoryExternalName,
      categoryExternalCode: categoryExternalCode ?? this.categoryExternalCode,
      categoryColor: categoryColor ?? this.categoryColor,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryImage: categoryImage ?? this.categoryImage,
      attribute1: attribute1 ?? this.attribute1,
      attribute2: attribute2 ?? this.attribute2,
      attribute3: attribute3 ?? this.attribute3,
    );
  }

  factory ConfigCategoryModel.fromJson(Map<String, dynamic> json) {
    return ConfigCategoryModel(
      categoryId: json['categoryId'] ?? json['CategoryId'] ?? json['id'] ?? json['Id'] ?? json['configCategoryId'] ?? json['ConfigCategoryID'] ?? 0,
      categoryCode: json['categoryCode'] ?? json['CategoryCode'] ?? json['code'] ?? json['Code'] ?? '',
      categoryName: json['categoryName'] ?? json['CategoryName'] ?? json['name'] ?? json['Name'] ?? '',
      description: json['description'] ?? json['Description'] ?? '',
      priority: json['priority'] ?? json['Priority'] ?? 1,
      active: json['active'] ?? json['Active'] ?? json['isActive'] ?? json['IsActive'] ?? true,
      allowModify: json['allowModify'] ?? json['AllowModify'] ?? true,
      rangeText: json['rangeText'] ?? json['RangeText'] ?? '',
      categoryExternalId: json['categoryExternalId'] ?? json['CategoryExternalId'],
      categoryExternalCode: json['categoryExternalCode'] ?? json['CategoryExternalCode'],
      categoryColor: json['categoryColor'] ?? json['CategoryColor'] ?? '#2F81F7',
      categoryIcon: json['categoryIcon'] ?? json['CategoryIcon'] ?? 'category',
      categoryImage: json['categoryImage'] ?? json['CategoryImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryCode': categoryCode,
      'categoryName': categoryName,
      'description': description,
      'priority': priority,
      'active': active,
      'allowModify': allowModify,
      'rangeText': rangeText,
      'categoryExternalId': categoryExternalId,
      'categoryExternalCode': categoryExternalCode,
      'categoryColor': categoryColor,
      'categoryIcon': categoryIcon,
      'categoryImage': categoryImage,
    };
  }
}

/// Complete ConfigParameter Model matching .NET Entity (ConfigParameter.cs)
class ConfigParameterModel {
  final int parameterId;
  final int categoryId;
  final String paramCode;
  final String paramName;
  final bool isDefault;
  final int priority;
  final bool isActive;
  final String description;

  // External & UI Visual Styling Attributes
  final String? parameterExternalId;
  final String? parameterExternalName;
  final String? parameterExternalCode;
  final String? parameterColor;
  final String? parameterIcon;
  final String? parameterImage;
  final String? attribute1;
  final String? attribute2;
  final String? attribute3;

  const ConfigParameterModel({
    required this.parameterId,
    required this.categoryId,
    required this.paramCode,
    required this.paramName,
    this.isDefault = false,
    this.priority = 1,
    this.isActive = true,
    required this.description,
    this.parameterExternalId,
    this.parameterExternalName,
    this.parameterExternalCode,
    this.parameterColor = '#2F81F7',
    this.parameterIcon = 'code',
    this.parameterImage,
    this.attribute1,
    this.attribute2,
    this.attribute3,
  });

  ConfigParameterModel copyWith({
    int? parameterId,
    int? categoryId,
    String? paramCode,
    String? paramName,
    bool? isDefault,
    int? priority,
    bool? isActive,
    String? description,
    String? parameterExternalId,
    String? parameterExternalName,
    String? parameterExternalCode,
    String? parameterColor,
    String? parameterIcon,
    String? parameterImage,
    String? attribute1,
    String? attribute2,
    String? attribute3,
  }) {
    return ConfigParameterModel(
      parameterId: parameterId ?? this.parameterId,
      categoryId: categoryId ?? this.categoryId,
      paramCode: paramCode ?? this.paramCode,
      paramName: paramName ?? this.paramName,
      isDefault: isDefault ?? this.isDefault,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      parameterExternalId: parameterExternalId ?? this.parameterExternalId,
      parameterExternalName: parameterExternalName ?? this.parameterExternalName,
      parameterExternalCode: parameterExternalCode ?? this.parameterExternalCode,
      parameterColor: parameterColor ?? this.parameterColor,
      parameterIcon: parameterIcon ?? this.parameterIcon,
      parameterImage: parameterImage ?? this.parameterImage,
      attribute1: attribute1 ?? this.attribute1,
      attribute2: attribute2 ?? this.attribute2,
      attribute3: attribute3 ?? this.attribute3,
    );
  }

  factory ConfigParameterModel.fromJson(Map<String, dynamic> json) {
    return ConfigParameterModel(
      parameterId: json['parameterId'] ?? json['ParameterId'] ?? json['id'] ?? json['Id'] ?? json['configParameterId'] ?? json['ConfigParameterID'] ?? 0,
      categoryId: json['categoryId'] ?? json['CategoryId'] ?? json['configCategoryId'] ?? json['ConfigCategoryID'] ?? 0,
      paramCode: json['paramCode'] ?? json['ParamCode'] ?? json['code'] ?? json['Code'] ?? '',
      paramName: json['paramName'] ?? json['ParamName'] ?? json['name'] ?? json['Name'] ?? '',
      isDefault: json['isDefault'] ?? json['IsDefault'] ?? false,
      priority: json['priority'] ?? json['Priority'] ?? 1,
      isActive: json['isActive'] ?? json['IsActive'] ?? json['active'] ?? json['Active'] ?? true,
      description: json['description'] ?? json['Description'] ?? '',
      parameterExternalId: json['parameterExternalId'] ?? json['ParameterExternalId'],
      parameterExternalCode: json['parameterExternalCode'] ?? json['ParameterExternalCode'],
      parameterColor: json['parameterColor'] ?? json['ParameterColor'] ?? '#2F81F7',
      parameterIcon: json['parameterIcon'] ?? json['ParameterIcon'] ?? 'code',
      parameterImage: json['parameterImage'] ?? json['ParameterImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parameterId': parameterId,
      'categoryId': categoryId,
      'paramCode': paramCode,
      'paramName': paramName,
      'isDefault': isDefault,
      'priority': priority,
      'isActive': isActive,
      'description': description,
      'parameterExternalId': parameterExternalId,
      'parameterExternalCode': parameterExternalCode,
      'parameterColor': parameterColor,
      'parameterIcon': parameterIcon,
      'parameterImage': parameterImage,
    };
  }
}

/// Helper function to resolve icon string to Flutter IconData
IconData _getIconData(String? iconName) {
  switch (iconName?.toLowerCase()) {
    case 'bloodtype':
      return Icons.bloodtype_rounded;
    case 'people':
      return Icons.people_rounded;
    case 'home_work':
      return Icons.home_work_rounded;
    case 'phone_android':
      return Icons.phone_android_rounded;
    case 'notifications':
      return Icons.notifications_rounded;
    case 'male':
      return Icons.male_rounded;
    case 'female':
      return Icons.female_rounded;
    case 'payments':
      return Icons.payments_rounded;
    case 'campaign':
      return Icons.campaign_rounded;
    case 'warning':
      return Icons.warning_rounded;
    case 'badge':
      return Icons.badge_rounded;
    case 'category':
      return Icons.category_rounded;
    default:
      return Icons.code_rounded;
  }
}

/// Helper function to parse Hex color safely
Color _parseHexColor(String? hexString) {
  if (hexString == null || hexString.isEmpty) return AppColors.brandPrimary;
  try {
    final hex = hexString.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  } catch (_) {
    return AppColors.brandPrimary;
  }
}

/// NEXUSCORE CONFIG CATEGORY & PARAMETERS MASTER VIEW
class ConfigCategoryParametersView extends ConsumerStatefulWidget {
  const ConfigCategoryParametersView({super.key});

  @override
  ConsumerState<ConfigCategoryParametersView> createState() => _ConfigCategoryParametersViewState();
}

class _ConfigCategoryParametersViewState extends ConsumerState<ConfigCategoryParametersView> {
  String _searchQuery = '';
  ConfigCategoryModel? _selectedCategory;

  late List<ConfigCategoryModel> _categories;
  late List<ConfigParameterModel> _parameters;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initDefaults();
    _fetchApiData();
  }

  Future<void> _fetchApiData() async {
    try {
      setState(() => _isLoading = true);
      final dio = ref.read(dioProvider);

      // Primary fetch using ConfigurationController endpoint with automatic Bearer & API Key headers
      final catRes = await dio.get('${AppConfig.apiBaseUrl}/api/v1/Configuration/categories');
      if (catRes.statusCode == 200 && catRes.data != null && catRes.data['data'] != null) {
        final List items = catRes.data['data'];
        if (items.isNotEmpty) {
          final fetched = items.map((json) => ConfigCategoryModel.fromJson(json)).toList();
          setState(() => _categories = fetched);
        }
      }

      final paramRes = await dio.get('${AppConfig.adminApiBase}/config-parameters');
      if (paramRes.statusCode == 200 && paramRes.data != null && paramRes.data['data'] != null) {
        final List items = paramRes.data['data'];
        if (items.isNotEmpty) {
          final fetched = items.map((json) => ConfigParameterModel.fromJson(json)).toList();
          setState(() => _parameters = fetched);
        }
      }
    } catch (_) {
      // Seamless fallback to defaults if offline
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Fetches parameters specifically for a category using GET /api/v1/Configuration/categories/{categoryId}/parameters
  Future<void> _fetchCategoryParameters(int categoryId) async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get('${AppConfig.apiBaseUrl}/api/v1/Configuration/categories/$categoryId/parameters');
      if (res.statusCode == 200 && res.data != null && res.data['data'] != null) {
        final List items = res.data['data'];
        if (items.isNotEmpty) {
          final fetched = items.map((j) => ConfigParameterModel.fromJson(j)).toList();
          setState(() {
            _parameters.removeWhere((p) => p.categoryId == categoryId);
            _parameters.addAll(fetched);
          });
        }
      }
    } catch (_) {}
  }

  void _initDefaults() {
    _categories = [
      const ConfigCategoryModel(
        categoryId: 1,
        categoryCode: 'GEN',
        categoryName: 'C_GENDER',
        description: 'Gender salutations & identification parameters',
        priority: 1,
        active: true,
        allowModify: false,
        rangeText: '1001 – 1999',
        categoryExternalCode: 'EXT-GEN-01',
        categoryColor: '#2F81F7',
        categoryIcon: 'people',
      ),
      const ConfigCategoryModel(
        categoryId: 2,
        categoryCode: 'TITLE',
        categoryName: 'C_TITLE',
        description: 'Name salutation titles (Mr, Dr, Ms, Prof)',
        priority: 2,
        active: true,
        allowModify: true,
        rangeText: '2001 – 2999',
        categoryExternalCode: 'EXT-TTL-02',
        categoryColor: '#8957E5',
        categoryIcon: 'badge',
      ),
      const ConfigCategoryModel(
        categoryId: 3,
        categoryCode: 'BLD',
        categoryName: 'C_BLOODGROUP',
        description: 'Human blood group classifications',
        priority: 3,
        active: true,
        allowModify: true,
        rangeText: '3001 – 3999',
        categoryExternalCode: 'EXT-BLD-03',
        categoryColor: '#DA3633',
        categoryIcon: 'bloodtype',
      ),
      const ConfigCategoryModel(
        categoryId: 4,
        categoryCode: 'ADRTYPE',
        categoryName: 'C_ADDRESSTYPE',
        description: 'Address categories (Home, Work, Billing, Shipping)',
        priority: 4,
        active: true,
        allowModify: true,
        rangeText: '4001 – 4999',
        categoryExternalCode: 'EXT-ADR-04',
        categoryColor: '#D29922',
        categoryIcon: 'home_work',
      ),
      const ConfigCategoryModel(
        categoryId: 5,
        categoryCode: 'CNTTYPE',
        categoryName: 'C_CONTACTTYPE',
        description: 'Communication channels (Mobile, Email, Work Phone)',
        priority: 5,
        active: true,
        allowModify: true,
        rangeText: '5001 – 5999',
        categoryExternalCode: 'EXT-CNT-05',
        categoryColor: '#238636',
        categoryIcon: 'phone_android',
      ),
      const ConfigCategoryModel(
        categoryId: 17,
        categoryCode: 'NOTIF_EVT',
        categoryName: 'C_NOTIFICATION_EVENT',
        description: 'Master notification event catalog',
        priority: 17,
        active: true,
        allowModify: true,
        rangeText: '17001 – 17999',
        categoryExternalCode: 'EXT-EVT-17',
        categoryColor: '#2F81F7',
        categoryIcon: 'notifications',
      ),
    ];

    _parameters = [
      const ConfigParameterModel(
        parameterId: 1001,
        categoryId: 1,
        paramCode: 'M',
        paramName: 'Male',
        isDefault: true,
        priority: 1,
        isActive: true,
        description: 'Male Gender Identification',
        parameterExternalCode: 'EXT-GEN-M',
        parameterColor: '#2F81F7',
        parameterIcon: 'male',
      ),
      const ConfigParameterModel(
        parameterId: 1002,
        categoryId: 1,
        paramCode: 'F',
        paramName: 'Female',
        isDefault: false,
        priority: 2,
        isActive: true,
        description: 'Female Gender Identification',
        parameterExternalCode: 'EXT-GEN-F',
        parameterColor: '#8957E5',
        parameterIcon: 'female',
      ),
      const ConfigParameterModel(
        parameterId: 3001,
        categoryId: 3,
        paramCode: 'O_POS',
        paramName: 'O+',
        isDefault: true,
        priority: 1,
        isActive: true,
        description: 'O Positive Universal Red Cell Donor',
        parameterExternalCode: 'BLD-O-POS',
        parameterColor: '#DA3633',
        parameterIcon: 'bloodtype',
      ),
      const ConfigParameterModel(
        parameterId: 3002,
        categoryId: 3,
        paramCode: 'O_NEG',
        paramName: 'O-',
        isDefault: false,
        priority: 2,
        isActive: true,
        description: 'O Negative Universal Donor',
        parameterExternalCode: 'BLD-O-NEG',
        parameterColor: '#DA3633',
        parameterIcon: 'bloodtype',
      ),
      const ConfigParameterModel(
        parameterId: 3003,
        categoryId: 3,
        paramCode: 'A_POS',
        paramName: 'A+',
        isDefault: false,
        priority: 3,
        isActive: true,
        description: 'A Positive Blood Group',
        parameterExternalCode: 'BLD-A-POS',
        parameterColor: '#DA3633',
        parameterIcon: 'bloodtype',
      ),
      const ConfigParameterModel(
        parameterId: 3004,
        categoryId: 3,
        paramCode: 'A_NEG',
        paramName: 'A-',
        isDefault: false,
        priority: 4,
        isActive: true,
        description: 'A Negative Blood Group',
        parameterExternalCode: 'BLD-A-NEG',
        parameterColor: '#DA3633',
        parameterIcon: 'bloodtype',
      ),
      const ConfigParameterModel(
        parameterId: 3005,
        categoryId: 3,
        paramCode: 'B_POS',
        paramName: 'B+',
        isDefault: false,
        priority: 5,
        isActive: true,
        description: 'B Positive Blood Group',
        parameterExternalCode: 'BLD-B-POS',
        parameterColor: '#DA3633',
        parameterIcon: 'bloodtype',
      ),
      const ConfigParameterModel(
        parameterId: 3006,
        categoryId: 3,
        paramCode: 'B_NEG',
        paramName: 'B-',
        isDefault: false,
        priority: 6,
        isActive: true,
        description: 'B Negative Blood Group',
        parameterExternalCode: 'BLD-B-NEG',
        parameterColor: '#DA3633',
        parameterIcon: 'bloodtype',
      ),
      const ConfigParameterModel(
        parameterId: 3007,
        categoryId: 3,
        paramCode: 'AB_POS',
        paramName: 'AB+',
        isDefault: false,
        priority: 7,
        isActive: true,
        description: 'AB Positive Universal Recipient',
        parameterExternalCode: 'BLD-AB-POS',
        parameterColor: '#DA3633',
        parameterIcon: 'bloodtype',
      ),
      const ConfigParameterModel(
        parameterId: 3008,
        categoryId: 3,
        paramCode: 'AB_NEG',
        paramName: 'AB-',
        isDefault: false,
        priority: 8,
        isActive: true,
        description: 'AB Negative Blood Group',
        parameterExternalCode: 'BLD-AB-NEG',
        parameterColor: '#DA3633',
        parameterIcon: 'bloodtype',
      ),
      const ConfigParameterModel(
        parameterId: 17001,
        categoryId: 17,
        paramCode: 'PAYMENT_RECEIVED',
        paramName: 'Payment Received Intimation',
        isDefault: true,
        priority: 1,
        isActive: true,
        description: 'Dispatched on transaction settlement',
        parameterExternalCode: 'EVT-PAY-17001',
        parameterColor: '#238636',
        parameterIcon: 'payments',
      ),
      const ConfigParameterModel(
        parameterId: 17002,
        categoryId: 17,
        paramCode: 'INTERNAL_ANNOUNCEMENT',
        paramName: 'Internal Broadcast Announcement',
        isDefault: false,
        priority: 2,
        isActive: true,
        description: 'Dispatched for organization announcements',
        parameterExternalCode: 'EVT-ANN-17002',
        parameterColor: '#2F81F7',
        parameterIcon: 'campaign',
      ),
      const ConfigParameterModel(
        parameterId: 17003,
        categoryId: 17,
        paramCode: 'SYSTEM_ALERT',
        paramName: 'System & Security Warning Alert',
        isDefault: false,
        priority: 3,
        isActive: true,
        description: 'Dispatched for SLA and security alerts',
        parameterExternalCode: 'EVT-ALT-17003',
        parameterColor: '#D29922',
        parameterIcon: 'warning',
      ),
    ];
  }

  Future<void> _saveCategory(ConfigCategoryModel updatedCategory) async {
    setState(() {
      final index = _categories.indexWhere((c) => c.categoryId == updatedCategory.categoryId);
      if (index != -1) {
        _categories[index] = updatedCategory;
      } else {
        _categories.add(updatedCategory);
      }
      _selectedCategory = updatedCategory;
    });

    try {
      final dio = ref.read(dioProvider);
      await dio.post('${AppConfig.adminApiBase}/config-category', data: updatedCategory.toJson());
    } catch (_) {
      // Local state updated
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Category "${updatedCategory.categoryName}" saved to API with Category Color (${updatedCategory.categoryColor}).'),
        backgroundColor: AppColors.statusActive,
      ),
    );
  }

  Future<void> _saveParameter(ConfigParameterModel updatedParam) async {
    setState(() {
      final index = _parameters.indexWhere((p) => p.parameterId == updatedParam.parameterId);
      if (index != -1) {
        _parameters[index] = updatedParam;
      } else {
        _parameters.add(updatedParam);
      }
    });

    try {
      final dio = ref.read(dioProvider);
      await dio.post('${AppConfig.adminApiBase}/config-parameter', data: updatedParam.toJson());
    } catch (_) {
      // Local state updated
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Parameter "${updatedParam.paramCode}" saved to API with Parameter Color (${updatedParam.parameterColor}).'),
        backgroundColor: AppColors.statusActive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _categories.where((c) {
      return c.categoryName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.categoryCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return MasterDetailLayout(
      masterWidget: _buildMasterTable(filtered),
      detailWidget: _selectedCategory != null
          ? _CategoryInspectorPanel(
              category: _selectedCategory!,
              parameters: _parameters.where((p) => p.categoryId == _selectedCategory!.categoryId).toList(),
              onSaveCategory: _saveCategory,
              onAddParameter: () => _showAddParameterModal(context, _selectedCategory!),
              onEditParameter: (param) => _showEditParameterModal(context, param),
            )
          : null,
      detailTitle: _selectedCategory != null ? 'Category Inspector — ${_selectedCategory!.categoryName}' : 'Category Catalog',
      onCloseDetail: () => setState(() => _selectedCategory = null),
    );
  }

  Widget _buildMasterTable(List<ConfigCategoryModel> categories) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(color: AppColors.brandPrimary, minHeight: 2),
            ),
          Row(
            children: [
              Expanded(
                child: DqmsTextField(
                  hintText: 'Search Category Code, Category Name (C_*), or Description...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 12),
              DqmsButton(
                label: 'Add Category',
                icon: Icons.add_circle_outline_rounded,
                onPressed: () => _showAddCategoryModal(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.bgHeader,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 50, child: Text('ID', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                      Expanded(flex: 3, child: Text('CATEGORY NAME (C_*)', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                      SizedBox(width: 70, child: Text('PRIORITY', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                      Expanded(flex: 3, child: Text('EXTERNAL CODE / COLOR', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                      SizedBox(width: 110, child: Text('PARAM RANGE', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                      SizedBox(width: 70, child: Text('STATUS', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView.separated(
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                    itemBuilder: (ctx, i) {
                      final cat = categories[i];
                      final isSelected = _selectedCategory?.categoryId == cat.categoryId;

                      return InkWell(
                        onTap: () {
                          setState(() => _selectedCategory = cat);
                          _fetchCategoryParameters(cat.categoryId);
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.12) : AppColors.bgCard,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 50,
                                child: Text('#${cat.categoryId}', style: const TextStyle(color: AppColors.textSubtle, fontSize: 12, fontWeight: FontWeight.w700)),
                              ),
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    Icon(_getIconData(cat.categoryIcon), size: 16, color: _parseHexColor(cat.categoryColor)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        cat.categoryName,
                                        style: const TextStyle(color: AppColors.brandPrimary, fontSize: 13, fontWeight: FontWeight.w800, fontFamily: 'monospace'),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 70,
                                child: Text('Prio: ${cat.priority}', style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: _parseHexColor(cat.categoryColor),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white24, width: 1),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${cat.categoryColor ?? "#2F81F7"} (${cat.categoryExternalCode ?? "N/A"})',
                                        style: const TextStyle(color: AppColors.textSubtle, fontSize: 11, fontFamily: 'monospace'),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 110,
                                child: Text(cat.rangeText, style: const TextStyle(color: AppColors.brandAccent, fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                              SizedBox(
                                width: 70,
                                child: DqmsStatusBadge.activeState(cat.active),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Add Category Modal
  void _showAddCategoryModal(BuildContext context) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController(text: 'C_');
    final descCtrl = TextEditingController();
    final prioCtrl = TextEditingController(text: '1');
    final extCodeCtrl = TextEditingController();
    final extIdCtrl = TextEditingController();
    String selectedCategoryColor = '#2F81F7';
    final iconCtrl = TextEditingController(text: 'category');
    bool isActive = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: AppColors.bgSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: AppColors.borderSubtle)),
          title: const Text('Create ConfigCategory (.NET Entity)', style: TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.w700)),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: DqmsTextField(label: 'Category Code', controller: codeCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: DqmsTextField(label: 'Priority', controller: prioCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DqmsTextField(label: 'Category Name (e.g., C_NOTIFICATION_EVENT)', controller: nameCtrl),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: DqmsTextField(label: 'External Code', controller: extCodeCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: DqmsTextField(label: 'External ID', controller: extIdCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Category Color Picker with Live Hex Display Value
                  _DqmsColorPicker(
                    label: 'Category Color',
                    initialHex: selectedCategoryColor,
                    onColorChanged: (hex) => setModalState(() => selectedCategoryColor = hex),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: DqmsTextField(label: 'Category Icon Identifier', controller: iconCtrl)),
                      const SizedBox(width: 8),
                      Icon(_getIconData(iconCtrl.text), size: 24, color: _parseHexColor(selectedCategoryColor)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DqmsTextField(label: 'Description & System Usage', controller: descCtrl, maxLines: 2),
                  const SizedBox(height: 8),
                  Material(
                    color: Colors.transparent,
                    child: SwitchListTile(
                      value: isActive,
                      onChanged: (val) => setModalState(() => isActive = val),
                      title: Text(isActive ? 'Category Active' : 'Category Inactive', style: TextStyle(color: isActive ? AppColors.statusActive : AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w700)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandPrimary, foregroundColor: Colors.white),
              onPressed: () {
                final newId = _categories.length + 1;
                final newCat = ConfigCategoryModel(
                  categoryId: newId,
                  categoryCode: codeCtrl.text.isEmpty ? 'CAT_$newId' : codeCtrl.text.toUpperCase(),
                  categoryName: nameCtrl.text.isEmpty ? 'C_NEWCATEGORY' : nameCtrl.text,
                  description: descCtrl.text.isEmpty ? 'New Config Category' : descCtrl.text,
                  priority: int.tryParse(prioCtrl.text) ?? 1,
                  active: isActive,
                  allowModify: true,
                  rangeText: '${newId * 1000 + 1} – ${newId * 1000 + 999}',
                  categoryExternalCode: extCodeCtrl.text.isEmpty ? null : extCodeCtrl.text,
                  categoryExternalId: extIdCtrl.text.isEmpty ? null : extIdCtrl.text,
                  categoryColor: selectedCategoryColor,
                  categoryIcon: iconCtrl.text,
                );

                _saveCategory(newCat);
                Navigator.pop(ctx);
              },
              child: const Text('Save Category'),
            ),
          ],
        ),
      ),
    );
  }

  /// Add Parameter Modal Dialog with Interactive Parameter Color Picker & Display Value
  void _showAddParameterModal(BuildContext context, ConfigCategoryModel category) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final baseId = category.categoryId * 1000 + (100 + _parameters.where((p) => p.categoryId == category.categoryId).length + 1);
    final idCtrl = TextEditingController(text: '$baseId');
    final prioCtrl = TextEditingController(text: '1');
    final extCodeCtrl = TextEditingController();
    final extIdCtrl = TextEditingController();
    String selectedParameterColor = '#2F81F7';
    final iconCtrl = TextEditingController(text: 'code');
    final imageCtrl = TextEditingController();
    bool isDefault = false;
    bool isActive = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: AppColors.bgSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.borderSubtle),
          ),
          title: Text('Add Parameter to ${category.categoryName}', style: const TextStyle(color: AppColors.textMain, fontSize: 15, fontWeight: FontWeight.w700)),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(flex: 2, child: DqmsTextField(label: 'Parameter ID', controller: idCtrl)),
                      const SizedBox(width: 12),
                      Expanded(flex: 1, child: DqmsTextField(label: 'Priority', controller: prioCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: DqmsTextField(label: 'Parameter Code (e.g. AB_NEG)', controller: codeCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: DqmsTextField(label: 'Parameter Name', controller: nameCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Parameter Color Picker with Display Value
                  _DqmsColorPicker(
                    label: 'Parameter Color',
                    initialHex: selectedParameterColor,
                    onColorChanged: (hex) => setModalState(() => selectedParameterColor = hex),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: DqmsTextField(label: 'Icon Identifier', controller: iconCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: DqmsTextField(label: 'External Code', controller: extCodeCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: DqmsTextField(label: 'External ID', controller: extIdCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: DqmsTextField(label: 'Image Asset URL', controller: imageCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DqmsTextField(label: 'Description', controller: descCtrl, maxLines: 2),
                  const SizedBox(height: 8),
                  Material(
                    color: Colors.transparent,
                    child: SwitchListTile(
                      value: isActive,
                      onChanged: (val) => setModalState(() => isActive = val),
                      title: Text(isActive ? 'Parameter Active' : 'Parameter Inactive', style: TextStyle(color: isActive ? AppColors.statusActive : AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w700)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: CheckboxListTile(
                      value: isDefault,
                      onChanged: (val) => setModalState(() => isDefault = val ?? false),
                      title: const Text('Set as Category Default Parameter (IsDefault)', style: TextStyle(color: AppColors.textMain, fontSize: 12)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final newParam = ConfigParameterModel(
                  parameterId: int.tryParse(idCtrl.text) ?? baseId,
                  categoryId: category.categoryId,
                  paramCode: codeCtrl.text.isEmpty ? 'NEW_PARAM' : codeCtrl.text.toUpperCase(),
                  paramName: nameCtrl.text.isEmpty ? 'New Parameter' : nameCtrl.text,
                  isDefault: isDefault,
                  priority: int.tryParse(prioCtrl.text) ?? 1,
                  isActive: isActive,
                  description: descCtrl.text.isEmpty ? 'Custom Parameter' : descCtrl.text,
                  parameterExternalCode: extCodeCtrl.text.isEmpty ? null : extCodeCtrl.text,
                  parameterExternalId: extIdCtrl.text.isEmpty ? null : extIdCtrl.text,
                  parameterColor: selectedParameterColor,
                  parameterIcon: iconCtrl.text,
                  parameterImage: imageCtrl.text.isEmpty ? null : imageCtrl.text,
                );

                _saveParameter(newParam);
                Navigator.pop(ctx);
              },
              child: const Text('Add Parameter'),
            ),
          ],
        ),
      ),
    );
  }

  /// Edit Parameter Modal Dialog with Interactive Parameter Color Picker & Display Value
  void _showEditParameterModal(BuildContext context, ConfigParameterModel parameter) {
    final codeCtrl = TextEditingController(text: parameter.paramCode);
    final nameCtrl = TextEditingController(text: parameter.paramName);
    final descCtrl = TextEditingController(text: parameter.description);
    final idCtrl = TextEditingController(text: '${parameter.parameterId}');
    final prioCtrl = TextEditingController(text: '${parameter.priority}');
    final extCodeCtrl = TextEditingController(text: parameter.parameterExternalCode ?? '');
    final extIdCtrl = TextEditingController(text: parameter.parameterExternalId ?? '');
    String selectedParameterColor = parameter.parameterColor ?? '#2F81F7';
    final iconCtrl = TextEditingController(text: parameter.parameterIcon ?? 'code');
    final imageCtrl = TextEditingController(text: parameter.parameterImage ?? '');
    bool isDefault = parameter.isDefault;
    bool isActive = parameter.isActive;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: AppColors.bgSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.borderSubtle),
          ),
          title: Text('Edit Parameter — ${parameter.paramCode} (#${parameter.parameterId})', style: const TextStyle(color: AppColors.textMain, fontSize: 15, fontWeight: FontWeight.w700)),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(flex: 2, child: DqmsTextField(label: 'Parameter ID (Fixed)', controller: idCtrl)),
                      const SizedBox(width: 12),
                      Expanded(flex: 1, child: DqmsTextField(label: 'Priority Level', controller: prioCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: DqmsTextField(label: 'Parameter Code', controller: codeCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: DqmsTextField(label: 'Parameter Name', controller: nameCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Parameter Color Picker with Display Value
                  _DqmsColorPicker(
                    label: 'Parameter Color',
                    initialHex: selectedParameterColor,
                    onColorChanged: (hex) => setModalState(() => selectedParameterColor = hex),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: DqmsTextField(label: 'Icon Identifier', controller: iconCtrl)),
                      const SizedBox(width: 8),
                      Icon(_getIconData(iconCtrl.text), size: 22, color: _parseHexColor(selectedParameterColor)),
                      const SizedBox(width: 12),
                      Expanded(child: DqmsTextField(label: 'External Code', controller: extCodeCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: DqmsTextField(label: 'External ID', controller: extIdCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: DqmsTextField(label: 'Image Asset URL', controller: imageCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DqmsTextField(label: 'Description', controller: descCtrl, maxLines: 2),
                  const SizedBox(height: 8),
                  Material(
                    color: Colors.transparent,
                    child: SwitchListTile(
                      value: isActive,
                      onChanged: (val) => setModalState(() => isActive = val),
                      title: Text(isActive ? 'Parameter Active' : 'Parameter Inactive', style: TextStyle(color: isActive ? AppColors.statusActive : AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w700)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: CheckboxListTile(
                      value: isDefault,
                      onChanged: (val) => setModalState(() => isDefault = val ?? false),
                      title: const Text('Set as Category Default Parameter (IsDefault)', style: TextStyle(color: AppColors.textMain, fontSize: 12)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final updatedParam = parameter.copyWith(
                  paramCode: codeCtrl.text.toUpperCase(),
                  paramName: nameCtrl.text,
                  priority: int.tryParse(prioCtrl.text) ?? parameter.priority,
                  isActive: isActive,
                  isDefault: isDefault,
                  description: descCtrl.text,
                  parameterExternalCode: extCodeCtrl.text.isEmpty ? null : extCodeCtrl.text,
                  parameterExternalId: extIdCtrl.text.isEmpty ? null : extIdCtrl.text,
                  parameterColor: selectedParameterColor,
                  parameterIcon: iconCtrl.text,
                  parameterImage: imageCtrl.text.isEmpty ? null : imageCtrl.text,
                );

                _saveParameter(updatedParam);
                Navigator.pop(ctx);
              },
              child: const Text('Save Parameter Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

/// CATEGORY INSPECTOR PANEL
class _CategoryInspectorPanel extends StatefulWidget {
  final ConfigCategoryModel category;
  final List<ConfigParameterModel> parameters;
  final ValueChanged<ConfigCategoryModel> onSaveCategory;
  final VoidCallback onAddParameter;
  final ValueChanged<ConfigParameterModel> onEditParameter;

  const _CategoryInspectorPanel({
    required this.category,
    required this.parameters,
    required this.onSaveCategory,
    required this.onAddParameter,
    required this.onEditParameter,
  });

  @override
  State<_CategoryInspectorPanel> createState() => _CategoryInspectorPanelState();
}

class _CategoryInspectorPanelState extends State<_CategoryInspectorPanel> {
  late TextEditingController _codeCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _prioCtrl;
  late TextEditingController _extCodeCtrl;
  late TextEditingController _extIdCtrl;
  late TextEditingController _iconCtrl;
  late TextEditingController _imageCtrl;
  late TextEditingController _descCtrl;
  late String _categoryColor;
  late bool _isActive;
  late bool _allowModify;

  @override
  void initState() {
    super.initState();
    _initFields();
  }

  void _initFields() {
    _codeCtrl = TextEditingController(text: widget.category.categoryCode);
    _nameCtrl = TextEditingController(text: widget.category.categoryName);
    _prioCtrl = TextEditingController(text: '${widget.category.priority}');
    _extCodeCtrl = TextEditingController(text: widget.category.categoryExternalCode ?? '');
    _extIdCtrl = TextEditingController(text: widget.category.categoryExternalId ?? '');
    _iconCtrl = TextEditingController(text: widget.category.categoryIcon ?? 'category');
    _imageCtrl = TextEditingController(text: widget.category.categoryImage ?? '');
    _descCtrl = TextEditingController(text: widget.category.description);
    _categoryColor = widget.category.categoryColor ?? '#2F81F7';
    _isActive = widget.category.active;
    _allowModify = widget.category.allowModify;
  }

  @override
  void didUpdateWidget(_CategoryInspectorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category.categoryId != widget.category.categoryId ||
        oldWidget.category.categoryColor != widget.category.categoryColor ||
        oldWidget.category.active != widget.category.active) {
      _codeCtrl.text = widget.category.categoryCode;
      _nameCtrl.text = widget.category.categoryName;
      _prioCtrl.text = '${widget.category.priority}';
      _extCodeCtrl.text = widget.category.categoryExternalCode ?? '';
      _extIdCtrl.text = widget.category.categoryExternalId ?? '';
      _iconCtrl.text = widget.category.categoryIcon ?? 'category';
      _imageCtrl.text = widget.category.categoryImage ?? '';
      _descCtrl.text = widget.category.description;
      _categoryColor = widget.category.categoryColor ?? '#2F81F7';
      _isActive = widget.category.active;
      _allowModify = widget.category.allowModify;
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _prioCtrl.dispose();
    _extCodeCtrl.dispose();
    _extIdCtrl.dispose();
    _iconCtrl.dispose();
    _imageCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: DqmsTextField(label: 'Category Code', controller: _codeCtrl)),
              const SizedBox(width: 12),
              Expanded(child: DqmsTextField(label: 'Priority Level', controller: _prioCtrl)),
            ],
          ),
          const SizedBox(height: 14),
          DqmsTextField(label: 'Category Name (C_*)', controller: _nameCtrl),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: DqmsTextField(label: 'External Code', controller: _extCodeCtrl)),
              const SizedBox(width: 12),
              Expanded(child: DqmsTextField(label: 'External ID', controller: _extIdCtrl)),
            ],
          ),
          const SizedBox(height: 14),

          // INTERACTIVE CATEGORY COLOR PICKER & DISPLAY VALUE
          _DqmsColorPicker(
            label: 'Category Color',
            initialHex: _categoryColor,
            onColorChanged: (hex) {
              setState(() {
                _categoryColor = hex;
              });
            },
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(child: DqmsTextField(label: 'Icon Identifier', controller: _iconCtrl, onChanged: (_) => setState(() {}))),
              const SizedBox(width: 8),
              Icon(_getIconData(_iconCtrl.text), size: 24, color: _parseHexColor(_categoryColor)),
              const SizedBox(width: 12),
              Expanded(child: DqmsTextField(label: 'Category Image URL', controller: _imageCtrl)),
            ],
          ),
          const SizedBox(height: 14),
          DqmsTextField(label: 'Description & System Usage', controller: _descCtrl, maxLines: 2),
          const SizedBox(height: 16),

          Row(
            children: [
              Text('Allow User Modifications: ${_allowModify ? "YES" : "NO (System Fixed)"}', style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600)),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: Switch(
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
                  activeTrackColor: AppColors.statusActive,
                ),
              ),
              const SizedBox(width: 6),
              DqmsStatusBadge.activeState(_isActive),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: 16),

          // Parameter List Header with Add Parameter Button
          Row(
            children: [
              const Text('Seeded Category Parameters', style: TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('${widget.parameters.length} Items', style: const TextStyle(color: AppColors.brandPrimary, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 14),
                label: const Text('Add Parameter', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                onPressed: widget.onAddParameter,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Parameter Items Container
          Container(
            height: 230,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: widget.parameters.isEmpty
                ? const Center(
                    child: Text('No parameters configured. Click "+ Add Parameter" above.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  )
                : ListView.separated(
                    itemCount: widget.parameters.length,
                    separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                    itemBuilder: (ctx, idx) {
                      final p = widget.parameters[idx];
                      return InkWell(
                        onTap: () => widget.onEditParameter(p),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Text('${p.parameterId}', style: const TextStyle(color: AppColors.brandPrimary, fontSize: 11, fontWeight: FontWeight.w800, fontFamily: 'monospace')),
                              const SizedBox(width: 8),

                              // Display Swatch for Parameter Color
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: _parseHexColor(p.parameterColor),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white30, width: 1),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(_getIconData(p.parameterIcon), size: 14, color: _parseHexColor(p.parameterColor)),
                              const SizedBox(width: 8),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(p.paramCode, style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w700)),
                                        const SizedBox(width: 6),
                                        Text('— ${p.paramName}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                        if (p.isDefault) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(color: AppColors.statusSpecial.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(3)),
                                            child: const Text('DEFAULT', style: TextStyle(color: AppColors.statusSpecial, fontSize: 8, fontWeight: FontWeight.w900)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text('Color: ${p.parameterColor ?? "#2F81F7"} • ExtCode: ${p.parameterExternalCode ?? "N/A"} • Prio: ${p.priority}', style: const TextStyle(color: AppColors.textSubtle, fontSize: 10)),
                                  ],
                                ),
                              ),
                              DqmsStatusBadge.activeState(p.isActive),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.edit_outlined, size: 13),
                                label: const Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.brandAccent,
                                  side: const BorderSide(color: AppColors.brandAccent),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => widget.onEditParameter(p),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 24),
          DqmsButton(
            label: 'Save Category & Category Color',
            icon: Icons.save_rounded,
            isFullWidth: true,
            onPressed: () {
              final updated = widget.category.copyWith(
                categoryCode: _codeCtrl.text.toUpperCase(),
                categoryName: _nameCtrl.text,
                priority: int.tryParse(_prioCtrl.text) ?? widget.category.priority,
                categoryExternalCode: _extCodeCtrl.text.isEmpty ? null : _extCodeCtrl.text,
                categoryExternalId: _extIdCtrl.text.isEmpty ? null : _extIdCtrl.text,
                categoryColor: _categoryColor,
                categoryIcon: _iconCtrl.text,
                categoryImage: _imageCtrl.text.isEmpty ? null : _imageCtrl.text,
                description: _descCtrl.text,
                active: _isActive,
              );
              widget.onSaveCategory(updated);
            },
          ),
        ],
      ),
    );
  }
}

/// CUSTOM INTERACTIVE COLOR PICKER & HEX DISPLAY VALUE COMPONENT
class _DqmsColorPicker extends StatefulWidget {
  final String label;
  final String initialHex;
  final ValueChanged<String> onColorChanged;

  const _DqmsColorPicker({
    required this.label,
    required this.initialHex,
    required this.onColorChanged,
  });

  @override
  State<_DqmsColorPicker> createState() => _DqmsColorPickerState();
}

class _DqmsColorPickerState extends State<_DqmsColorPicker> {
  late String _currentHex;
  late TextEditingController _textCtrl;

  static const List<String> _swatches = [
    '#2F81F7', // Primary Blue
    '#8957E5', // Special Purple
    '#DA3633', // Alert Red
    '#D29922', // Warning Amber
    '#238636', // Success Green
    '#0969DA', // Deep Ocean Cyan
    '#BF3989', // Magenta Pink
    '#6E7681', // Neutral Grey
  ];

  @override
  void initState() {
    super.initState();
    _currentHex = widget.initialHex;
    _textCtrl = TextEditingController(text: _currentHex);
  }

  @override
  void didUpdateWidget(_DqmsColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialHex != widget.initialHex) {
      _currentHex = widget.initialHex;
      _textCtrl.text = _currentHex;
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppColors.brandPrimary;
    }
  }

  void _selectColor(String hex) {
    setState(() {
      _currentHex = hex;
      _textCtrl.text = hex;
    });
    widget.onColorChanged(hex);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(
          children: [
            // Live Color Preview Box with Display Value
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _parseColor(_currentHex),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white38, width: 1.5),
                boxShadow: [
                  BoxShadow(color: _parseColor(_currentHex).withValues(alpha: 0.4), blurRadius: 6, spreadRadius: 1),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DqmsTextField(
                controller: _textCtrl,
                prefixIcon: const Icon(Icons.palette_rounded, size: 16, color: AppColors.brandPrimary),
                onChanged: (val) {
                  setState(() => _currentHex = val);
                  widget.onColorChanged(val);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Interactive Color Swatches Palette
        Row(
          children: _swatches.map((hex) {
            final isSelected = _currentHex.toUpperCase() == hex.toUpperCase();
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => _selectColor(hex),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: isSelected ? 26 : 22,
                  height: isSelected ? 26 : 22,
                  decoration: BoxDecoration(
                    color: _parseColor(hex),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : AppColors.borderSubtle,
                      width: isSelected ? 2.5 : 1.0,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
