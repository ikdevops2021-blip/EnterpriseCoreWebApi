import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/models/customer_models.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/theme/app_decorations.dart';
import 'package:dqms_frontend/core/theme/app_typography.dart';
import 'package:dqms_frontend/core/theme/app_breakpoints.dart';
import 'package:dqms_frontend/core/widgets/glass_widgets.dart';
import 'package:dqms_frontend/core/widgets/language_selector_dropdown.dart';
import 'package:dqms_frontend/features/customer/providers/customer_providers.dart';

/// ============================================================================
/// WAITING ROOM 4K TV DISPLAY SCREEN (WaitingRoomTvScreen)
/// Real-time live TV monitor display prioritizing NOW CALLING & Previous Calls from DB
/// Modern luxury glassmorphism surfaces, cyan/emerald ambient aura & high visibility
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
            // Modern Frosted TV Header Bar
            _buildTvHeader(),

            // TV Main Body Split (Left: NOW CALLING Hero, Right: Previous Calls Matrix)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: isMobile
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildNowCallingHero(heroItem),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 340,
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
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.bgHeader,
        border: const Border(bottom: BorderSide(color: AppColors.glassBorderLight, width: 1.0)),
        boxShadow: AppShadows.subtle,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.cyanGlow.withValues(alpha: 0.6)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cyanGlow.withValues(alpha: 0.25),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Text(
                'DQMS TV DISPLAY',
                style: TextStyle(
                  color: AppColors.cyanGlow,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 20),
            const Text(
              'DQMS Medical Center HQ • Waiting Lounge TV Monitor',
              style: TextStyle(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.glassSurfaceDark,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.glassBorderLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_filled_rounded, color: AppColors.cyanGlow, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    timeStr,
                    style: const TextStyle(
                      color: AppColors.cyanGlow,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const LanguageSelectorDropdown(),
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

    return GlassContainer(
      padding: const EdgeInsets.all(32),
      borderRadius: AppRadius.hero,
      borderColor: isCalling ? AppColors.cyanGlow.withValues(alpha: 0.5) : AppColors.glassBorderLight,
      borderWidth: 1.5,
      shadows: [
        BoxShadow(
          color: (isCalling ? AppColors.cyanGlow : AppColors.brandPrimary).withValues(alpha: 0.2),
          blurRadius: 36,
          spreadRadius: 2,
        ),
      ],
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Audio Voice Announcement Pill
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  color: (isCalling ? AppColors.emeraldSuccess : AppColors.cyanGlow).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: isCalling ? AppColors.emeraldSuccess : AppColors.cyanGlow, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: (isCalling ? AppColors.emeraldSuccess : AppColors.cyanGlow).withValues(alpha: 0.25),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCalling ? Icons.campaign_rounded : Icons.radio_button_checked_rounded,
                      color: isCalling ? AppColors.emeraldSuccess : AppColors.cyanGlow,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'NOW CALLING',
                      style: TextStyle(
                        color: AppColors.emeraldSuccess,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Giant Token Number Capsule
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGlassHighlight,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.glassBorderLight),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyanGlow.withValues(alpha: 0.15),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Text(
                  token,
                  style: AppTypography.tokenHero.copyWith(
                    fontSize: 108,
                    color: AppColors.cyanGlow,
                    letterSpacing: 4.0,
                    height: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Directional Arrow & Assigned Counter Capsule
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.servingGradient,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyanGlow.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 36),
                    const SizedBox(width: 14),
                    Text(
                      counter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Service Location Name
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                service,
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
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
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: AppRadius.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              GlassSquircleIcon(
                icon: Icons.history_rounded,
                backgroundColor: AppColors.darkBlueIconBg,
                iconColor: AppColors.brandPrimary,
                size: 38,
                iconSize: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'PREVIOUS CALLS',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Calls List Matrix
          Expanded(
            child: calls.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.queue_rounded, size: 42, color: AppColors.textSubtle.withValues(alpha: 0.5)),
                        const SizedBox(height: 10),
                        const Text(
                          'No prior calls yet this session',
                          style: TextStyle(color: AppColors.textSubtle, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: calls.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final call = calls[i];

                      return GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        borderRadius: AppRadius.md,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Token
                            Text(
                              call.tokenNumber,
                              style: const TextStyle(
                                color: AppColors.textMain,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Arrow
                            const Icon(Icons.arrow_forward_rounded, color: AppColors.cyanGlow, size: 18),
                            const SizedBox(width: 12),

                            // Counter Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.brandPrimary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                                border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                call.counterNumber ?? 'C-01',
                                style: const TextStyle(
                                  color: AppColors.cyanGlow,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
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
      decoration: BoxDecoration(
        color: AppColors.bgHeader,
        border: const Border(top: BorderSide(color: AppColors.glassBorderLight, width: 1.0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.cyanGlow.withValues(alpha: 0.5)),
            ),
            child: const Row(
              children: [
                Icon(Icons.volume_up_rounded, color: AppColors.cyanGlow, size: 15),
                SizedBox(width: 6),
                Text(
                  'NOTICE',
                  style: TextStyle(color: AppColors.cyanGlow, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              tickerText,
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
