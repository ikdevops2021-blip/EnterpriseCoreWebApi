import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/theme/app_breakpoints.dart';
import 'package:dqms_frontend/features/dashboard/screens/dashboard_screen.dart';
import 'package:dqms_frontend/features/admin/screens/admin_workspace_screen.dart';
import 'package:dqms_frontend/features/operator/providers/operator_console_provider.dart';
import 'package:dqms_frontend/features/operator/widgets/current_token_panel.dart';
import 'package:dqms_frontend/features/operator/widgets/operator_action_bar.dart';
import 'package:dqms_frontend/features/operator/widgets/operator_queue_panel.dart';
import 'package:dqms_frontend/features/operator/widgets/token_history.dart';
import 'package:dqms_frontend/features/operator/widgets/operator_context_panel.dart';

/// Intent Actions for Flutter Shortcuts System
class CallNextIntent extends Intent { const CallNextIntent(); }
class RecallIntent extends Intent { const RecallIntent(); }
class ServeIntent extends Intent { const ServeIntent(); }
class HoldIntent extends Intent { const HoldIntent(); }
class CompleteIntent extends Intent { const CompleteIntent(); }
class CancelIntent extends Intent { const CancelIntent(); }

/// ============================================================================
/// COUNTER OPERATOR CONSOLE SCREEN
/// High-speed, keyboard-first operational console with responsive 3-region grid
/// ============================================================================
class OperatorConsoleScreen extends ConsumerStatefulWidget {
  const OperatorConsoleScreen({super.key});

  @override
  ConsumerState<OperatorConsoleScreen> createState() => _OperatorConsoleScreenState();
}

class _OperatorConsoleScreenState extends ConsumerState<OperatorConsoleScreen> {
  Timer? _timer;
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Ticking live timer
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(operatorConsoleProvider.notifier).tickTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(operatorConsoleProvider);
    final notifier = ref.read(operatorConsoleProvider.notifier);
    final isDesktop = AppBreakpoints.isDesktop(context);
    final isTablet = AppBreakpoints.isTablet(context);

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(LogicalKeyboardKey.space): const CallNextIntent(),
        LogicalKeySet(LogicalKeyboardKey.f1): const CallNextIntent(),
        LogicalKeySet(LogicalKeyboardKey.f2): const RecallIntent(),
        LogicalKeySet(LogicalKeyboardKey.f3): const ServeIntent(),
        LogicalKeySet(LogicalKeyboardKey.f4): const HoldIntent(),
        LogicalKeySet(LogicalKeyboardKey.f5): const CompleteIntent(),
        LogicalKeySet(LogicalKeyboardKey.f7): const CancelIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          CallNextIntent: CallbackAction<CallNextIntent>(onInvoke: (_) {
            notifier.callNext();
            return null;
          }),
          RecallIntent: CallbackAction<RecallIntent>(onInvoke: (_) {
            notifier.recall();
            return null;
          }),
          ServeIntent: CallbackAction<ServeIntent>(onInvoke: (_) {
            notifier.serve();
            return null;
          }),
          HoldIntent: CallbackAction<HoldIntent>(onInvoke: (_) {
            notifier.hold();
            return null;
          }),
          CompleteIntent: CallbackAction<CompleteIntent>(onInvoke: (_) {
            notifier.complete();
            return null;
          }),
          CancelIntent: CallbackAction<CancelIntent>(onInvoke: (_) {
            notifier.cancel();
            return null;
          }),
        },
        child: Focus(
          focusNode: _keyboardFocusNode,
          autofocus: true,
          child: Scaffold(
            backgroundColor: AppColors.bgCanvas,
            body: SafeArea(
              child: Column(
                children: [
                  // Top Command Bar
                  _buildTopHeader(context, state),

                  // Console Body Layout
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: isDesktop
                            ? _buildDesktopLayout(state, notifier)
                            : isTablet
                                ? _buildTabletLayout(state, notifier)
                                : _buildMobileLayout(state, notifier),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Top Operational Header Bar
  Widget _buildTopHeader(BuildContext context, OperatorConsoleState state) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.bgHeader,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withValues(alpha: 0.15),
                border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'COUNTER OPERATOR CONSOLE',
                style: TextStyle(
                  color: AppColors.brandPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              '${state.counterNumber} (${state.counterName})',
              style: const TextStyle(
                color: AppColors.textMain,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 14),

            // Action Feedback Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.statusActive.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.statusActive.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.statusActive, size: 12),
                  const SizedBox(width: 6),
                  Text(
                    state.lastActionNotice,
                    style: const TextStyle(color: AppColors.statusActive, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),

            // Navigation Links
            OutlinedButton.icon(
              icon: const Icon(Icons.dashboard_customize_rounded, size: 14),
              label: const Text('Command Center', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandPrimary,
                side: const BorderSide(color: AppColors.brandPrimary),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
              },
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.admin_panel_settings_rounded, size: 14),
              label: const Text('Admin Workspace', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSubtle,
                side: const BorderSide(color: AppColors.borderSubtle),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminWorkspaceScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Desktop Layout: High-density 3-region grid
  Widget _buildDesktopLayout(OperatorConsoleState state, OperatorConsoleNotifier notifier) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (Width 320): Station Metadata & Queue List
        SizedBox(
          width: 320,
          child: Column(
            children: [
              OperatorContextPanel(
                counterNumber: state.counterNumber,
                counterName: state.counterName,
                operatorName: state.operatorName,
                totalServedToday: state.totalServedToday,
                activeToken: state.currentToken,
              ),
              const SizedBox(height: 16),
              OperatorQueuePanel(queueItems: state.waitingQueue),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Center Column (Expanded): Focal Current Token & Dominant Action Bar
        Expanded(
          child: Column(
            children: [
              CurrentTokenPanel(token: state.currentToken),
              const SizedBox(height: 16),
              OperatorActionBar(
                onCallNext: notifier.callNext,
                onRecall: notifier.recall,
                onServe: notifier.serve,
                onHold: notifier.hold,
                onComplete: notifier.complete,
                onCancel: notifier.cancel,
                hasActiveToken: state.currentToken != null,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Right Column (Width 300): Step History Audit Trail
        SizedBox(
          width: 300,
          child: TokenHistory(historySteps: state.historySteps),
        ),
      ],
    );
  }

  /// Tablet Layout: Adaptive 2-column layout
  Widget _buildTabletLayout(OperatorConsoleState state, OperatorConsoleNotifier notifier) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary Column (Current Token & Action Bar)
        Expanded(
          flex: 6,
          child: Column(
            children: [
              CurrentTokenPanel(token: state.currentToken),
              const SizedBox(height: 16),
              OperatorActionBar(
                onCallNext: notifier.callNext,
                onRecall: notifier.recall,
                onServe: notifier.serve,
                onHold: notifier.hold,
                onComplete: notifier.complete,
                onCancel: notifier.cancel,
                hasActiveToken: state.currentToken != null,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Secondary Column (Queue & Context)
        Expanded(
          flex: 5,
          child: Column(
            children: [
              OperatorContextPanel(
                counterNumber: state.counterNumber,
                counterName: state.counterName,
                operatorName: state.operatorName,
                totalServedToday: state.totalServedToday,
                activeToken: state.currentToken,
              ),
              const SizedBox(height: 16),
              OperatorQueuePanel(queueItems: state.waitingQueue),
              const SizedBox(height: 16),
              TokenHistory(historySteps: state.historySteps),
            ],
          ),
        ),
      ],
    );
  }

  /// Mobile Layout: Single column touch-first flow
  Widget _buildMobileLayout(OperatorConsoleState state, OperatorConsoleNotifier notifier) {
    return Column(
      children: [
        CurrentTokenPanel(token: state.currentToken),
        const SizedBox(height: 16),
        OperatorActionBar(
          onCallNext: notifier.callNext,
          onRecall: notifier.recall,
          onServe: notifier.serve,
          onHold: notifier.hold,
          onComplete: notifier.complete,
          onCancel: notifier.cancel,
          hasActiveToken: state.currentToken != null,
        ),
        const SizedBox(height: 16),
        OperatorContextPanel(
          counterNumber: state.counterNumber,
          counterName: state.counterName,
          operatorName: state.operatorName,
          totalServedToday: state.totalServedToday,
          activeToken: state.currentToken,
        ),
        const SizedBox(height: 16),
        OperatorQueuePanel(queueItems: state.waitingQueue),
        const SizedBox(height: 16),
        TokenHistory(historySteps: state.historySteps),
      ],
    );
  }
}
