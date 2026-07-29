import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/enums/dqms_enums.dart';
import '../../../core/models/staff_models.dart';
import '../providers/staff_providers.dart';

/// ============================================================================
/// DQMS ENTERPRISE DESIGN TOKENS (Per UI_UX_DESIGN_SPEC.md)
/// Aesthetic: High-Speed Counter Command Station | Hotkeys: Space, F1-F7
/// ============================================================================
class OperatorTheme {
  static const Color bgCanvas = Color(0xFF090D11);
  static const Color bgSurface = Color(0xFF12171F);
  static const Color bgCard = Color(0xFF1A222D);

  static const Color borderSubtle = Color(0xFF222B36);
  static const Color borderHighlight = Color(0xFF2F81F7);

  static const Color actionCall = Color(0xFF238636);
  static const Color actionRecall = Color(0xFFD29922);
  static const Color actionServe = Color(0xFF2F81F7);
  static const Color actionHold = Color(0xFF8957E5);
  static const Color actionCancel = Color(0xFFDA3633);

  static const Color textMain = Color(0xFFF0F6FC);
  static const Color textMuted = Color(0xFF8B949E);
  static const Color textSubtle = Color(0xFF6E7681);
}

/// ============================================================================
/// STAGE 2: COUNTER OPERATOR STATION SCREEN
/// ============================================================================
class CounterOperatorScreen extends ConsumerStatefulWidget {
  const CounterOperatorScreen({super.key});

  @override
  ConsumerState<CounterOperatorScreen> createState() => _CounterOperatorScreenState();
}

class _CounterOperatorScreenState extends ConsumerState<CounterOperatorScreen> {
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _keyboardFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      final queueNotifier = ref.read(tokenQueueProvider.notifier);
      final queueList = ref.read(tokenQueueProvider).asData?.value ?? [];
      final activeToken = queueList.where((t) => t.tokenStatus == e_TokenStatus.calling.value || t.tokenStatus == e_TokenStatus.active.value || t.tokenStatus == e_TokenStatus.hold.value).firstOrNull;

      if (event.logicalKey == LogicalKeyboardKey.space || event.logicalKey == LogicalKeyboardKey.f1) {
        queueNotifier.callNextToken();
      } else if (event.logicalKey == LogicalKeyboardKey.f2 && activeToken != null) {
        queueNotifier.updateTokenStatus(activeToken.id, e_TokenStatus.calling);
      } else if (event.logicalKey == LogicalKeyboardKey.f3 && activeToken != null) {
        queueNotifier.updateTokenStatus(activeToken.id, e_TokenStatus.active);
      } else if (event.logicalKey == LogicalKeyboardKey.f4 && activeToken != null) {
        queueNotifier.updateTokenStatus(activeToken.id, e_TokenStatus.hold, reason: 'Put on hold by operator');
      } else if (event.logicalKey == LogicalKeyboardKey.f5 && activeToken != null) {
        queueNotifier.updateTokenStatus(activeToken.id, e_TokenStatus.completed).then((_) {
          queueNotifier.callNextToken();
        });
      } else if (event.logicalKey == LogicalKeyboardKey.f7 && activeToken != null) {
        queueNotifier.updateTokenStatus(activeToken.id, e_TokenStatus.canceled, reason: 'No show / Canceled');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokenQueueState = ref.watch(tokenQueueProvider);

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: _handleKeyPress,
      child: Scaffold(
        backgroundColor: OperatorTheme.bgCanvas,
        body: Column(
          children: [
            _buildOperatorHeader(),
            Expanded(
              child: tokenQueueState.when(
                loading: () => const Center(child: CircularProgressIndicator(color: OperatorTheme.borderHighlight)),
                error: (err, _) => Center(child: Text('Queue Error: $err', style: const TextStyle(color: OperatorTheme.actionCancel))),
                data: (tokens) {
                  final activeToken = tokens.where((t) => t.tokenStatus == e_TokenStatus.calling.value || t.tokenStatus == e_TokenStatus.active.value || t.tokenStatus == e_TokenStatus.hold.value).firstOrNull;
                  final waitingTokens = tokens.where((t) => t.tokenStatus == e_TokenStatus.queued.value || t.tokenStatus == e_TokenStatus.waiting.value).toList();

                  return Row(
                    children: [
                      // Active Token Work Area (Left 65%)
                      Expanded(
                        flex: 65,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildActiveTokenCard(activeToken),
                              const SizedBox(height: 24),
                              _buildHotkeyActionToolbar(activeToken),
                            ],
                          ),
                        ),
                      ),
                      // Waiting Queue Side Panel (Right 35%)
                      Expanded(
                        flex: 35,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: OperatorTheme.bgSurface,
                            border: Border(left: BorderSide(color: OperatorTheme.borderSubtle, width: 1)),
                          ),
                          child: _buildWaitingQueueList(waitingTokens),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Operator Header with Counter Info & Quick Token Issue
  Widget _buildOperatorHeader() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: OperatorTheme.bgSurface,
        border: Border(bottom: BorderSide(color: OperatorTheme.borderSubtle, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: OperatorTheme.actionServe.withValues(alpha: 0.15),
              border: Border.all(color: OperatorTheme.actionServe.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('COUNTER 01 • WINDOW A', style: TextStyle(color: OperatorTheme.actionServe, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.0)),
          ),
          const SizedBox(width: 16),
          const Text('Operator: Staff User 101', style: TextStyle(color: OperatorTheme.textMain, fontWeight: FontWeight.w600, fontSize: 14)),
          const Spacer(),
          ElevatedButton.icon(
            icon: const Icon(Icons.confirmation_number_outlined, size: 16),
            label: const Text('Issue New Token'),
            style: ElevatedButton.styleFrom(
              backgroundColor: OperatorTheme.bgCard,
              foregroundColor: OperatorTheme.textMain,
              side: const BorderSide(color: OperatorTheme.borderSubtle),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () => _showIssueTokenDialog(),
          ),
        ],
      ),
    );
  }

  /// Prominent Current Active Token Display
  Widget _buildActiveTokenCard(TokenTransactionDto? token) {
    if (token == null) {
      return Container(
        height: 280,
        width: double.infinity,
        decoration: BoxDecoration(
          color: OperatorTheme.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: OperatorTheme.borderSubtle),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_seat_outlined, color: OperatorTheme.textSubtle, size: 64),
              SizedBox(height: 16),
              Text('COUNTER IDLE', style: TextStyle(color: OperatorTheme.textMuted, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
              SizedBox(height: 8),
              Text('Press [ SPACE ] or [ F1 ] to Call Next Waiting Customer', style: TextStyle(color: OperatorTheme.borderHighlight, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    final isHolding = token.tokenStatus == e_TokenStatus.hold.value;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: OperatorTheme.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isHolding ? OperatorTheme.actionHold : OperatorTheme.borderHighlight, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('NOW SERVING', style: TextStyle(color: isHolding ? OperatorTheme.actionHold : OperatorTheme.borderHighlight, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
              const Spacer(),
              _buildPriorityBadge(token.priorityTier),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                token.tokenNumber,
                style: const TextStyle(color: OperatorTheme.textMain, fontSize: 72, fontWeight: FontWeight.w900, letterSpacing: -2),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(token.customerName ?? 'Walk-in Customer', style: const TextStyle(color: OperatorTheme.textMain, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(token.customerPhone ?? 'No Phone Provided', style: const TextStyle(color: OperatorTheme.textMuted, fontSize: 14)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Low-Friction Hotkey Action Toolbar
  Widget _buildHotkeyActionToolbar(TokenTransactionDto? activeToken) {
    final queueNotifier = ref.read(tokenQueueProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('OPERATOR HOTKEY CONTROLS', style: TextStyle(color: OperatorTheme.textSubtle, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionButton('SPACE / F1', 'Call Next', OperatorTheme.actionCall, Icons.campaign_rounded, () => queueNotifier.callNextToken(), isPrimary: true),
            _buildActionButton('F2', 'Recall', OperatorTheme.actionRecall, Icons.replay_rounded, activeToken != null ? () => queueNotifier.updateTokenStatus(activeToken.id, e_TokenStatus.calling) : null),
            _buildActionButton('F3', 'Serve Active', OperatorTheme.actionServe, Icons.play_arrow_rounded, activeToken != null ? () => queueNotifier.updateTokenStatus(activeToken.id, e_TokenStatus.active) : null),
            _buildActionButton('F4', 'Hold', OperatorTheme.actionHold, Icons.pause_rounded, activeToken != null ? () => queueNotifier.updateTokenStatus(activeToken.id, e_TokenStatus.hold, reason: 'Hold') : null),
            _buildActionButton('F5', 'Complete & Call Next', OperatorTheme.actionServe, Icons.check_circle_rounded, activeToken != null ? () {
              queueNotifier.updateTokenStatus(activeToken.id, e_TokenStatus.completed).then((_) => queueNotifier.callNextToken());
            } : null, isPrimary: true),
            _buildActionButton('F7', 'Cancel', OperatorTheme.actionCancel, Icons.cancel_outlined, activeToken != null ? () => queueNotifier.updateTokenStatus(activeToken.id, e_TokenStatus.canceled, reason: 'No Show') : null),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String hotkey, String label, Color color, IconData icon, VoidCallback? onPressed, {bool isPrimary = false}) {
    return Opacity(
      opacity: onPressed != null ? 1.0 : 0.4,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? color : OperatorTheme.bgSurface,
          foregroundColor: isPrimary ? Colors.white : color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isPrimary ? Colors.white.withValues(alpha: 0.2) : color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(hotkey, style: TextStyle(color: isPrimary ? Colors.white : color, fontWeight: FontWeight.w900, fontSize: 11)),
            ),
            const SizedBox(width: 10),
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  /// Waiting Queue Side Panel List
  Widget _buildWaitingQueueList(List<TokenTransactionDto> waitingTokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Text('WAITING QUEUE', style: TextStyle(color: OperatorTheme.textMain, fontWeight: FontWeight.w700, fontSize: 14)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: OperatorTheme.borderHighlight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${waitingTokens.length} Waiting', style: const TextStyle(color: OperatorTheme.borderHighlight, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        const Divider(color: OperatorTheme.borderSubtle, height: 1),
        Expanded(
          child: waitingTokens.isEmpty
              ? const Center(child: Text('Queue Empty', style: TextStyle(color: OperatorTheme.textSubtle, fontSize: 13)))
              : ListView.separated(
                  itemCount: waitingTokens.length,
                  separatorBuilder: (_, __) => const Divider(color: OperatorTheme.borderSubtle, height: 1),
                  itemBuilder: (ctx, i) {
                    final item = waitingTokens[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      title: Row(
                        children: [
                          Text(item.tokenNumber, style: const TextStyle(color: OperatorTheme.textMain, fontWeight: FontWeight.w800, fontSize: 16)),
                          const SizedBox(width: 10),
                          _buildPriorityBadge(item.priorityTier),
                        ],
                      ),
                      subtitle: Text(item.customerName ?? 'Walk-in Ticket', style: const TextStyle(color: OperatorTheme.textMuted, fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: OperatorTheme.textSubtle, size: 14),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPriorityBadge(int priorityTier) {
    String label = 'Standard';
    Color col = OperatorTheme.textMuted;

    if (priorityTier == e_PriorityTier.vip.value) {
      label = 'VIP';
      col = OperatorTheme.actionHold;
    } else if (priorityTier == e_PriorityTier.emergency.value) {
      label = 'Emergency';
      col = OperatorTheme.actionCancel;
    } else if (priorityTier == e_PriorityTier.seniorCitizen.value) {
      label = 'Senior';
      col = OperatorTheme.actionServe;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: col.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: col.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: TextStyle(color: col, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  void _showIssueTokenDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    int selectedPriority = 19001;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OperatorTheme.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: OperatorTheme.borderSubtle)),
        title: const Text('Issue New Queue Token', style: TextStyle(color: OperatorTheme.textMain, fontWeight: FontWeight.w700, fontSize: 16)),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: OperatorTheme.textMain, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Customer Name', labelStyle: TextStyle(color: OperatorTheme.textMuted)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                style: const TextStyle(color: OperatorTheme.textMain, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Phone Number (WhatsApp)', labelStyle: TextStyle(color: OperatorTheme.textMuted)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: OperatorTheme.textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: OperatorTheme.actionServe, foregroundColor: Colors.white),
            onPressed: () {
              ref.read(tokenQueueProvider.notifier).issueToken(
                    priorityTier: selectedPriority,
                    name: nameCtrl.text,
                    phone: phoneCtrl.text,
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Issue Token'),
          ),
        ],
      ),
    );
  }
}
