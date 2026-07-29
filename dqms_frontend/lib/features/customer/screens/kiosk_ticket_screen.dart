import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../admin/providers/admin_providers.dart';
import '../../staff/providers/staff_providers.dart';

/// ============================================================================
/// STAGE 3: SELF-SERVICE TICKET KIOSK SCREEN
/// Touchscreen ticket issuing kiosk for reception areas
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
  Widget build(BuildContext context) {
    final processState = ref.watch(processListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF070B0E),
      body: Column(
        children: [
          // Kiosk Header
          Container(
            height: 90,
            color: const Color(0xFF111822),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: const Row(
              children: [
                Icon(Icons.touch_app_rounded, color: Color(0xFF58A6FF), size: 36),
                SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SELF-SERVICE TICKET KIOSK', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    Text('Touch to select your service & print your queue ticket', style: TextStyle(color: Color(0xFF8B949E), fontSize: 13)),
                  ],
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
                  const Text('1. SELECT YOUR SERVICE DEPARTMENT', style: TextStyle(color: Color(0xFF58A6FF), fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: processState.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Error loading services: $err')),
                      data: (processes) => processes.isEmpty
                          ? const Center(child: Text('No service departments available.'))
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
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF2F81F7).withValues(alpha: 0.2) : const Color(0xFF111822),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFF2F81F7) : const Color(0xFF1E2836),
                                        width: isSelected ? 3 : 1,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF8957E5).withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(child: Text(proc.prefix, style: const TextStyle(color: Color(0xFF8957E5), fontWeight: FontWeight.w900, fontSize: 22))),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(proc.processName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                                              const SizedBox(height: 4),
                                              Text('Avg Wait: ~${proc.targetTATMinutes} mins', style: const TextStyle(color: Color(0xFF8B949E), fontSize: 12)),
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
                  const Text('2. SELECT CATEGORY (OPTIONAL)', style: TextStyle(color: Color(0xFF58A6FF), fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildPriorityCategoryChip('Standard', 19001),
                      const SizedBox(width: 12),
                      _buildPriorityCategoryChip('Senior Citizen', 19002),
                      const SizedBox(width: 12),
                      _buildPriorityCategoryChip('Person with Disability', 19003),
                      const SizedBox(width: 12),
                      _buildPriorityCategoryChip('VIP / Emergency', 19005),
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
                      label: Text(_isIssuing ? 'PRINTING TICKET...' : 'PRINT QUEUE TICKET', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedProcessId != null ? const Color(0xFF238636) : const Color(0xFF1E2836),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Ticket Printed! Please collect your ticket.'), backgroundColor: Color(0xFF238636)),
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
    );
  }

  Widget _buildPriorityCategoryChip(String label, int value) {
    final isSelected = _selectedPriorityTier == value;

    return ChoiceChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF8B949E), fontWeight: FontWeight.w700)),
      selected: isSelected,
      selectedColor: const Color(0xFF2F81F7),
      backgroundColor: const Color(0xFF111822),
      side: BorderSide(color: isSelected ? const Color(0xFF2F81F7) : const Color(0xFF1E2836)),
      onSelected: (_) => setState(() => _selectedPriorityTier = value),
    );
  }
}
