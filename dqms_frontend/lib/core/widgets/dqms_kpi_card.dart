import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';
import 'dqms_3d_card.dart';

/// ============================================================================
/// DQMS ENTERPRISE 3D SCI-FI KPI METRIC CARD
/// Compact operational summary metric card with interactive 3D perspective tilt,
/// sci-fi frosted glass backdrop, corner brackets, and animated value transitions.
/// ============================================================================
class DqmsKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;
  final Color accentColor;
  final bool isCompact;

  const DqmsKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.accentColor = AppColors.brandPrimary,
    this.isCompact = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dqms3dCard(
      accentColor: accentColor,
      isScifiGlass: true,
      showCornerBrackets: true,
      enableTilt: true,
      isCompact: isCompact,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Neon Accent Glow Line
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor,
                  accentColor.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isCompact ? AppSpacing.compactPadding : AppSpacing.md),
            child: Row(
              children: [
                // 3D Inset Icon Badge
                Container(
                  padding: EdgeInsets.all(isCompact ? 6.0 : AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: AppRadius.borderXs,
                    border: Border.all(color: accentColor.withValues(alpha: 0.35)),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.2),
                        blurRadius: 6,
                        spreadRadius: 0.5,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: accentColor, size: isCompact ? 18 : 22),
                ),
                SizedBox(width: isCompact ? AppSpacing.sm : AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title.toUpperCase(),
                              style: AppTypography.kpiLabel.copyWith(
                                fontSize: isCompact ? 10 : 11,
                                letterSpacing: 0.8,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Live Micro Status Indicator Dot
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.6),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Animated Numerical Value Transition
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.2),
                              end: Offset.zero,
                            ).animate(animation),
                            child: FadeTransition(opacity: animation, child: child),
                          );
                        },
                        child: Text(
                          value,
                          key: ValueKey<String>(value),
                          style: AppTypography.kpiValue.copyWith(
                            fontSize: isCompact ? 18 : 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          subtitle!,
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 10,
                            color: AppColors.textSubtle,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
}
