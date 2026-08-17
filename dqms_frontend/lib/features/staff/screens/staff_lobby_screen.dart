import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/features/admin/providers/admin_mock_providers.dart';
import 'package:dqms_frontend/features/auth/providers/auth_provider.dart';
import 'package:dqms_frontend/features/staff/providers/staff_session_provider.dart';

/// ============================================================================
/// STAFF COUNTER LOBBY SCREEN
/// Step 1: Select permitted Process
/// Step 2: Select available Counter for that Process/Area
/// Step 3: Open Counter Station
/// ============================================================================
class StaffLobbyScreen extends ConsumerStatefulWidget {
  const StaffLobbyScreen({super.key});

  @override
  ConsumerState<StaffLobbyScreen> createState() => _StaffLobbyScreenState();
}

class _StaffLobbyScreenState extends ConsumerState<StaffLobbyScreen> {
  int _lobbyStep = 0; // 0 = Select Process, 1 = Select Counter

  @override
  void initState() {
    super.initState();
    // Initialize staff identity in session from auth state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authStateProvider).currentUser;
      if (user != null) {
        ref.read(staffSessionProvider.notifier).initStaff(user.userId, user.fullName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final session = ref.watch(staffSessionProvider);
    final adminState = ref.watch(adminWorkspaceStateProvider);
    final user = authState.currentUser;

    // Filter processes by staff permissions
    final permittedProcessIds = user?.assignedProcessIds ?? [];
    final allProcesses = adminState.processes.where((p) => p.isActive).toList();
    final permittedProcesses = permittedProcessIds.isEmpty
        ? allProcesses // empty = all allowed (SuperAdmin)
        : allProcesses.where((p) => permittedProcessIds.contains(p.processId)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF090D11),
      body: Column(
        children: [
          _buildLobbyHeader(user, session),
          Expanded(
            child: _lobbyStep == 0
                ? _buildSelectProcess(permittedProcesses, session)
                : _buildSelectCounter(session, adminState, user),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLobbyHeader(AuthUserModel? user, StaffSessionState session) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF12171F),
        border: Border(bottom: BorderSide(color: Color(0xFF222B36))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.credit_card_rounded, color: AppColors.brandPrimary, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'COUNTER STATION LOBBY',
                style: TextStyle(color: Color(0xFFF0F6FC), fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.2),
              ),
              Text(
                user != null ? '${user.fullName}  •  ${user.roleName}' : 'Staff Login',
                style: const TextStyle(color: Color(0xFF8B949E), fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          // Step indicator
          if (session.selectedProcessId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.4)),
              ),
              child: Text(
                '${session.selectedProcessCode} — ${session.selectedProcessName}',
                style: const TextStyle(color: AppColors.brandPrimary, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout_rounded, size: 16),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF8B949E),
              side: const BorderSide(color: Color(0xFF222B36)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onPressed: () {
              ref.read(staffSessionProvider.notifier).reset();
              ref.read(authStateProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STEP 0: SELECT PROCESS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSelectProcess(
    List<ProcessModel> processes,
    StaffSessionState session,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SELECT YOUR SERVICE PROCESS', style: TextStyle(color: Color(0xFF2F81F7), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  Text('Which process will you be serving today?', style: TextStyle(color: Color(0xFFF0F6FC), fontSize: 20, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          if (processes.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF12171F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF222B36)),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.lock_outline_rounded, color: Color(0xFF8B949E), size: 48),
                    SizedBox(height: 12),
                    Text('No processes assigned to your account.', style: TextStyle(color: Color(0xFFF0F6FC), fontSize: 16, fontWeight: FontWeight.w700)),
                    SizedBox(height: 6),
                    Text('Contact your administrator to assign process permissions.', style: TextStyle(color: Color(0xFF8B949E), fontSize: 13)),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.2,
              ),
              itemCount: processes.length,
              itemBuilder: (ctx, i) => _buildProcessCard(processes[i], session)
                  .animate()
                  .fadeIn(duration: 250.ms, delay: (30 * i).ms)
                  .slideY(begin: 0.05, end: 0, duration: 250.ms),
            ),
        ],
      ),
    );
  }

  Widget _buildProcessCard(ProcessModel proc, StaffSessionState session) {
    final isSelected = session.selectedProcessId == proc.processId;

    IconData icon = Icons.medical_services_outlined;
    if (proc.processName.toLowerCase().contains('registration')) icon = Icons.assignment_ind_outlined;
    if (proc.processName.toLowerCase().contains('triage') || proc.processName.toLowerCase().contains('screening')) icon = Icons.health_and_safety_outlined;
    if (proc.processName.toLowerCase().contains('billing') || proc.processName.toLowerCase().contains('cashier')) icon = Icons.payments_outlined;
    if (proc.processName.toLowerCase().contains('pharmacy') || proc.processName.toLowerCase().contains('prescription')) icon = Icons.local_pharmacy_outlined;

    return InkWell(
      onTap: () {
        ref.read(staffSessionProvider.notifier).selectProcess(proc.processId, proc.processName, proc.processCode);
        setState(() => _lobbyStep = 1);
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF162032) : const Color(0xFF12171F),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF2F81F7) : const Color(0xFF222B36),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2F81F7).withValues(alpha: 0.2)
                    : const Color(0xFF1A222D),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: isSelected ? const Color(0xFF2F81F7) : const Color(0xFF8B949E), size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F81F7).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(proc.processCode, style: const TextStyle(color: Color(0xFF2F81F7), fontSize: 10, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 8),
                      Text(proc.areaName, style: const TextStyle(color: Color(0xFF6E7681), fontSize: 11), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(proc.processName, style: const TextStyle(color: Color(0xFFF0F6FC), fontSize: 14, fontWeight: FontWeight.w800), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, color: Color(0xFF8B949E), size: 12),
                      const SizedBox(width: 4),
                      Text('~${proc.targetSlaMins} min SLA', style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11)),
                      const Spacer(),
                      Text(proc.priorityLevel, style: TextStyle(
                        color: proc.priorityLevel == 'High' ? const Color(0xFFDA3633) : const Color(0xFF6E7681),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.arrow_forward_ios_rounded,
              color: isSelected ? const Color(0xFF238636) : const Color(0xFF6E7681),
              size: isSelected ? 22 : 14,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STEP 1: SELECT COUNTER
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSelectCounter(
    StaffSessionState session,
    AdminWorkspaceState adminState,
    AuthUserModel? user,
  ) {
    final permittedCounterIds = user?.assignedCounterIds ?? [];
    final selectedProcess = adminState.processes
        .where((p) => p.processId == session.selectedProcessId)
        .firstOrNull;

    // Filter counters: same area as selected process + permitted to this staff
    final areaId = selectedProcess?.areaId;
    final allCounters = adminState.counters.where((c) => c.status != 'Maintenance').toList();
    final areaCounters = areaId != null
        ? allCounters.where((c) => c.areaId == areaId).toList()
        : allCounters;
    final permittedCounters = permittedCounterIds.isEmpty
        ? areaCounters
        : areaCounters.where((c) => permittedCounterIds.contains(c.counterId)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button row
          Row(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF8B949E)),
                label: const Text('← Back to Process', style: TextStyle(color: Color(0xFF8B949E), fontSize: 13)),
                onPressed: () => setState(() => _lobbyStep = 0),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: const Color(0xFF238636), borderRadius: BorderRadius.circular(18)),
                child: const Center(child: Text('2', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16))),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SELECT YOUR COUNTER', style: TextStyle(color: Color(0xFF238636), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  Text('Area: ${selectedProcess?.areaName ?? 'All Areas'}  •  ${permittedCounters.length} counters available',
                      style: const TextStyle(color: Color(0xFFF0F6FC), fontSize: 18, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Counter cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.8,
            ),
            itemCount: permittedCounters.length,
            itemBuilder: (ctx, i) => _buildCounterCard(permittedCounters[i], session)
                .animate()
                .fadeIn(duration: 250.ms, delay: (25 * i).ms)
                .scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1), duration: 250.ms),
          ),
          const SizedBox(height: 32),

          // OPEN STATION button
          if (session.selectedCounterId != null)
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_outline_rounded, size: 26),
                label: Text(
                  'OPEN STATION  —  ${session.selectedCounterNumber}  •  ${session.selectedProcessName}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF238636),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  ref.read(staffSessionProvider.notifier).openStation();
                  context.go('/staff/counter');
                },
              ),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .shimmer(duration: 2.seconds, color: Colors.white.withValues(alpha: 0.2)),
        ],
      ),
    );
  }

  Widget _buildCounterCard(CounterModel counter, StaffSessionState session) {
    final isSelected = session.selectedCounterId == counter.counterId;
    final isIdle = counter.status == 'Idle';

    Color statusColor = const Color(0xFF238636);
    if (counter.status == 'Idle') statusColor = const Color(0xFF8B949E);
    if (counter.status == 'Closed') statusColor = const Color(0xFFDA3633);

    return InkWell(
      onTap: () {
        ref.read(staffSessionProvider.notifier).selectCounter(
          counter.counterId,
          counter.counterName,
          counter.counterNumber,
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D1F14) : const Color(0xFF12171F),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF238636) : const Color(0xFF222B36),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  counter.counterNumber,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF238636) : const Color(0xFF2F81F7),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF238636), size: 18),
              ],
            ),
            Text(counter.counterName, style: const TextStyle(color: Color(0xFFF0F6FC), fontSize: 12, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
            Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(counter.status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700)),
                if (isIdle) ...[
                  const SizedBox(width: 6),
                  const Text('• Available', style: TextStyle(color: Color(0xFF6E7681), fontSize: 10)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
