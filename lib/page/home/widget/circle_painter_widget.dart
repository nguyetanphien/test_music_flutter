import 'package:flutter/material.dart';

class CirclePainterWidget extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radiusStep = size.width / 5; 

    for (int i = 0; i < 5; i++) {
      final Paint paint = Paint()
        ..shader = LinearGradient(
          colors: [Colors.blue.withOpacity((5 - i) / 5), Colors.purple.withOpacity((5 - i) / 5)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Draw the circle with gradient
      canvas.drawCircle(Offset(centerX, centerY), radiusStep * (5 - i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
