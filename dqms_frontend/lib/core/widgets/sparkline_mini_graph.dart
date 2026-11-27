import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// ============================================================================
/// SPARKLINE MINI GRAPH
/// Ultra-compact 7-day canvas micro-chart for table rows and metric cards.
/// Draws a smooth cubic Bezier curve with an ambient gradient area fill.
/// ============================================================================
class SparklineMiniGraph extends StatelessWidget {
  final List<double> values;
  final double width;
  final double height;
  final Color? lineColor;
  final double lineWidth;

  const SparklineMiniGraph({
    super.key,
    required this.values,
    this.width = 68.0,
    this.height = 24.0,
    this.lineColor,
    this.lineWidth = 1.8,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return SizedBox(width: width, height: height);

    final resolvedColor = lineColor ?? AppColors.brandPrimary;

    return CustomPaint(
      size: Size(width, height),
      painter: _SparklinePainter(
        values: values,
        lineColor: resolvedColor,
        lineWidth: lineWidth,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final double lineWidth;

  _SparklinePainter({
    required this.values,
    required this.lineColor,
    required this.lineWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final points = <Offset>[];
    final dx = size.width / (values.length - 1);

    for (int i = 0; i < values.length; i++) {
      final normalized = (values[i] - minVal) / range;
      // Invert Y so highest value is at the top
      final y = size.height - (normalized * (size.height - 4)) - 2;
      points.add(Offset(i * dx, y));
    }

    // Build smooth cubic bezier path
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    // Gradient fill under the curve
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, size.height),
        [
          lineColor.withValues(alpha: 0.28),
          lineColor.withValues(alpha: 0.0),
        ],
      );
    canvas.drawPath(fillPath, fillPaint);

    // Line stroke
    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    // Endpoint dot
    final endDotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(points.last, lineWidth * 1.2, endDotPaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.lineColor != lineColor;
  }
}
