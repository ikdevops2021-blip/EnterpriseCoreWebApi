import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dqms_frontend/core/config/app_config.dart';
import 'package:dqms_frontend/core/network/dio_provider.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/widgets/dqms_button.dart';
import 'package:dqms_frontend/core/widgets/dqms_text_field.dart';
import 'package:dqms_frontend/features/auth/providers/auth_provider.dart';

/// ENTERPRISE LOGIN SCREEN (Application Entry Point)
class OrganizationOption {
  final String name;
  final String apiKey;
  final int organizationId;

  const OrganizationOption({
    required this.name,
    required this.apiKey,
    required this.organizationId,
  });
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _usernameCtrl = TextEditingController(text: 'admin@dqms.org');
  final TextEditingController _passwordCtrl = TextEditingController(text: 'Welc0me@555');

  final List<OrganizationOption> _orgOptions = const [
    OrganizationOption(
      name: 'Acme Enterprise Corp (Main HQ)',
      apiKey: 'dnaqms_live_alex_mercer_key_998877',
      organizationId: 3,
    ),
    OrganizationOption(
      name: 'West Wing Regional Medical Center',
      apiKey: 'dnaqms_live_john_doe_key_445566',
      organizationId: 2,
    ),
    OrganizationOption(
      name: 'Downtown Express Clinic',
      apiKey: 'dnaqms_live_icqfweN6llup9Umrp5J3SDR58fA1mGRbxBUDENjiNNw',
      organizationId: 1,
    ),
  ];

  late OrganizationOption _selectedOrg;

  @override
  void initState() {
    super.initState();
    _selectedOrg = _orgOptions.firstWhere(
      (opt) => opt.apiKey == AppConfig.organizationApiKey,
      orElse: () => _orgOptions.first,
    );
    // Sync active config on load
    AppConfig.updateEndpoints(
      organizationApiKey: _selectedOrg.apiKey,
      organizationId: _selectedOrg.organizationId,
    );
  }

  void _onOrgChanged(OrganizationOption? newOrg) {
    if (newOrg != null) {
      setState(() {
        _selectedOrg = newOrg;
        AppConfig.updateEndpoints(
          organizationApiKey: newOrg.apiKey,
          organizationId: newOrg.organizationId,
        );
      });
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final dio = ref.read(dioProvider);
    final success = await ref.read(authStateProvider.notifier).login(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text.trim(),
      dio,
    );

    if (success && mounted) {
      context.go('/admin/areas');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.brandPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.shield_rounded, color: AppColors.brandPrimary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('DQMS Enterprise', style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3), overflow: TextOverflow.ellipsis),
                          Text('Intelligent Queue Platform', style: TextStyle(color: AppColors.textSubtle, fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: AppColors.borderSubtle, height: 1),
                const SizedBox(height: 24),

                // Form Section
                const Text('Sign In to Account', style: TextStyle(color: AppColors.textMain, fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text('Enter your enterprise credentials to access workspace', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                const SizedBox(height: 18),

                if (authState.errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.statusDeactive.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.statusDeactive.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.statusDeactive, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authState.errorMessage!,
                            style: const TextStyle(color: AppColors.statusDeactive, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                DqmsTextField(
                  label: 'Username / Email Address',
                  hintText: 'e.g. admin@dqms.org',
                  controller: _usernameCtrl,
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 18),
                ),
                const SizedBox(height: 16),

                DqmsTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  controller: _passwordCtrl,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                ),
                const SizedBox(height: 20),

                // Organization Dropdown Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Organization / Tenant',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<OrganizationOption>(
                      initialValue: _selectedOrg,
                      dropdownColor: AppColors.bgSurface,
                      icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textSubtle),
                      style: const TextStyle(color: AppColors.textMain, fontSize: 13, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.bgCanvas,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        prefixIcon: const Icon(Icons.business_rounded, size: 18, color: AppColors.textSubtle),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.borderFocus, width: 1.5),
                        ),
                      ),
                      items: _orgOptions.map((OrganizationOption opt) {
                        return DropdownMenuItem<OrganizationOption>(
                          value: opt,
                          child: Text(
                            opt.name,
                            style: const TextStyle(color: AppColors.textMain, fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: _onOrgChanged,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit Button
                DqmsButton(
                  label: authState.isLoading ? 'Authenticating...' : 'Sign In to Workspace',
                  icon: Icons.login_rounded,
                  isFullWidth: true,
                  isLoading: authState.isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 20),

                // Quick Demo Preset Buttons
                const Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.borderSubtle)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('QUICK DEMO PRESETS', style: TextStyle(color: AppColors.textSubtle, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                    Expanded(child: Divider(color: AppColors.borderSubtle)),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.brandPrimary,
                          side: const BorderSide(color: AppColors.borderSubtle),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () {
                          setState(() {
                            _usernameCtrl.text = 'admin@dqms.org';
                            _passwordCtrl.text = 'Welc0me@555';
                          });
                        },
                        child: const Text('System Admin', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.brandPrimary,
                          side: const BorderSide(color: AppColors.borderSubtle),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () {
                          setState(() {
                            _usernameCtrl.text = 'operator@dqms.org';
                            _passwordCtrl.text = 'Operator@555';
                          });
                        },
                        child: const Text('Operator Staff', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
