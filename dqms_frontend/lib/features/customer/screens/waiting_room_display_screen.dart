import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/customer_models.dart';
import '../providers/customer_providers.dart';

/// ============================================================================
/// DQMS ENTERPRISE DESIGN TOKENS (Per UI_UX_DESIGN_SPEC.md)
/// Aesthetic: High-Visibility 4K Waiting Room Display Board (Template 21001)
/// ============================================================================
class DisplayTheme {
  static const Color bgCanvas = Color(0xFF070B0E);
  static const Color bgCard = Color(0xFF111822);

  static const Color borderSubtle = Color(0xFF1E2836);
  static const Color alertFlash = Color(0xFF3FB950);
  static const Color textMain = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF8B949E);
  static const Color accentBlue = Color(0xFF58A6FF);
  static const Color accentPurple = Color(0xFFBC8CFF);
}

/// ============================================================================
/// STAGE 3: WAITING ROOM TV OVERHEAD DISPLAY BOARD
/// ============================================================================
class WaitingRoomDisplayScreen extends ConsumerStatefulWidget {
  const WaitingRoomDisplayScreen({super.key});

  @override
  ConsumerState<WaitingRoomDisplayScreen> createState() => _WaitingRoomDisplayScreenState();
}

class _WaitingRoomDisplayScreenState extends ConsumerState<WaitingRoomDisplayScreen> {
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    // Auto-poll display board every 3 seconds for live overhead TV updates
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      ref.read(displayBoardProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayState = ref.watch(displayBoardProvider);

    return Scaffold(
      backgroundColor: DisplayTheme.bgCanvas,
      body: Column(
        children: [
          _buildTvHeader(),
          Expanded(
            child: displayState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: DisplayTheme.accentBlue)),
              error: (err, _) => Center(child: Text('Display Error: $err', style: const TextStyle(color: Colors.red))),
              data: (callingItems) => callingItems.isEmpty
                  ? _buildEmptyDisplayBoard()
                  : GridView.builder(
                      padding: const EdgeInsets.all(24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1.4,
                      ),
                      itemCount: callingItems.length,
                      itemBuilder: (ctx, i) => _buildCallingCard(callingItems[i]),
                    ),
            ),
          ),
          _buildLiveFooterTicker(),
        ],
      ),
    );
  }

  /// TV Header with Organization & Live Clock
  Widget _buildTvHeader() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: DisplayTheme.bgCard,
        border: Border(bottom: BorderSide(color: DisplayTheme.borderSubtle, width: 2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2F81F7), Color(0xFF8957E5)]),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('DQMS TV', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
          ),
          const SizedBox(width: 20),
          const Text('Main Hospital Waiting Area • Live Queue Board', style: TextStyle(color: DisplayTheme.textMain, fontWeight: FontWeight.w700, fontSize: 20)),
          const Spacer(),
          const Icon(Icons.volume_up_rounded, color: DisplayTheme.accentBlue, size: 24),
          const SizedBox(width: 8),
          const Text('AUDIO ANNOUNCEMENT ACTIVE', style: TextStyle(color: DisplayTheme.accentBlue, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
        ],
      ),
    );
  }

  /// High-Visibility Calling Card for TV Grid
  Widget _buildCallingCard(DisplayBoardItemDto item) {
    final isFlashing = item.flashAlert;

    return Container(
      decoration: BoxDecoration(
        color: DisplayTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFlashing ? DisplayTheme.alertFlash : DisplayTheme.accentBlue,
          width: isFlashing ? 4 : 2,
        ),
        boxShadow: isFlashing
            ? [BoxShadow(color: DisplayTheme.alertFlash.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2)]
            : [],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item.processName.toUpperCase(), style: const TextStyle(color: DisplayTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
          const Spacer(),
          Text(
            item.tokenNumber,
            style: const TextStyle(color: DisplayTheme.textMain, fontSize: 64, fontWeight: FontWeight.w900, letterSpacing: -2),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: DisplayTheme.accentBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: DisplayTheme.accentBlue.withValues(alpha: 0.4)),
            ),
            child: Text(
              'GO TO COUNTER ${item.counterNumber ?? '01'}',
              style: const TextStyle(color: DisplayTheme.accentBlue, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDisplayBoard() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.tv_off_rounded, color: DisplayTheme.textMuted.withValues(alpha: 0.3), size: 96),
          const SizedBox(height: 20),
          const Text('WAITING ROOM QUEUE CLEAR', style: TextStyle(color: DisplayTheme.textMuted, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 2.0)),
          const SizedBox(height: 8),
          const Text('New token calls will flash here automatically', style: TextStyle(color: DisplayTheme.accentBlue, fontSize: 14)),
        ],
      ),
    );
  }

  /// Live Ticker Footer
  Widget _buildLiveFooterTicker() {
    return Container(
      height: 48,
      color: DisplayTheme.bgCard,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: DisplayTheme.textMuted, size: 18),
          SizedBox(width: 12),
          Text('Please keep your ticket ready and proceed promptly to the indicated counter when called.', style: TextStyle(color: DisplayTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
          Spacer(),
          Text('Powered by AntiGravity Enterprise DQMS', style: TextStyle(color: DisplayTheme.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}
