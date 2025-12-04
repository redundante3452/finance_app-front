import 'dart:math';
import 'package:finance_app/core/config/app_colors.dart';
import 'package:flutter/material.dart';

class HexagonBackground extends StatefulWidget {
  final Widget child;
  const HexagonBackground({super.key, required this.child});

  @override
  State<HexagonBackground> createState() => _HexagonBackgroundState();
}

class _HexagonBackgroundState extends State<HexagonBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Color
        Container(color: AppColors.background),
        
        // Hexagon Grid
        Positioned.fill(
          child: CustomPaint(
            painter: HexagonGridPainter(
              animation: _controller,
              color: AppColors.primary.withOpacity(0.05),
            ),
          ),
        ),
        
        // Content
        widget.child,
      ],
    );
  }
}

class HexagonGridPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  HexagonGridPainter({required this.animation, required this.color})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double hexSize = 40.0;
    final double width = sqrt(3) * hexSize;
    final double height = 2 * hexSize;
    final double xOffset = width;
    final double yOffset = height * 0.75;

    final int cols = (size.width / width).ceil() + 2;
    final int rows = (size.height / yOffset).ceil() + 2;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final double xPos = (col * xOffset) + ((row % 2) * (width / 2));
        final double yPos = row * yOffset;

        // Simple animation effect: fade in/out based on position and time
        final double wave = sin((xPos / 100) + (yPos / 100) + (animation.value * 2 * pi));
        final double opacity = (wave + 1) / 2 * 0.15; // Max opacity 0.15

        paint.color = color.withOpacity(opacity);
        
        _drawHexagon(canvas, Offset(xPos, yPos), hexSize, paint);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final double angle = (60 * i - 30) * (pi / 180);
      final double x = center.dx + size * cos(angle);
      final double y = center.dy + size * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HexagonGridPainter oldDelegate) => true;
}
