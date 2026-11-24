import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dqms_frontend/features/admin/models/signage_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';

/// ============================================================================
/// DIGITAL SIGNAGE MEDIA ZONE
/// Multi-zone rotating carousel for promotional videos, image slides, and health advisories.
/// Features dwell-time timer, progress bar, and elegant cross-fade transitions.
/// ============================================================================
class SignageMediaZone extends StatefulWidget {
  final List<SignageMediaItem> items;
  final bool isDucked; // True when queue voice chime is sounding

  const SignageMediaZone({
    super.key,
    required this.items,
    this.isDucked = false,
  });

  @override
  State<SignageMediaZone> createState() => _SignageMediaZoneState();
}

class _SignageMediaZoneState extends State<SignageMediaZone> {
  int _currentIndex = 0;
  Timer? _rotationTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant SignageMediaZone oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _currentIndex = 0;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _rotationTimer?.cancel();
    if (widget.items.isEmpty) return;

    final currentDuration = widget.items[_currentIndex % widget.items.length].durationSeconds;
    final seconds = currentDuration > 0 ? currentDuration : 15;

    _rotationTimer = Timer(Duration(seconds: seconds), () {
      if (mounted && widget.items.isNotEmpty) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.items.length;
        });
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return _buildDefaultPromoCard();
    }

    final item = widget.items[_currentIndex % widget.items.length];
    final total = widget.items.length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.glassBorderLight),
        boxShadow: AppShadows.subtle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Media Content Viewer
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: _buildMediaContent(item, key: ValueKey('media_${item.id}_$_currentIndex')),
          ),

          // Top Badge: Slide Tracker & Media Type
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: AppColors.cyanGlow.withValues(alpha: 0.6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.mediaType == 2 ? Icons.videocam_rounded : Icons.campaign_rounded,
                    color: AppColors.cyanGlow,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_currentIndex + 1} / $total • ${item.mediaType == 2 ? "VIDEO" : "ADVISORY"}',
                    style: const TextStyle(
                      color: AppColors.cyanGlow,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Audio Ducking Indicator
          if (widget.isDucked)
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: Colors.amber, width: 1.0),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.volume_mute_rounded, color: Colors.amber, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'AUDIO DUCKED',
                      style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Media Caption Banner
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.9),
                    Colors.black.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title.isNotEmpty ? item.title : 'Digital Signage Broadcast',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'DQMS Enterprise Media Network • Auto-advancing in ${item.durationSeconds}s',
                          style: const TextStyle(
                            color: AppColors.textSubtle,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent(SignageMediaItem item, {required Key key}) {
    final isUrl = item.mediaUrl.startsWith('http://') || item.mediaUrl.startsWith('https://');

    if (item.mediaType == 1 && isUrl) {
      return Image.network(
        item.mediaUrl,
        key: key,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => _buildPlaceholderSlide(item, key: key),
      );
    }

    return _buildPlaceholderSlide(item, key: key);
  }

  Widget _buildPlaceholderSlide(SignageMediaItem item, {required Key key}) {
    return Container(
      key: key,
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.brandPrimary.withValues(alpha: 0.15),
            AppColors.bgSurface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.mediaType == 2 ? Icons.play_circle_fill_rounded : Icons.photo_library_rounded,
              size: 56,
              color: AppColors.cyanGlow.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 14),
            Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.cyanGlow.withValues(alpha: 0.3)),
              ),
              child: Text(
                item.mediaType == 2 ? 'Streaming Rich Video Media' : 'High-Resolution Promotional Slide',
                style: const TextStyle(
                  color: AppColors.cyanGlow,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultPromoCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.glassBorderLight),
      ),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.health_and_safety_rounded, size: 52, color: AppColors.brandPrimary.withValues(alpha: 0.7)),
            const SizedBox(height: 14),
            const Text(
              'Welcome to DQMS Medical Center',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Please relax in the waiting lounge. Your token will be called and announced on this screen shortly.',
              style: TextStyle(color: AppColors.textSubtle, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
