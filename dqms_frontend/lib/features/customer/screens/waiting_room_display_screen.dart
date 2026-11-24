import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/models/customer_models.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/features/customer/providers/customer_providers.dart';

/// ============================================================================
/// WAITING ROOM TV OVERHEAD DISPLAY BOARD
/// 1:1 Matched to Stitch Screen: "DQMS Public TV Queue Display"
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
      backgroundColor: AppColors.bgCanvas,
      body: Column(
        children: [
          _buildTvHeader(),
          Expanded(
            child: displayState.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandPrimary)),
              error: (err, _) => Center(child: Text('Display Error: $err', style: const TextStyle(color: AppColors.statusError))),
              data: (board) {
                final callingItems = board.activeCalls;
                return callingItems.isEmpty
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
                      );
              },
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
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 1.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.tv_rounded, color: AppColors.brandPrimary, size: 20),
                SizedBox(width: 8),
                Text('DQMS DISPLAY', style: TextStyle(color: AppColors.brandPrimary, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
              ],
            ),
          ),
          const SizedBox(width: 20),
          const Text(
            'Main Clinical Facility • Live Overhead Calling Board',
            style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.statusActive.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.statusActive.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.volume_up_rounded, color: AppColors.statusActive, size: 16),
                SizedBox(width: 6),
                Text(
                  'AUDIO CHIME ACTIVE',
                  style: TextStyle(color: AppColors.statusActive, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// High-Visibility Calling Card for TV Grid
  Widget _buildCallingCard(DisplayBoardItemDto item) {
    final isFlashing = item.flashAlert;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFlashing ? AppColors.statusActive : AppColors.brandPrimary.withValues(alpha: 0.5),
          width: isFlashing ? 3 : 1.5,
        ),
        boxShadow: isFlashing
            ? [BoxShadow(color: AppColors.statusActive.withValues(alpha: 0.4), blurRadius: 24, spreadRadius: 3)]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.processName.toUpperCase(),
            style: const TextStyle(color: AppColors.textSubtle, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.2),
          ),
          const Spacer(),
          Text(
            item.tokenNumber,
            style: const TextStyle(
              color: AppColors.brandPrimary,
              fontSize: 64,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
              fontFamily: 'monospace',
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.3)),
            ),
            child: Text(
              'PROCEED TO COUNTER ${item.counterNumber ?? '01'}',
              style: const TextStyle(color: AppColors.brandPrimary, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.0),
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
          Icon(Icons.tv_off_rounded, color: AppColors.textMuted.withValues(alpha: 0.3), size: 96),
          const SizedBox(height: 20),
          const Text('WAITING ROOM QUEUE CLEAR', style: TextStyle(color: AppColors.textMuted, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 2.0)),
          const SizedBox(height: 8),
          const Text('New token calls will flash here automatically', style: TextStyle(color: AppColors.brandPrimary, fontSize: 14)),
        ],
      ),
    );
  }

  /// Live Ticker Footer
  Widget _buildLiveFooterTicker() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.textSubtle, size: 18),
          SizedBox(width: 12),
          Text(
            'Please keep your ticket ready and proceed promptly to the indicated counter station when called.',
            style: TextStyle(color: AppColors.textSubtle, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Spacer(),
          Text('DQMS Enterprise Clinical Suite v4.8', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
