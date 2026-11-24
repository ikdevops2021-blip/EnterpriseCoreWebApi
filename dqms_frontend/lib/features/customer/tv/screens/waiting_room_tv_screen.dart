import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/models/customer_models.dart';
import 'package:dqms_frontend/core/services/dqms_audio_voice_service.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/theme/app_decorations.dart';
import 'package:dqms_frontend/core/theme/app_typography.dart';
import 'package:dqms_frontend/core/theme/app_breakpoints.dart';
import 'package:dqms_frontend/core/widgets/glass_widgets.dart';
import 'package:dqms_frontend/core/widgets/language_selector_dropdown.dart';
import 'package:dqms_frontend/features/customer/providers/customer_providers.dart';
import '../widgets/emergency_broadcast_overlay.dart';
import '../widgets/signage_media_zone.dart';
import '../../../admin/providers/signage_provider.dart';

/// ============================================================================
/// WAITING ROOM 4K TV DISPLAY SCREEN (WaitingRoomTvScreen)
/// Left-Side Split Layout (Option A):
/// - Top-Left (52%): NOW CALLING Hero Capsule with audio voice triggering
/// - Bottom-Left (48%): Digital Signage & Google Ads Media Zone
/// - Top-Right (38%): Active Counter Stations Matrix
/// - Bottom-Right (62%): Live Upcoming Queue & On-Hold Status Matrix
/// Modern luxury glassmorphism surfaces, cyan/emerald ambient aura & high visibility.
/// ============================================================================
class WaitingRoomTvScreen extends ConsumerStatefulWidget {
  const WaitingRoomTvScreen({super.key});

  @override
  ConsumerState<WaitingRoomTvScreen> createState() => _WaitingRoomTvScreenState();
}

class _WaitingRoomTvScreenState extends ConsumerState<WaitingRoomTvScreen> {
  bool _isAudioEnabled = false;
  String? _lastAnnouncedKey;

  Future<void> _triggerAnnouncement(DisplayBoardItemDto item) async {
    if (!_isAudioEnabled) return;
    String? nextToken;
    try {
      nextToken = await ref.read(nextWaitingTokenProvider.future);
    } catch (_) {}

    DqmsAudioVoiceService().announceToken(
      tokenNumber: item.tokenNumber,
      counterName: item.counterNumber ?? 'C-01',
      primaryLanguageCode: 'en',
      nextTokenNumber: nextToken,
    );
  }

  void _toggleAudio([DisplayBoardItemDto? heroItem]) {
    DqmsAudioVoiceService().unlockAudio();
    setState(() {
      _isAudioEnabled = !_isAudioEnabled;
    });
    if (_isAudioEnabled && heroItem != null) {
      _triggerAnnouncement(heroItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<PublicDisplayBoardDto>>(displayBoardProvider, (previous, next) {
      final board = next.value;
      final list = board?.activeCalls ?? [];
      if (list.isNotEmpty) {
        final top = list.first;
        final key = '${top.tokenNumber}_${top.counterNumber}_${top.calledTime}_${top.flashAlert}';
        if (key != _lastAnnouncedKey) {
          _lastAnnouncedKey = key;
          _triggerAnnouncement(top);
        }
      }
    });

    final boardAsync = ref.watch(displayBoardProvider);
    final playlistAsync = ref.watch(activePlaylistProvider(1));
    final emergencyAsync = ref.watch(activeEmergencyProvider(1));
    final isMobile = AppBreakpoints.isMobile(context);

    final board = boardAsync.value ?? PublicDisplayBoardDto.empty();
    final mediaItems = playlistAsync.value ?? [];
    final activeCalls = board.activeCalls;
    final upcomingQueue = board.upcomingQueue;
    final emergencyAlert = emergencyAsync.value;

    final DisplayBoardItemDto? heroItem = activeCalls.isNotEmpty ? activeCalls.first : null;
    final heldTokens = upcomingQueue.where((t) => t.tokenStatus == 18005).toList();

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (!_isAudioEnabled) {
            _toggleAudio(heroItem);
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Modern Frosted TV Header Bar
              _buildTvHeader(heroItem),

              // Emergency Broadcast Overlay (High Priority Strobe Banner)
              if (emergencyAlert != null && emergencyAlert.isActive)
                EmergencyBroadcastOverlay(broadcast: emergencyAlert),

              // TV Main Body (Option A: Left-Side Split Layout)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: isMobile
                      ? SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildNowCallingHero(heroItem),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: SignageMediaZone(
                                  items: mediaItems,
                                  isDucked: heroItem != null && heroItem.flashAlert,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 240,
                                child: _buildActiveCountersPanel(activeCalls),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 380,
                                child: _buildUpcomingQueuePanel(upcomingQueue),
                              ),
                            ],
                          ),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Left Column (flex: 6): NOW CALLING Hero (Top 52%) + Signage/Ads (Bottom 48%)
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Top: NOW CALLING Hero Capsule (52%)
                                  Expanded(
                                    flex: 52,
                                    child: _buildNowCallingHero(heroItem),
                                  ),
                                  const SizedBox(height: 16),

                                  // Bottom: Digital Signage & Google Ads Media Zone (48%)
                                  Expanded(
                                    flex: 48,
                                    child: SignageMediaZone(
                                      items: mediaItems,
                                      isDucked: heroItem != null && heroItem.flashAlert,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),

                            // Right Column (flex: 6): Active Counters (Top 38%) + Upcoming Queue Matrix (Bottom 62%)
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Active Counter Stations Matrix (Top 38%)
                                  Expanded(
                                    flex: 38,
                                    child: _buildActiveCountersPanel(activeCalls),
                                  ),
                                  const SizedBox(height: 16),

                                  // Live Upcoming Queue & Status Matrix (Bottom 62%)
                                  Expanded(
                                    flex: 62,
                                    child: _buildUpcomingQueuePanel(upcomingQueue),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              // Bottom Dynamic Ticker Bar
              _buildBottomTickerBar(heldTokens),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTvHeader(DisplayBoardItemDto? heroItem) {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      height: 64,
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 18),
            const Text(
              'DQMS Medical Center HQ • Waiting Lounge TV Monitor',
              style: TextStyle(color: AppColors.textMain, fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 22),

            // Interactive Audio Announcement Toggle Button
            InkWell(
              onTap: () => _toggleAudio(heroItem),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _isAudioEnabled
                      ? AppColors.statusActive.withValues(alpha: 0.2)
                      : AppColors.statusWarning.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: _isAudioEnabled ? AppColors.statusActive : AppColors.statusWarning,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isAudioEnabled ? AppColors.statusActive : AppColors.statusWarning).withValues(alpha: 0.35),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isAudioEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      color: _isAudioEnabled ? AppColors.statusActive : AppColors.statusWarning,
                      size: 16,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      _isAudioEnabled ? 'AUDIO LIVE' : 'CLICK TO ENABLE AUDIO',
                      style: TextStyle(
                        color: _isAudioEnabled ? AppColors.statusActive : AppColors.statusWarning,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.glassSurfaceDark,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.glassBorderLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_filled_rounded, color: AppColors.cyanGlow, size: 16),
                  const SizedBox(width: 7),
                  Text(
                    timeStr,
                    style: const TextStyle(
                      color: AppColors.cyanGlow,
                      fontSize: 18,
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

  /// NOW CALLING Hero Panel (High-Visibility Left Card)
  Widget _buildNowCallingHero(DisplayBoardItemDto? item) {
    final token = item?.tokenNumber ?? 'STANDBY';
    final counter = item != null ? 'COUNTER ${item.counterNumber ?? "C-01"}' : 'ALL COUNTERS READY';
    final service = item?.processName ?? 'Waiting for Next Operator Call';
    final isCalling = item != null;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      borderRadius: AppRadius.card,
      borderColor: isCalling ? AppColors.cyanGlow.withValues(alpha: 0.5) : AppColors.glassBorderLight,
      borderWidth: 1.5,
      shadows: [
        BoxShadow(
          color: (isCalling ? AppColors.cyanGlow : AppColors.brandPrimary).withValues(alpha: 0.2),
          blurRadius: 28,
          spreadRadius: 2,
        ),
      ],
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Audio Voice Announcement Pill
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isCalling ? AppColors.emeraldSuccess : AppColors.cyanGlow).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: isCalling ? AppColors.emeraldSuccess : AppColors.cyanGlow, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: (isCalling ? AppColors.emeraldSuccess : AppColors.cyanGlow).withValues(alpha: 0.25),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCalling ? Icons.campaign_rounded : Icons.radio_button_checked_rounded,
                        color: isCalling ? AppColors.emeraldSuccess : AppColors.cyanGlow,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isCalling ? 'NOW CALLING' : 'READY FOR SERVICE',
                        style: TextStyle(
                          color: isCalling ? AppColors.emeraldSuccess : AppColors.cyanGlow,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Giant Token Number Capsule
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGlassHighlight,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.glassBorderLight),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyanGlow.withValues(alpha: 0.15),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: Text(
                    token,
                    style: AppTypography.tokenHero.copyWith(
                      fontSize: 72,
                      color: AppColors.cyanGlow,
                      letterSpacing: 3.0,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Directional Arrow & Assigned Counter Capsule
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppColors.servingGradient,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyanGlow.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        counter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Service Location Name
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  service,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Active Counter Stations Panel (Top Right Section)
  Widget _buildActiveCountersPanel(List<DisplayBoardItemDto> calls) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: AppRadius.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GlassSquircleIcon(
                icon: Icons.meeting_room_rounded,
                backgroundColor: AppColors.darkBlueIconBg,
                iconColor: AppColors.emeraldSuccess,
                size: 32,
                iconSize: 16,
              ),
              const SizedBox(width: 10),
              const Text(
                'ACTIVE COUNTER STATIONS',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.emeraldSuccess.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.emeraldSuccess.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '${calls.length} In-Service',
                  style: const TextStyle(
                    color: AppColors.emeraldSuccess,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Active Stations List
          Expanded(
            child: calls.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.desk_rounded, size: 28, color: AppColors.textSubtle.withValues(alpha: 0.4)),
                        const SizedBox(height: 6),
                        const Text(
                          'All counter stations standby',
                          style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: calls.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (ctx, i) {
                      final call = calls[i];
                      final isCallingStatus = call.tokenStatus == 18003;

                      return GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        borderRadius: AppRadius.md,
                        borderColor: isCallingStatus
                            ? AppColors.emeraldSuccess.withValues(alpha: 0.4)
                            : AppColors.glassBorderLight,
                        child: Row(
                          children: [
                            // Counter Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.brandPrimary.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                                border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                call.counterNumber ?? 'C-01',
                                style: const TextStyle(
                                  color: AppColors.cyanGlow,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Arrow Indicator
                            const Icon(Icons.arrow_forward_rounded, color: AppColors.cyanGlow, size: 14),
                            const SizedBox(width: 10),

                            // Token Number
                            Text(
                              call.tokenNumber,
                              style: const TextStyle(
                                color: AppColors.textMain,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const Spacer(),

                            // Status Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(
                                color: (isCallingStatus ? AppColors.emeraldSuccess : AppColors.brandPrimary)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                                border: Border.all(
                                  color: isCallingStatus ? AppColors.emeraldSuccess : AppColors.cyanGlow,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isCallingStatus) ...[
                                    const Icon(Icons.volume_up_rounded, color: AppColors.emeraldSuccess, size: 12),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    isCallingStatus ? 'CALLING' : 'SERVING',
                                    style: TextStyle(
                                      color: isCallingStatus ? AppColors.emeraldSuccess : AppColors.cyanGlow,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
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

  /// Live Upcoming Queue & On-Hold Status Matrix (Bottom Right Section)
  Widget _buildUpcomingQueuePanel(List<DisplayBoardQueueItemDto> queue) {
    final waitingTokens = queue.where((t) => t.tokenStatus == 18001 || t.tokenStatus == 18002).toList();
    final heldTokens = queue.where((t) => t.tokenStatus == 18005).toList();

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: AppRadius.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GlassSquircleIcon(
                icon: Icons.format_list_numbered_rounded,
                backgroundColor: AppColors.darkBlueIconBg,
                iconColor: AppColors.brandPrimary,
                size: 32,
                iconSize: 16,
              ),
              const SizedBox(width: 10),
              const Text(
                'UPCOMING QUEUE & STATUS',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              // Queue Count Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${waitingTokens.length} Waiting • ${heldTokens.length} On Hold',
                  style: const TextStyle(
                    color: AppColors.cyanGlow,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Queue Items List
          Expanded(
            child: queue.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.queue_rounded, size: 32, color: AppColors.textSubtle.withValues(alpha: 0.4)),
                        const SizedBox(height: 6),
                        const Text(
                          'No patients waiting in queue',
                          style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: queue.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (ctx, i) {
                      final item = queue[i];
                      final isHold = item.tokenStatus == 18005;
                      final isVip = item.priorityTier >= 19003;
                      final isSenior = item.priorityTier == 19002;

                      // Calculate waiting position among waiting-only tokens
                      int waitPos = 0;
                      if (!isHold) {
                        waitPos = waitingTokens.indexWhere((t) => t.id == item.id) + 1;
                      }

                      return GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        borderRadius: AppRadius.md,
                        borderColor: isHold
                            ? AppColors.statusWarning.withValues(alpha: 0.5)
                            : (isVip
                                ? AppColors.brandAccent.withValues(alpha: 0.4)
                                : AppColors.glassBorderLight),
                        child: Row(
                          children: [
                            // Token Number
                            Text(
                              item.tokenNumber,
                              style: TextStyle(
                                color: isHold ? AppColors.statusWarning : AppColors.textMain,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Priority Tier Badge (VIP / Senior)
                            if (isVip)
                              Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.brandAccent.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.brandAccent.withValues(alpha: 0.6)),
                                ),
                                child: const Text(
                                  'VIP',
                                  style: TextStyle(
                                    color: AppColors.brandAccent,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              )
                            else if (isSenior)
                              Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.cyanGlow.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.cyanGlow.withValues(alpha: 0.5)),
                                ),
                                child: const Text(
                                  'SENIOR',
                                  style: TextStyle(
                                    color: AppColors.cyanGlow,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),

                            // Department Name
                            Expanded(
                              child: Text(
                                item.processName,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Status Badge: WAITING #X or ON HOLD
                            if (isHold)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.statusWarning.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                  border: Border.all(color: AppColors.statusWarning, width: 1.2),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.pause_circle_filled_rounded, color: AppColors.statusWarning, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      item.counterNumber != null ? 'ON HOLD (${item.counterNumber})' : 'ON HOLD',
                                      style: const TextStyle(
                                        color: AppColors.statusWarning,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.brandPrimary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                  border: Border.all(color: AppColors.cyanGlow.withValues(alpha: 0.5), width: 1.0),
                                ),
                                child: Text(
                                  'WAITING #$waitPos',
                                  style: const TextStyle(
                                    color: AppColors.cyanGlow,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
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

  /// Bottom Announcement Ticker Bar with Dynamic On-Hold Notice
  Widget _buildBottomTickerBar(List<DisplayBoardQueueItemDto> heldTokens) {
    String tickerText = 'Welcome to DQMS Medical Center. Please keep your ticket until your number is announced on screen.';
    if (heldTokens.isNotEmpty) {
      final numbers = heldTokens.map((t) => t.tokenNumber).join(', ');
      tickerText = 'NOTICE: Token(s) $numbers are paused on hold. If you have returned to the lounge, please contact your counter staff.  •  Welcome to DQMS Medical Center.';
    }

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.bgHeader,
        border: const Border(top: BorderSide(color: AppColors.glassBorderLight, width: 1.0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.cyanGlow.withValues(alpha: 0.5)),
            ),
            child: const Row(
              children: [
                Icon(Icons.volume_up_rounded, color: AppColors.cyanGlow, size: 14),
                SizedBox(width: 5),
                Text(
                  'NOTICE',
                  style: TextStyle(color: AppColors.cyanGlow, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              tickerText,
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 12,
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
