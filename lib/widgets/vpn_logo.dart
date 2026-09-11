import 'package:flutter/material.dart';
import '../theme/colors.dart';

class VpnLogo extends StatelessWidget {
  final double size;
  final bool glow;

  const VpnLogo({super.key, this.size = 120, this.glow = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.neon.withOpacity(0.25),
            AppColors.neon.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: AppColors.neon, width: 2),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: AppColors.neon.withOpacity(0.5),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.5, size * 0.5),
          painter: _ShieldPainter(),
        ),
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neon
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..color = AppColors.neon.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w * 0.5, h * 0.05);
    path.lineTo(w * 0.9, h * 0.25);
    path.lineTo(w * 0.9, h * 0.55);
    path.quadraticBezierTo(w * 0.9, h * 0.85, w * 0.5, h * 0.98);
    path.quadraticBezierTo(w * 0.1, h * 0.85, w * 0.1, h * 0.55);
    path.lineTo(w * 0.1, h * 0.25);
    path.close();

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);

    // ستاره وسط سپر
    final starPaint = Paint()
      ..color = AppColors.neon
      ..style = PaintingStyle.fill;

    final starPath = Path();
    final cx = w * 0.5;
    final cy = h * 0.5;
    final outerR = w * 0.18;
    final innerR = outerR * 0.4;

    for (int i = 0; i < 10; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = (i * 3.14159 / 5) - 3.14159 / 2;
      final x = cx + r * _cos(angle);
      final y = cy + r * _sin(angle);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();

    canvas.drawPath(starPath, starPaint);
  }

  double _cos(double x) => _taylorCos(x);
  double _sin(double x) => _taylorCos(x - 1.5708);

  double _taylorCos(double x) {
    while (x > 3.14159) x -= 6.28318;
    while (x < -3.14159) x += 6.28318;
    final x2 = x * x;
    return 1 - x2 / 2 + x2 * x2 / 24 - x2 * x2 * x2 / 720;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
