import 'package:flutter/material.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/theme/app_decorations.dart';
import 'package:dqms_frontend/core/widgets/glass_widgets.dart';
import 'package:dqms_frontend/features/operator/widgets/hotkey_hint.dart';

/// ============================================================================
/// OPERATOR ACTION BAR (OperatorActionBar)
/// Keyboard-first action bar with visually dominant CALL NEXT primary trigger
/// Modernized with luxury glass surface, gradient action buttons & tactile feedback
/// ============================================================================
class OperatorActionBar extends StatelessWidget {
  final VoidCallback onCallNext;
  final VoidCallback onRecall;
  final VoidCallback onServe;
  final VoidCallback onHold;
  final VoidCallback onComplete;
  final VoidCallback onCancel;
  final bool hasActiveToken;

  const OperatorActionBar({
    super.key,
    required this.onCallNext,
    required this.onRecall,
    required this.onServe,
    required this.onHold,
    required this.onComplete,
    required this.onCancel,
    required this.hasActiveToken,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: AppRadius.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.keyboard_alt_outlined, color: AppColors.cyanGlow, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'EXPRESS OPERATOR ACTIONS (KEYBOARD SHORTCUTS ENABLED)',
                  style: TextStyle(
                    color: AppColors.textSubtle,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Primary Dominant Action: CALL NEXT
          SizedBox(
            width: double.infinity,
            height: 54,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF059669),
                    Color(0xFF10B981),
                    Color(0xFF06B6D4),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emeraldSuccess.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                ),
                onPressed: onCallNext,
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.campaign_rounded, size: 24, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'CALL NEXT CUSTOMER',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      HotkeyHint(keyLabel: 'SPACE / F1', isPrimary: true),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Secondary Action Grid (RECALL, SERVE, HOLD, COMPLETE, CANCEL)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // RECALL (F2)
                SizedBox(
                  width: 110,
                  child: _buildSecondaryActionButton(
                    label: 'RECALL',
                    hotkey: 'F2',
                    icon: Icons.replay_rounded,
                    color: AppColors.cyanGlow,
                    onPressed: hasActiveToken ? onRecall : null,
                  ),
                ),
                const SizedBox(width: 8),

                // SERVE (F3)
                SizedBox(
                  width: 110,
                  child: _buildSecondaryActionButton(
                    label: 'SERVE',
                    hotkey: 'F3',
                    icon: Icons.play_arrow_rounded,
                    color: AppColors.brandPrimary,
                    onPressed: hasActiveToken ? onServe : null,
                  ),
                ),
                const SizedBox(width: 8),

                // HOLD (F4)
                SizedBox(
                  width: 110,
                  child: _buildSecondaryActionButton(
                    label: 'HOLD',
                    hotkey: 'F4',
                    icon: Icons.pause_rounded,
                    color: AppColors.statusSpecial,
                    onPressed: hasActiveToken ? onHold : null,
                  ),
                ),
                const SizedBox(width: 8),

                // COMPLETE (F5)
                SizedBox(
                  width: 115,
                  child: _buildSecondaryActionButton(
                    label: 'COMPLETE',
                    hotkey: 'F5',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.emeraldSuccess,
                    onPressed: hasActiveToken ? onComplete : null,
                  ),
                ),
                const SizedBox(width: 8),

                // CANCEL (F7)
                SizedBox(
                  width: 115,
                  child: _buildSecondaryActionButton(
                    label: 'NO-SHOW',
                    hotkey: 'F7',
                    icon: Icons.cancel_outlined,
                    color: AppColors.statusDeactive,
                    onPressed: hasActiveToken ? onCancel : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryActionButton({
    required String label,
    required String hotkey,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    final isDisabled = onPressed == null;

    return SizedBox(
      height: 44,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          disabledForegroundColor: AppColors.textDisabled,
          side: BorderSide(
            color: isDisabled ? AppColors.borderSubtle : color.withValues(alpha: 0.6),
            width: 1.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          backgroundColor: isDisabled ? AppColors.glassSurfaceDarkSubtle : color.withValues(alpha: 0.10),
        ),
        onPressed: onPressed,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isDisabled ? AppColors.textDisabled : color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDisabled ? AppColors.textDisabled : color,
                ),
              ),
              const SizedBox(width: 4),
              HotkeyHint(keyLabel: hotkey, isPrimary: false),
            ],
          ),
        ),
      ),
    );
  }
}
