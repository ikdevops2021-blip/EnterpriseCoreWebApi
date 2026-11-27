import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// ============================================================================
/// CIRCULAR SLA PROGRESS RING
/// Precision canvas gauge for token SLA tracking with 3-tier state transition:
/// - Mint Emerald (< 70% elapsed SLA)
/// - High-Vis Amber Warning (70% - 99% elapsed SLA)
/// - Crimson Pulse (> 100% SLA Breach)
/// ============================================================================
class CircularSlaProgressRing extends StatefulWidget {
  final double progress; // 0.0 to 1.0+ (values > 1.0 indicate breach)
  final double size;
  final double strokeWidth;
  final String? centerLabel;
  final String? subLabel;
  final bool animateBreach;

  const CircularSlaProgressRing({
    super.key,
    required this.progress,
    this.size = 54.0,
    this.strokeWidth = 4.5,
    this.centerLabel,
    this.subLabel,
    this.animateBreach = true,
  });

  @override
  State<CircularSlaProgressRing> createState() => _CircularSlaProgressRingState();
}

class _CircularSlaProgressRingState extends State<CircularSlaProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _resolveRingColor(double progress) {
    if (progress >= 1.0) {
      return const Color(0xFFFF4D4F); // Crimson Alert
    } else if (progress >= 0.70) {
      return AppColors.amberWarning; // Amber Warning
    } else {
      return AppColors.mintEmerald; // Mint Emerald
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBreached = widget.progress >= 1.0;
    final ringColor = _resolveRingColor(widget.progress);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glowOpacity = isBreached && widget.animateBreach
            ? 0.3 + (_pulseController.value * 0.4)
            : 0.0;

        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: glowOpacity > 0
                ? [
                    BoxShadow(
                      color: ringColor.withValues(alpha: glowOpacity),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: CustomPaint(
            painter: _SlaRingPainter(
              progress: widget.progress.clamp(0.0, 1.0),
              color: ringColor,
              strokeWidth: widget.strokeWidth,
              backgroundColor: AppColors.borderSubtle.withValues(alpha: 0.4),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.centerLabel != null)
                    Text(
                      widget.centerLabel!,
                      style: AppTypography.timerDisplay.copyWith(
                        fontSize: (widget.size * 0.22).clamp(10.0, 18.0),
                        fontWeight: FontWeight.w800,
                        color: ringColor,
                      ),
                    ),
                  if (widget.subLabel != null)
                    Text(
                      widget.subLabel!,
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: (widget.size * 0.14).clamp(8.0, 11.0),
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SlaRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final Color backgroundColor;

  _SlaRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track background
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Active progress arc
    final sweepAngle = 2 * math.pi * progress;
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start at top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SlaRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
