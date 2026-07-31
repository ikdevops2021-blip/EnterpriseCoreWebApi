import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final String roleName;
  final bool isActive;

  // Address Entity Fields (UserAddress.cs)
  final String addressTypeName; // 'Home', 'Work', 'Billing', 'Shipping'
  final String addressLine1;
  final String? addressLine2;
  final String postalCode;
  final String countryName;
  final String stateName;
  final String cityName;

  // Contact Entity Fields (UserContact.cs)
  final String contactTypeName; // 'Mobile', 'Work Phone', 'Email'
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
    required this.roleName,
    required this.isActive,
    required this.addressTypeName,
    required this.addressLine1,
    this.addressLine2,
    required this.postalCode,
    required this.countryName,
    required this.stateName,
    required this.cityName,
    required this.contactTypeName,
    required this.relationshipTypeName,
    this.isEmergencyContact = false,
    this.isVerifiedContact = true,
  });

  String get calculatedFullName => '$titleName $firstName $lastName'.trim();
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
                        onTap: () => setState(() => _selectedUser = u),
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

  Widget _buildDetailInspector(UserProfileModel user) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DqmsTextField(label: 'Custom User Handle (UserCode)', initialValue: user.userCode),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(width: 90, child: DqmsTextField(label: 'Title ID', initialValue: '${user.titleName} (${user.titleId})')),
              const SizedBox(width: 12),
              Expanded(child: DqmsTextField(label: 'First Name', initialValue: user.firstName)),
              const SizedBox(width: 12),
              Expanded(child: DqmsTextField(label: 'Last Name', initialValue: user.lastName)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: DqmsTextField(label: 'Gender Salutation', initialValue: user.genderName)),
              const SizedBox(width: 12),
              Expanded(child: DqmsTextField(label: 'Assigned Role', initialValue: user.roleName)),
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
              Expanded(child: DqmsTextField(label: 'Address Type', initialValue: user.addressTypeName)),
              const SizedBox(width: 12),
              Expanded(child: DqmsTextField(label: 'Postal Code', initialValue: user.postalCode)),
            ],
          ),
          const SizedBox(height: 10),
          DqmsTextField(label: 'Address Line 1', initialValue: user.addressLine1),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: DqmsTextField(label: 'Country', initialValue: user.countryName)),
              const SizedBox(width: 12),
              Expanded(child: DqmsTextField(label: 'State', initialValue: user.stateName)),
              const SizedBox(width: 12),
              Expanded(child: DqmsTextField(label: 'City', initialValue: user.cityName)),
            ],
          ),
          const SizedBox(height: 16),

          // User Contact Entity Section
          const Text('User Contact & Emergency Profile (UserContact Entity)', style: TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: DqmsTextField(label: 'Contact Channel Type', initialValue: user.contactTypeName)),
              const SizedBox(width: 12),
              Expanded(child: DqmsTextField(label: 'Relationship Type', initialValue: user.relationshipTypeName)),
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User ${user.calculatedFullName} profile saved matching User.cs entity.'), backgroundColor: AppColors.statusActive),
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: AppColors.borderSubtle)),
        title: const Text('Create User Account (User.cs Entity)', style: TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DqmsTextField(label: 'UserCode / Handle (Defaults to Email)', controller: userCodeCtrl),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: DqmsTextField(label: 'First Name', controller: firstNameCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: DqmsTextField(label: 'Last Name', controller: lastNameCtrl)),
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
                const SnackBar(content: Text('User account created.'), backgroundColor: AppColors.statusActive),
              );
            },
            child: const Text('Save User'),
          ),
        ],
      ),
    );
  }
}
