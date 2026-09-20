import 'package:flutter/material.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/theme/app_decorations.dart';
import 'package:dqms_frontend/core/theme/app_typography.dart';
import 'package:dqms_frontend/core/widgets/glass_widgets.dart';
import 'package:dqms_frontend/features/operator/providers/operator_console_provider.dart';
import 'package:dqms_frontend/features/operator/widgets/token_priority_badge.dart';
import 'package:dqms_frontend/features/operator/widgets/token_timer.dart';

/// ============================================================================
/// CURRENT TOKEN PANEL (CurrentTokenPanel)
/// Giant luxury glassmorphic focal card displaying the active operational ticket
/// ============================================================================
class CurrentTokenPanel extends StatelessWidget {
  final OperatorTokenModel? token;

  const CurrentTokenPanel({
    super.key,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    if (token == null) {
      return GlassContainer(
        height: 280,
        padding: const EdgeInsets.all(24),
        borderRadius: AppRadius.card,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlassSquircleIcon(
                icon: Icons.coffee_rounded,
                backgroundColor: AppColors.darkBlueIconBg,
                iconColor: AppColors.brandPrimary,
                size: 54,
                iconSize: 28,
              ),
              SizedBox(height: 16),
              Text(
                'COUNTER IS IDLE',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Press [SPACE / F1] or click "CALL NEXT" to call the next customer.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final activeToken = token!;
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: AppRadius.card,
      borderColor: AppColors.cyanGlow.withValues(alpha: 0.5),
      borderWidth: 1.5,
      shadows: AppShadows.token3dGlow(glowColor: AppColors.cyanGlow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Neon Cyan Accent Glow Stroke
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.cyanGlow,
                  AppColors.brandPrimary,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row: Priority & Status Pill
                Row(
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: TokenPriorityBadge(priority: activeToken.priority),
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: _buildStatusPill(activeToken.status),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Focal Giant Token Number Capsule
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'CURRENT ACTIVE TOKEN',
                        style: TextStyle(
                          color: AppColors.textSubtle,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: AppColors.cardGlassHighlight,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(color: AppColors.glassBorderLight),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyanGlow.withValues(alpha: 0.15),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            activeToken.tokenNumber,
                            style: AppTypography.tokenHero.copyWith(
                              fontSize: 68,
                              color: AppColors.cyanGlow,
                              letterSpacing: 3.0,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${activeToken.customerName} • ${activeToken.customerCategory}',
                        style: const TextStyle(
                          color: AppColors.textMain,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        activeToken.processName,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Live Timer Bar
                TokenTimer(
                  elapsedSeconds: activeToken.elapsedSeconds,
                  targetSlaMinutes: activeToken.targetSlaMinutes,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(OperatorTokenStatus status) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status) {
      case OperatorTokenStatus.calling:
        bg = AppColors.brandPrimary.withValues(alpha: 0.18);
        fg = AppColors.cyanGlow;
        label = 'ANNOUNCING CALL';
        icon = Icons.campaign_rounded;
        break;
      case OperatorTokenStatus.serving:
        bg = AppColors.emeraldSuccess.withValues(alpha: 0.18);
        fg = AppColors.emeraldSuccess;
        label = 'IN SERVICE';
        icon = Icons.play_arrow_rounded;
        break;
      case OperatorTokenStatus.onHold:
        bg = AppColors.statusSpecial.withValues(alpha: 0.18);
        fg = AppColors.statusSpecial;
        label = 'ON HOLD';
        icon = Icons.pause_rounded;
        break;
      case OperatorTokenStatus.completed:
        bg = AppColors.emeraldSuccess.withValues(alpha: 0.18);
        fg = AppColors.emeraldSuccess;
        label = 'COMPLETED';
        icon = Icons.check_circle_rounded;
        break;
      case OperatorTokenStatus.canceled:
        bg = AppColors.statusDeactive.withValues(alpha: 0.18);
        fg = AppColors.statusDeactive;
        label = 'NO-SHOW / CANCELED';
        icon = Icons.close_rounded;
        break;
      default:
        bg = AppColors.bgSubtle;
        fg = AppColors.textSubtle;
        label = 'IDLE';
        icon = Icons.circle_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: fg.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: fg.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
