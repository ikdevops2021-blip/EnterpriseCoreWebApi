import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../../../core/enums/dqms_enums.dart';
import '../../../core/models/staff_models.dart';
import '../../../core/services/dqms_audio_voice_service.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/staff_providers.dart';
import '../providers/staff_session_provider.dart';
import '../repositories/staff_repository.dart';
import '../models/staff_dto.dart';

/// ============================================================================
/// DQMS ENTERPRISE DESIGN TOKENS (Per UI_UX_DESIGN_SPEC.md)
/// Aesthetic: High-Speed Counter Command Station | Hotkeys: Space, F1-F7
/// ============================================================================
class OperatorTheme {
  static const Color bgCanvas = AppColors.bgCanvas;
  static const Color bgSurface = AppColors.bgSurface;
  static const Color bgCard = AppColors.bgCard;

  static const Color borderSubtle = AppColors.borderSubtle;
  static const Color borderHighlight = AppColors.brandPrimary;

  static const Color actionCall = AppColors.statusActive;
  static const Color actionRecall = AppColors.statusWarning;
  static const Color actionServe = AppColors.brandPrimary;
  static const Color actionHold = AppColors.brandSecondary;
  static const Color actionCancel = AppColors.statusError;

  static const Color textMain = AppColors.textMain;
  static const Color textMuted = AppColors.textMuted;
  static const Color textSubtle = AppColors.textSubtle;
}

/// ============================================================================
/// STAGE 2: COUNTER OPERATOR STATION SCREEN
/// ============================================================================
class CounterOperatorScreen extends ConsumerStatefulWidget {
  const CounterOperatorScreen({super.key});

  @override
  ConsumerState<CounterOperatorScreen> createState() =>
      _CounterOperatorScreenState();
}

/// Navigation views for the operator right sidebar panel
enum OperatorSidebarTab {
  waitingQueue,
  parkedOnHold,
  activityLog,
}

class _CounterOperatorScreenState extends ConsumerState<CounterOperatorScreen> {
  final FocusNode _keyboardFocusNode = FocusNode();
  OperatorSidebarTab _selectedSidebarTab = OperatorSidebarTab.waitingQueue;

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

  Future<void> _handleCallNext() async {
    DqmsAudioVoiceService().unlockAudio();

    final queueList = ref.read(tokenQueueProvider).asData?.value ?? [];
    final waitingTokens = queueList
        .where(
          (t) =>
              t.tokenStatus == e_TokenStatus.queued.value ||
              t.tokenStatus == e_TokenStatus.waiting.value,
        )
        .toList();

    final tokenToCall = waitingTokens.firstOrNull;
    final nextToGetReady = waitingTokens.length > 1 ? waitingTokens[1] : null;

    final session = ref.read(staffSessionProvider);

    await ref.read(tokenQueueProvider.notifier).callNextToken();

    if (tokenToCall != null) {
      DqmsAudioVoiceService().announceToken(
        tokenNumber: tokenToCall.tokenNumber,
        counterName: session.selectedCounterName,
        primaryLanguageCode: 'en',
        nextTokenNumber: nextToGetReady?.tokenNumber,
      );
    } else {
      try {
        final updatedList = await ref.read(tokenQueueProvider.future);
        final active = updatedList
            .where(
              (t) =>
                  t.tokenStatus == e_TokenStatus.calling.value ||
                  t.tokenStatus == e_TokenStatus.active.value,
            )
            .firstOrNull;
        final updatedWaiting = updatedList
            .where(
              (t) =>
                  t.tokenStatus == e_TokenStatus.queued.value ||
                  t.tokenStatus == e_TokenStatus.waiting.value,
            )
            .toList();
        final nextWaiting = updatedWaiting.firstOrNull;

        if (active != null) {
          DqmsAudioVoiceService().announceToken(
            tokenNumber: active.tokenNumber,
            counterName: session.selectedCounterName,
            primaryLanguageCode: 'en',
            nextTokenNumber: nextWaiting?.tokenNumber,
          );
        }
      } catch (_) {}
    }
  }

  void _handleRecall(TokenTransactionDto activeToken) {
    DqmsAudioVoiceService().unlockAudio();
    ref
        .read(tokenQueueProvider.notifier)
        .updateTokenStatus(
          activeToken.id,
          e_TokenStatus.calling,
          tokenNumber: activeToken.tokenNumber,
        );
    final session = ref.read(staffSessionProvider);
    final queueList = ref.read(tokenQueueProvider).asData?.value ?? [];
    final waitingTokens = queueList
        .where(
          (t) =>
              t.tokenStatus == e_TokenStatus.queued.value ||
              t.tokenStatus == e_TokenStatus.waiting.value,
        )
        .toList();
    final nextToGetReady = waitingTokens.firstOrNull;

    DqmsAudioVoiceService().announceToken(
      tokenNumber: activeToken.tokenNumber,
      counterName: session.selectedCounterName,
      primaryLanguageCode: 'en',
      nextTokenNumber: nextToGetReady?.tokenNumber,
    );
  }

  void _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      final queueNotifier = ref.read(tokenQueueProvider.notifier);
      final queueList = ref.read(tokenQueueProvider).asData?.value ?? [];
      final activeToken = queueList
          .where(
            (t) =>
                t.tokenStatus == e_TokenStatus.calling.value ||
                t.tokenStatus == e_TokenStatus.active.value,
          )
          .firstOrNull;

      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.f1) {
        _handleCallNext();
      } else if (event.logicalKey == LogicalKeyboardKey.f2 &&
          activeToken != null) {
        _handleRecall(activeToken);
      } else if (event.logicalKey == LogicalKeyboardKey.f3 &&
          activeToken != null) {
        queueNotifier.updateTokenStatus(
          activeToken.id,
          e_TokenStatus.active,
          tokenNumber: activeToken.tokenNumber,
        );
      } else if (event.logicalKey == LogicalKeyboardKey.f4 &&
          activeToken != null) {
        _showHoldDialog(activeToken);
      } else if (event.logicalKey == LogicalKeyboardKey.f5 &&
          activeToken != null) {
        queueNotifier
            .updateTokenStatus(
              activeToken.id,
              e_TokenStatus.completed,
              tokenNumber: activeToken.tokenNumber,
            )
            .then((_) {
              _handleCallNext();
            });
      } else if (event.logicalKey == LogicalKeyboardKey.f6 &&
          activeToken != null) {
        _openForwardingDialog(activeToken);
      } else if (event.logicalKey == LogicalKeyboardKey.f7 &&
          activeToken != null) {
        queueNotifier.updateTokenStatus(
          activeToken.id,
          e_TokenStatus.canceled,
          reason: 'No show / Canceled',
          tokenNumber: activeToken.tokenNumber,
        );
      } else if (event.logicalKey == LogicalKeyboardKey.f8 &&
          activeToken != null) {
        _openWorkflowTimeline(activeToken);
      }
    }
  }

  /// Dialog to put a token on Hold (Park) with customizable quick-select reasons
  void _showHoldDialog(TokenTransactionDto token) {
    final reasons = [
      'Customer absent from waiting area',
      'Stepped out / will return shortly',
      'Waiting for documents / test reports',
      'Payment / insurance verification',
      'Other / Custom reason',
    ];
    String selectedReason = reasons.first;
    final customNoteCtrl = TextEditingController();
    bool isCustom = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: OperatorTheme.bgSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: OperatorTheme.actionHold),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.pause_circle_outline_rounded,
                color: OperatorTheme.actionHold,
              ),
              const SizedBox(width: 10),
              Text(
                'Park Token on Hold — ${token.tokenNumber}',
                style: const TextStyle(
                  color: OperatorTheme.textMain,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer: ${token.customerName ?? "Walk-in Ticket"}',
                  style: const TextStyle(
                    color: OperatorTheme.textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Reason for Hold:',
                  style: TextStyle(
                    color: OperatorTheme.textSubtle,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: reasons.map((r) {
                    final isSel = selectedReason == r;
                    return ChoiceChip(
                      label: Text(r),
                      selected: isSel,
                      selectedColor:
                          OperatorTheme.actionHold.withValues(alpha: 0.3),
                      backgroundColor: OperatorTheme.bgCanvas,
                      labelStyle: TextStyle(
                        color:
                            isSel ? Colors.purpleAccent : OperatorTheme.textMuted,
                        fontSize: 11,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: isSel
                            ? OperatorTheme.actionHold
                            : OperatorTheme.borderSubtle,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setDialogState(() {
                            selectedReason = r;
                            isCustom = r == 'Other / Custom reason';
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                if (isCustom) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: customNoteCtrl,
                    autofocus: true,
                    style: const TextStyle(
                      color: OperatorTheme.textMain,
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Specify Custom Reason',
                      labelStyle: TextStyle(color: OperatorTheme.textMuted),
                      hintText: 'Enter reason...',
                      hintStyle: TextStyle(color: OperatorTheme.textSubtle),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: OperatorTheme.textMuted),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.pause_rounded, size: 16),
              label: const Text('Park on Hold'),
              style: ElevatedButton.styleFrom(
                backgroundColor: OperatorTheme.actionHold,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final finalReason =
                    isCustom && customNoteCtrl.text.trim().isNotEmpty
                        ? customNoteCtrl.text.trim()
                        : selectedReason;
                Navigator.pop(ctx);
                ref.read(tokenQueueProvider.notifier).updateTokenStatus(
                      token.id,
                      e_TokenStatus.hold,
                      reason: finalReason,
                      tokenNumber: token.tokenNumber,
                    );
                setState(() {
                  _selectedSidebarTab = OperatorSidebarTab.parkedOnHold;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Token ${token.tokenNumber} parked on hold'),
                    backgroundColor: OperatorTheme.actionHold,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Recalls a held token back to the counter work station
  Future<void> _handleResumeHeldToken(
    TokenTransactionDto heldToken,
    TokenTransactionDto? activeToken,
  ) async {
    if (activeToken != null) {
      _showActiveCollisionWarning(activeToken, heldToken);
      return;
    }

    DqmsAudioVoiceService().unlockAudio();
    await ref.read(tokenQueueProvider.notifier).updateTokenStatus(
          heldToken.id,
          e_TokenStatus.calling,
          reason: 'Recalled from Hold',
          tokenNumber: heldToken.tokenNumber,
        );

    final session = ref.read(staffSessionProvider);
    DqmsAudioVoiceService().announceToken(
      tokenNumber: heldToken.tokenNumber,
      counterName: session.selectedCounterName.isNotEmpty
          ? session.selectedCounterName
          : 'Counter',
      primaryLanguageCode: 'en',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Token ${heldToken.tokenNumber} recalled to counter'),
          backgroundColor: OperatorTheme.actionCall,
        ),
      );
    }
  }

  /// Collision guard when recalling a held token while active customer is being served
  void _showActiveCollisionWarning(
    TokenTransactionDto currentActive,
    TokenTransactionDto heldToken,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OperatorTheme.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: OperatorTheme.actionRecall),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: OperatorTheme.actionRecall),
            SizedBox(width: 10),
            Text(
              'Counter Currently Busy',
              style: TextStyle(
                color: OperatorTheme.textMain,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are currently serving Token ${currentActive.tokenNumber} (${currentActive.customerName ?? 'Customer'}).',
                style: const TextStyle(
                  color: OperatorTheme.textMain,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'To recall Token ${heldToken.tokenNumber}, please complete or park Token ${currentActive.tokenNumber} first.',
                style: const TextStyle(
                  color: OperatorTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Keep Serving ${currentActive.tokenNumber}',
              style: const TextStyle(color: OperatorTheme.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: OperatorTheme.actionHold,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(tokenQueueProvider.notifier).updateTokenStatus(
                    currentActive.id,
                    e_TokenStatus.hold,
                    reason: 'Swapped to recall ${heldToken.tokenNumber}',
                    tokenNumber: currentActive.tokenNumber,
                  );
              _handleResumeHeldToken(heldToken, null);
            },
            child: Text(
              'Park ${currentActive.tokenNumber} & Recall ${heldToken.tokenNumber}',
            ),
          ),
        ],
      ),
    );
  }

  /// Cancels a held token if the customer permanently abandoned the visit
  void _handleCancelHeldToken(TokenTransactionDto token) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OperatorTheme.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: OperatorTheme.actionCancel),
        ),
        title: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: OperatorTheme.actionCancel),
            const SizedBox(width: 10),
            Text(
              'Cancel Parked Ticket — ${token.tokenNumber}',
              style: const TextStyle(
                color: OperatorTheme.textMain,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to cancel Token ${token.tokenNumber} (${token.customerName ?? "Customer"})? This will mark the ticket as No-Show.',
          style: const TextStyle(color: OperatorTheme.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Back',
              style: TextStyle(color: OperatorTheme.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: OperatorTheme.actionCancel,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(tokenQueueProvider.notifier).updateTokenStatus(
                    token.id,
                    e_TokenStatus.canceled,
                    reason: 'No-Show / Abandoned on Hold',
                    tokenNumber: token.tokenNumber,
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Token ${token.tokenNumber} marked as canceled'),
                  backgroundColor: OperatorTheme.actionCancel,
                ),
              );
            },
            child: const Text('Cancel Ticket'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokenQueueState = ref.watch(tokenQueueProvider);
    final session = ref.watch(staffSessionProvider);
    final allTokens = tokenQueueState.asData?.value ?? [];
    final heldCount = allTokens
        .where((t) => t.tokenStatus == e_TokenStatus.hold.value)
        .length;

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: _handleKeyPress,
      child: Scaffold(
        backgroundColor: OperatorTheme.bgCanvas,
        body: Column(
          children: [
            _buildOperatorHeader(session, heldCount),
            Expanded(
              child: tokenQueueState.when(
                loading: () => _buildSkeletonQueueScreen(),
                error: (err, _) => Center(
                  child: Text(
                    'Queue Error: $err',
                    style: const TextStyle(color: OperatorTheme.actionCancel),
                  ),
                ),
                data: (tokens) {
                  final activeToken = tokens
                      .where(
                        (t) =>
                            t.tokenStatus == e_TokenStatus.calling.value ||
                            t.tokenStatus == e_TokenStatus.active.value,
                      )
                      .firstOrNull;
                  final heldTokens = tokens
                      .where((t) => t.tokenStatus == e_TokenStatus.hold.value)
                      .toList();
                  final waitingTokens = tokens
                      .where(
                        (t) =>
                            t.tokenStatus == e_TokenStatus.queued.value ||
                            t.tokenStatus == e_TokenStatus.waiting.value,
                      )
                      .toList();

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
                              _buildActiveTokenCard(
                                activeToken,
                                heldTokensCount: heldTokens.length,
                              ),
                              const SizedBox(height: 24),
                              _buildHotkeyActionToolbar(activeToken),
                            ],
                          ),
                        ),
                      ),
                      // Queue/Audit/Parked Panel (Right 35%)
                      Expanded(
                        flex: 35,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: OperatorTheme.bgSurface,
                            border: Border(
                              left: BorderSide(
                                color: OperatorTheme.borderSubtle,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildSidebarHeader(
                                waitingTokens.length,
                                heldTokens.length,
                                session.todayLog.length,
                              ),
                              Expanded(
                                child: _selectedSidebarTab ==
                                        OperatorSidebarTab.waitingQueue
                                    ? _buildWaitingQueueList(waitingTokens)
                                    : (_selectedSidebarTab ==
                                            OperatorSidebarTab.parkedOnHold
                                        ? _buildParkedTokensList(
                                            heldTokens,
                                            activeToken,
                                          )
                                        : _buildAuditLogPanel(session)),
                              ),
                            ],
                          ),
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

  /// Operator Header with Counter Info & Session Context
  Widget _buildOperatorHeader(StaffSessionState session, int heldCount) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: OperatorTheme.bgSurface,
        border: Border(
          bottom: BorderSide(color: OperatorTheme.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back to Lobby
          IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: OperatorTheme.textMuted,
              size: 20,
            ),
            tooltip: 'Back to Lobby',
            onPressed: () {
              ref.read(staffSessionProvider.notifier).endSession();
              context.go('/staff/lobby');
            },
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: OperatorTheme.actionServe.withValues(alpha: 0.15),
              border: Border.all(
                color: OperatorTheme.actionServe.withValues(alpha: 0.4),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${session.selectedCounterNumber.isNotEmpty ? session.selectedCounterNumber : "C-01"}  •  ${session.selectedProcessCode.isNotEmpty ? session.selectedProcessCode : "PROC"}',
              style: const TextStyle(
                color: OperatorTheme.actionServe,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.selectedProcessName.isNotEmpty
                    ? session.selectedProcessName
                    : 'Counter Station',
                style: const TextStyle(
                  color: OperatorTheme.textMain,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Text(
                'Operator: ${session.staffName.isNotEmpty ? session.staffName : "Staff"}',
                style: const TextStyle(
                  color: OperatorTheme.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Stats badges
          _buildStatBadge(
            'Called',
            session.totalCalled.toString(),
            OperatorTheme.borderHighlight,
          ),
          const SizedBox(width: 8),
          _buildStatBadge(
            'Done',
            session.tokensCompleted.toString(),
            OperatorTheme.actionCall,
          ),
          const SizedBox(width: 8),
          _buildStatBadge(
            'On Hold',
            heldCount.toString(),
            OperatorTheme.actionHold,
            isAlert: heldCount > 0,
            onTap: () {
              setState(() {
                _selectedSidebarTab = OperatorSidebarTab.parkedOnHold;
              });
            },
          ),
          const SizedBox(width: 8),
          _buildStatBadge(
            'Cancelled',
            session.tokensCancelled.toString(),
            OperatorTheme.actionCancel,
          ),
          const SizedBox(width: 16),
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

  Widget _buildStatBadge(
    String label,
    String count,
    Color color, {
    VoidCallback? onTap,
    bool isAlert = false,
  }) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isAlert ? 0.22 : 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withValues(alpha: isAlert ? 0.6 : 0.3),
          width: isAlert ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: TextStyle(
              color: isAlert ? Colors.purpleAccent : color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: badge,
      );
    }
    return badge;
  }

  /// Modern Tri-Segmented Header for the Operator Sidebar
  Widget _buildSidebarHeader(
    int waitingCount,
    int heldCount,
    int activityCount,
  ) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: OperatorTheme.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildSidebarTabButton(
            tab: OperatorSidebarTab.waitingQueue,
            icon: Icons.people_alt_outlined,
            label: 'Queue',
            count: waitingCount,
            activeColor: OperatorTheme.borderHighlight,
          ),
          const SizedBox(width: 6),
          _buildSidebarTabButton(
            tab: OperatorSidebarTab.parkedOnHold,
            icon: Icons.pause_circle_outline_rounded,
            label: 'Parked',
            count: heldCount,
            activeColor: OperatorTheme.actionHold,
            highlightAlert: heldCount > 0,
          ),
          const SizedBox(width: 6),
          _buildSidebarTabButton(
            tab: OperatorSidebarTab.activityLog,
            icon: Icons.history_rounded,
            label: 'Activity',
            count: activityCount,
            activeColor: OperatorTheme.actionRecall,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarTabButton({
    required OperatorSidebarTab tab,
    required IconData icon,
    required String label,
    required int count,
    required Color activeColor,
    bool highlightAlert = false,
  }) {
    final isSelected = _selectedSidebarTab == tab;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedSidebarTab = tab),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: 0.15)
                : (highlightAlert
                    ? OperatorTheme.actionHold.withValues(alpha: 0.1)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected
                  ? activeColor
                  : (highlightAlert
                      ? OperatorTheme.actionHold.withValues(alpha: 0.5)
                      : Colors.transparent),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? activeColor
                    : (highlightAlert
                        ? OperatorTheme.actionHold
                        : OperatorTheme.textMuted),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? activeColor
                      : (highlightAlert
                          ? Colors.purpleAccent
                          : OperatorTheme.textMuted),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? activeColor
                      : (highlightAlert
                          ? OperatorTheme.actionHold
                          : OperatorTheme.bgCard),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected || highlightAlert
                        ? Colors.white
                        : OperatorTheme.textSubtle,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Skeleton Shimmer Loading Screen for Operator
  Widget _buildSkeletonQueueScreen() {
    return Shimmer.fromColors(
      baseColor: OperatorTheme.bgSurface,
      highlightColor: OperatorTheme.bgCard,
      child: Row(
        children: [
          Expanded(
            flex: 65,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 240,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 35,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Prominent Current Active Token Display
  Widget _buildActiveTokenCard(TokenTransactionDto? token,
      {int heldTokensCount = 0}) {
    if (token == null) {
      return Container(
        height: 280,
        width: double.infinity,
        decoration: BoxDecoration(
          color: OperatorTheme.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: OperatorTheme.borderSubtle),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.event_seat_outlined,
                color: OperatorTheme.textSubtle,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'COUNTER IDLE',
                style: TextStyle(
                  color: OperatorTheme.textMuted,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Press [ SPACE ] or [ F1 ] to Call Next Waiting Customer',
                style: TextStyle(
                  color: OperatorTheme.borderHighlight,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (heldTokensCount > 0) ...[
                const SizedBox(height: 18),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: OperatorTheme.actionHold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: OperatorTheme.actionHold.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.pause_circle_outline_rounded,
                        color: OperatorTheme.actionHold,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$heldTokensCount patient(s) parked on hold',
                        style: const TextStyle(
                          color: OperatorTheme.textMain,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _selectedSidebarTab =
                                OperatorSidebarTab.parkedOnHold;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: OperatorTheme.actionHold,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'View Parked Panel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final isHolding = token.tokenStatus == e_TokenStatus.hold.value;
    final isCalling = token.tokenStatus == e_TokenStatus.calling.value;

    return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: OperatorTheme.bgSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHolding
                  ? OperatorTheme.actionHold
                  : (isCalling
                        ? OperatorTheme.actionRecall
                        : OperatorTheme.borderHighlight),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    (isCalling
                            ? OperatorTheme.actionRecall
                            : OperatorTheme.borderHighlight)
                        .withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    isCalling
                        ? 'NOW CALLING...'
                        : (isHolding ? 'ON HOLD' : 'NOW SERVING'),
                    style: TextStyle(
                      color: isHolding
                          ? OperatorTheme.actionHold
                          : (isCalling
                                ? OperatorTheme.actionRecall
                                : OperatorTheme.borderHighlight),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  if (token.subTokenSequence > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.purpleAccent),
                      ),
                      child: Text(
                        'SUB-TOKEN #${token.subTokenSequence}',
                        style: const TextStyle(
                          color: Colors.purpleAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.tealAccent),
                    ),
                    child: Text(
                      'PIPELINE STEP ${token.stepOrder}',
                      style: const TextStyle(
                        color: Colors.tealAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                    style: const TextStyle(
                      color: OperatorTheme.textMain,
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        token.customerName ?? 'Walk-in Customer',
                        style: const TextStyle(
                          color: OperatorTheme.textMain,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        token.customerPhone ?? 'No Phone Provided',
                        style: const TextStyle(
                          color: OperatorTheme.textMuted,
                          fontSize: 14,
                        ),
                      ),
                      if (token.notes != null && token.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Handoff Notes: ${token.notes}',
                          style: const TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        )
        .animate(key: ValueKey('${token.tokenNumber}_${token.tokenStatus}'))
        .scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1.0, 1.0),
          duration: 350.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn();
  }

  /// Low-Friction Hotkey Action Toolbar
  Widget _buildHotkeyActionToolbar(TokenTransactionDto? activeToken) {
    final queueNotifier = ref.read(tokenQueueProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OPERATOR HOTKEY CONTROLS',
          style: TextStyle(
            color: OperatorTheme.textSubtle,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionButton(
              'SPACE / F1',
              'Call Next',
              OperatorTheme.actionCall,
              Icons.campaign_rounded,
              () => _handleCallNext(),
              isPrimary: true,
            ),
            _buildActionButton(
              'F2',
              'Recall',
              OperatorTheme.actionRecall,
              Icons.replay_rounded,
              activeToken != null ? () => _handleRecall(activeToken) : null,
            ),
            _buildActionButton(
              'F3',
              'Serve Active',
              OperatorTheme.actionServe,
              Icons.play_arrow_rounded,
              activeToken != null
                  ? () => queueNotifier.updateTokenStatus(
                      activeToken.id,
                      e_TokenStatus.active,
                      tokenNumber: activeToken.tokenNumber,
                    )
                  : null,
            ),
            _buildActionButton(
              'F4',
              'Hold',
              OperatorTheme.actionHold,
              Icons.pause_rounded,
              activeToken != null
                  ? () => _showHoldDialog(activeToken)
                  : null,
            ),
            _buildActionButton(
              'F5',
              'Complete & Call Next',
              OperatorTheme.actionServe,
              Icons.check_circle_rounded,
              activeToken != null
                  ? () {
                      queueNotifier
                          .updateTokenStatus(
                            activeToken.id,
                            e_TokenStatus.completed,
                            tokenNumber: activeToken.tokenNumber,
                          )
                          .then((_) => _handleCallNext());
                    }
                  : null,
              isPrimary: true,
            ),
            _buildActionButton(
              'F6',
              'Forward / Next Step',
              Colors.tealAccent.shade400,
              Icons.fast_forward_rounded,
              activeToken != null
                  ? () => _openForwardingDialog(activeToken)
                  : null,
            ),
            _buildActionButton(
              'F7',
              'Cancel',
              OperatorTheme.actionCancel,
              Icons.cancel_outlined,
              activeToken != null
                  ? () => queueNotifier.updateTokenStatus(
                      activeToken.id,
                      e_TokenStatus.canceled,
                      reason: 'No Show',
                      tokenNumber: activeToken.tokenNumber,
                    )
                  : null,
            ),
            _buildActionButton(
              'F8',
              'Journey History',
              const Color(0xFFB388FF),
              Icons.timeline_rounded,
              activeToken != null
                  ? () => _openWorkflowTimeline(activeToken)
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String hotkey,
    String label,
    Color color,
    IconData icon,
    VoidCallback? onPressed, {
    bool isPrimary = false,
  }) {
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
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.2)
                    : color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                hotkey,
                style: TextStyle(
                  color: isPrimary ? Colors.white : color,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
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
              const Text(
                'WAITING QUEUE',
                style: TextStyle(
                  color: OperatorTheme.textMain,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: OperatorTheme.borderHighlight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${waitingTokens.length} Waiting',
                  style: const TextStyle(
                    color: OperatorTheme.borderHighlight,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: OperatorTheme.borderSubtle, height: 1),
        Expanded(
          child: waitingTokens.isEmpty
              ? const Center(
                  child: Text(
                    'Queue Empty',
                    style: TextStyle(
                      color: OperatorTheme.textSubtle,
                      fontSize: 13,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: waitingTokens.length,
                  separatorBuilder: (_, s) => const Divider(
                    color: OperatorTheme.borderSubtle,
                    height: 1,
                  ),
                  itemBuilder: (ctx, i) {
                    final item = waitingTokens[i];
                    return Material(
                          color: Colors.transparent,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
                            title: Row(
                              children: [
                                Text(
                                  item.tokenNumber,
                                  style: const TextStyle(
                                    color: OperatorTheme.textMain,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _buildPriorityBadge(item.priorityTier),
                              ],
                            ),
                            subtitle: Text(
                              item.customerName ?? 'Walk-in Ticket',
                              style: const TextStyle(
                                color: OperatorTheme.textMuted,
                                fontSize: 12,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: OperatorTheme.textSubtle,
                              size: 14,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 250.ms, delay: (25 * i).ms)
                        .slideX(begin: 0.04, end: 0, duration: 250.ms);
                  },
                ),
        ),
      ],
    );
  }

  /// Dedicated Parked / On-Hold Side Panel List
  Widget _buildParkedTokensList(
    List<TokenTransactionDto> heldTokens,
    TokenTransactionDto? activeToken,
  ) {
    if (heldTokens.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pause_circle_outline_rounded,
                color: OperatorTheme.textSubtle,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'No Tickets On Hold',
                style: TextStyle(
                  color: OperatorTheme.textMain,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'When a customer is absent or stepped away, press [F4] or click "Hold" to park their ticket here without losing their queue progress.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: OperatorTheme.textSubtle,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              const Icon(
                Icons.pause_circle_filled_rounded,
                color: OperatorTheme.actionHold,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'PARKED TICKETS',
                style: TextStyle(
                  color: OperatorTheme.textMain,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: OperatorTheme.actionHold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: OperatorTheme.actionHold.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${heldTokens.length} Parked',
                  style: const TextStyle(
                    color: OperatorTheme.actionHold,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: OperatorTheme.borderSubtle, height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: heldTokens.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final item = heldTokens[i];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: OperatorTheme.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: OperatorTheme.actionHold.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.tokenNumber,
                          style: const TextStyle(
                            color: OperatorTheme.textMain,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildPriorityBadge(item.priorityTier),
                        const Spacer(),
                        const Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: OperatorTheme.textSubtle,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'On Hold',
                          style: TextStyle(
                            color: OperatorTheme.actionHold,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: OperatorTheme.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.customerName ?? 'Walk-in Customer',
                          style: const TextStyle(
                            color: OperatorTheme.textMain,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (item.customerPhone != null &&
                            item.customerPhone!.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Text(
                            '(${item.customerPhone})',
                            style: const TextStyle(
                              color: OperatorTheme.textSubtle,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (item.notes != null && item.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              OperatorTheme.actionHold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 13,
                              color: Colors.purpleAccent,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Reason: ${item.notes}',
                                style: const TextStyle(
                                  color: Colors.purpleAccent,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(
                              Icons.campaign_rounded,
                              size: 16,
                            ),
                            label: const Text('Recall to Counter'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: OperatorTheme.actionCall,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () =>
                                _handleResumeHeldToken(item, activeToken),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Cancel Ticket (No-Show)',
                          icon: const Icon(
                            Icons.cancel_outlined,
                            size: 18,
                            color: OperatorTheme.actionCancel,
                          ),
                          onPressed: () => _handleCancelHeldToken(item),
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 250.ms, delay: (25 * i).ms)
                  .slideY(begin: 0.04, end: 0, duration: 250.ms);
            },
          ),
        ),
      ],
    );
  }
  Widget _buildAuditLogPanel(StaffSessionState session) {
    final log = session.todayLog;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(
                Icons.history_rounded,
                color: OperatorTheme.actionRecall,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'TODAY\'S ACTIVITY LOG',
                style: TextStyle(
                  color: OperatorTheme.textMain,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: OperatorTheme.actionRecall.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${log.length} actions',
                  style: const TextStyle(
                    color: OperatorTheme.actionRecall,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: OperatorTheme.borderSubtle, height: 1),
        Expanded(
          child: log.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_toggle_off_rounded,
                        color: OperatorTheme.textSubtle,
                        size: 40,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No activity yet this session',
                        style: TextStyle(
                          color: OperatorTheme.textSubtle,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: log.length,
                  separatorBuilder: (_, s) => const Divider(
                    color: OperatorTheme.borderSubtle,
                    height: 1,
                  ),
                  itemBuilder: (ctx, i) {
                    final entry = log[i];
                    final actionColor = _auditActionColor(entry.action);
                    return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Text(
                                entry.formattedTime,
                                style: const TextStyle(
                                  color: OperatorTheme.textSubtle,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                entry.tokenNumber,
                                style: const TextStyle(
                                  color: OperatorTheme.textMain,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: actionColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  entry.action,
                                  style: TextStyle(
                                    color: actionColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (entry.notes != null) ...[
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    entry.notes!,
                                    style: const TextStyle(
                                      color: OperatorTheme.textSubtle,
                                      fontSize: 10,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 250.ms, delay: (20 * i).ms)
                        .slideY(begin: 0.05, end: 0, duration: 250.ms);
                  },
                ),
        ),
      ],
    );
  }

  Color _auditActionColor(String action) {
    switch (action) {
      case 'Called':
        return OperatorTheme.actionCall;
      case 'Recalled':
        return OperatorTheme.actionRecall;
      case 'Serving':
        return OperatorTheme.actionServe;
      case 'Completed':
        return OperatorTheme.actionCall;
      case 'Cancelled':
        return OperatorTheme.actionCancel;
      case 'On Hold':
        return OperatorTheme.actionHold;
      default:
        return OperatorTheme.textMuted;
    }
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
      child: Text(
        label,
        style: TextStyle(color: col, fontSize: 10, fontWeight: FontWeight.w700),
      ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: OperatorTheme.borderSubtle),
        ),
        title: const Text(
          'Issue New Queue Token',
          style: TextStyle(
            color: OperatorTheme.textMain,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(
                  color: OperatorTheme.textMain,
                  fontSize: 13,
                ),
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  labelStyle: TextStyle(color: OperatorTheme.textMuted),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                style: const TextStyle(
                  color: OperatorTheme.textMain,
                  fontSize: 13,
                ),
                decoration: const InputDecoration(
                  labelText: 'Phone Number (WhatsApp)',
                  labelStyle: TextStyle(color: OperatorTheme.textMuted),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: OperatorTheme.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: OperatorTheme.actionServe,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref
                  .read(tokenQueueProvider.notifier)
                  .issueToken(
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

  /// N-Level Pipeline Forwarding & Sub-Token Dialog
  void _openForwardingDialog(TokenTransactionDto token) async {
    final repo = ref.read(staffRepositoryProvider);
    final steps = await repo.fetchProcessSteps(processId: token.processId);
    final nextStep = steps
        .where((s) => s.stepOrder == token.stepOrder + 1)
        .firstOrNull;

    final reasonCtrl = TextEditingController();
    bool isSubToken = false;
    int? selectedTargetProcessId;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: OperatorTheme.bgSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.tealAccent),
          ),
          title: Row(
            children: [
              const Icon(Icons.alt_route_rounded, color: Colors.tealAccent),
              const SizedBox(width: 10),
              Text(
                'Forward & Pipeline Routing — ${token.tokenNumber}',
                style: const TextStyle(
                  color: OperatorTheme.textMain,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.teal.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Journey Step: ${token.stepOrder} of ${steps.isNotEmpty ? steps.length : 4}',
                          style: const TextStyle(
                            color: Colors.tealAccent,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nextStep != null
                              ? 'Next Sequential Step: ${nextStep.stepName}'
                              : 'Final Step Reached (or cross-process branch)',
                          style: const TextStyle(
                            color: OperatorTheme.textMain,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Switch(
                        value: isSubToken,
                        activeThumbColor: Colors.purpleAccent,
                        onChanged: (val) {
                          setDialogState(() {
                            isSubToken = val;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSubToken
                                  ? 'Parallel Sub-Token Mode (Branch)'
                                  : 'Sequential Handoff Mode',
                              style: TextStyle(
                                color: isSubToken
                                    ? Colors.purpleAccent
                                    : OperatorTheme.textMain,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              isSubToken
                                  ? 'Dispatches linked sub-ticket (e.g. Lab/Pharmacy) while parent token stays active'
                                  : 'Completes current counter step and queues customer for Step ${token.stepOrder + 1}',
                              style: const TextStyle(
                                color: OperatorTheme.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Branch to Target Department (Optional):',
                    style: TextStyle(
                      color: OperatorTheme.textSubtle,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    initialValue: selectedTargetProcessId,
                    dropdownColor: OperatorTheme.bgSurface,
                    style: const TextStyle(
                      color: OperatorTheme.textMain,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: OperatorTheme.bgCanvas,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                          color: OperatorTheme.borderSubtle,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    hint: Text(
                      isSubToken
                          ? 'Select sub-token destination (e.g. Lab, Pharmacy)'
                          : 'Auto: Next Step in Pipeline (${nextStep?.stepName ?? "Step ${token.stepOrder + 1}"})',
                      style: const TextStyle(
                        color: OperatorTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 1,
                        child: Text(
                          'PROC-101: Comprehensive Patient Registration & Triage',
                        ),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text(
                          'PROC-201: Executive Health Screening Workflow',
                        ),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text(
                          'PROC-301: Express Fast-Track Billing & Cashier',
                        ),
                      ),
                      DropdownMenuItem(
                        value: 4,
                        child: Text('PROC-401: VIP Specialist Consultation'),
                      ),
                      DropdownMenuItem(
                        value: 5,
                        child: Text(
                          'PROC-501: Prescription Dispensing & Pharmacy Advisory',
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setDialogState(() {
                        selectedTargetProcessId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reasonCtrl,
                    style: const TextStyle(
                      color: OperatorTheme.textMain,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Clinical / Routing Remarks',
                      labelStyle: const TextStyle(
                        color: OperatorTheme.textMuted,
                      ),
                      hintText:
                          'e.g. Triage vitals normal. Handoff to Doctor Desk.',
                      hintStyle: const TextStyle(
                        color: OperatorTheme.textSubtle,
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: OperatorTheme.bgCanvas,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                          color: OperatorTheme.borderSubtle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: OperatorTheme.textMuted),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSubToken
                    ? Colors.purpleAccent
                    : Colors.tealAccent.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
              ),
              icon: Icon(
                isSubToken
                    ? Icons.call_split_rounded
                    : Icons.fast_forward_rounded,
                size: 18,
              ),
              label: Text(
                isSubToken ? 'Dispatch Sub-Token' : 'Forward to Next Step',
              ),
              onPressed: () async {
                final success = await ref
                    .read(tokenQueueProvider.notifier)
                    .forwardToken(
                      token.id,
                      targetProcessId: selectedTargetProcessId,
                      isSubToken: isSubToken,
                      reason: reasonCtrl.text.trim().isNotEmpty
                          ? reasonCtrl.text.trim()
                          : null,
                      tokenNumber: token.tokenNumber,
                    );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? (isSubToken
                                  ? 'Sub-token dispatched successfully'
                                  : 'Token forwarded to next pipeline step')
                            : 'Workflow routing executed',
                      ),
                      backgroundColor: Colors.teal,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Full N-Level Journey Timeline Stepper Dialog
  void _openWorkflowTimeline(TokenTransactionDto token) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OperatorTheme.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFB388FF)),
        ),
        title: Row(
          children: [
            const Icon(Icons.timeline_rounded, color: Color(0xFFB388FF)),
            const SizedBox(width: 10),
            Text(
              'Patient Journey Lifecycle — ${token.tokenNumber}',
              style: const TextStyle(
                color: OperatorTheme.textMain,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 560,
          height: 440,
          child: FutureBuilder<TokenWorkflowHistoryDto?>(
            future: ref
                .read(staffRepositoryProvider)
                .fetchTokenWorkflow(token.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.tealAccent),
                );
              }

              final history = snapshot.data;
              if (history == null || history.steps.isEmpty) {
                return const Center(
                  child: Text(
                    'No workflow history records found.',
                    style: TextStyle(color: OperatorTheme.textMuted),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.purple.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Customer: ${history.customerName ?? "Walk-in"}',
                          style: const TextStyle(
                            color: OperatorTheme.textMain,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Service: ${history.processCode}',
                          style: const TextStyle(
                            color: Colors.purpleAccent,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sequential Pipeline Steps:',
                    style: TextStyle(
                      color: OperatorTheme.textSubtle,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      itemCount: history.steps.length,
                      separatorBuilder: (_, _) => const Divider(
                        color: OperatorTheme.borderSubtle,
                        height: 16,
                      ),
                      itemBuilder: (context, idx) {
                        final step = history.steps[idx];
                        final isDone =
                            step.tokenStatus == 18007 ||
                            step.tokenStatus == 18008;
                        final isCurrent =
                            step.tokenStatus == 18003 ||
                            step.tokenStatus == 18004;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: isDone
                                  ? Colors.teal
                                  : (isCurrent
                                        ? Colors.amber.shade700
                                        : OperatorTheme.borderSubtle),
                              child: Text(
                                '${step.stepOrder}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          step.stepName,
                                          style: const TextStyle(
                                            color: OperatorTheme.textMain,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDone
                                              ? Colors.teal.withValues(
                                                  alpha: 0.2,
                                                )
                                              : Colors.amber.withValues(
                                                  alpha: 0.2,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          step.statusName,
                                          style: TextStyle(
                                            color: isDone
                                                ? Colors.tealAccent
                                                : Colors.amberAccent,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Counter: ${step.counterNumber ?? "Enqueued"} | Target TAT: ${step.targetTATMinutes}m | Elapsed: ${step.durationSeconds}s',
                                    style: const TextStyle(
                                      color: OperatorTheme.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                  if (step.notes != null &&
                                      step.notes!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Notes: ${step.notes}',
                                      style: const TextStyle(
                                        color: OperatorTheme.textSubtle,
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  if (history.subTokens.isNotEmpty) ...[
                    const Divider(color: OperatorTheme.borderSubtle),
                    const Text(
                      'Branching Sub-Tokens:',
                      style: TextStyle(
                        color: Colors.purpleAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...history.subTokens.map(
                      (st) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.subdirectory_arrow_right_rounded,
                              color: Colors.purpleAccent,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              st.tokenNumber,
                              style: const TextStyle(
                                color: Colors.purpleAccent,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                st.processName,
                                style: const TextStyle(
                                  color: OperatorTheme.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              st.statusName,
                              style: const TextStyle(
                                color: Colors.tealAccent,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB388FF),
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Close Journey View',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
