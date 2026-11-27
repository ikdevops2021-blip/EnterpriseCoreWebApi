import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/models/customer_models.dart';
import 'package:dqms_frontend/core/services/dqms_audio_voice_service.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/theme/app_typography.dart';
import 'package:dqms_frontend/core/theme/app_decorations.dart';
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
  ConsumerState<WaitingRoomTvScreen> createState() =>
      _WaitingRoomTvScreenState();
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
    ref.listen<AsyncValue<PublicDisplayBoardDto>>(displayBoardProvider, (
      previous,
      next,
    ) {
      final board = next.value;
      final list = board?.activeCalls ?? [];
      if (list.isNotEmpty) {
        final top = list.first;
        final key =
            '${top.tokenNumber}_${top.counterNumber}_${top.calledTime}_${top.flashAlert}';
        if (key != _lastAnnouncedKey) {
          _lastAnnouncedKey = key;
          _triggerAnnouncement(top);
        }
      }
    });

    final boardAsync = ref.watch(displayBoardProvider);
    final playlistAsync = ref.watch(activePlaylistProvider(1));
    final emergencyAsync = ref.watch(activeEmergencyProvider(1));
    final isCompact = MediaQuery.of(context).size.width < 1024;

    final board = boardAsync.value ?? PublicDisplayBoardDto.empty();
    final mediaItems = playlistAsync.value ?? [];
    final activeCalls = board.activeCalls;
    final upcomingQueue = board.upcomingQueue;
    final emergencyAlert = emergencyAsync.value;

    final DisplayBoardItemDto? heroItem = activeCalls.isNotEmpty
        ? activeCalls.first
        : null;
    final heldTokens = upcomingQueue
        .where((t) => t.tokenStatus == 18005)
        .toList();

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
                  child: isCompact
                      ? SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 280,
                                child: _buildNowCallingHero(heroItem),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: SignageMediaZone(
                                  items: mediaItems,
                                  isDucked:
                                      heroItem != null && heroItem.flashAlert,
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
                                      isDucked:
                                          heroItem != null &&
                                          heroItem.flashAlert,
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
                                    child: _buildActiveCountersPanel(
                                      activeCalls,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Live Upcoming Queue & Status Matrix (Bottom 62%)
                                  Expanded(
                                    flex: 62,
                                    child: _buildUpcomingQueuePanel(
                                      upcomingQueue,
                                    ),
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
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.bgHeader,
        border: const Border(
          bottom: BorderSide(color: AppColors.glassBorderLight, width: 1.0),
        ),
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
                border: Border.all(
                  color: AppColors.cyanGlow.withValues(alpha: 0.6),
                ),
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
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 22),

            // Interactive Audio Announcement Toggle Button
            InkWell(
              onTap: () => _toggleAudio(heroItem),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _isAudioEnabled
                      ? AppColors.statusActive.withValues(alpha: 0.2)
                      : AppColors.statusWarning.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: _isAudioEnabled
                        ? AppColors.statusActive
                        : AppColors.statusWarning,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_isAudioEnabled
                                  ? AppColors.statusActive
                                  : AppColors.statusWarning)
                              .withValues(alpha: 0.35),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isAudioEnabled
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      color: _isAudioEnabled
                          ? AppColors.statusActive
                          : AppColors.statusWarning,
                      size: 16,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      _isAudioEnabled ? 'AUDIO LIVE' : 'CLICK TO ENABLE AUDIO',
                      style: TextStyle(
                        color: _isAudioEnabled
                            ? AppColors.statusActive
                            : AppColors.statusWarning,
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
                  const Icon(
                    Icons.access_time_filled_rounded,
                    color: AppColors.cyanGlow,
                    size: 16,
                  ),
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

  /// NOW CALLING Hero Panel (High-Visibility Left Card matching Image 2)
  Widget _buildNowCallingHero(DisplayBoardItemDto? item) {
    final token = item?.tokenNumber ?? 'STANDBY';
    final counter = item != null
        ? 'COUNTER ${item.counterNumber ?? "C-01"}'
        : 'ALL COUNTERS READY';
    final service =
        item?.processName ?? 'Comprehensive Patient Registration & Triage';
    final isCalling = item != null;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF070F1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isCalling ? const Color(0xFF00E5FF) : AppColors.brandPrimary)
              .withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (isCalling ? const Color(0xFF00E5FF) : AppColors.brandPrimary)
                    .withValues(alpha: 0.16),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Ribbon Banner: Solid Mint Green Header Strap
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF00E5A3), // Bright Teal / Mint Green
            ),
            alignment: Alignment.center,
            child: const Text(
              'NOW CALLING',
              style: TextStyle(
                color: Color(0xFF061520),
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
          ),

          // Hero Body with High-Contrast Typography
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Giant Pure White Token Number with Tabular Figures
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          token,
                          style: AppTypography.tokenHero.copyWith(
                            fontSize: 78,
                            letterSpacing: 2.5,
                            height: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Directional Cyan Pill
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C8FF),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF00C8FF,
                                ).withValues(alpha: 0.4),
                                blurRadius: 14,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Color(0xFF061520),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                counter,
                                style: const TextStyle(
                                  color: Color(0xFF061520),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Service Location Name
                      Text(
                        service,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Active Counter Stations Panel (Top Right Section matching Image 2)
  Widget _buildActiveCountersPanel(List<DisplayBoardItemDto> calls) {
    // Dynamic counter names from active calls with fallback slots
    final dynamicCounterSet = <String>{};
    for (final c in calls) {
      if (c.counterNumber != null && c.counterNumber!.trim().isNotEmpty) {
        dynamicCounterSet.add(c.counterNumber!.trim());
      }
    }
    for (final def in ['C-01', 'C-02', 'C-03', 'C-04']) {
      if (dynamicCounterSet.length < 4) {
        dynamicCounterSet.add(def);
      }
    }
    final defaultCounterNames = dynamicCounterSet.toList();

    return GlassContainer(
      padding: const EdgeInsets.all(14),
      borderRadius: AppRadius.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GlassSquircleIcon(
                      icon: Icons.meeting_room_rounded,
                      backgroundColor: AppColors.darkBlueIconBg,
                      iconColor: AppColors.emeraldSuccess,
                      size: 28,
                      iconSize: 15,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'ACTIVE COUNTER STATIONS',
                      style: TextStyle(
                        color: AppColors.textMain,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.emeraldSuccess.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: AppColors.emeraldSuccess.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  '${calls.length} In-Service',
                  style: const TextStyle(
                    color: AppColors.emeraldSuccess,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 4-Column Counter Tiles Grid
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(defaultCounterNames.length, (index) {
                final counterName = defaultCounterNames[index];
                final matchingCall = calls
                    .where((c) => c.counterNumber == counterName)
                    .firstOrNull;

                final isActive = matchingCall != null;
                final tokenNumber = matchingCall?.tokenNumber;
                final isCalling = matchingCall?.tokenStatus == 18003;

                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0 : 4,
                      right: index == defaultCounterNames.length - 1 ? 0 : 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF0F2B48), Color(0xFF081729)],
                            )
                          : null,
                      color: isActive ? null : const Color(0xFF0D1829),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isActive
                            ? const Color(0xFF00E5FF)
                            : const Color(0xFF1E2F46),
                        width: isActive ? 1.5 : 1.0,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF00E5FF,
                                ).withValues(alpha: 0.25),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 8,
                    ),
                    child: isActive
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '$counterName ➜ $tokenNumber',
                                  style: const TextStyle(
                                    color: Color(0xFF38BDF8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF00E5FF,
                                  ).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF00E5FF),
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  isCalling ? 'CALLING' : 'SERVING',
                                  style: const TextStyle(
                                    color: Color(0xFF38BDF8),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Text(
                              counterName,
                              style: const TextStyle(
                                color: Color(0xFF6B7D96),
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Live Upcoming Queue & Status Matrix (Bottom Right Section matching Image 2)
  Widget _buildUpcomingQueuePanel(List<DisplayBoardQueueItemDto> queue) {
    final waitingTokens = queue
        .where((t) => t.tokenStatus == 18001 || t.tokenStatus == 18002)
        .toList();
    final heldTokens = queue.where((t) => t.tokenStatus == 18005).toList();

    return GlassContainer(
      padding: const EdgeInsets.all(14),
      borderRadius: AppRadius.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GlassSquircleIcon(
                      icon: Icons.format_list_numbered_rounded,
                      backgroundColor: AppColors.darkBlueIconBg,
                      iconColor: AppColors.brandPrimary,
                      size: 28,
                      iconSize: 15,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'UPCOMING QUEUE & STATUS',
                      style: TextStyle(
                        color: AppColors.textMain,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              // Queue Count Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: AppColors.brandPrimary.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '${waitingTokens.length} Waiting • ${heldTokens.length} On Hold',
                  style: const TextStyle(
                    color: AppColors.cyanGlow,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2-Column Grid of Queue Cards
          Expanded(
            child: queue.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.queue_rounded,
                          size: 28,
                          color: AppColors.textSubtle.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'No patients waiting in queue',
                          style: TextStyle(
                            color: AppColors.textSubtle,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (ctx, constraints) {
                      // Take up to 6 items to form the 2x3 grid
                      final displayItems = queue.take(6).toList();

                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.8,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: displayItems.length,
                        itemBuilder: (ctx, i) {
                          final item = displayItems[i];
                          final isHold = item.tokenStatus == 18005;
                          final isVip = item.priorityTier >= 19003;
                          final isSenior = item.priorityTier == 19002;

                          // Waiting position
                          int waitPos = 0;
                          if (!isHold) {
                            waitPos =
                                waitingTokens.indexWhere(
                                  (t) => t.id == item.id,
                                ) +
                                1;
                          }

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF091424),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isHold
                                    ? const Color(
                                        0xFFE5A300,
                                      ).withValues(alpha: 0.7)
                                    : const Color(0xFF1E2D44),
                                width: isHold ? 1.4 : 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Row: Big Token Number + Priority Badge Pill
                                Row(
                                  children: [
                                    Text(
                                      item.tokenNumber,
                                      style: TextStyle(
                                        color: isHold
                                            ? const Color(0xFFFBBF24)
                                            : Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const Spacer(),
                                    if (isHold)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFE5A300,
                                          ).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFE5A300),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Text(
                                          item.counterNumber != null
                                              ? 'ON HOLD (${item.counterNumber})'
                                              : 'ON HOLD',
                                          style: const TextStyle(
                                            color: Color(0xFFFBBF24),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      )
                                    else if (isVip)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFD97706,
                                          ).withValues(alpha: 0.22),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFF59E0B),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: const Text(
                                          'VIP',
                                          style: TextStyle(
                                            color: Color(0xFFFCD34D),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      )
                                    else if (isSenior)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFD97706,
                                          ).withValues(alpha: 0.22),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFF59E0B),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: const Text(
                                          'SENIOR',
                                          style: TextStyle(
                                            color: Color(0xFFFCD34D),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF00E5FF,
                                          ).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(
                                              0xFF00E5FF,
                                            ).withValues(alpha: 0.4),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: const Text(
                                          'STANDARD',
                                          style: TextStyle(
                                            color: Color(0xFF38BDF8),
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 3),

                                // Bottom Row: Department Name + WAITING #X
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.processName,
                                        style: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    if (!isHold && waitPos > 0)
                                      Text(
                                        'WAITING #$waitPos',
                                        style: const TextStyle(
                                          color: Color(0xFFF59E0B),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Bottom Announcement Ticker Bar with Dynamic On-Hold Notice matching Image 2
  Widget _buildBottomTickerBar(List<DisplayBoardQueueItemDto> heldTokens) {
    String tickerText =
        'Welcome to DQMS Medical Center. Please keep your ticket until your number is announced on screen.';
    if (heldTokens.isNotEmpty) {
      final numbers = heldTokens.map((t) => t.tokenNumber).join(', ');
      tickerText =
          'Token(s) $numbers are paused on hold. If you have returned to the lounge, please contact your counter staff.  •  Welcome to DQMS Medical Center.';
    }

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF070F1E),
        border: Border(
          top: BorderSide(
            color: AppColors.glassBorderLight.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          // High-Contrast Solid White Capsule Pill matching Image 2
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'NOTICE',
              style: TextStyle(
                color: Color(0xFF070F1E),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              tickerText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          // Diamond / Chime Star Accent Icon
          Icon(
            Icons.auto_awesome,
            color: const Color(0xFF00E5FF).withValues(alpha: 0.7),
            size: 16,
          ),
        ],
      ),
    );
  }
}
