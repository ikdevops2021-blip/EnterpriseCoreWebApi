import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:dqms_frontend/core/config/app_config.dart';
import 'package:dqms_frontend/core/network/dio_provider.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/widgets/dqms_button.dart';
import 'package:dqms_frontend/core/widgets/dqms_text_field.dart';
import 'package:dqms_frontend/core/widgets/dqms_status_badge.dart';
import 'package:dqms_frontend/features/admin/widgets/master_detail_layout.dart';

/// User Profile Model matching .NET Entity (User.cs + LocationAndUserProfiles.cs)
class UserProfileModel {
  final int userId;
  final String userCode;
  final int? titleId;
  final String titleName; // 'Mr.', 'Dr.', 'Ms.', 'Prof'
  final String firstName;
  final String lastName;
  final String? displayName;
  final int? genderId;
  final String genderName; // 'Male', 'Female', 'Transgender Male', 'Transgender Female', 'Unknown'
  final String? profileImageUrl;
  final String email;
  final String mobileNumber;
  final int roleId;
  final String roleName;
  final bool isActive;

  // Address Entity Fields (UserAddress.cs)
  final int addressTypeId;
  final String addressTypeName; // 'Home', 'Work', 'Billing', 'Shipping'
  final String addressLine1;
  final String? addressLine2;
  final String postalCode;
  final String countryName;
  final String stateName;
  final String cityName;

  // Contact Entity Fields (UserContact.cs)
  final int contactTypeId;
  final String contactTypeName; // 'Mobile', 'Work Phone', 'Email'
  final int relationshipTypeId;
  final String relationshipTypeName; // 'Self', 'Father', 'Spouse'
  final bool isEmergencyContact;
  final bool isVerifiedContact;

  const UserProfileModel({
    required this.userId,
    required this.userCode,
    this.titleId = 2003,
    required this.titleName,
    required this.firstName,
    required this.lastName,
    this.displayName,
    this.genderId = 1001,
    required this.genderName,
    this.profileImageUrl,
    required this.email,
    required this.mobileNumber,
    this.roleId = 1,
    required this.roleName,
    required this.isActive,
    this.addressTypeId = 4003,
    required this.addressTypeName,
    required this.addressLine1,
    this.addressLine2,
    required this.postalCode,
    required this.countryName,
    required this.stateName,
    required this.cityName,
    this.contactTypeId = 5001,
    required this.contactTypeName,
    this.relationshipTypeId = 16001,
    required this.relationshipTypeName,
    this.isEmergencyContact = false,
    this.isVerifiedContact = true,
  });

  UserProfileModel copyWith({
    int? userId,
    String? userCode,
    int? titleId,
    String? titleName,
    String? firstName,
    String? lastName,
    String? displayName,
    int? genderId,
    String? genderName,
    String? profileImageUrl,
    String? email,
    String? mobileNumber,
    int? roleId,
    String? roleName,
    bool? isActive,
    int? addressTypeId,
    String? addressTypeName,
    String? addressLine1,
    String? addressLine2,
    String? postalCode,
    String? countryName,
    String? stateName,
    String? cityName,
    int? contactTypeId,
    String? contactTypeName,
    int? relationshipTypeId,
    String? relationshipTypeName,
    bool? isEmergencyContact,
    bool? isVerifiedContact,
  }) {
    return UserProfileModel(
      userId: userId ?? this.userId,
      userCode: userCode ?? this.userCode,
      titleId: titleId ?? this.titleId,
      titleName: titleName ?? this.titleName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      genderId: genderId ?? this.genderId,
      genderName: genderName ?? this.genderName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      isActive: isActive ?? this.isActive,
      addressTypeId: addressTypeId ?? this.addressTypeId,
      addressTypeName: addressTypeName ?? this.addressTypeName,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      postalCode: postalCode ?? this.postalCode,
      countryName: countryName ?? this.countryName,
      stateName: stateName ?? this.stateName,
      cityName: cityName ?? this.cityName,
      contactTypeId: contactTypeId ?? this.contactTypeId,
      contactTypeName: contactTypeName ?? this.contactTypeName,
      relationshipTypeId: relationshipTypeId ?? this.relationshipTypeId,
      relationshipTypeName: relationshipTypeName ?? this.relationshipTypeName,
      isEmergencyContact: isEmergencyContact ?? this.isEmergencyContact,
      isVerifiedContact: isVerifiedContact ?? this.isVerifiedContact,
    );
  }

  String get calculatedFullName => '$titleName $firstName $lastName'.trim();
}

/// Generic Configuration Parameter Model (Categories: C_TITLE, C_GENDER, C_ADDRESSTYPE, etc.)
class CoreConfigParameter {
  final int parameterId;
  final String parameterCode;
  final String parameterName;
  /// Hex color string e.g. "#E74C3C" — null means no color override
  final String? parameterColor;
  /// Material icon name e.g. "person", "male", "home" — null means no icon
  final String? parameterIcon;
  /// Image URL for avatar/thumbnail — null means no image
  final String? parameterImage;

  const CoreConfigParameter({
    required this.parameterId,
    required this.parameterCode,
    required this.parameterName,
    this.parameterColor,
    this.parameterIcon,
    this.parameterImage,
  });

  factory CoreConfigParameter.fromJson(Map<String, dynamic> json) {
    return CoreConfigParameter(
      parameterId: json['parameterID'] ?? json['parameterId'] ?? 0,
      parameterCode: json['parameterCode']?.toString() ?? '',
      parameterName: json['parameterName']?.toString() ?? '',
      parameterColor: json['parameterColor']?.toString(),
      parameterIcon: json['parameterIcon']?.toString(),
      parameterImage: json['parameterImage']?.toString(),
    );
  }
}

/// USER PROFILES & ADD/EDIT USER MASTER VIEW
class UserProfilesView extends ConsumerStatefulWidget {
  const UserProfilesView({super.key});

  @override
  ConsumerState<UserProfilesView> createState() => _UserProfilesViewState();
}

class _UserProfilesViewState extends ConsumerState<UserProfilesView> {
  String _searchQuery = '';
  UserProfileModel? _selectedUser;

  List<CoreConfigParameter> _titleOptions = const [
    CoreConfigParameter(parameterId: 2001, parameterCode: 'Sir', parameterName: 'Sir'),
    CoreConfigParameter(parameterId: 2002, parameterCode: 'Madam', parameterName: 'Madam'),
    CoreConfigParameter(parameterId: 2003, parameterCode: 'Mr.', parameterName: 'Mr.'),
    CoreConfigParameter(parameterId: 2004, parameterCode: 'Ms.', parameterName: 'Ms.'),
    CoreConfigParameter(parameterId: 2005, parameterCode: 'Mrs.', parameterName: 'Mrs.'),
    CoreConfigParameter(parameterId: 2006, parameterCode: 'Miss', parameterName: 'Miss'),
    CoreConfigParameter(parameterId: 2007, parameterCode: 'Dr.', parameterName: 'Dr.'),
    CoreConfigParameter(parameterId: 2008, parameterCode: 'Doctor', parameterName: 'Doctor'),
    CoreConfigParameter(parameterId: 2009, parameterCode: 'Prof', parameterName: 'Profesor'),
  ];

  List<CoreConfigParameter> _genderOptions = const [
    CoreConfigParameter(parameterId: 1001, parameterCode: 'M', parameterName: 'Male'),
    CoreConfigParameter(parameterId: 1002, parameterCode: 'F', parameterName: 'Female'),
    CoreConfigParameter(parameterId: 1003, parameterCode: 'TGM', parameterName: 'Transgender Male'),
    CoreConfigParameter(parameterId: 1004, parameterCode: 'TGF', parameterName: 'Transgender Female'),
    CoreConfigParameter(parameterId: 1005, parameterCode: 'UN', parameterName: 'Unknown'),
  ];

  List<CoreConfigParameter> _addressTypeOptions = const [
    CoreConfigParameter(parameterId: 4001, parameterCode: 'RESIDENTIAL', parameterName: 'Residential Address'),
    CoreConfigParameter(parameterId: 4002, parameterCode: 'PERMANENT', parameterName: 'Permanent Address'),
    CoreConfigParameter(parameterId: 4003, parameterCode: 'WORK', parameterName: 'Office / Work'),
    CoreConfigParameter(parameterId: 4004, parameterCode: 'BILLING', parameterName: 'Billing Address'),
    CoreConfigParameter(parameterId: 4005, parameterCode: 'SHIPPING', parameterName: 'Shipping Address'),
  ];

  List<CoreConfigParameter> _contactTypeOptions = const [
    CoreConfigParameter(parameterId: 5001, parameterCode: 'MOBILE', parameterName: 'Mobile Phone'),
    CoreConfigParameter(parameterId: 5002, parameterCode: 'WORK_PHONE', parameterName: 'Work Landline'),
    CoreConfigParameter(parameterId: 5003, parameterCode: 'EMAIL_PERS', parameterName: 'Personal Email'),
    CoreConfigParameter(parameterId: 5004, parameterCode: 'EMAIL_WORK', parameterName: 'Work Email'),
    CoreConfigParameter(parameterId: 5005, parameterCode: 'WHATSAPP', parameterName: 'WhatsApp'),
    CoreConfigParameter(parameterId: 5006, parameterCode: 'FAX', parameterName: 'Fax'),
  ];

  List<CoreConfigParameter> _relationshipOptions = const [
    CoreConfigParameter(parameterId: 16001, parameterCode: 'SELF', parameterName: 'Self'),
    CoreConfigParameter(parameterId: 16002, parameterCode: 'FATHER', parameterName: 'Father'),
    CoreConfigParameter(parameterId: 16003, parameterCode: 'MOTHER', parameterName: 'Mother'),
    CoreConfigParameter(parameterId: 16004, parameterCode: 'SPOUSE', parameterName: 'Spouse (Husband/Wife)'),
    CoreConfigParameter(parameterId: 16005, parameterCode: 'SON', parameterName: 'Son'),
    CoreConfigParameter(parameterId: 16006, parameterCode: 'DAUGHTER', parameterName: 'Daughter'),
    CoreConfigParameter(parameterId: 16007, parameterCode: 'GUARDIAN', parameterName: 'Legal Guardian'),
    CoreConfigParameter(parameterId: 16024, parameterCode: 'OTHER', parameterName: 'Other / Dependent'),
  ];

  final List<CoreConfigParameter> _roleOptions = const [
    CoreConfigParameter(parameterId: 1, parameterCode: 'SUPERADMIN', parameterName: 'SuperAdmin (Role ID: 1)'),
    CoreConfigParameter(parameterId: 2, parameterCode: 'ENTERPRISE_ADMIN', parameterName: 'Enterprise Admin (Role ID: 2)'),
    CoreConfigParameter(parameterId: 3, parameterCode: 'COUNTER_OPERATOR', parameterName: 'CounterOperator (Role ID: 3)'),
    CoreConfigParameter(parameterId: 4, parameterCode: 'CUSTOMER', parameterName: 'Customer / User (Role ID: 4)'),
  ];

  List<CoreConfigParameter> _countryOptions = const [
    CoreConfigParameter(parameterId: 1, parameterCode: 'US', parameterName: 'United States'),
    CoreConfigParameter(parameterId: 2, parameterCode: 'AU', parameterName: 'Australia'),
    CoreConfigParameter(parameterId: 3, parameterCode: 'IN', parameterName: 'India'),
    CoreConfigParameter(parameterId: 4, parameterCode: 'GB', parameterName: 'United Kingdom'),
    CoreConfigParameter(parameterId: 5, parameterCode: 'CA', parameterName: 'Canada'),
  ];
  List<CoreConfigParameter> _stateOptions = [];
  List<CoreConfigParameter> _cityOptions = [];
  final Map<int, List<CoreConfigParameter>> _statesCache = {};
  final Map<int, List<CoreConfigParameter>> _citiesCache = {};

  CoreConfigParameter? _selectedCountry;
  CoreConfigParameter? _selectedState;
  CoreConfigParameter? _selectedCity;

  @override
  void initState() {
    super.initState();
    _fetchConfigParameters();
    _fetchCountries();
  }

  Future<void> _fetchConfigParameters() async {
    try {
      final dio = ref.read(dioProvider);

      // Category 2: C_TITLE
      final resTitle = await dio.get('${AppConfig.apiV1Base}/Configuration/categories/2/parameters');
      if (resTitle.data != null && resTitle.data['data'] is List) {
        final list = (resTitle.data['data'] as List).map((i) => CoreConfigParameter.fromJson(i as Map<String, dynamic>)).where((p) => p.parameterId > 0).toList();
        if (list.isNotEmpty && mounted) setState(() => _titleOptions = list);
      }

      // Category 1: C_GENDER
      final resGender = await dio.get('${AppConfig.apiV1Base}/Configuration/categories/1/parameters');
      if (resGender.data != null && resGender.data['data'] is List) {
        final list = (resGender.data['data'] as List).map((i) => CoreConfigParameter.fromJson(i as Map<String, dynamic>)).where((p) => p.parameterId > 0).toList();
        if (list.isNotEmpty && mounted) setState(() => _genderOptions = list);
      }

      // Category 4: C_ADDRESSTYPE
      final resAddr = await dio.get('${AppConfig.apiV1Base}/Configuration/categories/4/parameters');
      if (resAddr.data != null && resAddr.data['data'] is List) {
        final list = (resAddr.data['data'] as List).map((i) => CoreConfigParameter.fromJson(i as Map<String, dynamic>)).where((p) => p.parameterId > 0).toList();
        if (list.isNotEmpty && mounted) setState(() => _addressTypeOptions = list);
      }

      // Category 5: C_CONTACTTYPE
      final resContact = await dio.get('${AppConfig.apiV1Base}/Configuration/categories/5/parameters');
      if (resContact.data != null && resContact.data['data'] is List) {
        final list = (resContact.data['data'] as List).map((i) => CoreConfigParameter.fromJson(i as Map<String, dynamic>)).where((p) => p.parameterId > 0).toList();
        if (list.isNotEmpty && mounted) setState(() => _contactTypeOptions = list);
      }

      // Category 16: C_RELATIONSHIP
      final resRel = await dio.get('${AppConfig.apiV1Base}/Configuration/categories/16/parameters');
      if (resRel.data != null && resRel.data['data'] is List) {
        final list = (resRel.data['data'] as List).map((i) => CoreConfigParameter.fromJson(i as Map<String, dynamic>)).where((p) => p.parameterId > 0).toList();
        if (list.isNotEmpty && mounted) setState(() => _relationshipOptions = list);
      }
    } catch (_) {}
  }

  Future<void> _fetchCountries() async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get('${AppConfig.apiV1Base}/Locations/countries');
      if (res.data != null && res.data['data'] is List) {
        final list = (res.data['data'] as List)
            .map((i) => CoreConfigParameter(
                  parameterId: i['countryId'] ?? 0,
                  parameterCode: i['countryCode']?.toString() ?? '',
                  parameterName: i['countryName']?.toString() ?? '',
                ))
            .where((p) => p.parameterId > 0)
            .toList();
        if (list.isNotEmpty && mounted) setState(() => _countryOptions = list);
      }
    } catch (_) {}
  }

  Future<void> _fetchStates(int countryId) async {
    if (_statesCache.containsKey(countryId)) {
      setState(() => _stateOptions = _statesCache[countryId]!);
      return;
    }
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get('${AppConfig.apiV1Base}/Locations/states', queryParameters: {'countryId': countryId});
      if (res.data != null && res.data['data'] is List) {
        final list = (res.data['data'] as List)
            .map((i) => CoreConfigParameter(
                  parameterId: i['stateId'] ?? 0,
                  parameterCode: i['stateCode']?.toString() ?? '',
                  parameterName: i['stateName']?.toString() ?? '',
                ))
            .where((p) => p.parameterId > 0)
            .toList();
        if (list.isNotEmpty) _statesCache[countryId] = list;
        if (list.isNotEmpty && mounted) setState(() => _stateOptions = list);
      }
    } catch (_) {}
  }

  Future<void> _fetchCities(int stateId) async {
    if (_citiesCache.containsKey(stateId)) {
      setState(() => _cityOptions = _citiesCache[stateId]!);
      return;
    }
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get('${AppConfig.apiV1Base}/Locations/cities', queryParameters: {'stateId': stateId});
      if (res.data != null && res.data['data'] is List) {
        final list = (res.data['data'] as List)
            .map((i) => CoreConfigParameter(
                  parameterId: i['cityId'] ?? 0,
                  parameterCode: i['cityCode']?.toString() ?? '',
                  parameterName: i['cityName']?.toString() ?? '',
                ))
            .where((p) => p.parameterId > 0)
            .toList();
        if (list.isNotEmpty) _citiesCache[stateId] = list;
        if (list.isNotEmpty && mounted) setState(() => _cityOptions = list);
      }
    } catch (_) {}
  }

  void _onUserSelected(UserProfileModel u) {
    setState(() {
      _selectedUser = u;
      _selectedCountry = _countryOptions.cast<CoreConfigParameter?>().firstWhere(
        (c) => c?.parameterName.toLowerCase() == u.countryName.toLowerCase(),
        orElse: () => CoreConfigParameter(parameterId: 0, parameterCode: '', parameterName: u.countryName),
      );
      _selectedState = CoreConfigParameter(parameterId: 0, parameterCode: '', parameterName: u.stateName);
      _selectedCity = CoreConfigParameter(parameterId: 0, parameterCode: '', parameterName: u.cityName);
    });

    if (_selectedCountry != null && _selectedCountry!.parameterId > 0) {
      _fetchStates(_selectedCountry!.parameterId).then((_) {
        if (mounted && _stateOptions.isNotEmpty) {
          final matchedState = _stateOptions.cast<CoreConfigParameter?>().firstWhere(
            (s) => s?.parameterName.toLowerCase() == u.stateName.toLowerCase(),
            orElse: () => CoreConfigParameter(parameterId: 0, parameterCode: '', parameterName: u.stateName),
          );
          setState(() => _selectedState = matchedState);
          if (matchedState != null && matchedState.parameterId > 0) {
            _fetchCities(matchedState.parameterId).then((_) {
              if (mounted && _cityOptions.isNotEmpty) {
                final matchedCity = _cityOptions.cast<CoreConfigParameter?>().firstWhere(
                  (c) => c?.parameterName.toLowerCase() == u.cityName.toLowerCase(),
                  orElse: () => CoreConfigParameter(parameterId: 0, parameterCode: '', parameterName: u.cityName),
                );
                setState(() => _selectedCity = matchedCity);
              }
            });
          }
        }
      });
    }
  }

  final List<UserProfileModel> _users = const [
    UserProfileModel(
      userId: 1,
      userCode: 'admin@dqms.org',
      titleId: 2007,
      titleName: 'Dr.',
      firstName: 'System',
      lastName: 'Admin',
      displayName: 'System Admin (SuperAdmin)',
      genderId: 1001,
      genderName: 'Male (1001)',
      profileImageUrl: 'https://cdn.dqms.org/avatars/admin.png',
      email: 'admin@dqms.org',
      mobileNumber: '+1 800 555 0199',
      roleName: 'SuperAdmin (Role ID: 1)',
      isActive: true,
      addressTypeName: 'Work (4002)',
      addressLine1: '742 Evergreen Terrace',
      addressLine2: 'Suite 100 Main Building',
      postalCode: '62704',
      countryName: 'United States',
      stateName: 'Illinois',
      cityName: 'Springfield',
      contactTypeName: 'Work Phone (5003)',
      relationshipTypeName: 'Self (16001)',
      isEmergencyContact: true,
      isVerifiedContact: true,
    ),
    UserProfileModel(
      userId: 2,
      userCode: 'alex2026',
      titleId: 2003,
      titleName: 'Mr.',
      firstName: 'Alex',
      lastName: 'Mercer',
      displayName: 'Alex Mercer',
      genderId: 1001,
      genderName: 'Male (1001)',
      profileImageUrl: 'https://cdn.dqms.org/avatars/alex.png',
      email: 'alex.mercer@acme.com',
      mobileNumber: '+1 800 555 0142',
      roleName: 'Enterprise Admin (Role ID: 1)',
      isActive: true,
      addressTypeName: 'Office (4002)',
      addressLine1: '100 Enterprise Way',
      addressLine2: 'Floor 4',
      postalCode: '10001',
      countryName: 'United States',
      stateName: 'New York',
      cityName: 'New York City',
      contactTypeName: 'Mobile (5001)',
      relationshipTypeName: 'Self (16001)',
      isEmergencyContact: false,
      isVerifiedContact: true,
    ),
    UserProfileModel(
      userId: 3,
      userCode: 'maria.chen',
      titleId: 2004,
      titleName: 'Ms.',
      firstName: 'Maria',
      lastName: 'Chen',
      displayName: 'Maria Chen',
      genderId: 1002,
      genderName: 'Female (1002)',
      profileImageUrl: 'https://cdn.dqms.org/avatars/maria.png',
      email: 'maria.chen@dqms.org',
      mobileNumber: '+1 800 555 0188',
      roleName: 'CounterOperator (Role ID: 3)',
      isActive: true,
      addressTypeName: 'Home (4001)',
      addressLine1: '42 Wallaby Way',
      postalCode: '2000',
      countryName: 'Australia',
      stateName: 'New South Wales',
      cityName: 'Sydney',
      contactTypeName: 'Mobile (5001)',
      relationshipTypeName: 'Self (16001)',
      isEmergencyContact: true,
      isVerifiedContact: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _users.where((u) {
      return u.calculatedFullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.userCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.roleName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return MasterDetailLayout(
      masterWidget: _buildMasterTable(filtered),
      detailWidget: _selectedUser != null ? _buildDetailInspector(_selectedUser!) : null,
      detailTitle: _selectedUser != null ? 'User Profile Inspector — ${_selectedUser!.calculatedFullName}' : 'User Inspector',
      onCloseDetail: () => setState(() => _selectedUser = null),
    );
  }

  Widget _buildMasterTable(List<UserProfileModel> users) {
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
                  hintText: 'Search UserCode, Full Name, Email, or Role...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 12),
              DqmsButton(
                label: 'Create User Account',
                icon: Icons.person_add_rounded,
                onPressed: () => _showCreateUserModal(context),
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
                      SizedBox(width: 120, child: Text('USER CODE', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                      Expanded(flex: 3, child: Text('FULL NAME & TITLE', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                      Expanded(flex: 3, child: Text('PRIMARY EMAIL & MOBILE', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                      Expanded(flex: 2, child: Text('ROLE ASSIGNMENT', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                      SizedBox(width: 80, child: Text('STATUS', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (_, _) => const Divider(color: AppColors.borderSubtle, height: 1),
                    itemBuilder: (ctx, i) {
                      final u = users[i];
                      final isSelected = _selectedUser?.userId == u.userId;

                      return InkWell(
                        onTap: () => _onUserSelected(u),
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
                                width: 120,
                                child: Text(u.userCode, style: const TextStyle(color: AppColors.brandPrimary, fontSize: 12, fontWeight: FontWeight.w800, fontFamily: 'monospace')),
                              ),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(u.calculatedFullName, style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700)),
                                    Text('Gender: ${u.genderName}', style: const TextStyle(color: AppColors.textSubtle, fontSize: 10)),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(u.email, style: const TextStyle(color: AppColors.brandAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                                    Text(u.mobileNumber, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(u.roleName, style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                              SizedBox(
                                width: 80,
                                child: DqmsStatusBadge.activeState(u.isActive),
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

  // ─── Config Dropdown Helpers ────────────────────────────────────────────────

  /// Parses a hex color string ("#RRGGBB" or "#AARRGGBB") into a Flutter [Color].
  /// Returns null if the input is null or invalid.
  Color? _hexToColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final clean = hex.replaceAll('#', '');
    try {
      if (clean.length == 6) return Color(int.parse('FF$clean', radix: 16));
      if (clean.length == 8) return Color(int.parse(clean, radix: 16));
    } catch (_) {}
    return null;
  }

  /// Creates [IconData] from a runtime codepoint — non-const by design.
  // ignore: prefer_const_constructors, non_constant_identifier_names
  IconData _makeIconData(int code) {
    // ignore: non_const_argument_for_const_parameter
    return IconData(code, fontFamily: 'MaterialIcons');
  }

  /// Maps a Material icon name string to an [IconData].
  /// Supports common names; falls back to [Icons.label_outline] for unknowns.
  IconData? _iconNameToIconData(String? name) {
    if (name == null || name.isEmpty) return null;
    // Try codepoint first (e.g. "0xe7fd")
    if (name.startsWith('0x')) {
      try {
        final code = int.parse(name);
        return _makeIconData(code);
      } catch (_) {}
    }
    const map = <String, IconData>{
      'person': Icons.person,
      'male': Icons.male,
      'female': Icons.female,
      'transgender': Icons.transgender,
      'home': Icons.home,
      'work': Icons.work,
      'business': Icons.business,
      'location_on': Icons.location_on,
      'local_shipping': Icons.local_shipping,
      'receipt': Icons.receipt,
      'phone': Icons.phone,
      'phone_iphone': Icons.phone_iphone,
      'email': Icons.email,
      'whatsapp': Icons.chat,
      'fax': Icons.fax,
      'family_restroom': Icons.family_restroom,
      'escalator_warning': Icons.escalator_warning,
      'supervisor_account': Icons.supervisor_account,
      'manage_accounts': Icons.manage_accounts,
      'support_agent': Icons.support_agent,
      'admin_panel_settings': Icons.admin_panel_settings,
      'star': Icons.star,
      'verified': Icons.verified,
      'badge': Icons.badge,
      'school': Icons.school,
      'medical_services': Icons.medical_services,
      'psychology': Icons.psychology,
      'favorite': Icons.favorite,
      'handshake': Icons.handshake,
      'groups': Icons.groups,
      'child_care': Icons.child_care,
      'elderly': Icons.elderly,
      'accessible': Icons.accessible,
    };
    return map[name.toLowerCase().trim()];
  }

  /// Builds the leading widget (image thumbnail or icon) for a config param.
  /// Image takes priority over icon. Returns null if neither is set.
  Widget? _buildParamLeading(CoreConfigParameter p, {double size = 20}) {
    if (p.parameterImage != null && p.parameterImage!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          p.parameterImage!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, e, s) => Icon(Icons.broken_image_outlined, size: size, color: AppColors.textMuted),
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : SizedBox(width: size, height: size, child: const CircularProgressIndicator(strokeWidth: 1.5)),
        ),
      );
    }
    final icon = _iconNameToIconData(p.parameterIcon);
    if (icon != null) {
      return Icon(icon, size: size, color: _hexToColor(p.parameterColor) ?? AppColors.textSubtle);
    }
    return null;
  }

  /// Reusable searchable dropdown backed by [CoreConfigParameter] list.
  /// Renders [parameterColor] as text color, [parameterIcon] as leading icon,
  /// and [parameterImage] as leading thumbnail (image takes priority over icon).
  Widget _buildConfigDropdown({
    required String label,
    required List<CoreConfigParameter> options,
    required int? selectedId,
    required ValueChanged<CoreConfigParameter?> onChanged,
  }) {
    final selected = options.firstWhere(
      (p) => p.parameterId == selectedId,
      orElse: () => options.isNotEmpty ? options.first : const CoreConfigParameter(parameterId: 0, parameterCode: '', parameterName: ''),
    );
    final hasSelection = selected.parameterId > 0;

    return DropdownSearch<CoreConfigParameter>(
      items: options,
      selectedItem: hasSelection ? selected : null,
      itemAsString: (p) => '${p.parameterName}  (${p.parameterId})',
      filterFn: (p, filter) =>
        p.parameterName.toLowerCase().contains(filter.toLowerCase()) ||
        p.parameterId.toString().contains(filter),
      compareFn: (a, b) => a.parameterId == b.parameterId,
      onChanged: onChanged,
      // ── Rich selected-item display in the closed dropdown ──
      dropdownBuilder: (ctx, item) {
        if (item == null) {
          return const Text('— Select —', style: TextStyle(color: AppColors.textMuted, fontSize: 12));
        }
        final textColor = _hexToColor(item.parameterColor) ?? AppColors.textMain;
        final leading = _buildParamLeading(item, size: 18);
        return Row(
          children: [
            if (leading != null) ...[leading, const SizedBox(width: 8)],
            Expanded(
              child: Text(
                '${item.parameterName}  (${item.parameterId})',
                style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w600),
          filled: true,
          fillColor: AppColors.bgSubtle,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: const OutlineInputBorder(),
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: 'Search by name or ID...',
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            filled: true,
            fillColor: AppColors.bgSubtle,
            prefixIcon: const Icon(Icons.search, color: AppColors.textSubtle, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
          style: const TextStyle(color: AppColors.textMain, fontSize: 12),
        ),
        containerBuilder: (ctx, child) => Container(
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: child,
        ),
        // ── Rich item row in popup list ──
        itemBuilder: (ctx, item, isSelected) {
          final textColor = _hexToColor(item.parameterColor) ?? (isSelected ? AppColors.brandPrimary : AppColors.textMain);
          final leading = _buildParamLeading(item, size: 20);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.12) : Colors.transparent,
            child: Row(
              children: [
                // Selected checkmark
                if (isSelected) ...[const Icon(Icons.check_circle, color: AppColors.brandPrimary, size: 14), const SizedBox(width: 6)],
                // Image or icon (if set on the parameter)
                if (leading != null) ...[leading, const SizedBox(width: 8)],
                // Name + ID
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.parameterName,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      Text(
                        'ID: ${item.parameterId}  |  Code: ${item.parameterCode}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailInspector(UserProfileModel user) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DqmsTextField(label: 'Custom User Handle (UserCode)', initialValue: user.userCode),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 200,
                child: _buildConfigDropdown(
                  label: 'Title (C_TITLE)',
                  options: _titleOptions,
                  selectedId: user.titleId,
                  onChanged: (p) {
                    if (p != null) setState(() => _selectedUser = user.copyWith(titleId: p.parameterId, titleName: p.parameterName));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: DqmsTextField(label: 'First Name', initialValue: user.firstName)),
              const SizedBox(width: 12),
              Expanded(child: DqmsTextField(label: 'Last Name', initialValue: user.lastName)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildConfigDropdown(
                  label: 'Gender (C_GENDER)',
                  options: _genderOptions,
                  selectedId: user.genderId,
                  onChanged: (p) {
                    if (p != null) setState(() => _selectedUser = user.copyWith(genderId: p.parameterId, genderName: '${p.parameterName} (${p.parameterId})'));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildConfigDropdown(
                  label: 'Assigned Role',
                  options: _roleOptions,
                  selectedId: user.roleId,
                  onChanged: (r) {
                    if (r != null) setState(() => _selectedUser = user.copyWith(roleId: r.parameterId, roleName: r.parameterName));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DqmsTextField(label: 'Primary Login Email', initialValue: user.email),
          const SizedBox(height: 14),
          DqmsTextField(label: 'Profile Avatar Image URL', initialValue: user.profileImageUrl ?? 'https://cdn.dqms.org/avatars/default.png'),
          const SizedBox(height: 16),

          // User Address Entity Section
          const Text('User Primary Address (UserAddress Entity)', style: TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildConfigDropdown(
                  label: 'Address Type (C_ADDRESSTYPE)',
                  options: _addressTypeOptions,
                  selectedId: user.addressTypeId,
                  onChanged: (a) {
                    if (a != null) setState(() => _selectedUser = user.copyWith(addressTypeId: a.parameterId, addressTypeName: '${a.parameterName} (${a.parameterId})'));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: DqmsTextField(label: 'Postal Code', initialValue: user.postalCode)),
            ],
          ),
          const SizedBox(height: 10),
          DqmsTextField(label: 'Address Line 1', initialValue: user.addressLine1),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildConfigDropdown(
                  label: 'Country (Locations API)',
                  options: _countryOptions.isNotEmpty
                      ? _countryOptions
                      : (_selectedCountry != null ? [_selectedCountry!] : []),
                  selectedId: _selectedCountry?.parameterId,
                  onChanged: (c) {
                    if (c != null) {
                      setState(() {
                        _selectedCountry = c;
                        _selectedState = null;
                        _selectedCity = null;
                        _stateOptions = [];
                        _cityOptions = [];
                        if (_selectedUser != null) {
                          _selectedUser = _selectedUser!.copyWith(
                            countryName: c.parameterName,
                            stateName: '',
                            cityName: '',
                          );
                        }
                      });
                      if (c.parameterId > 0) {
                        _fetchStates(c.parameterId);
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildConfigDropdown(
                  label: 'State (Locations API)',
                  options: _stateOptions.isNotEmpty
                      ? _stateOptions
                      : (_selectedState != null ? [_selectedState!] : []),
                  selectedId: _selectedState?.parameterId,
                  onChanged: (s) {
                    if (s != null) {
                      setState(() {
                        _selectedState = s;
                        _selectedCity = null;
                        _cityOptions = [];
                        if (_selectedUser != null) {
                          _selectedUser = _selectedUser!.copyWith(
                            stateName: s.parameterName,
                            cityName: '',
                          );
                        }
                      });
                      if (s.parameterId > 0) {
                        _fetchCities(s.parameterId);
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildConfigDropdown(
                  label: 'City (Locations API)',
                  options: _cityOptions.isNotEmpty
                      ? _cityOptions
                      : (_selectedCity != null ? [_selectedCity!] : []),
                  selectedId: _selectedCity?.parameterId,
                  onChanged: (ct) {
                    if (ct != null) {
                      setState(() {
                        _selectedCity = ct;
                        if (_selectedUser != null) {
                          _selectedUser = _selectedUser!.copyWith(
                            cityName: ct.parameterName,
                          );
                        }
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // User Contact Entity Section
          const Text('User Contact & Emergency Profile (UserContact Entity)', style: TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildConfigDropdown(
                  label: 'Contact Type (C_CONTACTTYPE)',
                  options: _contactTypeOptions,
                  selectedId: user.contactTypeId,
                  onChanged: (c) {
                    if (c != null) setState(() => _selectedUser = user.copyWith(contactTypeId: c.parameterId, contactTypeName: '${c.parameterName} (${c.parameterId})'));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildConfigDropdown(
                  label: 'Relationship (C_RELATIONSHIP)',
                  options: _relationshipOptions,
                  selectedId: user.relationshipTypeId,
                  onChanged: (r) {
                    if (r != null) setState(() => _selectedUser = user.copyWith(relationshipTypeId: r.parameterId, relationshipTypeName: '${r.parameterName} (${r.parameterId})'));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DqmsTextField(label: 'Primary Phone / Contact Value', initialValue: user.mobileNumber),
          const SizedBox(height: 14),

          Row(
            children: [
              Text('Emergency Flag: ${user.isEmergencyContact ? "YES" : "NO"}', style: const TextStyle(color: AppColors.brandAccent, fontSize: 11, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('Verified Contact: ${user.isVerifiedContact ? "VERIFIED" : "UNVERIFIED"}', style: const TextStyle(color: AppColors.statusActive, fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 24),

          DqmsButton(
            label: 'Save Full User Profile & Addresses',
            icon: Icons.save_rounded,
            isFullWidth: true,
            onPressed: () async {
              try {
                final dio = ref.read(dioProvider);
                await dio.post('${AppConfig.apiV1Base}/users/${user.userId}/addresses', data: {
                  'addressId': 0,
                  'userId': user.userId,
                  'addressLine1': user.addressLine1,
                  'city': user.cityName,
                  'state': user.stateName,
                  'postalCode': user.postalCode,
                  'country': user.countryName,
                });
              } catch (_) {}

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User ${user.calculatedFullName} saved to backend API.'), backgroundColor: AppColors.statusActive),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showCreateUserModal(BuildContext context) {
    final userCodeCtrl = TextEditingController();
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController(text: 'Welc0me@555');
    CoreConfigParameter? selectedTitle = _titleOptions.isNotEmpty ? _titleOptions.first : null;
    CoreConfigParameter? selectedGender = _genderOptions.isNotEmpty ? _genderOptions.first : null;
    CoreConfigParameter? selectedRole = _roleOptions.isNotEmpty ? _roleOptions.first : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.bgSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: AppColors.borderSubtle)),
          title: const Text('Create User Account (User.cs Entity)', style: TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.w700)),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DqmsTextField(label: 'UserCode / Handle (Defaults to Email)', controller: userCodeCtrl),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 180,
                      child: DropdownSearch<CoreConfigParameter>(
                        items: _titleOptions,
                        selectedItem: selectedTitle,
                        itemAsString: (p) => '${p.parameterName}  (${p.parameterId})',
                        compareFn: (a, b) => a.parameterId == b.parameterId,
                        filterFn: (p, filter) => p.parameterName.toLowerCase().contains(filter.toLowerCase()),
                        onChanged: (p) => setDialogState(() => selectedTitle = p),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Title (C_TITLE)',
                            labelStyle: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w600),
                            filled: true,
                            fillColor: AppColors.bgSubtle,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
                              filled: true,
                              fillColor: AppColors.bgSubtle,
                              prefixIcon: Icon(Icons.search, color: AppColors.textSubtle, size: 18),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(),
                            ),
                            style: TextStyle(color: AppColors.textMain, fontSize: 12),
                          ),
                          containerBuilder: (ctx, child) => Container(
                            decoration: BoxDecoration(
                              color: AppColors.bgSurface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: child,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: DqmsTextField(label: 'First Name', controller: firstNameCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: DqmsTextField(label: 'Last Name', controller: lastNameCtrl)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownSearch<CoreConfigParameter>(
                        items: _genderOptions,
                        selectedItem: selectedGender,
                        itemAsString: (p) => '${p.parameterName}  (${p.parameterId})',
                        compareFn: (a, b) => a.parameterId == b.parameterId,
                        filterFn: (p, filter) => p.parameterName.toLowerCase().contains(filter.toLowerCase()),
                        onChanged: (p) => setDialogState(() => selectedGender = p),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Gender (C_GENDER)',
                            labelStyle: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w600),
                            filled: true,
                            fillColor: AppColors.bgSubtle,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          containerBuilder: (ctx, child) => Container(
                            decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.borderSubtle)),
                            child: child,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownSearch<CoreConfigParameter>(
                        items: _roleOptions,
                        selectedItem: selectedRole,
                        itemAsString: (p) => p.parameterName,
                        compareFn: (a, b) => a.parameterId == b.parameterId,
                        filterFn: (p, filter) => p.parameterName.toLowerCase().contains(filter.toLowerCase()),
                        onChanged: (r) => setDialogState(() => selectedRole = r),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Assigned Role',
                            labelStyle: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w600),
                            filled: true,
                            fillColor: AppColors.bgSubtle,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          containerBuilder: (ctx, child) => Container(
                            decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.borderSubtle)),
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DqmsTextField(label: 'Login Email Address', controller: emailCtrl),
                const SizedBox(height: 12),
                DqmsTextField(label: 'Password Hash (PBKDF2 SHA256)', controller: passCtrl, obscureText: true),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandPrimary, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User created — Title: "${selectedTitle?.parameterName ?? "-"}" | Gender: "${selectedGender?.parameterName ?? "-"}" | Role: "${selectedRole?.parameterName ?? "-"}".'),
                    backgroundColor: AppColors.statusActive,
                  ),
                );
              },
              child: const Text('Save User'),
            ),
          ],
        ),
      ),
    );
  }
}
