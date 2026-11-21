import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/features/admin/providers/admin_providers.dart';
import 'package:dqms_frontend/features/staff/providers/staff_providers.dart';

/// ============================================================================
/// SELF-SERVICE TICKET KIOSK SCREEN
/// Touchscreen ticket issuing kiosk for reception areas
/// 1:1 Matched to Stitch Screen: "DQMS Self-Service Touch Kiosk"
/// ============================================================================
class KioskTicketScreen extends ConsumerStatefulWidget {
  const KioskTicketScreen({super.key});

  @override
  ConsumerState<KioskTicketScreen> createState() => _KioskTicketScreenState();
}

class _KioskTicketScreenState extends ConsumerState<KioskTicketScreen> {
  int? _selectedProcessId;
  int _selectedPriorityTier = 19001; // e_PriorityTier.Standard
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isIssuing = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final processState = ref.watch(processListProvider);

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            // Kiosk Header
            Container(
              height: 90,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                border: const Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 1.5)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.touch_app_rounded, color: AppColors.brandPrimary, size: 32),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SELF-SERVICE TICKET KIOSK',
                        style: TextStyle(
                          color: AppColors.textMain,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Touch to select your service department & print your clinical queue ticket',
                        style: TextStyle(color: AppColors.textSubtle, fontSize: 13),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.statusActive.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.statusActive.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.statusActive, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'KIOSK NODE READY',
                          style: TextStyle(color: AppColors.statusActive, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Kiosk Touchscreen Selection Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.brandPrimary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '1. SELECT YOUR SERVICE DEPARTMENT',
                          style: TextStyle(
                            color: AppColors.brandPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: processState.when(
                        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandPrimary)),
                        error: (err, _) => Center(child: Text('Error loading services: $err', style: const TextStyle(color: AppColors.statusError))),
                        data: (processes) => processes.isEmpty
                            ? const Center(child: Text('No service departments available.', style: TextStyle(color: AppColors.textMuted)))
                            : GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 2.2,
                                ),
                                itemCount: processes.length,
                                itemBuilder: (ctx, i) {
                                  final proc = processes[i];
                                  final isSelected = _selectedProcessId == proc.id;

                                  return InkWell(
                                    onTap: () => setState(() => _selectedProcessId = proc.id),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.18) : AppColors.bgSurface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected ? AppColors.brandPrimary : AppColors.borderSubtle,
                                          width: isSelected ? 2.5 : 1,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.brandPrimary.withValues(alpha: 0.25),
                                                  blurRadius: 16,
                                                  spreadRadius: 1,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      padding: const EdgeInsets.all(20),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 52,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: AppColors.brandPrimary.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.3)),
                                            ),
                                            child: Center(
                                              child: Text(
                                                proc.prefix,
                                                style: const TextStyle(
                                                  color: AppColors.brandPrimary,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 22,
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  proc.processName,
                                                  style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w800, fontSize: 16),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.timer_outlined, size: 13, color: AppColors.statusActive),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Avg Wait: ~${proc.targetTATMinutes} mins',
                                                      style: const TextStyle(color: AppColors.statusActive, fontSize: 12, fontWeight: FontWeight.w600),
                                                    ),
                                                  ],
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
                    ),
                    const SizedBox(height: 20),

                    // Priority Category Selection
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.brandAccent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '2. SELECT CATEGORY (OPTIONAL)',
                          style: TextStyle(
                            color: AppColors.brandAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildPriorityCategoryChip('Standard Patient', 19001, Icons.person_outline_rounded),
                        _buildPriorityCategoryChip('Senior Citizen', 19002, Icons.elderly_rounded),
                        _buildPriorityCategoryChip('Person with Disability', 19003, Icons.accessible_rounded),
                        _buildPriorityCategoryChip('VIP / Emergency Triage', 19005, Icons.emergency_rounded),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Issue Button
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton.icon(
                        icon: _isIssuing
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.print_rounded, size: 28),
                        label: Text(
                          _isIssuing ? 'PRINTING TICKET...' : 'PRINT QUEUE TICKET',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedProcessId != null ? AppColors.brandPrimary : AppColors.bgSurfaceHover,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: _selectedProcessId != null ? 8 : 0,
                          shadowColor: AppColors.brandPrimary.withValues(alpha: 0.5),
                        ),
                        onPressed: (_selectedProcessId == null || _isIssuing)
                            ? null
                            : () async {
                                setState(() => _isIssuing = true);
                                await ref.read(tokenQueueProvider.notifier).issueToken(
                                      priorityTier: _selectedPriorityTier,
                                      name: _nameController.text.isEmpty ? null : _nameController.text,
                                      phone: _phoneController.text.isEmpty ? null : _phoneController.text,
                                    );
                                setState(() {
                                  _isIssuing = false;
                                  _selectedProcessId = null;
                                });
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Ticket Printed! Please collect your clinical ticket.'),
                                      backgroundColor: AppColors.statusActive,
                                    ),
                                  );
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityCategoryChip(String label, int value, IconData icon) {
    final isSelected = _selectedPriorityTier == value;

    return ChoiceChip(
      avatar: Icon(icon, size: 18, color: isSelected ? Colors.white : AppColors.textSubtle),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSubtle,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.brandPrimary,
      backgroundColor: AppColors.bgSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide(
        color: isSelected ? AppColors.brandPrimary : AppColors.borderSubtle,
        width: isSelected ? 1.5 : 1,
      ),
      onSelected: (_) => setState(() => _selectedPriorityTier = value),
    );
  }
}
