import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  final List<ConfigCategoryModel> _categories = const [
    ConfigCategoryModel(
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
    ConfigCategoryModel(
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
    ConfigCategoryModel(
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
    ConfigCategoryModel(
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
    ConfigCategoryModel(
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
    ConfigCategoryModel(
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

  late List<ConfigParameterModel> _parameters;

  @override
  void initState() {
    super.initState();
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
        paramCode: 'A_POS',
        paramName: 'A+',
        isDefault: true,
        priority: 1,
        isActive: true,
        description: 'A Positive Blood Group',
        parameterExternalCode: 'BLD-A-POS',
        parameterColor: '#DA3633',
        parameterIcon: 'bloodtype',
      ),
      const ConfigParameterModel(
        parameterId: 3002,
        categoryId: 3,
        paramCode: 'B_POS',
        paramName: 'B+',
        isDefault: false,
        priority: 2,
        isActive: true,
        description: 'B Positive Blood Group',
        parameterExternalCode: 'BLD-B-POS',
        parameterColor: '#DA3633',
        parameterIcon: 'bloodtype',
      ),
      const ConfigParameterModel(
        parameterId: 3003,
        categoryId: 3,
        paramCode: 'O_POS',
        paramName: 'O+',
        isDefault: false,
        priority: 3,
        isActive: true,
        description: 'O Positive Universal Donor',
        parameterExternalCode: 'BLD-O-POS',
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

  @override
  Widget build(BuildContext context) {
    final filtered = _categories.where((c) {
      return c.categoryName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.categoryCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return MasterDetailLayout(
      masterWidget: _buildMasterTable(filtered),
      detailWidget: _selectedCategory != null ? _buildDetailInspector(_selectedCategory!) : null,
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
                        onTap: () => setState(() => _selectedCategory = cat),
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
                                child: Text(cat.categoryName, style: const TextStyle(color: AppColors.brandPrimary, fontSize: 13, fontWeight: FontWeight.w800, fontFamily: 'monospace')),
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
                                    Text('${cat.categoryColor ?? "#2F81F7"} (${cat.categoryExternalCode ?? "N/A"})', style: const TextStyle(color: AppColors.textSubtle, fontSize: 11, fontFamily: 'monospace')),
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

  Widget _buildDetailInspector(ConfigCategoryModel cat) {
    final catParams = _parameters.where((p) => p.categoryId == cat.categoryId).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: DqmsTextField(label: 'Category Code', initialValue: cat.categoryCode)),
              const SizedBox(width: 12),
              Expanded(child: DqmsTextField(label: 'Priority Level', initialValue: '${cat.priority}')),
            ],
          ),
          const SizedBox(height: 14),
          DqmsTextField(label: 'Category Name (C_*)', initialValue: cat.categoryName),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: DqmsTextField(label: 'External Code', initialValue: cat.categoryExternalCode ?? '')),
              const SizedBox(width: 12),
              Expanded(child: DqmsTextField(label: 'External ID', initialValue: cat.categoryExternalId ?? '')),
            ],
          ),
          const SizedBox(height: 14),

          // INTERACTIVE CATEGORY COLOR PICKER & DISPLAY VALUE
          _DqmsColorPicker(
            label: 'Category Color',
            initialHex: cat.categoryColor ?? '#2F81F7',
            onColorChanged: (hex) {
              // Updates category color
            },
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(child: DqmsTextField(label: 'Icon Identifier', initialValue: cat.categoryIcon ?? 'category')),
              const SizedBox(width: 12),
              Expanded(child: DqmsTextField(label: 'Category Image URL', initialValue: cat.categoryImage ?? 'https://cdn.dqms.org/categories/default.png')),
            ],
          ),
          const SizedBox(height: 14),
          DqmsTextField(label: 'Description & System Usage', initialValue: cat.description, maxLines: 2),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Allow User Modifications: ${cat.allowModify ? "YES" : "NO (System Fixed)"}', style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600)),
              const Spacer(),
              DqmsStatusBadge.activeState(cat.active),
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
                child: Text('${catParams.length} Items', style: const TextStyle(color: AppColors.brandPrimary, fontSize: 10, fontWeight: FontWeight.w800)),
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
                onPressed: () => _showAddParameterModal(context, cat),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Parameter Items Container
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: catParams.isEmpty
                ? const Center(
                    child: Text('No parameters configured. Click "+ Add Parameter" above.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  )
                : ListView.separated(
                    itemCount: catParams.length,
                    separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                    itemBuilder: (ctx, idx) {
                      final p = catParams[idx];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Text('${p.parameterId}', style: const TextStyle(color: AppColors.brandPrimary, fontSize: 11, fontWeight: FontWeight.w800, fontFamily: 'monospace')),
                            const SizedBox(width: 10),

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

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(p.paramCode, style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w700)),
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
                          ],
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Category ${cat.categoryName} updated with Category Color.'), backgroundColor: AppColors.statusActive),
              );
            },
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
    String selectedCategoryColor = '#2F81F7';
    final iconCtrl = TextEditingController(text: 'category');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: AppColors.bgSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: AppColors.borderSubtle)),
          title: const Text('Create ConfigCategory (.NET Entity)', style: TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.w700)),
          content: SizedBox(
            width: 480,
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
                  DqmsTextField(label: 'External Code', controller: extCodeCtrl),
                  const SizedBox(height: 12),

                  // Category Color Picker with Display Value
                  _DqmsColorPicker(
                    label: 'Category Color',
                    initialHex: selectedCategoryColor,
                    onColorChanged: (hex) => setModalState(() => selectedCategoryColor = hex),
                  ),
                  const SizedBox(height: 12),

                  DqmsTextField(label: 'Category Icon Identifier', controller: iconCtrl),
                  const SizedBox(height: 12),
                  DqmsTextField(label: 'Description & System Usage', controller: descCtrl, maxLines: 2),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandPrimary, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ConfigCategory created.'), backgroundColor: AppColors.statusActive),
                );
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
    String selectedParameterColor = '#2F81F7'; // Parameter Color
    final iconCtrl = TextEditingController(text: 'code');
    final imageCtrl = TextEditingController();
    bool isDefault = false;

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
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(flex: 2, child: DqmsTextField(label: 'Parameter ID (Range)', controller: idCtrl)),
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

                  // INTERACTIVE PARAMETER COLOR PICKER WITH DISPLAY VALUE
                  _DqmsColorPicker(
                    label: 'Parameter Color',
                    initialHex: selectedParameterColor,
                    onColorChanged: (hex) => setModalState(() => selectedParameterColor = hex),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: DqmsTextField(label: 'External Code', controller: extCodeCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: DqmsTextField(label: 'Icon Name', controller: iconCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DqmsTextField(label: 'Image Asset URL', controller: imageCtrl),
                  const SizedBox(height: 12),
                  DqmsTextField(label: 'Description', controller: descCtrl, maxLines: 2),
                  const SizedBox(height: 8),
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
                  isActive: true,
                  description: descCtrl.text.isEmpty ? 'Custom Parameter' : descCtrl.text,
                  parameterExternalCode: extCodeCtrl.text.isEmpty ? null : extCodeCtrl.text,
                  parameterColor: selectedParameterColor,
                  parameterIcon: iconCtrl.text,
                  parameterImage: imageCtrl.text.isEmpty ? null : imageCtrl.text,
                );

                setState(() {
                  _parameters.add(newParam);
                });

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Parameter ${newParam.paramCode} created with Parameter Color ${newParam.parameterColor}.'), backgroundColor: AppColors.statusActive),
                );
              },
              child: const Text('Add Parameter'),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseHexColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return AppColors.brandPrimary;
    try {
      final hex = hexString.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.brandPrimary;
    }
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
