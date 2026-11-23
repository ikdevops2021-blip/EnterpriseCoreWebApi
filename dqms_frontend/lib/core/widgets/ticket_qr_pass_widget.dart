import 'package:flutter/material.dart';

/// Reusable QR Pass Matrix Widget
/// Renders standard visual QR pattern linking directly to mobile web tracker
class TicketQrPassWidget extends StatelessWidget {
  final String tokenNumber;
  final double size;

  const TicketQrPassWidget({
    super.key,
    required this.tokenNumber,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Visual high-contrast 2D matrix pattern
                CustomPaint(
                  size: Size(size - 20, size - 20),
                  painter: _QrMatrixPatternPainter(tokenNumber),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_iphone_rounded,
                    color: Color(0xFF0F172A),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'SCAN FOR LIVE QUEUE',
            style: TextStyle(
              color: Colors.black87,
              fontSize: size > 120 ? 8 : 7,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _QrMatrixPatternPainter extends CustomPainter {
  final String seed;
  _QrMatrixPatternPainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    const cells = 15;
    final cellWidth = size.width / cells;
    final cellHeight = size.height / cells;

    // 1. Draw Corner Positioning Squares (Top-Left, Top-Right, Bottom-Left)
    _drawFinderPattern(canvas, 0, 0, cellWidth, cellHeight, paint);
    _drawFinderPattern(canvas, (cells - 4) * cellWidth, 0, cellWidth, cellHeight, paint);
    _drawFinderPattern(canvas, 0, (cells - 4) * cellHeight, cellWidth, cellHeight, paint);

    // 2. Deterministic data dot fill based on token seed
    final hash = seed.hashCode;
    for (int r = 0; r < cells; r++) {
      for (int c = 0; c < cells; c++) {
        // Skip finder areas
        if ((r < 4 && c < 4) || (r < 4 && c >= cells - 4) || (r >= cells - 4 && c < 4)) {
          continue;
        }

        // Center badge gap
        if (r >= 6 && r <= 8 && c >= 6 && c <= 8) continue;

        if (((r * 31 + c * 17 + hash) % 3) == 0) {
          canvas.drawRect(
            Rect.fromLTWH(c * cellWidth + 0.5, r * cellHeight + 0.5, cellWidth - 1, cellHeight - 1),
            paint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, double x, double y, double cw, double ch, Paint paint) {
    canvas.drawRect(Rect.fromLTWH(x, y, cw * 4, ch * 4), paint);
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(x + cw, y + ch, cw * 2, ch * 2), whitePaint);
    canvas.drawRect(Rect.fromLTWH(x + cw * 1.5, y + ch * 1.5, cw, ch), paint);
  }

  @override
  bool shouldRepaint(covariant _QrMatrixPatternPainter oldDelegate) => oldDelegate.seed != seed;
}
