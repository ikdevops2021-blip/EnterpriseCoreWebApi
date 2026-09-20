import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/theme/app_decorations.dart';
import 'package:dqms_frontend/core/theme/app_typography.dart';
import 'package:dqms_frontend/core/widgets/glass_widgets.dart';
import 'package:dqms_frontend/core/widgets/dqms_button.dart';
import 'package:dqms_frontend/core/widgets/dqms_text_field.dart';
import 'package:dqms_frontend/features/customer/providers/customer_experience_provider.dart';

/// ============================================================================
/// APPOINTMENT PRE-BOOKING SCREEN (AppointmentBookingScreen)
/// Modern luxury glassmorphism pre-booking wizard with digital QR Pass generation
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
  final TextEditingController _serviceSearchCtrl = TextEditingController();
  String _selectedServiceFilter = 'All';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _serviceSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentBookingStateProvider);
    final notifier = ref.read(appointmentBookingStateProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            // Modern Frosted Header
            _buildAppBar(context, state, notifier),

            // Step Progress Bar
            _buildStepIndicator(state),

            // Wizard Step Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 860),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildBookingStep(context, state, notifier),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppointmentBookingState state, AppointmentBookingNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgHeader,
        border: const Border(bottom: BorderSide(color: AppColors.glassBorderLight, width: 1.0)),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.cyanGlow),
            tooltip: 'Back',
            onPressed: () {
              if (state.activeStep > 0 && state.activeStep < 4) {
                notifier.goToStep(state.activeStep - 1);
              } else if (context.canPop()) {
                context.pop();
              } else {
                context.go('/mobile');
              }
            },
          ),
          const SizedBox(width: 8),
          const GlassSquircleIcon(
            icon: Icons.calendar_month_rounded,
            backgroundColor: AppColors.darkBlueIconBg,
            iconColor: AppColors.brandPrimary,
            size: 36,
            iconSize: 18,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DQMS Appointment Booking',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Fast-track digital priority reservation',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.textMuted),
            label: const Text('Reset', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            onPressed: () {
              _serviceSearchCtrl.clear();
              notifier.reset();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(AppointmentBookingState state) {
    final stepLabels = ['Facility', 'Service', 'Schedule', 'Details', 'Pass'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(stepLabels.length, (index) {
            final isCurrent = state.activeStep == index;
            final isDone = state.activeStep > index;

            return Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.brandPrimary
                        : (isDone ? AppColors.emeraldSuccess : AppColors.bgCanvas),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent
                          ? AppColors.brandPrimary
                          : (isDone ? AppColors.emeraldSuccess : AppColors.borderSubtle),
                    ),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent ? Colors.white : AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  stepLabels[index],
                  style: TextStyle(
                    color: isCurrent ? AppColors.textMain : (isDone ? AppColors.textMain : AppColors.textMuted),
                    fontSize: 12,
                    fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
                if (index < stepLabels.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      width: 24,
                      height: 2,
                      color: isDone ? AppColors.emeraldSuccess : AppColors.borderSubtle,
                    ),
                  ),
              ],
            );
          }),
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
      {
        'name': 'HQ Main Medical Center',
        'address': 'Building A, 100 Enterprise Way',
        'icon': Icons.local_hospital_rounded,
        'tag': 'Main Hospital Campus',
        'color': AppColors.brandPrimary,
        'badge': 'Full Diagnostics',
      },
      {
        'name': 'West Wing Priority Clinic',
        'address': 'Building B, 200 Healthcare Blvd',
        'icon': Icons.medical_services_rounded,
        'tag': 'Specialist Wing',
        'color': AppColors.violetPrimary,
        'badge': 'Express Triage',
      },
      {
        'name': 'Express Outpatient Branch',
        'address': 'Plaza Level 1, 50 Express St',
        'icon': Icons.storefront_rounded,
        'tag': 'Rapid Care Center',
        'color': AppColors.emeraldSuccess,
        'badge': 'Walk-in & Rx',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GlassPillBadge(
          label: 'STEP 1 OF 4: SELECT FACILITY',
          variant: GlassPillVariant.upcoming,
        ),
        const SizedBox(height: 10),
        const Text(
          'Where would you like to schedule your appointment?',
          style: TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          'Choose from our certified healthcare facilities offering priority queue coordination.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 22),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: locations.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (ctx, i) {
            final loc = locations[i];
            final color = loc['color'] as Color;

            return GlassCard(
              onTap: () => notifier.selectLocation(loc['name'] as String),
              padding: const EdgeInsets.all(18),
              borderRadius: AppRadius.card,
              child: Row(
                children: [
                  GlassSquircleIcon(
                    icon: loc['icon'] as IconData,
                    backgroundColor: color.withValues(alpha: 0.15),
                    iconColor: color,
                    size: 46,
                    iconSize: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                loc['name'] as String,
                                style: const TextStyle(
                                  color: AppColors.textMain,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                                border: Border.all(color: color.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                loc['badge'] as String,
                                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc['address'] as String,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.cyanGlow, size: 15),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// Step 1: Service Selection (2-column layout matching reference design)
  Widget _buildStep1Service(AppointmentBookingState state, AppointmentBookingNotifier notifier) {
    final servicesCatalog = [
      {
        'name': 'General Consultation & Registration',
        'category': 'Consultation',
        'doctor': 'Dr. Marcus Vance, MD',
        'icon': Icons.medical_services_rounded,
        'color': AppColors.electricBlue,
        'sla': '10 mins',
      },
      {
        'name': 'Specialist Medical Triage',
        'category': 'Specialist',
        'doctor': 'Dr. Sarah Connor, FACP',
        'icon': Icons.favorite_rounded,
        'color': AppColors.violetPrimary,
        'sla': '15 mins',
      },
      {
        'name': 'Fast-Track Cashier & Billing',
        'category': 'Billing',
        'doctor': 'Station C-04 Operator',
        'icon': Icons.payments_rounded,
        'color': AppColors.amberOrange,
        'sla': '5 mins',
      },
      {
        'name': 'Outpatient Pharmacy Dispensing',
        'category': 'Pharmacy',
        'doctor': 'Dr. Ethan Miller, PharmD',
        'icon': Icons.local_pharmacy_rounded,
        'color': AppColors.emeraldSuccess,
        'sla': '8 mins',
      },
      {
        'name': 'Diagnostic Lab & Blood Panel',
        'category': 'Diagnostics',
        'doctor': 'Lab Wing 2 Diagnostics',
        'icon': Icons.science_rounded,
        'color': AppColors.cyanGlow,
        'sla': '12 mins',
      },
      {
        'name': 'Dental & Maxillofacial Care',
        'category': 'Dental',
        'doctor': 'Dr. Olivia Bennett, DDS',
        'icon': Icons.health_and_safety_rounded,
        'color': const Color(0xFFEC4899),
        'sla': '20 mins',
      },
    ];

    final query = _serviceSearchCtrl.text.trim().toLowerCase();
    final filtered = servicesCatalog.where((s) {
      if (_selectedServiceFilter != 'All' && s['category'] != _selectedServiceFilter) {
        return false;
      }
      if (query.isEmpty) return true;
      return (s['name'] as String).toLowerCase().contains(query) ||
          (s['category'] as String).toLowerCase().contains(query) ||
          (s['doctor'] as String).toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Facility Header Tag
        Row(
          children: [
            const Icon(Icons.location_on_rounded, color: AppColors.cyanGlow, size: 15),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'LOCATION: ${state.selectedLocation ?? "HQ Main Medical Center"}',
                style: const TextStyle(
                  color: AppColors.cyanGlow,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const GlassPillBadge(
          label: 'STEP 2 OF 4: CHOOSE YOUR SERVICE',
          variant: GlassPillVariant.upcoming,
        ),
        const SizedBox(height: 10),
        const Text(
          'Choose the required clinical service:',
          style: TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          'Select your department to match with available specialists and optimal wait times.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 18),

        // Reference Card 4: Choose Your Service Concierge Card (Web, Mobile, Desktop)
        const ConciergeServiceGlassCard(
          title: 'Choose Your Service',
          subtitle: 'Select a department to book an appointment',
        ),
        const SizedBox(height: 18),

        // Department Search Bar
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          borderRadius: AppRadius.md,
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.cyanGlow, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _serviceSearchCtrl,
                  style: const TextStyle(color: AppColors.textMain, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search service, doctor, or department...',
                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    border: InputBorder.none,
                    suffixIcon: _serviceSearchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 16, color: AppColors.textMuted),
                            onPressed: () {
                              setState(() {
                                _serviceSearchCtrl.clear();
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Consultation', 'Specialist', 'Billing', 'Pharmacy', 'Diagnostics'].map((cat) {
              final isSelected = _selectedServiceFilter == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => setState(() => _selectedServiceFilter = cat),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.brandPrimary.withValues(alpha: 0.25)
                          : AppColors.glassSurfaceDark,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: isSelected ? AppColors.cyanGlow : AppColors.glassBorderLight,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? AppColors.cyanGlow : AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        // 2-Column Responsive Service Cards Grid
        LayoutBuilder(
          builder: (ctx, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 1 : 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: isMobile ? 2.6 : 2.2,
              ),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final srv = filtered[i];
                final color = srv['color'] as Color;

                return GlassCard(
                  onTap: () => notifier.selectService(srv['name'] as String),
                  padding: const EdgeInsets.all(16),
                  borderRadius: AppRadius.card,
                  child: Row(
                    children: [
                      GlassSquircleIcon(
                        icon: srv['icon'] as IconData,
                        backgroundColor: color.withValues(alpha: 0.16),
                        iconColor: color,
                        size: 46,
                        iconSize: 22,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              srv['name'] as String,
                              style: const TextStyle(
                                color: AppColors.textMain,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              srv['doctor'] as String,
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, color: AppColors.cyanGlow, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  '~${srv['sla']} avg wait',
                                  style: const TextStyle(color: AppColors.cyanGlow, fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.cyanGlow, size: 14),
                    ],
                  ),
                );
              },
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
        const GlassPillBadge(
          label: 'STEP 3 OF 4: CHOOSE DATE & TIME',
          variant: GlassPillVariant.upcoming,
        ),
        const SizedBox(height: 10),
        const Text(
          'Select an available appointment slot:',
          style: TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          'Selected Service: ${state.selectedService ?? "General Consultation"}',
          style: const TextStyle(color: AppColors.cyanGlow, fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 22),

        // Date Display Tile
        GlassCard(
          padding: const EdgeInsets.all(18),
          child: const Row(
            children: [
              GlassSquircleIcon(
                icon: Icons.calendar_today_rounded,
                backgroundColor: AppColors.darkBlueIconBg,
                iconColor: AppColors.brandPrimary,
                size: 40,
                iconSize: 20,
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saturday, August 1, 2026',
                      style: TextStyle(color: AppColors.textMain, fontSize: 15, fontWeight: FontWeight.w800),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Morning and afternoon sessions open for booking',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              GlassPillBadge(
                label: 'Available',
                variant: GlassPillVariant.nowServing,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'AVAILABLE TIME SLOTS',
          style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
        const SizedBox(height: 14),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: slots.map((slot) {
            return InkWell(
              onTap: () => notifier.selectDateTime('2026-08-01', slot),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGlassHighlight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.5), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandPrimary.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_rounded, color: AppColors.cyanGlow, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      slot,
                      style: const TextStyle(
                        color: AppColors.cyanGlow,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                      ),
                    ),
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
        const GlassPillBadge(
          label: 'STEP 4 OF 4: CUSTOMER INFORMATION',
          variant: GlassPillVariant.upcoming,
        ),
        const SizedBox(height: 10),
        const Text(
          'Please enter your contact details to generate your pass:',
          style: TextStyle(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          'Your digital pass and QR code will be generated instantly and synced with kiosk check-in.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 24),

        GlassCard(
          padding: const EdgeInsets.all(26),
          borderRadius: AppRadius.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DqmsTextField(label: 'Full Name', controller: _nameCtrl),
              const SizedBox(height: 16),
              DqmsTextField(label: 'Email Address', controller: _emailCtrl),
              const SizedBox(height: 16),
              DqmsTextField(label: 'Mobile Number', controller: _mobileCtrl),
              const SizedBox(height: 28),
              DqmsButton(
                label: 'CONFIRM & GENERATE QR PASS',
                icon: Icons.qr_code_2_rounded,
                variant: DqmsButtonVariant.gradientPill,
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
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          borderRadius: AppRadius.hero,
          borderColor: AppColors.emeraldSuccess.withValues(alpha: 0.4),
          borderWidth: 1.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.emeraldSuccess, size: 58),
              const SizedBox(height: 12),
              const Text(
                'APPOINTMENT CONFIRMED!',
                style: TextStyle(
                  color: AppColors.emeraldSuccess,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your fast-track digital priority reservation is confirmed.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Reference Card 1: Your Next Appointment Glass Hero Card (Web, Mobile, Desktop)
              NextAppointmentGlassCard(
                ticketNumber: state.bookingReference.isNotEmpty ? state.bookingReference : 'A012',
                serviceName: state.selectedService ?? 'Consultation - General Physician',
                time: state.selectedTimeSlot ?? '10:20 AM',
                dateText: (state.selectedDate != null && state.selectedDate!.length >= 6)
                    ? state.selectedDate!.substring(0, 6).toUpperCase()
                    : 'SEP 16',
                onViewDetails: () => context.go('/mobile'),
              ),
              const SizedBox(height: 20),

              // Booking Reference Card
              GlassCard(
                padding: const EdgeInsets.all(20),
                borderRadius: AppRadius.card,
                child: Column(
                  children: [
                    const Text(
                      'BOOKING REFERENCE',
                      style: TextStyle(
                        color: AppColors.textSubtle,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.bookingReference,
                      style: AppTypography.tokenHero.copyWith(
                        fontSize: 34,
                        color: AppColors.cyanGlow,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const Divider(color: AppColors.glassBorderLight, height: 20),
                    _buildPassDetailRow('Customer:', state.fullName),
                    const SizedBox(height: 8),
                    _buildPassDetailRow('Facility:', state.selectedLocation ?? 'HQ Main Medical Center'),
                    const SizedBox(height: 8),
                    _buildPassDetailRow('Service:', state.selectedService ?? 'Consultation'),
                    const SizedBox(height: 8),
                    _buildPassDetailRow('Date & Time:', '${state.selectedDate} at ${state.selectedTimeSlot}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // QR Pass Code Surface
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.qr_code_2_rounded, color: Colors.black, size: 110),
              ),
              const SizedBox(height: 12),
              const Text(
                'Present this QR Pass at the Kiosk upon arrival for priority check-in.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              DqmsButton(
                label: 'BOOK ANOTHER APPOINTMENT',
                icon: Icons.add_task_rounded,
                variant: DqmsButtonVariant.gradientPill,
                isFullWidth: true,
                onPressed: () => notifier.reset(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassDetailRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            val,
            style: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w800),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
