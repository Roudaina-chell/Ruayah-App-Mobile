import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A quiet eight-point star lattice, built from two overlapping
/// squares — a classic Islamic geometric construction, drawn as a
/// thin, low-opacity line texture.
///
/// This is the app's one deliberate ornamental flourish. It only
/// ever appears on the deep teal hero surfaces, never on light
/// backgrounds, so it reads as a signature rather than decoration
/// scattered everywhere.
class GeometricPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double tileSize;

  GeometricPatternPainter({
    required this.color,
    this.opacity = 0.07,
    this.tileSize = 52,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final rowHeight = tileSize * 0.87;
    final cols = (size.width / tileSize).ceil() + 2;
    final rows = (size.height / rowHeight).ceil() + 2;

    for (var row = -1; row < rows; row++) {
      for (var col = -1; col < cols; col++) {
        final cx = col * tileSize + (row.isOdd ? tileSize / 2 : 0);
        final cy = row * rowHeight;
        _drawStar(canvas, paint, Offset(cx, cy), tileSize * 0.4);
      }
    }
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double r) {
    final squareA = Path();
    final squareB = Path();
    for (var i = 0; i < 4; i++) {
      final angleA = (math.pi / 2) * i;
      final angleB = angleA + math.pi / 4;
      final pointA = center + Offset(math.cos(angleA) * r, math.sin(angleA) * r);
      final pointB = center + Offset(math.cos(angleB) * r, math.sin(angleB) * r);
      if (i == 0) {
        squareA.moveTo(pointA.dx, pointA.dy);
        squareB.moveTo(pointB.dx, pointB.dy);
      } else {
        squareA.lineTo(pointA.dx, pointA.dy);
        squareB.lineTo(pointB.dx, pointB.dy);
      }
    }
    squareA.close();
    squareB.close();
    canvas.drawPath(squareA, paint);
    canvas.drawPath(squareB, paint);
  }

  @override
  bool shouldRepaint(covariant GeometricPatternPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.opacity != opacity ||
      oldDelegate.tileSize != tileSize;
}

/// Convenience wrapper — drop into a [Stack] over a dark hero surface.
class GeometricPatternBackground extends StatelessWidget {
  final Color color;
  final double opacity;

  const GeometricPatternBackground({
    super.key,
    this.color = Colors.white,
    this.opacity = 0.07,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: GeometricPatternPainter(color: color, opacity: opacity),
        ),
      ),
    );
  }
}