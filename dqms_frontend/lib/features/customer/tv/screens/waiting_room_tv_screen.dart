import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dqms_frontend/core/models/customer_models.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/theme/app_breakpoints.dart';
import 'package:dqms_frontend/features/customer/providers/customer_providers.dart';

/// ============================================================================
/// WAITING ROOM 4K TV DISPLAY SCREEN (WaitingRoomTvScreen)
/// Real-time live TV monitor display prioritizing NOW CALLING & Previous Calls from DB
/// ============================================================================
class WaitingRoomTvScreen extends ConsumerWidget {
  const WaitingRoomTvScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardAsync = ref.watch(displayBoardProvider);
    final isMobile = AppBreakpoints.isMobile(context);

    final items = boardAsync.value ?? [];
    final DisplayBoardItemDto? heroItem = items.isNotEmpty ? items.first : null;
    final List<DisplayBoardItemDto> previousCalls = items.length > 1 ? items.sublist(1) : [];

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
                            _buildNowCallingHero(heroItem),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 300,
                              child: _buildPreviousCallsPanel(previousCalls),
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
                            child: _buildNowCallingHero(heroItem),
                          ),
                          const SizedBox(width: 24),

                          // Previous Calls Matrix Panel (Right Column)
                          Expanded(
                            flex: 5,
                            child: _buildPreviousCallsPanel(previousCalls),
                          ),
                        ],
                      ),
              ),
            ),

            // Bottom Ticker Bar
            _buildBottomTickerBar('Welcome to DQMS Medical Center. Please keep your ticket until your number is announced on screen.'),
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
  Widget _buildNowCallingHero(DisplayBoardItemDto? item) {
    final token = item?.tokenNumber ?? 'STANDBY';
    final counter = item != null ? 'COUNTER ${item.counterNumber ?? "C-01"}' : 'ALL COUNTERS READY';
    final service = item?.processName ?? 'Waiting for Next Operator Call';
    final isCalling = item != null;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCalling ? AppColors.brandPrimary : AppColors.borderSubtle,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCalling ? AppColors.brandPrimary : AppColors.statusActive).withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Audio Voice Announcement Pill (Pulsing Animation)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: (isCalling ? AppColors.statusActive : AppColors.brandAccent).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: isCalling ? AppColors.statusActive : AppColors.brandAccent),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCalling ? Icons.campaign_rounded : Icons.radio_button_checked_rounded,
                      color: isCalling ? AppColors.statusActive : AppColors.brandAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isCalling ? 'NOW CALLING' : 'QUEUE MONITOR LIVE',
                      style: TextStyle(
                        color: isCalling ? AppColors.statusActive : AppColors.brandAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.04, 1.04),
                    duration: 800.ms,
                    curve: Curves.easeInOut,
                  ),
            ),
            const SizedBox(height: 28),

            // Giant Token Number (Smooth Scale & Fade-In on change)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                token,
                style: const TextStyle(
                  color: AppColors.brandPrimary,
                  fontSize: 104,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  letterSpacing: 4.0,
                  height: 1.0,
                ),
              )
                  .animate(key: ValueKey(token))
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1.0, 1.0),
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(),
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
                    counter,
                    style: const TextStyle(
                      color: AppColors.brandAccent,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              )
                  .animate(key: ValueKey(counter))
                  .slideX(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic)
                  .fadeIn(),
            ),
            const SizedBox(height: 20),

            // Service Location Name
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                service,
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
  Widget _buildPreviousCallsPanel(List<DisplayBoardItemDto> calls) {
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
                  'RECENT & ACTIVE CALLS',
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
            child: calls.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.queue_rounded, size: 36, color: AppColors.textSubtle.withValues(alpha: 0.5)),
                        const SizedBox(height: 8),
                        const Text(
                          'No prior calls yet this session',
                          style: TextStyle(color: AppColors.textSubtle, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: calls.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final call = calls[i];

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
                                call.counterNumber ?? 'C-01',
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
                      )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: (50 * i).ms)
                          .slideX(begin: 0.05, end: 0, duration: 300.ms);
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
