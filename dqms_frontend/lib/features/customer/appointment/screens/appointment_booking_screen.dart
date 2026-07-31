import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/widgets/dqms_button.dart';
import 'package:dqms_frontend/core/widgets/dqms_text_field.dart';
import 'package:dqms_frontend/features/customer/providers/customer_experience_provider.dart';

/// ============================================================================
/// APPOINTMENT PRE-BOOKING SCREEN (AppointmentBookingScreen)
/// Pre-booking appointment wizard with digital QR Pass generation
/// ============================================================================
class AppointmentBookingScreen extends ConsumerStatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  ConsumerState<AppointmentBookingScreen> createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends ConsumerState<AppointmentBookingScreen> {
  final TextEditingController _nameCtrl = TextEditingController(text: 'Marcus Vance');
  final TextEditingController _emailCtrl = TextEditingController(text: 'marcus.vance@dqms.org');
  final TextEditingController _mobileCtrl = TextEditingController(text: '+1 (555) 234-5678');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentBookingStateProvider);
    final notifier = ref.read(appointmentBookingStateProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.bgHeader,
        title: const Row(
          children: [
            Icon(Icons.calendar_month_rounded, color: AppColors.brandPrimary, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'DQMS Appointment Booking',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Reset'),
            style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
            onPressed: () => notifier.reset(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildBookingStep(context, state, notifier),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingStep(BuildContext context, AppointmentBookingState state, AppointmentBookingNotifier notifier) {
    switch (state.activeStep) {
      case 0:
        return _buildStep0Location(notifier);
      case 1:
        return _buildStep1Service(state, notifier);
      case 2:
        return _buildStep2DateTime(state, notifier);
      case 3:
        return _buildStep3CustomerDetails(state, notifier);
      case 4:
        return _buildStep4ConfirmationQrPass(state, notifier);
      default:
        return _buildStep0Location(notifier);
    }
  }

  /// Step 0: Location Selection
  Widget _buildStep0Location(AppointmentBookingNotifier notifier) {
    final locations = [
      {'name': 'HQ Main Medical Center', 'address': 'Building A, 100 Enterprise Way', 'icon': Icons.business_rounded},
      {'name': 'West Wing Priority Clinic', 'address': 'Building B, 200 Healthcare Blvd', 'icon': Icons.local_hospital_rounded},
      {'name': 'Express Outpatient Branch', 'address': 'Plaza Level 1, 50 Express St', 'icon': Icons.storefront_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('STEP 1 OF 4: SELECT FACILITY LOCATION', style: TextStyle(color: AppColors.brandPrimary, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        const SizedBox(height: 6),
        const Text('Where would you like to schedule your appointment?', style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: locations.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) {
            final loc = locations[i];
            return InkWell(
              onTap: () => notifier.selectLocation(loc['name'] as String),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Icon(loc['icon'] as IconData, color: AppColors.brandPrimary, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc['name'] as String, style: const TextStyle(color: AppColors.textMain, fontSize: 15, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(loc['address'] as String, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSubtle, size: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Step 1: Service Selection
  Widget _buildStep1Service(AppointmentBookingState state, AppointmentBookingNotifier notifier) {
    final services = [
      'General Consultation & Registration',
      'Specialist Medical Triage',
      'Fast-Track Cashier & Billing',
      'Outpatient Pharmacy Dispensing',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('LOCATION: ${state.selectedLocation}', style: const TextStyle(color: AppColors.brandAccent, fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('STEP 2 OF 4: SELECT SERVICE', style: TextStyle(color: AppColors.brandPrimary, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        const SizedBox(height: 6),
        const Text('Choose the required clinical service:', style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) {
            final srv = services[i];
            return InkWell(
              onTap: () => notifier.selectService(srv),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_box_outline_blank_rounded, color: AppColors.brandPrimary, size: 24),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(srv, style: const TextStyle(color: AppColors.textMain, fontSize: 15, fontWeight: FontWeight.w800)),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSubtle, size: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Step 2: Date & Time Slot Selector
  Widget _buildStep2DateTime(AppointmentBookingState state, AppointmentBookingNotifier notifier) {
    final slots = ['09:00 AM', '10:30 AM', '01:15 PM', '02:30 PM', '04:00 PM'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('STEP 3 OF 4: CHOOSE DATE & TIME', style: TextStyle(color: AppColors.brandPrimary, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        const SizedBox(height: 6),
        const Text('Select an available appointment slot:', style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),

        // Date Picker Display
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: const Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: AppColors.brandPrimary, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Saturday, August 1, 2026',
                  style: TextStyle(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Text('Available', style: TextStyle(color: AppColors.statusActive, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text('AVAILABLE TIME SLOTS', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: slots.map((slot) {
            return InkWell(
              onTap: () => notifier.selectDateTime('2026-08-01', slot),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.brandPrimary),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_rounded, color: AppColors.brandPrimary, size: 16),
                    const SizedBox(width: 8),
                    Text(slot, style: const TextStyle(color: AppColors.brandPrimary, fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'monospace')),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Step 3: Customer Details Form
  Widget _buildStep3CustomerDetails(AppointmentBookingState state, AppointmentBookingNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('STEP 4 OF 4: CUSTOMER INFORMATION', style: TextStyle(color: AppColors.brandPrimary, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        const SizedBox(height: 6),
        const Text('Please enter your contact details to generate your pass:', style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: [
              DqmsTextField(label: 'Full Name', controller: _nameCtrl),
              const SizedBox(height: 14),
              DqmsTextField(label: 'Email Address', controller: _emailCtrl),
              const SizedBox(height: 14),
              DqmsTextField(label: 'Mobile Number', controller: _mobileCtrl),
              const SizedBox(height: 24),
              DqmsButton(
                label: 'CONFIRM & GENERATE QR PASS',
                icon: Icons.qr_code_2_rounded,
                isFullWidth: true,
                onPressed: () {
                  notifier.submitCustomerDetails(_nameCtrl.text, _emailCtrl.text, _mobileCtrl.text);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Step 4: Confirmation & QR Pass
  Widget _buildStep4ConfirmationQrPass(AppointmentBookingState state, AppointmentBookingNotifier notifier) {
    return Center(
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.statusActive.withValues(alpha: 0.5), width: 2),
        ),
        child: Column(
          children: [
            const Icon(Icons.verified_rounded, color: AppColors.statusActive, size: 56),
            const SizedBox(height: 12),
            const Text('APPOINTMENT CONFIRMED!', style: TextStyle(color: AppColors.statusActive, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
            const SizedBox(height: 16),

            // Booking Ref
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  const Text('BOOKING REFERENCE', style: TextStyle(color: AppColors.textSubtle, fontSize: 10, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(
                    state.bookingReference,
                    style: const TextStyle(color: AppColors.brandPrimary, fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'monospace', letterSpacing: 1.5),
                  ),
                  const Divider(color: AppColors.borderSubtle, height: 16),
                  _buildPassDetailRow('Customer:', state.fullName),
                  const SizedBox(height: 6),
                  _buildPassDetailRow('Facility:', state.selectedLocation ?? 'HQ Main Center'),
                  const SizedBox(height: 6),
                  _buildPassDetailRow('Date & Time:', '${state.selectedDate} at ${state.selectedTimeSlot}'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // QR Pass Code
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.qr_code_2_rounded, color: Colors.black, size: 100),
            ),
            const SizedBox(height: 8),
            const Text('Present this QR Pass at the Kiosk upon arrival for priority check-in.', style: TextStyle(color: AppColors.textMuted, fontSize: 11), textAlign: TextAlign.center),
            const SizedBox(height: 24),

            DqmsButton(
              label: 'BOOK ANOTHER APPOINTMENT',
              icon: Icons.add_task_rounded,
              isFullWidth: true,
              onPressed: () => notifier.reset(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassDetailRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        Text(val, style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
