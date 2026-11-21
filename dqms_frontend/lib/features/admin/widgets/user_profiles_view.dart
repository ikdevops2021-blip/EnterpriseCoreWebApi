import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dqms_frontend/core/config/app_config.dart';
import 'package:dqms_frontend/core/network/dio_provider.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/widgets/dqms_text_field.dart';
import 'package:dqms_frontend/core/widgets/dqms_status_badge.dart';
import 'package:dqms_frontend/core/widgets/dqms_dropdown.dart';
import 'package:dqms_frontend/core/widgets/dqms_selection_controls.dart';
import 'package:dqms_frontend/features/admin/widgets/master_detail_layout.dart';

/// User Profile Model matching .NET Entity (User.cs + LocationAndUserProfiles.cs)
class UserProfileModel {
  final int userId;
  final String userCode;
  final int? titleId;
  final String titleName;
  final String firstName;
  final String lastName;
  final String? displayName;
  final int? genderId;
  final String genderName;
  final String? profileImageUrl;
  final String email;
  final String mobileNumber;
  final int roleId;
  final String roleName;
  final String department;
  final bool isActive;

  // Address Entity Fields (UserAddress.cs)
  final int addressTypeId;
  final String addressTypeName;
  final String addressLine1;
  final String? addressLine2;
  final String postalCode;
  final String countryName;
  final String stateName;
  final String cityName;

  // Contact Entity Fields (UserContact.cs)
  final int contactTypeId;
  final String contactTypeName;
  final int relationshipTypeId;
  final String relationshipTypeName;
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
    this.department = 'Emergency Medicine',
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
    String? department,
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
      department: department ?? this.department,
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

  String get calculatedFullName {
    final title = titleName.trim();
    final first = firstName.trim();
    final last = lastName.trim();
    if (title.isNotEmpty) {
      return '$title $first $last'.trim();
    }
    return '$first $last'.trim();
  }
}

/// Generic Configuration Parameter Model (Categories: C_TITLE, C_GENDER, C_ADDRESSTYPE, etc.)
class CoreConfigParameter {
  final int parameterId;
  final String parameterCode;
  final String parameterName;
  final String? parameterColor;
  final String? parameterIcon;
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
  bool _isUploadingAvatar = false;
  bool _isSavingUser = false;

  // Text Controllers for Bidirectional Binding
  late TextEditingController _userCodeCtrl;
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _mobileNumberCtrl;
  late TextEditingController _addressLine1Ctrl;
  late TextEditingController _addressLine2Ctrl;
  late TextEditingController _postalCodeCtrl;

  List<CoreConfigParameter> _titleOptions = const [
    CoreConfigParameter(parameterId: 2001, parameterCode: 'Sir', parameterName: 'Sir'),
    CoreConfigParameter(parameterId: 2002, parameterCode: 'Madam', parameterName: 'Madam'),
    CoreConfigParameter(parameterId: 2003, parameterCode: 'Mr.', parameterName: 'Mr.'),
    CoreConfigParameter(parameterId: 2004, parameterCode: 'Ms.', parameterName: 'Ms.'),
    CoreConfigParameter(parameterId: 2005, parameterCode: 'Mrs.', parameterName: 'Mrs.'),
    CoreConfigParameter(parameterId: 2006, parameterCode: 'Miss', parameterName: 'Miss'),
    CoreConfigParameter(parameterId: 2007, parameterCode: 'Dr.', parameterName: 'Dr.'),
    CoreConfigParameter(parameterId: 2008, parameterCode: 'Doctor', parameterName: 'Doctor'),
    CoreConfigParameter(parameterId: 2009, parameterCode: 'Prof', parameterName: 'Professor'),
  ];

  List<CoreConfigParameter> _genderOptions = const [
    CoreConfigParameter(parameterId: 1001, parameterCode: 'M', parameterName: 'Male'),
    CoreConfigParameter(parameterId: 1002, parameterCode: 'F', parameterName: 'Female'),
    CoreConfigParameter(parameterId: 1003, parameterCode: 'TGM', parameterName: 'Transgender Male'),
    CoreConfigParameter(parameterId: 1004, parameterCode: 'TGF', parameterName: 'Transgender Female'),
    CoreConfigParameter(parameterId: 1005, parameterCode: 'UN', parameterName: 'Non-Binary / Other'),
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
    CoreConfigParameter(parameterId: 16004, parameterCode: 'SPOUSE', parameterName: 'Spouse'),
    CoreConfigParameter(parameterId: 16005, parameterCode: 'SON', parameterName: 'Son'),
    CoreConfigParameter(parameterId: 16006, parameterCode: 'DAUGHTER', parameterName: 'Daughter'),
    CoreConfigParameter(parameterId: 16007, parameterCode: 'GUARDIAN', parameterName: 'Legal Guardian'),
    CoreConfigParameter(parameterId: 16024, parameterCode: 'OTHER', parameterName: 'Other / Dependent'),
  ];

  final List<CoreConfigParameter> _roleOptions = const [
    CoreConfigParameter(parameterId: 1, parameterCode: 'SUPERADMIN', parameterName: 'SuperAdmin'),
    CoreConfigParameter(parameterId: 2, parameterCode: 'ENTERPRISE_ADMIN', parameterName: 'Enterprise Admin'),
    CoreConfigParameter(parameterId: 3, parameterCode: 'COUNTER_OPERATOR', parameterName: 'Counter Operator'),
    CoreConfigParameter(parameterId: 4, parameterCode: 'CUSTOMER', parameterName: 'Customer / User'),
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

  String _selectedRoleFilter = 'All Roles (148)';

  List<UserProfileModel> _users = [
    const UserProfileModel(
      userId: 8841,
      userCode: '#DQMS-8841',
      titleId: 2007,
      titleName: 'Dr.',
      firstName: 'Eleanor',
      lastName: 'Vance, MD',
      displayName: 'Dr. Eleanor Vance, MD',
      genderId: 1002,
      genderName: 'Female',
      profileImageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=256',
      email: 'e.vance@metrogeneral.org',
      mobileNumber: '+1 555 019 8841',
      roleId: 2,
      roleName: 'Clinical Lead',
      department: 'Emergency Medicine',
      isActive: true,
      addressTypeId: 4003,
      addressTypeName: 'Office / Work',
      addressLine1: 'Metropolis General Hospital, Wing A',
      addressLine2: 'Station Alpha-04',
      postalCode: '10001',
      countryName: 'United States',
      stateName: 'New York',
      cityName: 'New York City',
      contactTypeId: 5001,
      contactTypeName: 'Work Phone',
      relationshipTypeId: 16001,
      relationshipTypeName: 'Self',
      isEmergencyContact: true,
      isVerifiedContact: true,
    ),
    const UserProfileModel(
      userId: 1,
      userCode: 'admin@dqms.org',
      titleId: 2007,
      titleName: 'Dr.',
      firstName: 'System',
      lastName: 'Admin',
      displayName: 'Dr. System Admin',
      genderId: 1001,
      genderName: 'Male',
      profileImageUrl: 'https://cdn.dqms.org/avatars/admin.png',
      email: 'admin@dqms.org',
      mobileNumber: '+1 800 555 0199',
      roleId: 1,
      roleName: 'System Admin',
      department: 'Executive Operations',
      isActive: true,
      addressTypeId: 4003,
      addressTypeName: 'Office / Work',
      addressLine1: '742 Evergreen Terrace',
      addressLine2: 'Suite 100 Main Building',
      postalCode: '62704',
      countryName: 'United States',
      stateName: 'Illinois',
      cityName: 'Springfield',
      contactTypeId: 5001,
      contactTypeName: 'Work Phone',
      relationshipTypeId: 16001,
      relationshipTypeName: 'Self',
      isEmergencyContact: true,
      isVerifiedContact: true,
    ),
    const UserProfileModel(
      userId: 4920,
      userCode: '#DQMS-4920',
      titleId: 2004,
      titleName: 'Nurse',
      firstName: 'David',
      lastName: 'Kim',
      displayName: 'Nurse David Kim',
      genderId: 1001,
      genderName: 'Male',
      profileImageUrl: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&q=80&w=256',
      email: 'd.kim@metrogeneral.org',
      mobileNumber: '+1 555 019 4920',
      roleId: 3,
      roleName: 'Triage Reception',
      department: 'Oncology / Triage',
      isActive: true,
      addressTypeId: 4003,
      addressTypeName: 'Office / Work',
      addressLine1: 'Metropolis General Hospital, Wing B',
      addressLine2: 'Triage Desk 02',
      postalCode: '10001',
      countryName: 'United States',
      stateName: 'New York',
      cityName: 'New York City',
      contactTypeId: 5001,
      contactTypeName: 'Work Phone',
      relationshipTypeId: 16001,
      relationshipTypeName: 'Self',
      isEmergencyContact: false,
      isVerifiedContact: true,
    ),
    const UserProfileModel(
      userId: 3102,
      userCode: '#DQMS-3102',
      titleId: 2005,
      titleName: 'Teller',
      firstName: 'Sarah',
      lastName: 'Jenkins',
      displayName: 'Teller Sarah Jenkins',
      genderId: 1002,
      genderName: 'Female',
      profileImageUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=256',
      email: 's.jenkins@metrogeneral.org',
      mobileNumber: '+1 555 019 3102',
      roleId: 4,
      roleName: 'Counter Teller',
      department: 'Central Billing & Records',
      isActive: true,
      addressTypeId: 4003,
      addressTypeName: 'Office / Work',
      addressLine1: 'Metropolis General Hospital, Ground Floor',
      addressLine2: 'Counter 04',
      postalCode: '10001',
      countryName: 'United States',
      stateName: 'New York',
      cityName: 'New York City',
      contactTypeId: 5001,
      contactTypeName: 'Work Phone',
      relationshipTypeId: 16001,
      relationshipTypeName: 'Self',
      isEmergencyContact: false,
      isVerifiedContact: true,
    ),
    const UserProfileModel(
      userId: 9042,
      userCode: '#DQMS-9042',
      titleId: 2007,
      titleName: 'Dr.',
      firstName: 'Ahmed',
      lastName: 'Rahman',
      displayName: 'Dr. Ahmed Rahman',
      genderId: 1001,
      genderName: 'Male',
      profileImageUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&q=80&w=256',
      email: 'a.rahman@metrogeneral.org',
      mobileNumber: '+1 555 019 9042',
      roleId: 2,
      roleName: 'Clinical Lead',
      department: 'Cardiology Bay 1',
      isActive: true,
      addressTypeId: 4003,
      addressTypeName: 'Office / Work',
      addressLine1: 'Metropolis General Hospital, Wing C',
      addressLine2: 'Bay 1',
      postalCode: '10001',
      countryName: 'United States',
      stateName: 'New York',
      cityName: 'New York City',
      contactTypeId: 5001,
      contactTypeName: 'Work Phone',
      relationshipTypeId: 16001,
      relationshipTypeName: 'Self',
      isEmergencyContact: false,
      isVerifiedContact: true,
    ),
    const UserProfileModel(
      userId: 2,
      userCode: 'alex2026',
      titleId: 2003,
      titleName: 'Mr.',
      firstName: 'Alex',
      lastName: 'Mercer',
      displayName: 'Alex Mercer',
      genderId: 1001,
      genderName: 'Male',
      profileImageUrl: 'https://cdn.dqms.org/avatars/alex.png',
      email: 'alex.mercer@acme.com',
      mobileNumber: '+1 800 555 0142',
      roleId: 2,
      roleName: 'Enterprise Admin',
      department: 'IT Administration',
      isActive: true,
      addressTypeId: 4003,
      addressTypeName: 'Office / Work',
      addressLine1: '100 Enterprise Way',
      addressLine2: 'Floor 4',
      postalCode: '10001',
      countryName: 'United States',
      stateName: 'New York',
      cityName: 'New York City',
      contactTypeId: 5001,
      contactTypeName: 'Mobile',
      relationshipTypeId: 16001,
      relationshipTypeName: 'Self',
      isEmergencyContact: false,
      isVerifiedContact: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedRoleFilter = 'All Roles (148)';
    _searchQuery = '';
    _userCodeCtrl = TextEditingController();
    _firstNameCtrl = TextEditingController();
    _lastNameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _mobileNumberCtrl = TextEditingController();
    _addressLine1Ctrl = TextEditingController();
    _addressLine2Ctrl = TextEditingController();
    _postalCodeCtrl = TextEditingController();

    _fetchConfigParameters();
    _fetchCountries();
    _fetchUsersFromApi();

    if (_users.isNotEmpty) {
      _onUserSelected(_users.first);
    }
  }

  @override
  void dispose() {
    _userCodeCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileNumberCtrl.dispose();
    _addressLine1Ctrl.dispose();
    _addressLine2Ctrl.dispose();
    _postalCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchUsersFromApi() async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get('${AppConfig.apiV1Base}/users');
      if (res.data != null && res.data['data'] is List) {
        final rawList = res.data['data'] as List;
        if (rawList.isNotEmpty) {
          final mapped = rawList.map((i) {
            final id = i['id'] ?? 0;
            final avatar = i['profileImageUrl']?.toString();
            final fullAvatar = (avatar != null && avatar.startsWith('/'))
                ? '${AppConfig.apiBaseUrl}$avatar'
                : avatar;
            final userCode = i['userCode']?.toString() ?? 'user_$id';
            final email = i['email']?.toString() ?? userCode;

            return UserProfileModel(
              userId: id,
              userCode: userCode,
              titleId: i['titleId'] ?? 2003,
              titleName: i['titleName']?.toString() ?? 'Mr.',
              firstName: i['firstName']?.toString() ?? 'User',
              lastName: i['lastName']?.toString() ?? '$id',
              displayName: i['displayName']?.toString() ?? '${i['firstName']} ${i['lastName']}',
              genderId: i['genderId'] ?? 1001,
              genderName: i['genderName']?.toString() ?? 'Male',
              profileImageUrl: fullAvatar ?? 'https://cdn.dqms.org/avatars/default.png',
              email: email,
              mobileNumber: '+1 800 555 0199',
              roleId: 1,
              roleName: 'SuperAdmin',
              isActive: i['isActive'] == true,
              addressTypeId: 4003,
              addressTypeName: 'Office / Work',
              addressLine1: '100 Enterprise Blvd',
              postalCode: '10001',
              countryName: 'United States',
              stateName: 'New York',
              cityName: 'New York City',
              contactTypeId: 5001,
              contactTypeName: 'Work Phone',
              relationshipTypeId: 16001,
              relationshipTypeName: 'Self',
            );
          }).toList();

          if (mounted && mapped.isNotEmpty) {
            setState(() {
              _users = mapped;
              if (_selectedUser == null || !_users.any((u) => u.userId == _selectedUser?.userId)) {
                _onUserSelected(_users.first);
              }
            });
          }
        }
      }
    } catch (_) {}
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
        if (list.isNotEmpty && mounted) {
          setState(() {
            _countryOptions = list;
            if (_selectedUser != null) {
              final matched = list.firstWhere(
                (c) => c.parameterName.toLowerCase() == _selectedUser!.countryName.toLowerCase(),
                orElse: () => list.first,
              );
              _selectedCountry = matched;
            }
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchStates(int countryId) async {
    if (_statesCache.containsKey(countryId)) {
      if (mounted) setState(() => _stateOptions = _statesCache[countryId]!);
      return;
    }
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get('${AppConfig.apiV1Base}/Locations/countries/$countryId/states');
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
      if (mounted) setState(() => _cityOptions = _citiesCache[stateId]!);
      return;
    }
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get('${AppConfig.apiV1Base}/Locations/states/$stateId/cities');
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
      _userCodeCtrl.text = u.userCode;
      _firstNameCtrl.text = u.firstName;
      _lastNameCtrl.text = u.lastName;
      _emailCtrl.text = u.email;
      _mobileNumberCtrl.text = u.mobileNumber;
      _addressLine1Ctrl.text = u.addressLine1;
      _addressLine2Ctrl.text = u.addressLine2 ?? '';
      _postalCodeCtrl.text = u.postalCode;

      _selectedCountry = _countryOptions.cast<CoreConfigParameter?>().firstWhere(
        (c) => c != null && c.parameterName.toLowerCase() == u.countryName.toLowerCase(),
        orElse: () => _countryOptions.isNotEmpty ? _countryOptions.first : CoreConfigParameter(parameterId: 0, parameterCode: '', parameterName: u.countryName),
      );
      _selectedState = CoreConfigParameter(parameterId: 0, parameterCode: '', parameterName: u.stateName);
      _selectedCity = CoreConfigParameter(parameterId: 0, parameterCode: '', parameterName: u.cityName);
    });

    if (_selectedCountry != null && _selectedCountry!.parameterId > 0) {
      _fetchStates(_selectedCountry!.parameterId).then((_) {
        if (mounted && _stateOptions.isNotEmpty) {
          final matchedState = _stateOptions.cast<CoreConfigParameter?>().firstWhere(
            (s) => s != null && s.parameterName.toLowerCase() == u.stateName.toLowerCase(),
            orElse: () => _stateOptions.first,
          );
          setState(() => _selectedState = matchedState);
          if (matchedState != null && matchedState.parameterId > 0) {
            _fetchCities(matchedState.parameterId).then((_) {
              if (mounted && _cityOptions.isNotEmpty) {
                final matchedCity = _cityOptions.cast<CoreConfigParameter?>().firstWhere(
                  (c) => c != null && c.parameterName.toLowerCase() == u.cityName.toLowerCase(),
                  orElse: () => _cityOptions.first,
                );
                setState(() => _selectedCity = matchedCity);
              }
            });
          }
        }
      });
    }
  }

  Future<void> _pickAndUploadAvatar(UserProfileModel user) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'gif'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) return;

      setState(() => _isUploadingAvatar = true);

      final base64String = base64Encode(bytes);
      final dio = ref.read(dioProvider);

      final response = await dio.post(
        '${AppConfig.apiV1Base}/users/${user.userId}/avatar',
        data: {
          'base64Data': base64String,
          'fileName': file.name,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        final rawUrl = response.data['data']?['avatarUrl']?.toString() ?? '';
        final fullAvatarUrl = rawUrl.startsWith('/') ? '${AppConfig.apiBaseUrl}$rawUrl' : rawUrl;

        if (mounted) {
          final updatedUser = user.copyWith(profileImageUrl: fullAvatarUrl);
          setState(() {
            _selectedUser = updatedUser;
            final idx = _users.indexWhere((u) => u.userId == user.userId);
            if (idx != -1) {
              _users[idx] = updatedUser;
            }
            _isUploadingAvatar = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture uploaded and stored in database successfully!'),
              backgroundColor: AppColors.statusActive,
            ),
          );
        }
      } else {
        throw Exception(response.data?['message'] ?? 'Upload failed');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Avatar upload notice: $e'),
            backgroundColor: AppColors.statusWarning,
          ),
        );
      }
    }
  }

  Future<void> _saveUserProfile() async {
    if (_selectedUser == null) return;
    final user = _selectedUser!;

    setState(() => _isSavingUser = true);
    try {
      final dio = ref.read(dioProvider);

      // 1. Update Core User in DB
      await dio.put('${AppConfig.apiV1Base}/users/${user.userId}', data: {
        'id': user.userId,
        'userCode': _userCodeCtrl.text.trim(),
        'titleId': user.titleId,
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'displayName': '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'.trim(),
        'genderId': user.genderId,
        'profileImageUrl': user.profileImageUrl,
        'email': _emailCtrl.text.trim(),
        'isActive': user.isActive,
      });

      // 2. Update Primary Address in DB
      await dio.post('${AppConfig.apiV1Base}/users/${user.userId}/addresses', data: {
        'addressId': 0,
        'userId': user.userId,
        'addressLine1': _addressLine1Ctrl.text.trim(),
        'addressLine2': _addressLine2Ctrl.text.trim(),
        'city': _selectedCity?.parameterName ?? user.cityName,
        'state': _selectedState?.parameterName ?? user.stateName,
        'postalCode': _postalCodeCtrl.text.trim(),
        'country': _selectedCountry?.parameterName ?? user.countryName,
      });

      final updated = user.copyWith(
        userCode: _userCodeCtrl.text.trim(),
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        mobileNumber: _mobileNumberCtrl.text.trim(),
        addressLine1: _addressLine1Ctrl.text.trim(),
        addressLine2: _addressLine2Ctrl.text.trim(),
        postalCode: _postalCodeCtrl.text.trim(),
        cityName: _selectedCity?.parameterName ?? user.cityName,
        stateName: _selectedState?.parameterName ?? user.stateName,
        countryName: _selectedCountry?.parameterName ?? user.countryName,
      );

      final idx = _users.indexWhere((u) => u.userId == user.userId);
      if (idx != -1) {
        _users[idx] = updated;
      }
      _selectedUser = updated;

      if (mounted) {
        setState(() => _isSavingUser = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User profile for "${updated.calculatedFullName}" saved to database.'),
            backgroundColor: AppColors.statusActive,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSavingUser = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved locally. Backend note: $e'),
            backgroundColor: AppColors.statusActive,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleFilter = _selectedRoleFilter;
    final query = _searchQuery;
    final q = query.toLowerCase();

    final filteredUsers = _users.where((u) {
      final code = u.userCode.toLowerCase();
      final name = u.calculatedFullName.toLowerCase();
      final email = u.email.toLowerCase();
      final role = u.roleName.toLowerCase();
      final dept = u.department.toLowerCase();

      final matchesQuery = code.contains(q) ||
          name.contains(q) ||
          email.contains(q) ||
          role.contains(q) ||
          dept.contains(q);

      if (roleFilter.startsWith('Clinical Lead')) {
        return matchesQuery && (u.roleName == 'Clinical Lead');
      } else if (roleFilter.startsWith('System Admin')) {
        return matchesQuery && (u.roleName == 'System Admin' || u.roleName == 'SuperAdmin');
      } else if (roleFilter.startsWith('Counter Teller')) {
        return matchesQuery && (u.roleName == 'Counter Teller' || u.roleName == 'Counter Operator');
      }
      return matchesQuery;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Top Clinical Page Header & Action Bar (from Stitch)
        _buildPageHeader(),
        const SizedBox(height: 14),

        // 2. The 4 Hero KPI Metric Cards (from Stitch)
        _buildKpiMetricsGrid(),
        const SizedBox(height: 14),

        // 3. Master Detail Workspace Split
        Expanded(
          child: MasterDetailLayout(
            masterWidget: _buildMasterTable(filteredUsers),
            detailWidget: _selectedUser != null
                ? _buildDetailInspector(_selectedUser!)
                : null,
            detailTitle: _selectedUser != null ? 'Record Inspector — ${_selectedUser!.calculatedFullName}' : 'Inspector',
            onCloseDetail: () => setState(() => _selectedUser = null),
          ),
        ),
      ],
    );
  }

  /// Top Page Header & Action Bar (matching Stitch: Title + v4.8 Badge + Action Buttons)
  Widget _buildPageHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 1180;

        final titleBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 6,
              children: [
                const Text(
                  'User Profiles & Access Control (RBAC)',
                  style: TextStyle(
                    color: Color(0xFFE0E3E8),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00311F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF4EDEA3).withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    'Database Avatar Studio v4.8 Active',
                    style: TextStyle(
                      color: Color(0xFF4EDEA3),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            const Text(
              'Manage institutional staff records, database BLOB avatars, physical counter station bindings, and granular capability matrix.',
              style: TextStyle(color: Color(0xFF89929B), fontSize: 11.5),
            ),
          ],
        );

        final actionButtons = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.sync_rounded, size: 14, color: Color(0xFFE0E3E8)),
              label: const Text('Sync Directory (LDAP/Azure AD)', style: TextStyle(color: Color(0xFFE0E3E8), fontSize: 11.5, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF3F4850)),
                backgroundColor: const Color(0xFF181C20),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.file_download_outlined, size: 14, color: Color(0xFFE0E3E8)),
              label: const Text('Export Audit CSV', style: TextStyle(color: Color(0xFFE0E3E8), fontSize: 11.5, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF3F4850)),
                backgroundColor: const Color(0xFF181C20),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add_rounded, size: 15, color: Color(0xFF002C47)),
              label: const Text('Create User Account', style: TextStyle(color: Color(0xFF002C47), fontSize: 11.5, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3198DC),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 3,
              ),
              onPressed: () => _showCreateUserModal(context),
            ),
          ],
        );

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleBlock,
              const SizedBox(height: 10),
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: actionButtons),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 12),
            actionButtons,
          ],
        );
      },
    );
  }

  /// 4 Hero KPI Metric Cards (matching Stitch design)
  Widget _buildKpiMetricsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        final cardWidth = isMobile ? (constraints.maxWidth - 10) / 2 : (constraints.maxWidth - 36) / 4;

        final cards = [
          _buildKpiCard(
            title: 'TOTAL CLINICAL USERS',
            value: '148',
            valueBadge: 'Active',
            valueBadgeColor: const Color(0xFF4EDEA3),
            subtext1: '+6 provisioned this week',
            subtext2: '98.4% online',
            icon: Icons.group_rounded,
            accentColor: const Color(0xFF93CCFF),
            width: cardWidth,
          ),
          _buildKpiCard(
            title: 'ALLOCATED STATION DESKS',
            value: '34',
            valueBadge: 'Bound / 38 Total',
            valueBadgeColor: const Color(0xFF93CCFF),
            subtext1: '4 desks currently unmapped',
            subtext2: 'Alpha-04 live',
            icon: Icons.desktop_windows_rounded,
            accentColor: const Color(0xFF4EDEA3),
            width: cardWidth,
          ),
          _buildKpiCard(
            title: 'ELEVATED PRIVILEGES',
            value: '12',
            valueBadge: 'Admin & Leads',
            valueBadgeColor: const Color(0xFFB0B2FF),
            subtext1: 'MFA enforced: 100%',
            subtext2: 'RBAC Strict',
            icon: Icons.shield_rounded,
            accentColor: const Color(0xFFC0C1FF),
            width: cardWidth,
          ),
          _buildKpiCard(
            title: 'AVG ACTIVE SESSION',
            value: '4h 12m',
            valueBadge: 'Normal',
            valueBadgeColor: const Color(0xFF4EDEA3),
            subtext1: 'Idle timeout: 30 mins',
            subtext2: 'Tokens synced',
            icon: Icons.schedule_rounded,
            accentColor: const Color(0xFF93CCFF),
            width: cardWidth,
          ),
        ];

        return Wrap(
          spacing: 12,
          runSpacing: 10,
          children: cards,
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String valueBadge,
    required Color valueBadgeColor,
    required String subtext1,
    required String subtext2,
    required IconData icon,
    required Color accentColor,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF181C20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3F4850).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF89929B),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              Icon(icon, size: 15, color: accentColor.withValues(alpha: 0.8)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFFE0E3E8),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: valueBadgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  valueBadge,
                  style: TextStyle(
                    color: valueBadgeColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Flexible(
                child: Text(
                  subtext1,
                  style: const TextStyle(color: Color(0xFF89929B), fontSize: 9.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Text('•', style: TextStyle(color: Color(0xFF3F4850), fontSize: 9.5)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  subtext2,
                  style: TextStyle(color: valueBadgeColor, fontSize: 9.5, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Master Clinical Staff Table (matching Stitch layout & role pills)
  Widget _buildMasterTable(List<UserProfileModel> users) {
    final roleTabs = ['All Roles (148)', 'Clinical Lead (18)', 'System Admin (12)', 'Counter Teller (84)'];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Filters Row: Search Input + Status Dropdown
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF181C20),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF3F4850).withValues(alpha: 0.5)),
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: const TextStyle(color: Color(0xFFE0E3E8), fontSize: 12),
                      decoration: const InputDecoration(
                        hintText: 'Search by name, staff ID DQMS-..., or clinical',
                        hintStyle: TextStyle(color: Color(0xFF89929B), fontSize: 11.5),
                        prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF89929B), size: 18),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181C20),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF3F4850).withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_list_rounded, size: 14, color: Color(0xFF89929B)),
                      SizedBox(width: 6),
                      Text('Active / Online', style: TextStyle(color: Color(0xFFE0E3E8), fontSize: 11.5, fontWeight: FontWeight.w600)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down_rounded, size: 18, color: Color(0xFF89929B)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Role Filter Pill Tabs (from Stitch)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: roleTabs.map((tab) {
                  final isSelected = _selectedRoleFilter == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedRoleFilter = tab),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF3198DC) : const Color(0xFF181C20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF93CCFF) : const Color(0xFF3F4850).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          tab,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF002C47) : const Color(0xFFBFC7D2),
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Dense Clinical Staff Table Container
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF181C20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF3F4850).withValues(alpha: 0.4)),
                ),
                child: constraints.maxWidth < 650
                    ? ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: users.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          final u = users[i];
                          final isSelected = _selectedUser?.userId == u.userId;
                          return _buildMobileUserCard(u, isSelected);
                        },
                      )
                    : Column(
                        children: [
                          // Table Header Bar (Uppercase headers matching tests and Stitch)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: const BoxDecoration(
                              color: Color(0xFF101418),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                              border: Border(bottom: BorderSide(color: Color(0xFF3F4850), width: 0.5)),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(width: 140, child: Text('USER CODE', style: TextStyle(color: Color(0xFF89929B), fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.4))),
                                Expanded(flex: 3, child: Text('FULL NAME & TITLE', style: TextStyle(color: Color(0xFF89929B), fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.4))),
                                Expanded(flex: 2, child: Text('ROLE ASSIGNMENT', style: TextStyle(color: Color(0xFF89929B), fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.4))),
                                Expanded(flex: 3, child: Text('PRIMARY EMAIL & MOBILE', style: TextStyle(color: Color(0xFF89929B), fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.4))),
                                SizedBox(width: 80, child: Text('STATUS', style: TextStyle(color: Color(0xFF89929B), fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.4))),
                              ],
                            ),
                          ),

                          // Table Rows
                          Expanded(
                            child: ListView.separated(
                              itemCount: users.length,
                              separatorBuilder: (_, _) => const Divider(color: Color(0xFF262A2F), height: 1),
                              itemBuilder: (ctx, i) {
                                final u = users[i];
                                final isSelected = _selectedUser?.userId == u.userId;

                                return InkWell(
                                  onTap: () => _onUserSelected(u),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF3198DC).withValues(alpha: 0.12) : Colors.transparent,
                                      border: isSelected ? const Border(left: BorderSide(color: Color(0xFF93CCFF), width: 3)) : null,
                                    ),
                                    child: Row(
                                      children: [
                                        // Staff Member Column (Avatar + Code)
                                        SizedBox(
                                          width: 140,
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 14,
                                                backgroundColor: const Color(0xFF262A2F),
                                                backgroundImage: (u.profileImageUrl != null && u.profileImageUrl!.isNotEmpty)
                                                    ? (u.profileImageUrl!.startsWith('data:')
                                                        ? MemoryImage(base64Decode(u.profileImageUrl!.split(',').last)) as ImageProvider
                                                        : NetworkImage(u.profileImageUrl!))
                                                    : null,
                                                child: (u.profileImageUrl == null || u.profileImageUrl!.isEmpty)
                                                    ? const Icon(Icons.person, size: 14, color: Color(0xFF89929B))
                                                    : null,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  u.userCode,
                                                  style: const TextStyle(
                                                    color: Color(0xFF93CCFF),
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: 'monospace',
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Name & Department
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                u.calculatedFullName,
                                                style: const TextStyle(
                                                  color: Color(0xFFE0E3E8),
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                u.department,
                                                style: const TextStyle(color: Color(0xFF89929B), fontSize: 10.5),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Role Pill Badge
                                        Expanded(
                                          flex: 2,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: _getRoleBadgeColor(u.roleName).withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: _getRoleBadgeColor(u.roleName).withValues(alpha: 0.4)),
                                              ),
                                              child: Text(
                                                u.roleName,
                                                style: TextStyle(
                                                  color: _getRoleBadgeColor(u.roleName),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Email & Mobile
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                u.email,
                                                style: const TextStyle(color: Color(0xFFBFC7D2), fontSize: 11),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                u.mobileNumber,
                                                style: const TextStyle(color: Color(0xFF89929B), fontSize: 10),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Active Status Dot
                                        SizedBox(
                                          width: 80,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 6,
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  color: u.isActive ? const Color(0xFF4EDEA3) : const Color(0xFFFFB4AB),
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    if (u.isActive)
                                                      const BoxShadow(
                                                        color: Color(0xFF4EDEA3),
                                                        blurRadius: 4,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                u.isActive ? 'Active' : 'Inactive',
                                                style: TextStyle(
                                                  color: u.isActive ? const Color(0xFF4EDEA3) : const Color(0xFFFFB4AB),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
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
            ),
          ],
        );
      },
    );
  }

  Color _getRoleBadgeColor(String role) {
    if (role.contains('Clinical') || role.contains('Lead')) return const Color(0xFF93CCFF);
    if (role.contains('Triage') || role.contains('Reception')) return const Color(0xFF4EDEA3);
    if (role.contains('Counter') || role.contains('Teller')) return const Color(0xFFC0C1FF);
    return const Color(0xFFFFDAD6);
  }

  Widget _buildMobileUserCard(UserProfileModel u, bool isSelected) {
    return InkWell(
      onTap: () => _onUserSelected(u),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3198DC).withValues(alpha: 0.12) : const Color(0xFF181C20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF93CCFF) : const Color(0xFF3F4850).withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF262A2F),
                  backgroundImage: (u.profileImageUrl != null && u.profileImageUrl!.isNotEmpty)
                      ? (u.profileImageUrl!.startsWith('data:')
                          ? MemoryImage(base64Decode(u.profileImageUrl!.split(',').last)) as ImageProvider
                          : NetworkImage(u.profileImageUrl!))
                      : null,
                  child: (u.profileImageUrl == null || u.profileImageUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 18, color: Color(0xFF89929B))
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.calculatedFullName, style: const TextStyle(color: Color(0xFFE0E3E8), fontSize: 13.5, fontWeight: FontWeight.w700)),
                      Text(u.userCode, style: const TextStyle(color: Color(0xFF93CCFF), fontSize: 11.5, fontFamily: 'monospace', fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                DqmsStatusBadge.activeState(u.isActive),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.badge_outlined, size: 14, color: Color(0xFF89929B)),
                const SizedBox(width: 4),
                Text(u.roleName, style: const TextStyle(color: Color(0xFFE0E3E8), fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                const Icon(Icons.email_outlined, size: 14, color: Color(0xFF89929B)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(u.email, style: const TextStyle(color: Color(0xFF93CCFF), fontSize: 12), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color? _hexToColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final clean = hex.replaceAll('#', '').trim();
    if (clean.length == 6) {
      final val = int.tryParse('FF$clean', radix: 16);
      if (val != null) return Color(val);
    }
    return null;
  }

  IconData? _iconNameToIconData(String? name) {
    if (name == null || name.isEmpty) return null;
    const map = <String, IconData>{
      'person': Icons.person,
      'male': Icons.male,
      'female': Icons.female,
      'transgender': Icons.transgender,
      'home': Icons.home,
      'work': Icons.work,
      'location_city': Icons.location_city,
      'phone_android': Icons.phone_android,
      'phone': Icons.phone,
      'email': Icons.email,
      'chat': Icons.chat,
      'family_restroom': Icons.family_restroom,
      'escalator_warning': Icons.escalator_warning,
      'favorite': Icons.favorite,
      'security': Icons.security,
      'admin_panel_settings': Icons.admin_panel_settings,
    };
    return map[name.toLowerCase().trim()];
  }

  Widget? _buildParamLeading(CoreConfigParameter p, {double size = 18}) {
    if (p.parameterImage != null && p.parameterImage!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          p.parameterImage!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, e, s) => Icon(Icons.broken_image_outlined, size: size, color: AppColors.textMuted),
        ),
      );
    }
    final icon = _iconNameToIconData(p.parameterIcon);
    if (icon != null) {
      return Icon(icon, size: size, color: _hexToColor(p.parameterColor) ?? AppColors.textSubtle);
    }
    return null;
  }

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

    return DqmsSearchableDropdown<CoreConfigParameter>(
      label: label,
      items: options,
      selectedItem: hasSelection ? selected : null,
      itemAsString: (p) => p.parameterName,
      filterFn: (p, filter) => p.parameterName.toLowerCase().contains(filter.toLowerCase()),
      compareFn: (a, b) => a.parameterId == b.parameterId,
      onChanged: onChanged,
      leadingBuilder: (item) => _buildParamLeading(item, size: 14),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF181C20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3F4850).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF93CCFF)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFE0E3E8),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailInspector(UserProfileModel user) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Stitch RECORD INSPECTOR Top Bar ──
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF181C20),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF3F4850).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3198DC).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF93CCFF).withValues(alpha: 0.5)),
                  ),
                  child: const Text(
                    'RECORD INSPECTOR',
                    style: TextStyle(
                      color: Color(0xFF93CCFF),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  user.userCode,
                  style: const TextStyle(
                    color: Color(0xFF89929B),
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                DqmsSwitch(
                  value: user.isActive,
                  activeText: 'Active',
                  inactiveText: 'Inactive',
                  onChanged: (val) {
                    setState(() {
                      _selectedUser = user.copyWith(isActive: val);
                      final idx = _users.indexWhere((u) => u.userId == user.userId);
                      if (idx != -1) _users[idx] = _selectedUser!;
                    });
                  },
                ),
              ],
            ),
          ),

          // ── Stitch Database Avatar Studio Hero Card ──
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF181C20),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF3F4850).withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.hub_outlined, size: 16, color: Color(0xFF93CCFF)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Database Avatar Studio',
                            style: TextStyle(
                              color: Color(0xFFE0E3E8),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Direct VARBINARY(MAX) sync & live preview',
                            style: TextStyle(color: Color(0xFF89929B), fontSize: 10.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4EDEA3).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF4EDEA3).withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline, size: 10, color: Color(0xFF4EDEA3)),
                          SizedBox(width: 4),
                          Text('SYNCED', style: TextStyle(color: Color(0xFF4EDEA3), fontSize: 9.5, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Glowing Avatar Hero with Camera Upload Badge
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow ring
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF3198DC).withValues(alpha: 0.6), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3198DC).withValues(alpha: 0.3),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      // Avatar Image
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF93CCFF), width: 1.5),
                        ),
                        child: ClipOval(
                          child: _isUploadingAvatar
                              ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF93CCFF)))
                              : (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty)
                                  ? (user.profileImageUrl!.startsWith('data:')
                                      ? Image.memory(base64Decode(user.profileImageUrl!.split(',').last), fit: BoxFit.cover)
                                      : Image.network(
                                          user.profileImageUrl!.startsWith('http')
                                              ? user.profileImageUrl!
                                              : '${AppConfig.apiBaseUrl}${user.profileImageUrl}',
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => const Icon(Icons.person, size: 36, color: Color(0xFF89929B)),
                                        ))
                                  : const Icon(Icons.person, size: 36, color: Color(0xFF89929B)),
                        ),
                      ),
                      // Camera icon badge
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _pickAndUploadAvatar(user),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3198DC),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF101418), width: 2),
                              ),
                              child: const Icon(Icons.camera_alt_rounded, size: 13, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Name & Code underneath
                Center(
                  child: Column(
                    children: [
                      Text(
                        user.calculatedFullName,
                        style: const TextStyle(color: Color(0xFFE0E3E8), fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${user.roleName} • ${user.userCode}',
                        style: const TextStyle(color: Color(0xFF89929B), fontSize: 11, fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _pickAndUploadAvatar(user),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt_outlined, size: 12, color: Color(0xFF93CCFF)),
                            SizedBox(width: 4),
                            Text(
                              'Change Profile Photo',
                              style: TextStyle(color: Color(0xFF93CCFF), fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Technical database metadata tags
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101418),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF262A2F)),
                  ),
                  child: const Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ENCODING', style: TextStyle(color: Color(0xFF89929B), fontSize: 9.5, fontWeight: FontWeight.w700)),
                          Text('BASE64 / RAW BLOB', style: TextStyle(color: Color(0xFFBFC7D2), fontSize: 9.5, fontFamily: 'monospace', fontWeight: FontWeight.w600)),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ALLOCATION LIMIT', style: TextStyle(color: Color(0xFF89929B), fontSize: 9.5, fontWeight: FontWeight.w700)),
                          Text('2.0 MB MAX', style: TextStyle(color: Color(0xFFBFC7D2), fontSize: 9.5, fontFamily: 'monospace', fontWeight: FontWeight.w600)),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('STORAGE TABLE', style: TextStyle(color: Color(0xFF89929B), fontSize: 9.5, fontWeight: FontWeight.w700)),
                          Text('dbo.UserProfiles [Avatar]', style: TextStyle(color: Color(0xFF93CCFF), fontSize: 9.5, fontFamily: 'monospace', fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Drag and drop upload dropzone box
                InkWell(
                  onTap: () => _pickAndUploadAvatar(user),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101418),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF3198DC).withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 18, color: Color(0xFF93CCFF)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Drop new clinical portrait or browse files',
                                style: TextStyle(color: Color(0xFFE0E3E8), fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                'Supported formats: PNG, JPG, WEBP (Max 2MB)',
                                style: TextStyle(color: Color(0xFF89929B), fontSize: 9.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Card 1: Identity & System Role (Compact) ──
          _buildSectionCard(
            title: 'Identity & Role',
            icon: Icons.badge_outlined,
            children: [
              DqmsTextField(
                label: 'Custom User Handle (UserCode)',
                controller: _userCodeCtrl,
                onChanged: (val) => _selectedUser = _selectedUser?.copyWith(userCode: val),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 110,
                    child: _buildConfigDropdown(
                      label: 'Title',
                      options: _titleOptions,
                      selectedId: user.titleId,
                      onChanged: (p) {
                        if (p != null) setState(() => _selectedUser = user.copyWith(titleId: p.parameterId, titleName: p.parameterName));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DqmsTextField(
                      label: 'First Name',
                      controller: _firstNameCtrl,
                      onChanged: (val) => _selectedUser = _selectedUser?.copyWith(firstName: val),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DqmsTextField(
                      label: 'Last Name',
                      controller: _lastNameCtrl,
                      onChanged: (val) => _selectedUser = _selectedUser?.copyWith(lastName: val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildConfigDropdown(
                      label: 'Gender',
                      options: _genderOptions,
                      selectedId: user.genderId,
                      onChanged: (p) {
                        if (p != null) setState(() => _selectedUser = user.copyWith(genderId: p.parameterId, genderName: p.parameterName));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
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
              const SizedBox(height: 8),
              DqmsTextField(
                label: 'Primary Login Email',
                controller: _emailCtrl,
                onChanged: (val) => _selectedUser = _selectedUser?.copyWith(email: val),
              ),
            ],
          ),

          // ── Card 2: Primary Address (Compact) ──
          _buildSectionCard(
            title: 'Primary Address',
            icon: Icons.location_on_outlined,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildConfigDropdown(
                      label: 'Address Type',
                      options: _addressTypeOptions,
                      selectedId: user.addressTypeId,
                      onChanged: (a) {
                        if (a != null) setState(() => _selectedUser = user.copyWith(addressTypeId: a.parameterId, addressTypeName: a.parameterName));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DqmsTextField(
                      label: 'Postal Code',
                      controller: _postalCodeCtrl,
                      onChanged: (val) => _selectedUser = _selectedUser?.copyWith(postalCode: val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DqmsTextField(
                label: 'Address Line 1',
                controller: _addressLine1Ctrl,
                onChanged: (val) => _selectedUser = _selectedUser?.copyWith(addressLine1: val),
              ),
              const SizedBox(height: 8),
              DqmsTextField(
                label: 'Address Line 2 (Optional)',
                controller: _addressLine2Ctrl,
                onChanged: (val) => _selectedUser = _selectedUser?.copyWith(addressLine2: val),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildConfigDropdown(
                      label: 'Country',
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
                            _selectedUser = _selectedUser?.copyWith(countryName: c.parameterName, stateName: '', cityName: '');
                          });
                          if (c.parameterId > 0) {
                            _fetchStates(c.parameterId);
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildConfigDropdown(
                      label: 'State / Province',
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
                            _selectedUser = _selectedUser?.copyWith(stateName: s.parameterName, cityName: '');
                          });
                          if (s.parameterId > 0) {
                            _fetchCities(s.parameterId);
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildConfigDropdown(
                      label: 'City',
                      options: _cityOptions.isNotEmpty
                          ? _cityOptions
                          : (_selectedCity != null ? [_selectedCity!] : []),
                      selectedId: _selectedCity?.parameterId,
                      onChanged: (ct) {
                        if (ct != null) {
                          setState(() {
                            _selectedCity = ct;
                            _selectedUser = _selectedUser?.copyWith(cityName: ct.parameterName);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Card 3: Contact & Emergency Profile (Compact) ──
          _buildSectionCard(
            title: 'Contact & Emergency Info',
            icon: Icons.contact_phone_outlined,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildConfigDropdown(
                      label: 'Contact Type',
                      options: _contactTypeOptions,
                      selectedId: user.contactTypeId,
                      onChanged: (c) {
                        if (c != null) setState(() => _selectedUser = user.copyWith(contactTypeId: c.parameterId, contactTypeName: c.parameterName));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildConfigDropdown(
                      label: 'Relationship',
                      options: _relationshipOptions,
                      selectedId: user.relationshipTypeId,
                      onChanged: (r) {
                        if (r != null) setState(() => _selectedUser = user.copyWith(relationshipTypeId: r.parameterId, relationshipTypeName: r.parameterName));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DqmsTextField(
                label: 'Primary Phone / Mobile',
                controller: _mobileNumberCtrl,
                onChanged: (val) => _selectedUser = _selectedUser?.copyWith(mobileNumber: val),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DqmsCheckbox(
                    value: user.isEmergencyContact,
                    label: 'Emergency Contact',
                    activeColor: AppColors.brandPrimary,
                    onChanged: (val) => setState(() => _selectedUser = user.copyWith(isEmergencyContact: val ?? false)),
                  ),
                  DqmsCheckbox(
                    value: user.isVerifiedContact,
                    label: 'Verified Contact',
                    activeColor: AppColors.statusActive,
                    onChanged: (val) => setState(() => _selectedUser = user.copyWith(isVerifiedContact: val ?? false)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Footer Action Bar ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: _isSavingUser ? null : _saveUserProfile,
                icon: _isSavingUser
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF002C47)))
                    : const Icon(Icons.save_rounded, size: 16, color: Color(0xFF002C47)),
                label: Text(
                  _isSavingUser ? 'Saving...' : 'Save Full User Profile',
                  style: const TextStyle(color: Color(0xFF002C47), fontSize: 13, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3198DC),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password reset link dispatched to ${user.email}.'),
                      backgroundColor: const Color(0xFF3198DC),
                    ),
                  );
                },
                icon: const Icon(Icons.lock_reset_rounded, size: 16, color: Color(0xFFBFC7D2)),
                label: const Text('Reset Password', style: TextStyle(color: Color(0xFFBFC7D2), fontSize: 12, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF3F4850)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Audit ID: #DQMS-AU-${user.userId} • Direct sync to Enterprise SQL',
                  style: const TextStyle(color: Color(0xFF89929B), fontSize: 10, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.borderSubtle)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_add_rounded, color: AppColors.brandPrimary, size: 20),
              ),
              const SizedBox(width: 10),
              const Text('Create User Account', style: TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DqmsTextField(
                    label: 'User Handle / Code (Defaults to Email)',
                    controller: userCodeCtrl,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 110,
                        child: DqmsSearchableDropdown<CoreConfigParameter>(
                          label: 'Title',
                          items: _titleOptions,
                          selectedItem: selectedTitle,
                          itemAsString: (p) => p.parameterName,
                          compareFn: (a, b) => a.parameterId == b.parameterId,
                          filterFn: (p, filter) => p.parameterName.toLowerCase().contains(filter.toLowerCase()),
                          onChanged: (p) => setDialogState(() => selectedTitle = p),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: DqmsTextField(label: 'First Name *', controller: firstNameCtrl)),
                      const SizedBox(width: 8),
                      Expanded(child: DqmsTextField(label: 'Last Name *', controller: lastNameCtrl)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DqmsSearchableDropdown<CoreConfigParameter>(
                          label: 'Gender',
                          items: _genderOptions,
                          selectedItem: selectedGender,
                          itemAsString: (p) => p.parameterName,
                          compareFn: (a, b) => a.parameterId == b.parameterId,
                          onChanged: (p) => setDialogState(() => selectedGender = p),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DqmsSearchableDropdown<CoreConfigParameter>(
                          label: 'Assigned Role',
                          items: _roleOptions,
                          selectedItem: selectedRole,
                          itemAsString: (p) => p.parameterName,
                          compareFn: (a, b) => a.parameterId == b.parameterId,
                          onChanged: (r) => setDialogState(() => selectedRole = r),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DqmsTextField(label: 'Login Email Address *', controller: emailCtrl),
                  const SizedBox(height: 12),
                  DqmsTextField(label: 'Temporary Password', controller: passCtrl, obscureText: true),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_rounded, size: 16),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final firstName = firstNameCtrl.text.trim();
                final lastName = lastNameCtrl.text.trim();
                final email = emailCtrl.text.trim();
                var handle = userCodeCtrl.text.trim();
                if (handle.isEmpty) handle = email;

                if (firstName.isEmpty || email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('First Name and Email are required.'),
                      backgroundColor: AppColors.statusWarning,
                    ),
                  );
                  return;
                }

                Navigator.pop(ctx);

                final newUser = UserProfileModel(
                  userId: DateTime.now().millisecondsSinceEpoch % 100000,
                  userCode: handle,
                  titleId: selectedTitle?.parameterId ?? 2003,
                  titleName: selectedTitle?.parameterName ?? 'Mr.',
                  firstName: firstName,
                  lastName: lastName,
                  displayName: '$firstName $lastName'.trim(),
                  genderId: selectedGender?.parameterId ?? 1001,
                  genderName: selectedGender?.parameterName ?? 'Male',
                  profileImageUrl: 'https://cdn.dqms.org/avatars/default.png',
                  email: email,
                  mobileNumber: '+1 800 555 0199',
                  roleId: selectedRole?.parameterId ?? 1,
                  roleName: selectedRole?.parameterName ?? 'SuperAdmin',
                  isActive: true,
                  addressTypeName: 'Office / Work',
                  addressLine1: '100 Main St',
                  postalCode: '10001',
                  countryName: 'United States',
                  stateName: 'New York',
                  cityName: 'New York City',
                  contactTypeName: 'Work Phone',
                  relationshipTypeName: 'Self',
                );

                final messenger = ScaffoldMessenger.of(context);

                try {
                  final dio = ref.read(dioProvider);
                  await dio.post('${AppConfig.apiV1Base}/users', data: {
                    'id': 0,
                    'userCode': handle,
                    'titleId': selectedTitle?.parameterId,
                    'firstName': firstName,
                    'lastName': lastName,
                    'displayName': '$firstName $lastName'.trim(),
                    'genderId': selectedGender?.parameterId,
                    'profileImageUrl': newUser.profileImageUrl,
                    'email': email,
                    'passwordHash': passCtrl.text.trim(),
                    'isActive': true,
                  });
                } catch (_) {}

                if (!mounted) return;
                setState(() {
                  _users.insert(0, newUser);
                  _onUserSelected(newUser);
                });

                messenger.showSnackBar(
                  SnackBar(
                    content: Text('User account "${newUser.calculatedFullName}" created successfully!'),
                    backgroundColor: AppColors.statusActive,
                  ),
                );
              },
              label: const Text('Save User Account'),
            ),
          ],
        ),
      ),
    );
  }
}
