import 'package:flutter/material.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/features/operator/providers/operator_console_provider.dart';

/// ============================================================================
/// OPERATOR CONTEXT PANEL (OperatorContextPanel)
/// Station metadata, active operator profile, & customer special notes
/// ============================================================================
class OperatorContextPanel extends StatelessWidget {
  final String counterNumber;
  final String counterName;
  final String operatorName;
  final int totalServedToday;
  final OperatorTokenModel? activeToken;

  const OperatorContextPanel({
    super.key,
    required this.counterNumber,
    required this.counterName,
    required this.operatorName,
    required this.totalServedToday,
    this.activeToken,
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
          // Station & Operator Card Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.desk_rounded, color: AppColors.brandPrimary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$counterNumber — $counterName',
                      style: const TextStyle(
                        color: AppColors.textMain,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, color: AppColors.textMuted, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          operatorName,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Daily Volume Stat
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.task_alt_rounded, color: AppColors.statusActive, size: 16),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'TOTAL SERVED',
                          style: TextStyle(color: AppColors.textSubtle, fontSize: 11, fontWeight: FontWeight.w800),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$totalServedToday Tokens',
                  style: const TextStyle(
                    color: AppColors.statusActive,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Active Customer Notes & Special Requirements
          if (activeToken != null) ...[
            const Text(
              'CUSTOMER SERVICE NOTES',
              style: TextStyle(
                color: AppColors.textSubtle,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.brandAccent.withValues(alpha: 0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.brandAccent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      activeToken!.notes,
                      style: const TextStyle(
                        color: AppColors.brandAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
