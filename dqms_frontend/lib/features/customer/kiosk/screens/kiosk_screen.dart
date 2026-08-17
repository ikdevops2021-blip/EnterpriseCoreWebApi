import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/theme/app_breakpoints.dart';
import 'package:dqms_frontend/core/widgets/dqms_button.dart';
import 'package:dqms_frontend/core/widgets/dqms_text_field.dart';
import 'package:dqms_frontend/features/admin/providers/admin_mock_providers.dart';
import 'package:dqms_frontend/features/customer/providers/customer_experience_provider.dart';

/// ============================================================================
/// SELF-SERVICE TOUCH KIOSK SCREEN (KioskScreen)
/// Touch-first 5-step wizard with live service search, category selection & ticket generation
/// ============================================================================
class KioskScreen extends ConsumerStatefulWidget {
  const KioskScreen({super.key});

  @override
  ConsumerState<KioskScreen> createState() => _KioskScreenState();
}

class _KioskScreenState extends ConsumerState<KioskScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _mobileCtrl = TextEditingController();
  String _selectedZoneFilter = 'All';

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kioskState = ref.watch(kioskStateProvider);
    final notifier = ref.read(kioskStateProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            // Kiosk Brand Header
            _buildKioskHeader(kioskState, notifier),

            // Step Progress Indicator Bar (if past welcome)
            if (kioskState.activeStep > 0 && kioskState.activeStep < 4)
              _buildStepProgressBar(kioskState, notifier),

            // Kiosk Wizard Body
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildWizardStep(context, kioskState, notifier),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKioskHeader(KioskState state, KioskNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.bgHeader,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.touch_app_rounded, color: AppColors.brandPrimary, size: 26),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DQMS SELF-SERVICE KIOSK',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                'Touch-first Service Selection & Queue Ticket Issuance',
                style: TextStyle(color: AppColors.textSubtle, fontSize: 11),
              ),
            ],
          ),
          const Spacer(),
          if (state.activeStep > 0)
            TextButton.icon(
              icon: const Icon(Icons.home_outlined, size: 18),
              label: const Text('Start Over / Reset'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () {
                _searchCtrl.clear();
                _nameCtrl.clear();
                _mobileCtrl.clear();
                notifier.reset();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStepProgressBar(KioskState state, KioskNotifier notifier) {
    final steps = [
      {'num': 1, 'title': 'Select Service'},
      {'num': 2, 'title': 'Priority Category'},
      {'num': 3, 'title': 'Confirm & Details'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: steps.map((s) {
          final stepNum = s['num'] as int;
          final isCurrent = state.activeStep == stepNum;
          final isDone = state.activeStep > stepNum;

          return InkWell(
            onTap: isDone ? () => notifier.goToStep(stepNum) : null,
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.brandPrimary
                        : (isDone ? AppColors.statusActive : AppColors.bgCanvas),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent
                          ? AppColors.brandPrimary
                          : (isDone ? AppColors.statusActive : AppColors.borderSubtle),
                    ),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                        : Text(
                            '$stepNum',
                            style: TextStyle(
                              color: isCurrent ? Colors.white : AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  s['title'] as String,
                  style: TextStyle(
                    color: isCurrent ? AppColors.textMain : (isDone ? AppColors.textMain : AppColors.textMuted),
                    fontSize: 12,
                    fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
                if (stepNum < steps.length)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Container(
                      width: 32,
                      height: 2,
                      color: isDone ? AppColors.statusActive : AppColors.borderSubtle,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWizardStep(BuildContext context, KioskState state, KioskNotifier notifier) {
    switch (state.activeStep) {
      case 0:
        return _buildStep0Welcome(notifier);
      case 1:
        return _buildStep1ServiceSelection(context, state, notifier);
      case 2:
        return _buildStep2CategorySelection(context, state, notifier);
      case 3:
        return _buildStep3Confirmation(context, state, notifier);
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
              const SizedBox(height: 32),
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
                'WELCOME TO DQMS ENTERPRISE',
                style: TextStyle(color: AppColors.textMain, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Touch to search and select your service, then receive your queue ticket.',
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
                  onPressed: () {
                    _searchCtrl.clear();
                    notifier.startCheckIn();
                  },
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  /// Step 1: Search & Service Selection
  Widget _buildStep1ServiceSelection(BuildContext context, KioskState state, KioskNotifier notifier) {
    final isMobile = AppBreakpoints.isMobile(context);
    final adminState = ref.watch(adminWorkspaceStateProvider);

    // Get live processes from workspace provider or fallback catalog
    final allProcesses = adminState.processes.isNotEmpty
        ? adminState.processes
        : [
            const ProcessModel(processId: 101, areaId: 1, areaName: 'Main Service Hall A', processCode: 'PROC-101', processName: 'Patient Registration & Check-in', targetSlaMins: 10, allowSubTokens: false, priorityLevel: 'Standard', isActive: true),
            const ProcessModel(processId: 102, areaId: 1, areaName: 'Main Service Hall A', processCode: 'PROC-102', processName: 'General Clinical Triage', targetSlaMins: 15, allowSubTokens: true, priorityLevel: 'Standard', isActive: true),
            const ProcessModel(processId: 103, areaId: 2, areaName: 'Priority Wing B', processCode: 'PROC-201', processName: 'Priority Medical Screening', targetSlaMins: 8, allowSubTokens: false, priorityLevel: 'High', isActive: true),
            const ProcessModel(processId: 104, areaId: 3, areaName: 'Express Desk C', processCode: 'PROC-301', processName: 'Fast-Track Billing & Cashier', targetSlaMins: 5, allowSubTokens: false, priorityLevel: 'Standard', isActive: true),
            const ProcessModel(processId: 105, areaId: 5, areaName: 'Pharmacy Outpatient E', processCode: 'PROC-501', processName: 'Prescription Dispensing & Advisory', targetSlaMins: 12, allowSubTokens: true, priorityLevel: 'Standard', isActive: true),
          ];

    // Filter processes based on search query and zone filter
    final query = state.searchQuery.trim().toLowerCase();
    final filteredProcesses = allProcesses.where((p) {
      if (!p.isActive) return false;
      if (_selectedZoneFilter != 'All' && !p.areaName.toLowerCase().contains(_selectedZoneFilter.toLowerCase())) {
        return false;
      }
      if (query.isEmpty) return true;
      return p.processName.toLowerCase().contains(query) ||
          p.processCode.toLowerCase().contains(query) ||
          p.areaName.toLowerCase().contains(query);
    }).toList();

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Back Button
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.brandPrimary),
                tooltip: 'Back to Welcome',
                onPressed: () => notifier.goToStep(0),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STEP 1: SEARCH & SELECT SERVICE',
                    style: TextStyle(color: AppColors.brandPrimary, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                  ),
                  Text(
                    'Which procedure or service do you require today?',
                    style: TextStyle(color: AppColors.textMain, fontSize: 19, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 🔍 Interactive Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.brandPrimary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: AppColors.textMain, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Search by service name, code, department (e.g. Registration, Triage, Cashier, Rx, PROC-101)...',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      border: InputBorder.none,
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textMuted),
                              onPressed: () {
                                _searchCtrl.clear();
                                notifier.setSearchQuery('');
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) => notifier.setSearchQuery(val),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Quick Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'All Services (${allProcesses.length})'),
                const SizedBox(width: 8),
                _buildFilterChip('Main Hall', 'Main Hall A'),
                const SizedBox(width: 8),
                _buildFilterChip('Priority', 'Priority Wing B'),
                const SizedBox(width: 8),
                _buildFilterChip('Cashier', 'Billing & Cashier'),
                const SizedBox(width: 8),
                _buildFilterChip('Pharmacy', 'Pharmacy Outpatient'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Services Grid
          Expanded(
            child: filteredProcesses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded, color: AppColors.textMuted, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'No services found matching "${state.searchQuery}"',
                          style: const TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Try searching with a different keyword or reset the search filter.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Clear Search Filter'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandPrimary),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _selectedZoneFilter = 'All');
                            notifier.setSearchQuery('');
                          },
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 1 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isMobile ? 2.5 : 2.4,
                    ),
                    itemCount: filteredProcesses.length,
                    itemBuilder: (ctx, i) {
                      final proc = filteredProcesses[i];
                      return _buildServiceCard(proc, notifier);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedZoneFilter == filterKey;
    return InkWell(
      onTap: () => setState(() => _selectedZoneFilter = filterKey),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.2) : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.brandPrimary : AppColors.borderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.brandPrimary : AppColors.textMuted,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(ProcessModel proc, KioskNotifier notifier) {
    IconData icon = Icons.medical_services_outlined;
    if (proc.processName.toLowerCase().contains('registration') || proc.processName.toLowerCase().contains('check-in')) {
      icon = Icons.assignment_ind_outlined;
    } else if (proc.processName.toLowerCase().contains('triage') || proc.processName.toLowerCase().contains('screening')) {
      icon = Icons.health_and_safety_outlined;
    } else if (proc.processName.toLowerCase().contains('billing') || proc.processName.toLowerCase().contains('cashier')) {
      icon = Icons.payments_outlined;
    } else if (proc.processName.toLowerCase().contains('pharmacy') || proc.processName.toLowerCase().contains('prescription')) {
      icon = Icons.local_pharmacy_outlined;
    } else if (proc.processName.toLowerCase().contains('vip') || proc.processName.toLowerCase().contains('consultation')) {
      icon = Icons.star_outline_rounded;
    }

    return InkWell(
      onTap: () {
        notifier.selectService(
          proc.processName,
          processId: proc.processId,
          processCode: proc.processCode,
          slaMins: proc.targetSlaMins,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.brandPrimary, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.brandAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              proc.processCode,
                              style: const TextStyle(color: AppColors.brandAccent, fontSize: 10, fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              proc.areaName,
                              style: const TextStyle(color: AppColors.textSubtle, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        proc.processName,
                        style: const TextStyle(color: AppColors.textMain, fontSize: 15, fontWeight: FontWeight.w800),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, color: AppColors.brandPrimary, size: 13),
                      const SizedBox(width: 4),
                      Text('~${proc.targetSlaMins} mins SLA', style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      if (proc.tokenLimitDaily > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.statusWarning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            'Limit: ${proc.tokenLimitDaily}/d',
                            style: const TextStyle(color: AppColors.statusWarning, fontSize: 9, fontWeight: FontWeight.w700),
                          ),
                        )
                      else
                        const Text(
                          'Unlimited',
                          style: TextStyle(color: AppColors.textSubtle, fontSize: 10),
                        ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.brandPrimary, size: 12),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Step 2: Category Selection
  Widget _buildStep2CategorySelection(BuildContext context, KioskState state, KioskNotifier notifier) {
    final isMobile = AppBreakpoints.isMobile(context);
    final categories = [
      {'title': 'Standard Customer', 'subtitle': 'Regular queue line registration', 'icon': Icons.person_outline_rounded, 'badge': 'Standard'},
      {'title': 'Senior Citizen (65+)', 'subtitle': 'Priority assisted queue line', 'icon': Icons.elderly_rounded, 'badge': 'Priority'},
      {'title': 'Accessibility / Assist', 'subtitle': 'Wheelchair & disability support', 'icon': Icons.accessible_rounded, 'badge': 'Priority'},
      {'title': 'VIP / Executive Pass', 'subtitle': 'Express private consultation lounge', 'icon': Icons.star_rounded, 'badge': 'VIP Tier'},
    ];

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.brandPrimary),
                tooltip: 'Back to Service Selection',
                onPressed: () => notifier.goToStep(1),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('STEP 2: SELECT CUSTOMER CATEGORY', style: TextStyle(color: AppColors.brandPrimary, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  Text(
                    'Selected Service: ${state.selectedService ?? "General Registration"}',
                    style: const TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 1 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 2.5 : 2.2,
              ),
              itemCount: categories.length,
              itemBuilder: (ctx, i) {
                final item = categories[i];
                return InkWell(
                  onTap: () => notifier.selectCategory(item['title'] as String),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.brandAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(item['icon'] as IconData, color: AppColors.brandAccent, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item['title'] as String, style: const TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(item['subtitle'] as String, style: const TextStyle(color: AppColors.textMuted, fontSize: 12), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.brandPrimary, size: 14),
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

  /// Step 3: Confirmation & Details
  Widget _buildStep3Confirmation(BuildContext context, KioskState state, KioskNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Center(
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.brandPrimary),
                    tooltip: 'Back to Category',
                    onPressed: () => notifier.goToStep(2),
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('STEP 3: CONFIRM TICKET DETAILS', style: TextStyle(color: AppColors.brandPrimary, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                      Text('Review Information', style: TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Summary Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Selected Service:', state.selectedService ?? 'General Registration'),
                    if (state.selectedProcessCode != null) ...[
                      const Divider(color: AppColors.borderSubtle, height: 16),
                      _buildSummaryRow('Service Code:', state.selectedProcessCode!),
                    ],
                    const Divider(color: AppColors.borderSubtle, height: 16),
                    _buildSummaryRow('Customer Category:', state.selectedCategory ?? 'Standard Customer'),
                    const Divider(color: AppColors.borderSubtle, height: 16),
                    _buildSummaryRow('Estimated Wait Time:', '~${state.estimatedWaitMins} Minutes'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Optional Customer Contact Inputs
              const Text(
                'OPTIONAL: NOTIFICATIONS (SMS & WHATSAPP)',
                style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              DqmsTextField(
                label: 'Customer / Patient Name (Optional)',
                hintText: 'e.g. John Smith',
                controller: _nameCtrl,
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 18),
                onChanged: (val) => notifier.setCustomerInfo(name: val),
              ),
              const SizedBox(height: 12),
              DqmsTextField(
                label: 'Mobile Phone Number (For WhatsApp / SMS Alerts)',
                hintText: 'e.g. +1 555 0199',
                controller: _mobileCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 18),
                onChanged: (val) => notifier.setCustomerInfo(mobile: val),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit_note_rounded, size: 18),
                    label: const Text('Change Service'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.brandPrimary,
                      side: const BorderSide(color: AppColors.brandPrimary),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onPressed: () => notifier.goToStep(1),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DqmsButton(
                      label: 'GENERATE TICKET NOW',
                      icon: Icons.confirmation_number_rounded,
                      onPressed: () => notifier.confirmAndGenerateTicket(),
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

  /// Step 4: Ticket Generated Screen
  Widget _buildStep4TicketGenerated(KioskState state, KioskNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: Container(
          width: 460,
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
              const SizedBox(height: 10),
              const Text('TICKET GENERATED SUCCESSFULLY!', style: TextStyle(color: AppColors.statusActive, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
              const SizedBox(height: 16),

              // Giant Token Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    const Text('YOUR QUEUE TICKET NUMBER', style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                      state.generatedTokenNumber,
                      style: const TextStyle(color: AppColors.brandPrimary, fontSize: 52, fontWeight: FontWeight.w900, fontFamily: 'monospace', letterSpacing: 2.0),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.selectedService ?? 'General Registration',
                      style: const TextStyle(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // QR Code Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.qr_code_2_rounded, color: Colors.black, size: 90),
              ),
              const SizedBox(height: 8),
              const Text('Scan QR code with your mobile phone to track live queue status remotely.', style: TextStyle(color: AppColors.textMuted, fontSize: 11), textAlign: TextAlign.center),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.print_rounded, size: 18),
                      label: const Text('Print Ticket'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textMain,
                        side: const BorderSide(color: AppColors.borderSubtle),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Printing ticket ${state.generatedTokenNumber}...'),
                            backgroundColor: AppColors.statusActive,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DqmsButton(
                      label: 'DONE / NEXT USER',
                      icon: Icons.done_rounded,
                      onPressed: () {
                        _searchCtrl.clear();
                        _nameCtrl.clear();
                        _mobileCtrl.clear();
                        notifier.reset();
                      },
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
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.w800),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
