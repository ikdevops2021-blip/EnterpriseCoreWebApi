import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dqms_frontend/features/admin/models/signage_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';

/// ============================================================================
/// DIGITAL SIGNAGE & ADS MEDIA ZONE
/// Multi-zone rotating carousel for promotional videos, image slides,
/// hospital health advisories, and Google Ads / Sponsored Partner broadcasts.
/// Features dwell-time timer, progress bar, audio ducking, and cross-fade transitions.
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

  // Number of default rotating slides (Clinic Welcome, Google Ads, Health Advisory)
  static const int _defaultSlideCount = 3;

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

    int seconds = 12;
    if (widget.items.isNotEmpty) {
      final currentDuration = widget.items[_currentIndex % widget.items.length].durationSeconds;
      seconds = currentDuration > 0 ? currentDuration : 15;
    }

    _rotationTimer = Timer(Duration(seconds: seconds), () {
      if (mounted) {
        setState(() {
          final total = widget.items.isNotEmpty ? widget.items.length : _defaultSlideCount;
          _currentIndex = (_currentIndex + 1) % total;
        });
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return _buildDefaultCarousel();
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
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: AppColors.cyanGlow.withValues(alpha: 0.6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.mediaType == 2 ? Icons.videocam_rounded : Icons.campaign_rounded,
                    color: AppColors.cyanGlow,
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${_currentIndex + 1} / $total • ${item.mediaType == 2 ? "VIDEO" : "CAMPAIGN"}',
                    style: const TextStyle(
                      color: AppColors.cyanGlow,
                      fontSize: 10,
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
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: Colors.amber, width: 1.0),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.volume_mute_rounded, color: Colors.amber, size: 13),
                    SizedBox(width: 4),
                    Text(
                      'AUDIO DUCKED',
                      style: TextStyle(color: Colors.amber, fontSize: 9, fontWeight: FontWeight.w800),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'DQMS Media Network • Next in ${item.durationSeconds}s',
                          style: const TextStyle(
                            color: AppColors.textSubtle,
                            fontSize: 10,
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.brandPrimary.withValues(alpha: 0.3),
            AppColors.bgCanvas,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.mediaType == 2 ? Icons.play_circle_fill_rounded : Icons.image_rounded,
              size: 44,
              color: AppColors.cyanGlow,
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Default Rotating Showcase: Clinic Welcome, Google Ads, and Health Advisory
  Widget _buildDefaultCarousel() {
    final slideIndex = _currentIndex % _defaultSlideCount;

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
          // Animated slide content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: slideIndex == 1
                ? _buildGoogleAdsSlide(key: const ValueKey('slide_google_ads'))
                : (slideIndex == 2
                    ? _buildHealthAdvisorySlide(key: const ValueKey('slide_advisory'))
                    : _buildClinicWelcomeSlide(key: const ValueKey('slide_welcome'))),
          ),

          // Slide Indicator Dots (Bottom Right)
          Positioned(
            bottom: 10,
            right: 14,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_defaultSlideCount, (i) {
                final isCurrent = i == slideIndex;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isCurrent ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.cyanGlow : Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),

          // Audio Ducking Indicator
          if (widget.isDucked)
            Positioned(
              top: 10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: Colors.amber, width: 1.0),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.volume_mute_rounded, color: Colors.amber, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'AUDIO DUCKED',
                      style: TextStyle(color: Colors.amber, fontSize: 9, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Slide 0: Clinic Welcome & General Guidelines
  Widget _buildClinicWelcomeSlide({required Key key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.brandPrimary.withValues(alpha: 0.22),
            AppColors.bgSurface,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.health_and_safety_rounded, size: 42, color: AppColors.cyanGlow.withValues(alpha: 0.85)),
            const SizedBox(height: 10),
            const Text(
              'Welcome to DQMS Medical Center',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Please relax in the waiting lounge. Your token number will be called and announced on screen.',
              style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Slide 1: Google Ads / Sponsored Healthcare Partner Ad
  Widget _buildGoogleAdsSlide({required Key key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A2744), // Deep Navy
            AppColors.bgSurface,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Google Ads Header Bar
          Row(
            children: [
              // Google 4-Color Dots Accent
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _colorDot(const Color(0xFF4285F4)), // Blue
                  _colorDot(const Color(0xFFEA4335)), // Red
                  _colorDot(const Color(0xFFFBBC05)), // Yellow
                  _colorDot(const Color(0xFF34A853)), // Green
                ],
              ),
              const SizedBox(width: 8),
              const Text(
                'Ads by Google',
                style: TextStyle(
                  color: Color(0xFFBDC1C6),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sponsored',
                      style: TextStyle(color: Color(0xFF9AA0A6), fontSize: 9, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: 3),
                    Icon(Icons.info_outline_rounded, color: Color(0xFF9AA0A6), size: 10),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Sponsored Ad Content
          Expanded(
            child: Row(
              children: [
                // Ad Icon / Badge
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4285F4).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: const Color(0xFF4285F4).withValues(alpha: 0.4)),
                  ),
                  child: const Center(
                    child: Icon(Icons.favorite_rounded, color: Color(0xFF4285F4), size: 28),
                  ),
                ),
                const SizedBox(width: 14),

                // Ad Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Annual Comprehensive Health Screening',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Full-body checkup, cardiac ECG & advanced blood panels. 30% off packages this month at reception.',
                        style: TextStyle(
                          color: AppColors.textSubtle,
                          fontSize: 11,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF34A853).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              border: Border.all(color: const Color(0xFF34A853), width: 1.0),
                            ),
                            child: const Text(
                              'Inquire at Reception',
                              style: TextStyle(
                                color: Color(0xFF81C995),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'google.com/ads',
                            style: TextStyle(color: Color(0xFF8AB4F8), fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorDot(Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 2.5),
      width: 5,
      height: 5,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  /// Slide 2: Preventative Health & Wellness Advisory
  Widget _buildHealthAdvisorySlide({required Key key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.emeraldSuccess.withValues(alpha: 0.15),
            AppColors.bgSurface,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.vaccines_rounded, size: 40, color: AppColors.emeraldSuccess),
            const SizedBox(height: 10),
            const Text(
              'Seasonal Flu & Booster Vaccines Available',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Walk-in immunizations available at Immunization Room 104 without an appointment.',
              style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
