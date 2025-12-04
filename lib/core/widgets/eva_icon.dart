import 'dart:math';
import 'package:finance_app/core/config/app_colors.dart';
import 'package:flutter/material.dart';

class EvaIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool animate;

  const EvaIcon(
    this.icon, {
    super.key,
    this.color = AppColors.primary,
    this.size = 24.0,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HexagonBorderPainter(color: color),
      child: Container(
        width: size * 2,
        height: size * 2,
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: color,
          size: size,
        ),
      ),
    );
  }
}

class _HexagonBorderPainter extends CustomPainter {
  final Color color;

  _HexagonBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final path = Path();
    for (int i = 0; i < 6; i++) {
      final double angle = (60 * i - 30) * (pi / 180);
      final double x = center.dx + radius * cos(angle);
      final double y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
    
    // Decorative dots
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(Offset(center.dx, center.dy - radius), 2, dotPaint);
    canvas.drawCircle(Offset(center.dx, center.dy + radius), 2, dotPaint);
  }

  @override
  bool shouldRepaint(_HexagonBorderPainter oldDelegate) => false;
}
