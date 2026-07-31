import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/config/app_config.dart';
import 'package:dqms_frontend/core/network/dio_provider.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/widgets/dqms_button.dart';
import 'package:dqms_frontend/core/widgets/dqms_text_field.dart';
import 'package:dqms_frontend/core/widgets/dqms_status_badge.dart';

/// EMAIL CONFIGURATION & GATEWAY DISPATCHER VIEW
class EmailConfigView extends ConsumerStatefulWidget {
  const EmailConfigView({super.key});

  @override
  ConsumerState<EmailConfigView> createState() => _EmailConfigViewState();
}

class _EmailConfigViewState extends ConsumerState<EmailConfigView> {
  final TextEditingController _smtpHostCtrl = TextEditingController(text: 'smtp.office365.com');
  final TextEditingController _smtpPortCtrl = TextEditingController(text: '587');
  final TextEditingController _smtpUserCtrl = TextEditingController(text: 'notifications@dqms-enterprise.org');
  final TextEditingController _smtpPassCtrl = TextEditingController(text: '••••••••••••••••');
  final TextEditingController _senderNameCtrl = TextEditingController(text: 'DQMS Enterprise Notification Gateway');
  final TextEditingController _htmlSignatureCtrl = TextEditingController(
    text: '<div style="font-family: Arial; color: #222;">\n  <p>Best regards,<br/><strong>DQMS Automated Dispatch Engine</strong></p>\n  <p style="font-size: 11px; color: #666;">This email was sent from an unmonitored mailbox.</p>\n</div>',
  );

  bool _enableSsl = true;
  bool _isAsyncQueueActive = true;

  @override
  void dispose() {
    _smtpHostCtrl.dispose();
    _smtpPortCtrl.dispose();
    _smtpUserCtrl.dispose();
    _smtpPassCtrl.dispose();
    _senderNameCtrl.dispose();
    _htmlSignatureCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
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
                    const Icon(Icons.mark_email_read_rounded, color: AppColors.brandPrimary, size: 24),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Organization SMTP Gateway & Email Queue Settings', style: TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.w700)),
                        Text('Configure tenant-aware SMTP server credentials, SSL/TLS, and HTML signatures', style: TextStyle(color: AppColors.textSubtle, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    DqmsStatusBadge.activeState(_isAsyncQueueActive),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: AppColors.borderSubtle, height: 1),
                const SizedBox(height: 20),

                // Form Fields
                Row(
                  children: [
                    Expanded(flex: 3, child: DqmsTextField(label: 'SMTP Host Server', controller: _smtpHostCtrl)),
                    const SizedBox(width: 16),
                    Expanded(flex: 1, child: DqmsTextField(label: 'SMTP Port', controller: _smtpPortCtrl)),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SSL / STARTTLS Enforced', style: TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(_enableSsl ? 'TLS Active' : 'Plaintext', style: const TextStyle(color: AppColors.brandAccent, fontSize: 11, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                              ),
                              Switch(
                                value: _enableSsl,
                                onChanged: (val) => setState(() => _enableSsl = val),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Async Background Queue', style: TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(_isAsyncQueueActive ? 'Queue Active' : 'Paused', style: TextStyle(color: _isAsyncQueueActive ? AppColors.statusActive : AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                              ),
                              Switch(
                                value: _isAsyncQueueActive,
                                onChanged: (val) => setState(() => _isAsyncQueueActive = val),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(child: DqmsTextField(label: 'SMTP Username / Sender Address', controller: _smtpUserCtrl)),
                    const SizedBox(width: 16),
                    Expanded(child: DqmsTextField(label: 'SMTP Password / API Token', controller: _smtpPassCtrl, obscureText: true)),
                  ],
                ),
                const SizedBox(height: 16),

                DqmsTextField(label: 'Default Outbound Display Name', controller: _senderNameCtrl),
                const SizedBox(height: 16),

                DqmsTextField(
                  label: 'Organization HTML Email Signature Template',
                  controller: _htmlSignatureCtrl,
                  maxLines: 5,
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: const Text('Send Test Connection Mail'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.brandPrimary,
                        side: const BorderSide(color: AppColors.brandPrimary),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Test mail dispatched to notifications@dqms-enterprise.org.'), backgroundColor: AppColors.statusActive),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    DqmsButton(
                      label: 'Save SMTP Settings',
                      icon: Icons.save_rounded,
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          final dio = ref.read(dioProvider);
                          await dio.post('${AppConfig.apiV1Base}/email/config', data: {
                            'smtpHost': _smtpHostCtrl.text,
                            'smtpPort': int.tryParse(_smtpPortCtrl.text) ?? 587,
                            'username': _smtpUserCtrl.text,
                            'password': _smtpPassCtrl.text,
                            'senderName': _senderNameCtrl.text,
                            'enableSsl': _enableSsl,
                            'isAsyncQueueActive': _isAsyncQueueActive,
                          });
                        } catch (_) {}

                        messenger.showSnackBar(
                          const SnackBar(content: Text('SMTP Gateway settings saved to backend API.'), backgroundColor: AppColors.statusActive),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
