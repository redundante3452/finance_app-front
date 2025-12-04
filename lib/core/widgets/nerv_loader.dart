import 'dart:math';
import 'package:finance_app/core/config/app_colors.dart';
import 'package:flutter/material.dart';

class NervLoader extends StatefulWidget {
  final double size;
  final Color color;

  const NervLoader({
    super.key,
    this.size = 50.0,
    this.color = AppColors.error, // NERV Red default
  });

  @override
  State<NervLoader> createState() => _NervLoaderState();
}

class _NervLoaderState extends State<NervLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * pi,
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _HexagonLoaderPainter(color: widget.color),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          'LOADING...',
          style: TextStyle(
            color: widget.color,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            fontFamily: 'Courier', // Monospace font
          ),
        ),
      ],
    );
  }
}

class _HexagonLoaderPainter extends CustomPainter {
  final Color color;

  _HexagonLoaderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

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

    // Inner details
    canvas.drawCircle(center, 4, Paint()..color = color);
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - radius),
      paint..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_HexagonLoaderPainter oldDelegate) => false;
}
