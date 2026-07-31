import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/theme/app_breakpoints.dart';
import 'package:dqms_frontend/core/widgets/dqms_button.dart';
import 'package:dqms_frontend/features/customer/providers/customer_experience_provider.dart';

/// ============================================================================
/// SELF-SERVICE TOUCH KIOSK SCREEN (KioskScreen)
/// Touch-first 5-step wizard for instant kiosk ticket generation & QR tracking
/// ============================================================================
class KioskScreen extends ConsumerWidget {
  const KioskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kioskState = ref.watch(kioskStateProvider);
    final notifier = ref.read(kioskStateProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            // Kiosk Brand Header
            _buildKioskHeader(ref),

            // Kiosk Wizard Body
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildWizardStep(context, kioskState, notifier),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKioskHeader(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.bgHeader,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.touch_app_rounded, color: AppColors.brandPrimary, size: 28),
            ),
            const SizedBox(width: 14),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DQMS SELF-SERVICE KIOSK',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  'Touch-first Ticket Issuance System',
                  style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(width: 24),
            TextButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reset Kiosk'),
              style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
              onPressed: () => ref.read(kioskStateProvider.notifier).reset(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWizardStep(BuildContext context, KioskState state, KioskNotifier notifier) {
    switch (state.activeStep) {
      case 0:
        return _buildStep0Welcome(notifier);
      case 1:
        return _buildStep1ServiceSelection(context, notifier);
      case 2:
        return _buildStep2CategorySelection(context, notifier);
      case 3:
        return _buildStep3Confirmation(state, notifier);
      case 4:
        return _buildStep4TicketGenerated(state, notifier);
      default:
        return _buildStep0Welcome(notifier);
    }
  }

  /// Step 0: Welcome Screen
  Widget _buildStep0Welcome(KioskNotifier notifier) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.4), width: 2),
                ),
                child: const Icon(Icons.touch_app_rounded, color: AppColors.brandPrimary, size: 72),
              ),
              const SizedBox(height: 24),
              const Text(
                'WELCOME TO DQMS MEDICAL CENTER',
                style: TextStyle(color: AppColors.textMain, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Please touch the button below to register and receive your queue ticket.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 320,
                height: 64,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward_rounded, size: 24),
                  label: const Text('TOUCH TO BEGIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => notifier.selectService('General Registration'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Step 1: Service Selection
  Widget _buildStep1ServiceSelection(BuildContext context, KioskNotifier notifier) {
    final isMobile = AppBreakpoints.isMobile(context);
    final services = [
      {'title': 'General Registration', 'subtitle': 'First-time check-in and patient triage', 'icon': Icons.assignment_outlined},
      {'title': 'Priority Medical Screening', 'subtitle': 'Priority care consultation', 'icon': Icons.medical_services_outlined},
      {'title': 'Express Cashier & Billing', 'subtitle': 'Document collection and payment', 'icon': Icons.payments_outlined},
      {'title': 'Outpatient Pharmacy', 'subtitle': 'Prescription dispensing and advice', 'icon': Icons.local_pharmacy_outlined},
    ];

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('STEP 1 OF 3: SELECT SERVICE', style: TextStyle(color: AppColors.brandPrimary, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          const SizedBox(height: 6),
          const Text('Which service do you require today?', style: TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 1 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 2.8 : 2.2,
              ),
              itemCount: services.length,
              itemBuilder: (ctx, i) {
                final item = services[i];
                return InkWell(
                  onTap: () => notifier.selectService(item['title'] as String),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Icon(item['icon'] as IconData, color: AppColors.brandPrimary, size: 32),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item['title'] as String, style: const TextStyle(color: AppColors.textMain, fontSize: 15, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(item['subtitle'] as String, style: const TextStyle(color: AppColors.textMuted, fontSize: 11), overflow: TextOverflow.ellipsis),
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
    );
  }

  /// Step 2: Category Selection
  Widget _buildStep2CategorySelection(BuildContext context, KioskNotifier notifier) {
    final isMobile = AppBreakpoints.isMobile(context);
    final categories = [
      {'title': 'Standard Customer', 'subtitle': 'General registration token', 'icon': Icons.person_outline_rounded},
      {'title': 'Senior Citizen (65+)', 'subtitle': 'Priority queue line', 'icon': Icons.elderly_rounded},
      {'title': 'Accessibility / Assist', 'subtitle': 'Wheelchair & disability priority', 'icon': Icons.accessible_rounded},
      {'title': 'VIP / Executive Pass', 'subtitle': 'Express private lounge access', 'icon': Icons.star_rounded},
    ];

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('STEP 2 OF 3: SELECT CATEGORY', style: TextStyle(color: AppColors.brandPrimary, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          const SizedBox(height: 6),
          const Text('Please select your customer category:', style: TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 1 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 2.8 : 2.2,
              ),
              itemCount: categories.length,
              itemBuilder: (ctx, i) {
                final item = categories[i];
                return InkWell(
                  onTap: () => notifier.selectCategory(item['title'] as String),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Icon(item['icon'] as IconData, color: AppColors.brandAccent, size: 32),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item['title'] as String, style: const TextStyle(color: AppColors.textMain, fontSize: 15, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(item['subtitle'] as String, style: const TextStyle(color: AppColors.textMuted, fontSize: 11), overflow: TextOverflow.ellipsis),
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
    );
  }

  /// Step 3: Confirmation
  Widget _buildStep3Confirmation(KioskState state, KioskNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CONFIRM TICKET DETAILS', style: TextStyle(color: AppColors.brandPrimary, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              const SizedBox(height: 16),
              _buildSummaryRow('Selected Service:', state.selectedService ?? 'General Registration'),
              const SizedBox(height: 12),
              _buildSummaryRow('Customer Category:', state.selectedCategory ?? 'Standard Customer'),
              const SizedBox(height: 12),
              _buildSummaryRow('Estimated Wait Time:', '~${state.estimatedWaitMins} Minutes'),
              const SizedBox(height: 28),
              DqmsButton(
                label: 'GENERATE TICKET NOW',
                icon: Icons.confirmation_number_rounded,
                isFullWidth: true,
                onPressed: () => notifier.confirmAndGenerateTicket(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Step 4: Ticket Generated Screen
  Widget _buildStep4TicketGenerated(KioskState state, KioskNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.statusActive.withValues(alpha: 0.5), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.statusActive, size: 56),
              const SizedBox(height: 12),
              const Text('TICKET GENERATED!', style: TextStyle(color: AppColors.statusActive, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
              const SizedBox(height: 16),

              // Giant Token Display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    const Text('YOUR TICKET NUMBER', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w800)),
                    Text(
                      state.generatedTokenNumber,
                      style: const TextStyle(color: AppColors.brandPrimary, fontSize: 56, fontWeight: FontWeight.w900, fontFamily: 'monospace', letterSpacing: 2.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // QR Code Mock
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.qr_code_2_rounded, color: Colors.black, size: 90),
              ),
              const SizedBox(height: 8),
              const Text('Scan QR code on your mobile phone to track live queue status.', style: TextStyle(color: AppColors.textMuted, fontSize: 11), textAlign: TextAlign.center),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: DqmsButton(
                      label: 'PRINT TICKET',
                      icon: Icons.print_rounded,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DqmsButton(
                      label: 'FINISH',
                      icon: Icons.done_rounded,
                      onPressed: () => notifier.reset(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        Text(value, style: const TextStyle(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
