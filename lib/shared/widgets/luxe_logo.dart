import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Branded diamond mark for splash, auth, and empty states.
class LuxeLogo extends StatelessWidget {
  const LuxeLogo({
    super.key,
    this.size = 72,
    this.animate = false,
    this.showLabel = false,
  });

  final double size;
  final bool animate;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final mark = CustomPaint(
      size: Size.square(size),
      painter: const _DiamondPainter(),
    );

    final logo = animate
        ? RotationTransition(
            turns: AlwaysStoppedAnimation(0),
            child: mark,
          )
        : mark;

    if (!showLabel) return logo;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        SizedBox(height: size * 0.2),
        Text(
          'LuxeJewel',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _DiamondPainter extends CustomPainter {
  const _DiamondPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final outer = Path()
      ..moveTo(cx, h * 0.04)
      ..lineTo(w * 0.92, h * 0.38)
      ..lineTo(cx, h * 0.96)
      ..lineTo(w * 0.08, h * 0.38)
      ..close();

    final inner = Path()
      ..moveTo(cx, h * 0.22)
      ..lineTo(w * 0.72, h * 0.38)
      ..lineTo(cx, h * 0.78)
      ..lineTo(w * 0.28, h * 0.38)
      ..close();

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.goldSoft, AppColors.gold],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final stroke = Paint()
      ..color = AppColors.goldSoft.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.03;

    canvas.drawPath(outer, fill);
    canvas.drawPath(outer, stroke);
    canvas.drawPath(
      inner,
      Paint()
        ..color = AppColors.bgPrimary.withOpacity(0.35)
        ..style = PaintingStyle.fill,
    );
    canvas.drawLine(Offset(cx, h * 0.04), Offset(cx, h * 0.78), stroke);
    canvas.drawLine(Offset(w * 0.28, h * 0.38), Offset(w * 0.72, h * 0.38), stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
