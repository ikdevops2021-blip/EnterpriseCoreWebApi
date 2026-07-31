import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dqms_frontend/core/theme/app_colors.dart';
import 'package:dqms_frontend/core/widgets/dqms_button.dart';
import 'package:dqms_frontend/features/customer/providers/customer_experience_provider.dart';

/// ============================================================================
/// MOBILE TICKET TRACKER SCREEN (MobileTrackerScreen)
/// Personal mobile ticket status view with high-visibility "PROCEED TO COUNTER" banner
/// ============================================================================
class MobileTrackerScreen extends ConsumerWidget {
  const MobileTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketState = ref.watch(mobileTicketStateProvider);
    final notifier = ref.read(mobileTicketStateProvider.notifier);
    final isCalling = ticketState.status == 'Calling';

    return Scaffold(
      backgroundColor: AppColors.bgCanvas,
      appBar: AppBar(
        backgroundColor: AppColors.bgHeader,
        title: const Row(
          children: [
            Icon(Icons.phone_iphone_rounded, color: AppColors.brandPrimary, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'DQMS Mobile Tracker',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.brandAccent),
            tooltip: 'Simulate Called/Waiting State',
            onPressed: () => notifier.toggleCallingState(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // High-Visibility CALL BANNER when status is 'Calling'
              if (isCalling) _buildProceedToCounterBanner(ticketState),

              const SizedBox(height: 16),

              // Main Ticket Container Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCalling ? AppColors.statusActive : AppColors.borderSubtle,
                    width: isCalling ? 2 : 1,
                  ),
                  boxShadow: [
                    if (isCalling)
                      BoxShadow(
                        color: AppColors.statusActive.withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                child: Column(
                  children: [
                    // Customer & Service Header
                    Text(
                      ticketState.customerName,
                      style: const TextStyle(color: AppColors.textMain, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticketState.serviceName,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    // Giant Token Display
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Column(
                        children: [
                          const Text('YOUR TOKEN NUMBER', style: TextStyle(color: AppColors.textSubtle, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                          const SizedBox(height: 4),
                          Text(
                            ticketState.tokenNumber,
                            style: const TextStyle(
                              color: AppColors.brandPrimary,
                              fontSize: 54,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Primary Live Metrics (Customers Ahead & Estimated Wait)
                    Row(
                      children: [
                        // Metric 1: Customers Ahead
                        Expanded(
                          child: _buildMetricCard(
                            title: 'CUSTOMERS AHEAD',
                            value: isCalling ? 'NOW!' : '${ticketState.customersAhead}',
                            subtitle: isCalling ? 'Your turn is called' : 'People ahead of you',
                            color: isCalling ? AppColors.statusActive : AppColors.brandAccent,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Metric 2: Estimated Wait Time
                        Expanded(
                          child: _buildMetricCard(
                            title: 'ESTIMATED WAIT',
                            value: isCalling ? '0 Mins' : '~${ticketState.estimatedWaitMins} Mins',
                            subtitle: isCalling ? 'Immediate Entry' : 'Approximate duration',
                            color: AppColors.textMain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Status & Assigned Counter Details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Assigned Station:', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${ticketState.assignedCounter} (${ticketState.counterName})',
                              style: const TextStyle(color: AppColors.brandPrimary, fontSize: 13, fontWeight: FontWeight.w800),
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              DqmsButton(
                label: 'REFRESH TICKET STATUS',
                icon: Icons.sync_rounded,
                isFullWidth: true,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ticket status refreshed.'), backgroundColor: AppColors.brandPrimary),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// High-Visibility CALL BANNER
  Widget _buildProceedToCounterBanner(MobileTicketState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.statusActive,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.statusActive.withValues(alpha: 0.4),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.campaign_rounded, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'YOUR NUMBER HAS BEEN CALLED!',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'PROCEED TO ${state.assignedCounter}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: AppColors.textSubtle, fontSize: 10, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
