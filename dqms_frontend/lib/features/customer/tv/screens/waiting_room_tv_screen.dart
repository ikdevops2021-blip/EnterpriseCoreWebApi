import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/theme/app_breakpoints.dart';
import 'package:dqms_frontend/features/customer/providers/customer_experience_provider.dart';

/// ============================================================================
/// WAITING ROOM 4K TV DISPLAY SCREEN (WaitingRoomTvScreen)
/// High-visibility 4K TV monitor display prioritizing NOW CALLING & Previous Calls
/// ============================================================================
class WaitingRoomTvScreen extends ConsumerWidget {
  const WaitingRoomTvScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tvState = ref.watch(waitingRoomTvStateProvider);
    final isMobile = AppBreakpoints.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: SafeArea(
        child: Column(
          children: [
            // TV Header Bar
            _buildTvHeader(),

            // TV Main Body Split (Left: NOW CALLING Hero, Right: Previous Calls Matrix)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: isMobile
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildNowCallingHero(tvState),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 300,
                              child: _buildPreviousCallsPanel(tvState),
                            ),
                          ],
                        ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // NOW CALLING Hero Display Card (Left / Center Focus)
                          Expanded(
                            flex: 7,
                            child: _buildNowCallingHero(tvState),
                          ),
                          const SizedBox(width: 24),

                          // Previous Calls Matrix Panel (Right Column)
                          Expanded(
                            flex: 5,
                            child: _buildPreviousCallsPanel(tvState),
                          ),
                        ],
                      ),
              ),
            ),

            // Bottom Ticker Bar
            _buildBottomTickerBar(tvState.tickerText),
          ],
        ),
      ),
    );
  }

  Widget _buildTvHeader() {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: AppColors.bgHeader,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 2)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.brandPrimary),
              ),
              child: const Text(
                'DQMS TV DISPLAY',
                style: TextStyle(
                  color: AppColors.brandPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'DQMS Medical Center HQ • Waiting Lounge TV Monitor',
              style: TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 24),
            Row(
              children: [
                const Icon(Icons.access_time_filled_rounded, color: AppColors.brandAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  timeStr,
                  style: const TextStyle(
                    color: AppColors.brandAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// NOW CALLING Hero Panel
  Widget _buildNowCallingHero(WaitingRoomTvState tvState) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brandPrimary, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandPrimary.withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // Audio Voice Announcement Pill
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.statusActive.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.statusActive),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.campaign_rounded, color: AppColors.statusActive, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'NOW CALLING',
                    style: TextStyle(
                      color: AppColors.statusActive,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Giant Token Number
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              tvState.nowCallingToken,
              style: const TextStyle(
                color: AppColors.brandPrimary,
                fontSize: 104,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                letterSpacing: 4.0,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Directional Arrow & Assigned Counter
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_forward_rounded, color: AppColors.brandAccent, size: 42),
                const SizedBox(width: 14),
                Text(
                  tvState.nowCallingCounter,
                  style: const TextStyle(
                    color: AppColors.brandAccent,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Service Location Name
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              tvState.nowCallingService,
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  /// Previous Calls Matrix Panel
  Widget _buildPreviousCallsPanel(WaitingRoomTvState tvState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_rounded, color: AppColors.textSubtle, size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'PREVIOUS CALLS',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Calls List Matrix
          Expanded(
            child: ListView.separated(
              itemCount: tvState.recentCalls.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final call = tvState.recentCalls[i];

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Token
                        Text(
                          call.tokenNumber,
                          style: const TextStyle(
                            color: AppColors.textMain,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Arrow
                        const Icon(Icons.arrow_forward_rounded, color: AppColors.textSubtle, size: 20),
                        const SizedBox(width: 16),

                        // Counter
                        Text(
                          call.counterNumber,
                          style: const TextStyle(
                            color: AppColors.brandPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'monospace',
                          ),
                        ),
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

  /// Bottom Announcement Ticker Bar
  Widget _buildBottomTickerBar(String tickerText) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.brandPrimary,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              children: [
                Icon(Icons.volume_up_rounded, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'NOTICE',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              tickerText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
