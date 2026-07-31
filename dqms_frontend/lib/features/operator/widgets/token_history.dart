import 'package:flutter/material.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/features/operator/providers/operator_console_provider.dart';

/// ============================================================================
/// TOKEN HISTORY STEP TIMELINE (TokenHistory)
/// Audit timeline log of process steps for the active operational ticket
/// ============================================================================
class TokenHistory extends StatelessWidget {
  final List<TokenHistoryStep> historySteps;

  const TokenHistory({
    super.key,
    required this.historySteps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_toggle_off_rounded, color: AppColors.brandAccent, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'TOKEN PROCESS AUDIT TRAIL',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (historySteps.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No process steps recorded for current token.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: historySteps.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final step = historySteps[i];
                final isLast = i == historySteps.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline Node Dot
                    Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: isLast ? AppColors.brandPrimary : AppColors.statusActive,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),

                    // Step Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.stepName,
                            style: TextStyle(
                              color: isLast ? AppColors.brandPrimary : AppColors.textMain,
                              fontSize: 12,
                              fontWeight: isLast ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                step.timestamp,
                                style: const TextStyle(
                                  color: AppColors.textSubtle,
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '•  Duration: ${step.durationStr}',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 10,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
