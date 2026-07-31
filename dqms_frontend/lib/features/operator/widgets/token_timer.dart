import 'package:flutter/material.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';

/// ============================================================================
/// REUSABLE TOKEN TIMER COMPONENT (TokenTimer)
/// Live elapsed time display with target SLA comparison & variance indicator
/// ============================================================================
class TokenTimer extends StatelessWidget {
  final int elapsedSeconds;
  final int targetSlaMinutes;

  const TokenTimer({
    super.key,
    required this.elapsedSeconds,
    required this.targetSlaMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final elapsedMin = elapsedSeconds ~/ 60;
    final elapsedSec = elapsedSeconds % 60;
    final elapsedStr = '${elapsedMin.toString().padLeft(2, '0')}:${elapsedSec.toString().padLeft(2, '0')}';

    final targetSec = targetSlaMinutes * 60;
    final isBreached = elapsedSeconds > targetSec;
    final varianceSec = (elapsedSeconds - targetSec).abs();
    final varMin = varianceSec ~/ 60;
    final varSec = varianceSec % 60;
    final varianceStr = '${isBreached ? '+' : '-'}${varMin.toString().padLeft(2, '0')}:${varSec.toString().padLeft(2, '0')}';

    final timerColor = isBreached ? AppColors.statusDeactive : AppColors.statusActive;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isBreached ? AppColors.statusDeactive.withValues(alpha: 0.5) : AppColors.borderSubtle),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Elapsed Main Timer
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.timer_outlined, color: AppColors.textSubtle, size: 14),
                    SizedBox(width: 5),
                    Text(
                      'ELAPSED TIME',
                      style: TextStyle(
                        color: AppColors.textSubtle,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  elapsedStr,
                  style: TextStyle(
                    color: timerColor,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Divider
            Container(width: 1, height: 36, color: AppColors.borderSubtle),
            const SizedBox(width: 16),

            // Target SLA
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TARGET SLA',
                  style: TextStyle(
                    color: AppColors.textSubtle,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${targetSlaMinutes.toString().padLeft(2, '0')}:00',
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Divider
            Container(width: 1, height: 36, color: AppColors.borderSubtle),
            const SizedBox(width: 16),

            // SLA Variance
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isBreached ? 'SLA BREACH' : 'SLA MARGIN',
                  style: TextStyle(
                    color: isBreached ? AppColors.statusDeactive : AppColors.brandAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: timerColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    varianceStr,
                    style: TextStyle(
                      color: timerColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
