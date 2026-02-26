import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:spin_wheel_picker/app/data/models/wheel_item.dart';

class WheelPainter extends CustomPainter {
  final List<WheelItem> items;
  final double angle;

  WheelPainter({required this.items, required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;
    final n = items.length;
    if (n == 0) return;

    final segAngle = (2 * math.pi) / n;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    // Outer shadow ring
    canvas.drawCircle(
      Offset.zero,
      radius + 2,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    for (int i = 0; i < n; i++) {
      final startAngle = -math.pi / 2 + i * segAngle;
      final color = Color(items[i].effectiveColorValue);

      // Segment fill with slight brightness variation for depth
      final fillPaint =
          Paint()
            ..color = color
            ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        startAngle,
        segAngle,
        true,
        fillPaint,
      );

      // Segment highlight (lighter top edge)
      final highlightPaint =
          Paint()
            ..color = Colors.white.withValues(alpha: 0.12)
            ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        startAngle,
        segAngle / 2,
        true,
        highlightPaint,
      );

      // Segment border
      final borderPaint =
          Paint()
            ..color = Colors.white.withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        startAngle,
        segAngle,
        true,
        borderPaint,
      );

      // Label text
      final mid = startAngle + segAngle / 2;
      final textRadius = radius * 0.62;
      final labelOffset = Offset(
        math.cos(mid) * textRadius,
        math.sin(mid) * textRadius,
      );

      canvas.save();
      canvas.translate(labelOffset.dx, labelOffset.dy);
      canvas.rotate(mid + math.pi / 2);

      final label = items[i].label;
      final displayLabel = label.length > 10 ? '${label.substring(0, 9)}…' : label;
      final fontSize = n <= 6 ? 13.0 : (n <= 10 ? 11.0 : 9.0);

      final tp = TextPainter(
        text: TextSpan(
          text: displayLabel,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            shadows: const [
              Shadow(color: Colors.black38, blurRadius: 3, offset: Offset(0, 1)),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: radius * 0.52);

      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // Outer rim
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Center pin
    canvas.drawCircle(
      Offset.zero,
      radius * 0.11,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset.zero,
      radius * 0.07,
      Paint()..color = Colors.grey.shade400,
    );

    canvas.restore();

    // Fixed indicator arrow at top (not rotated with wheel)
    _drawIndicator(canvas, center, radius);
  }

  void _drawIndicator(Canvas canvas, Offset center, double radius) {
    final tipY = center.dy - radius + 1;

    final path =
        Path()
          ..moveTo(center.dx, tipY)
          ..lineTo(center.dx - 13, tipY - 26)
          ..lineTo(center.dx + 13, tipY - 26)
          ..close();

    // Shadow
    canvas.drawPath(
      path.shift(const Offset(0, 2)),
      Paint()..color = Colors.black.withValues(alpha: 0.25),
    );

    // Fill
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // Border
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(WheelPainter oldDelegate) =>
      oldDelegate.angle != angle || oldDelegate.items != items;
}
