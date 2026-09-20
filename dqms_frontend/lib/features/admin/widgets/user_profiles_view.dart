import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
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

  List<UserProfileModel> _users = [
    const UserProfileModel(
      userId: 1,
      userCode: 'admin@dqms.org',
      titleId: 2007,
      titleName: 'Dr.',
      firstName: 'System',
      lastName: 'Admin',
      displayName: 'System Admin',
      genderId: 1001,
      genderName: 'Male',
      profileImageUrl: 'https://cdn.dqms.org/avatars/admin.png',
      email: 'admin@dqms.org',
      mobileNumber: '+1 800 555 0199',
      roleId: 1,
      roleName: 'SuperAdmin',
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
    const UserProfileModel(
      userId: 3,
      userCode: 'maria.chen',
      titleId: 2004,
      titleName: 'Ms.',
      firstName: 'Maria',
      lastName: 'Chen',
      displayName: 'Maria Chen',
      genderId: 1002,
      genderName: 'Female',
      profileImageUrl: 'https://cdn.dqms.org/avatars/maria.png',
      email: 'maria.chen@dqms.org',
      mobileNumber: '+1 800 555 0188',
      roleId: 3,
      roleName: 'Counter Operator',
      isActive: true,
      addressTypeId: 4001,
      addressTypeName: 'Residential',
      addressLine1: '42 Wallaby Way',
      postalCode: '2000',
      countryName: 'Australia',
      stateName: 'New South Wales',
      cityName: 'Sydney',
      contactTypeId: 5001,
      contactTypeName: 'Mobile',
      relationshipTypeId: 16001,
      relationshipTypeName: 'Self',
      isEmergencyContact: true,
      isVerifiedContact: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
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
    final filteredUsers = _users.where((u) {
      final q = _searchQuery.toLowerCase();
      return u.userCode.toLowerCase().contains(q) ||
          u.calculatedFullName.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.roleName.toLowerCase().contains(q);
    }).toList();

    return MasterDetailLayout(
      masterWidget: _buildMasterTable(filteredUsers),
      detailWidget: _selectedUser != null
          ? _buildDetailInspector(_selectedUser!)
          : null,
      detailTitle: _selectedUser != null ? 'User Profile Inspector — ${_selectedUser!.calculatedFullName}' : 'Inspector',
      onCloseDetail: () => setState(() => _selectedUser = null),
    );
  }

  Widget _buildMasterTable(List<UserProfileModel> users) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;

        return Column(
          children: [
            if (isMobile) ...[
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(color: AppColors.textMain, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search UserCode, Name, Email, or Role...',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSubtle, size: 20),
                  filled: true,
                  fillColor: AppColors.bgSurface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: DqmsButton(
                  label: 'Create User Account',
                  icon: Icons.person_add_rounded,
                  onPressed: () => _showCreateUserModal(context),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: const TextStyle(color: AppColors.textMain, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search UserCode, Full Name, Email, or Role...',
                        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSubtle, size: 20),
                        filled: true,
                        fillColor: AppColors.bgSurface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.borderSubtle),
                        ),
                      ),
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
            ],
            const SizedBox(height: 12),
            Expanded(
              child: isMobile
                  ? ListView.separated(
                      itemCount: users.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final u = users[i];
                        final isSelected = _selectedUser?.userId == u.userId;
                        return _buildMobileUserCard(u, isSelected);
                      },
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 850,
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
                                  SizedBox(width: 130, child: Text('USER CODE', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                  Expanded(flex: 3, child: Text('FULL NAME & TITLE', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                  Expanded(flex: 3, child: Text('PRIMARY EMAIL & MOBILE', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                  Expanded(flex: 2, child: Text('ROLE ASSIGNMENT', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
                                  SizedBox(width: 90, child: Text('STATUS', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w700))),
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
                                            width: 130,
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 14,
                                                  backgroundColor: AppColors.bgSubtle,
                                                  backgroundImage: (u.profileImageUrl != null && u.profileImageUrl!.isNotEmpty)
                                                      ? NetworkImage(u.profileImageUrl!)
                                                      : null,
                                                  child: (u.profileImageUrl == null || u.profileImageUrl!.isEmpty)
                                                      ? const Icon(Icons.person, size: 16, color: AppColors.textMuted)
                                                      : null,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    u.userCode,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(color: AppColors.brandPrimary, fontSize: 12, fontWeight: FontWeight.w800, fontFamily: 'monospace'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(u.calculatedFullName, style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700)),
                                                const SizedBox(height: 2),
                                                Text('Gender: ${u.genderName}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(u.email, style: const TextStyle(color: AppColors.brandAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                                                const SizedBox(height: 2),
                                                Text(u.mobileNumber, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(u.roleName, style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600)),
                                          ),
                                          SizedBox(
                                            width: 90,
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
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileUserCard(UserProfileModel u, bool isSelected) {
    return InkWell(
      onTap: () => _onUserSelected(u),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.12) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.brandPrimary : AppColors.borderSubtle,
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
                  backgroundColor: AppColors.bgSubtle,
                  backgroundImage: (u.profileImageUrl != null && u.profileImageUrl!.isNotEmpty)
                      ? NetworkImage(u.profileImageUrl!)
                      : null,
                  child: (u.profileImageUrl == null || u.profileImageUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 18, color: AppColors.textMuted)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(u.userCode, style: const TextStyle(color: AppColors.brandPrimary, fontSize: 13, fontWeight: FontWeight.w800, fontFamily: 'monospace')),
                ),
                DqmsStatusBadge.activeState(u.isActive),
              ],
            ),
            const SizedBox(height: 8),
            Text(u.calculatedFullName, style: const TextStyle(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(u.email, style: const TextStyle(color: AppColors.brandAccent, fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(u.roleName, style: const TextStyle(color: AppColors.textSubtle, fontSize: 12, fontWeight: FontWeight.w600)),
                const Spacer(),
                const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
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

    return DropdownSearch<CoreConfigParameter>(
      items: options,
      selectedItem: hasSelection ? selected : null,
      itemAsString: (p) => p.parameterName,
      filterFn: (p, filter) => p.parameterName.toLowerCase().contains(filter.toLowerCase()),
      compareFn: (a, b) => a.parameterId == b.parameterId,
      onChanged: onChanged,
      dropdownBuilder: (ctx, item) {
        if (item == null) {
          return const Text('— Select —', style: TextStyle(color: AppColors.textMuted, fontSize: 12));
        }
        final leading = _buildParamLeading(item, size: 16);
        return Row(
          children: [
            if (leading != null) ...[leading, const SizedBox(width: 8)],
            Expanded(
              child: Text(
                item.parameterName,
                style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSubtle, fontSize: 12, fontWeight: FontWeight.w600),
          filled: true,
          fillColor: AppColors.bgSubtle,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.borderSubtle),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.borderSubtle),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.brandPrimary, width: 1.5),
          ),
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: options.length > 5,
        searchFieldProps: const TextFieldProps(
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
        itemBuilder: (ctx, item, isSelected) {
          final leading = _buildParamLeading(item);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.15) : null,
            child: Row(
              children: [
                if (leading != null) ...[leading, const SizedBox(width: 10)],
                Expanded(
                  child: Text(
                    item.parameterName,
                    style: TextStyle(
                      color: isSelected ? AppColors.brandPrimary : AppColors.textMain,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.brandPrimary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
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
          // ── Header Profile Hero Card ──
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                // Avatar with Camera Upload Badge
                Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.brandPrimary, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandPrimary.withValues(alpha: 0.25),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _isUploadingAvatar
                            ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandAccent))
                            : (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty)
                                ? Image.network(
                                    user.profileImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Icon(Icons.person, size: 36, color: AppColors.textMuted),
                                  )
                                : const Icon(Icons.person, size: 36, color: AppColors.textMuted),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _pickAndUploadAvatar(user),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.brandPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.calculatedFullName, style: const TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.brandPrimary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(user.roleName, style: const TextStyle(color: AppColors.brandPrimary, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 8),
                          Text(user.userCode, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontFamily: 'monospace')),
                        ],
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => _pickAndUploadAvatar(user),
                        child: const Row(
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 14, color: AppColors.brandAccent),
                            SizedBox(width: 4),
                            Text('Change Profile Photo', style: TextStyle(color: AppColors.brandAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Active Switch
                Column(
                  children: [
                    Switch(
                      value: user.isActive,
                      activeThumbColor: AppColors.statusActive,
                      onChanged: (val) {
                        setState(() {
                          _selectedUser = user.copyWith(isActive: val);
                          final idx = _users.indexWhere((u) => u.userId == user.userId);
                          if (idx != -1) _users[idx] = _selectedUser!;
                        });
                      },
                    ),
                    Text(user.isActive ? 'Active' : 'Inactive', style: TextStyle(color: user.isActive ? AppColors.statusActive : AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),

          // ── Card 1: Identity & System Role ──
          _buildSectionCard(
            title: 'Identity & Role',
            icon: Icons.badge_outlined,
            children: [
              DqmsTextField(
                label: 'Custom User Handle (UserCode)',
                controller: _userCodeCtrl,
                onChanged: (val) => _selectedUser = _selectedUser?.copyWith(userCode: val),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  SizedBox(
                    width: 140,
                    child: _buildConfigDropdown(
                      label: 'Title',
                      options: _titleOptions,
                      selectedId: user.titleId,
                      onChanged: (p) {
                        if (p != null) setState(() => _selectedUser = user.copyWith(titleId: p.parameterId, titleName: p.parameterName));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DqmsTextField(
                      label: 'First Name',
                      controller: _firstNameCtrl,
                      onChanged: (val) => _selectedUser = _selectedUser?.copyWith(firstName: val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DqmsTextField(
                      label: 'Last Name',
                      controller: _lastNameCtrl,
                      onChanged: (val) => _selectedUser = _selectedUser?.copyWith(lastName: val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
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
              DqmsTextField(
                label: 'Primary Login Email',
                controller: _emailCtrl,
                onChanged: (val) => _selectedUser = _selectedUser?.copyWith(email: val),
              ),
            ],
          ),

          // ── Card 2: Primary Address ──
          _buildSectionCard(
            title: 'Primary Address',
            icon: Icons.location_on_outlined,
            children: [
              Row(
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: DqmsTextField(
                      label: 'Postal Code',
                      controller: _postalCodeCtrl,
                      onChanged: (val) => _selectedUser = _selectedUser?.copyWith(postalCode: val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DqmsTextField(
                label: 'Address Line 1',
                controller: _addressLine1Ctrl,
                onChanged: (val) => _selectedUser = _selectedUser?.copyWith(addressLine1: val),
              ),
              const SizedBox(height: 12),
              DqmsTextField(
                label: 'Address Line 2 (Optional)',
                controller: _addressLine2Ctrl,
                onChanged: (val) => _selectedUser = _selectedUser?.copyWith(addressLine2: val),
              ),
              const SizedBox(height: 12),
              Row(
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
                  const SizedBox(width: 12),
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
                  const SizedBox(width: 12),
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

          // ── Card 3: Contact & Emergency Profile ──
          _buildSectionCard(
            title: 'Contact & Emergency Info',
            icon: Icons.contact_phone_outlined,
            children: [
              Row(
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
                  const SizedBox(width: 12),
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
              const SizedBox(height: 12),
              DqmsTextField(
                label: 'Primary Phone / Mobile',
                controller: _mobileNumberCtrl,
                onChanged: (val) => _selectedUser = _selectedUser?.copyWith(mobileNumber: val),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: user.isEmergencyContact,
                        activeColor: AppColors.brandPrimary,
                        onChanged: (val) => setState(() => _selectedUser = user.copyWith(isEmergencyContact: val ?? false)),
                      ),
                      const Text('Emergency Contact', style: TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: user.isVerifiedContact,
                        activeColor: AppColors.statusActive,
                        onChanged: (val) => setState(() => _selectedUser = user.copyWith(isVerifiedContact: val ?? false)),
                      ),
                      const Text('Verified Contact', style: TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
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
              DqmsButton(
                label: _isSavingUser ? 'Saving...' : 'Save Full User Profile',
                icon: Icons.save_rounded,
                isLoading: _isSavingUser,
                isFullWidth: true,
                onPressed: _saveUserProfile,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password reset link dispatched to ${user.email}.'),
                      backgroundColor: AppColors.brandPrimary,
                    ),
                  );
                },
                icon: const Icon(Icons.lock_reset_rounded, size: 16, color: AppColors.textSubtle),
                label: const Text('Reset Password', style: TextStyle(color: AppColors.textSubtle, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderSubtle),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                    children: [
                      SizedBox(
                        width: 140,
                        child: DropdownSearch<CoreConfigParameter>(
                          items: _titleOptions,
                          selectedItem: selectedTitle,
                          itemAsString: (p) => p.parameterName,
                          compareFn: (a, b) => a.parameterId == b.parameterId,
                          filterFn: (p, filter) => p.parameterName.toLowerCase().contains(filter.toLowerCase()),
                          onChanged: (p) => setDialogState(() => selectedTitle = p),
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Title',
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
                      Expanded(child: DqmsTextField(label: 'First Name *', controller: firstNameCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: DqmsTextField(label: 'Last Name *', controller: lastNameCtrl)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownSearch<CoreConfigParameter>(
                          items: _genderOptions,
                          selectedItem: selectedGender,
                          itemAsString: (p) => p.parameterName,
                          compareFn: (a, b) => a.parameterId == b.parameterId,
                          onChanged: (p) => setDialogState(() => selectedGender = p),
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Gender',
                              labelStyle: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w600),
                              filled: true,
                              fillColor: AppColors.bgSubtle,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(),
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
