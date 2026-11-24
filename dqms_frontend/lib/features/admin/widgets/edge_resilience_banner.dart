import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum EdgeConnectivityStatus {
  cloudOnline,
  edgeAutonomous,
  synchronizing,
}

class EdgeResilienceBanner extends StatelessWidget {
  final EdgeConnectivityStatus status;
  final int pendingJournalCount;
  final String? edgeNodeName;
  final VoidCallback? onSyncPressed;

  const EdgeResilienceBanner({
    super.key,
    required this.status,
    this.pendingJournalCount = 0,
    this.edgeNodeName,
    this.onSyncPressed,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    IconData badgeIcon;
    String statusTitle;
    String statusDescription;

    switch (status) {
      case EdgeConnectivityStatus.cloudOnline:
        badgeColor = AppColors.statusActive;
        badgeIcon = Icons.cloud_done_rounded;
        statusTitle = 'Cloud Connected';
        statusDescription = 'Operating in real-time Cloud SaaS mode';
        break;
      case EdgeConnectivityStatus.edgeAutonomous:
        badgeColor = Colors.orangeAccent;
        badgeIcon = Icons.router_rounded;
        statusTitle = 'Edge Autonomous (Offline)';
        statusDescription = pendingJournalCount > 0
            ? 'Branch LAN operational • $pendingJournalCount offline events queued in local journal'
            : 'Branch LAN operational • Local Edge resilience active';
        break;
      case EdgeConnectivityStatus.synchronizing:
        badgeColor = AppColors.brandPrimary;
        badgeIcon = Icons.sync_rounded;
        statusTitle = 'Reconciling Offline Journal...';
        statusDescription = 'Pushing offline tokens and state transitions to Cloud database';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: badgeColor.withOpacity(0.35), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(badgeIcon, color: badgeColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      statusTitle,
                      style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (edgeNodeName != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '[$edgeNodeName]',
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  statusDescription,
                  style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (status == EdgeConnectivityStatus.edgeAutonomous && onSyncPressed != null) ...[
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: onSyncPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: badgeColor,
                side: BorderSide(color: badgeColor.withOpacity(0.6)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.sync_rounded, size: 14),
              label: const Text('Sync Now', style: TextStyle(fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }
}
