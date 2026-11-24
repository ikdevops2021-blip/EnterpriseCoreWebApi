import 'package:flutter/material.dart';
import 'package:dqms_frontend/features/admin/models/signage_models.dart';

/// ============================================================================
/// EMERGENCY PUBLIC BROADCAST OVERLAY WIDGET
/// High-priority visual and auditory alert interrupt taking over public screens.
/// Features pulsating strobe border, high-contrast banner, and emergency directives.
/// ============================================================================
class EmergencyBroadcastOverlay extends StatefulWidget {
  final EmergencyBroadcast? broadcast;
  final VoidCallback? onDismiss;

  const EmergencyBroadcastOverlay({
    super.key,
    required this.broadcast,
    this.onDismiss,
  });

  @override
  State<EmergencyBroadcastOverlay> createState() => _EmergencyBroadcastOverlayState();
}

class _EmergencyBroadcastOverlayState extends State<EmergencyBroadcastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alert = widget.broadcast;
    if (alert == null || !alert.isActive) {
      return const SizedBox.shrink();
    }

    final isCritical = alert.severity >= 3;
    final primaryColor = isCritical
        ? const Color(0xFFFF1744) // Intense Neon Red
        : (alert.severity == 2 ? const Color(0xFFFF9100) : const Color(0xFF00E5FF));

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0F0508).withValues(alpha: 0.94),
            border: Border.all(
              color: primaryColor.withValues(alpha: _glowAnimation.value),
              width: 5.0,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.6 * _glowAnimation.value),
                blurRadius: 36,
                spreadRadius: 6,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: primaryColor,
                    size: 44,
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      '🚨 ${alert.title.toUpperCase()} 🚨',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        fontFamily: 'monospace',
                        shadows: [
                          Shadow(
                            color: primaryColor,
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.warning_amber_rounded,
                    color: primaryColor,
                    size: 44,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  alert.messageText.isNotEmpty
                      ? alert.messageText
                      : 'Please follow facility staff instructions immediately and proceed calmly to the nearest designated exit.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.volume_up_rounded, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'AUDIO SIREN ACTIVE: ${alert.broadcastCode} • ALL COUNTER CALLS SUSPENDED',
                      style: TextStyle(
                        color: primaryColor.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
