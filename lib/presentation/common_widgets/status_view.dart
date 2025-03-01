import 'dart:math';

import 'package:flutter/material.dart';

import 'all.dart';

class StatusView extends StatelessWidget {
  final int numberOfStatus;
  final int indexOfSeenStatus;
  final double spacing;
  final double radius;
  final double padding;
  final String centerImageUrl;
  final double strokeWidth;
  final Color seenColor;
  final Color unSeenColor;

  const StatusView(
      {required this.centerImageUrl,
      super.key,
      this.numberOfStatus = 10,
      this.indexOfSeenStatus = 0,
      this.spacing = 10.0,
      this.radius = 50,
      this.padding = 5,
      this.strokeWidth = 4,
      this.seenColor = Colors.grey,
      this.unSeenColor = Colors.blue});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          AppCircleAvatar(size: radius * 2 - padding, url: centerImageUrl),
          SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: CustomPaint(
              painter: Arc(
                  alreadyWatch: indexOfSeenStatus,
                  numberOfArc: numberOfStatus,
                  spacing: spacing,
                  strokeWidth: strokeWidth,
                  seenColor: seenColor,
                  unSeenColor: unSeenColor),
            ),
          ),
        ],
      ),
    );
  }
}

class Arc extends CustomPainter {
  final int numberOfArc;
  final int alreadyWatch;
  final double spacing;
  final double strokeWidth;
  final Color seenColor;
  final Color unSeenColor;
  Arc(
      {required this.numberOfArc,
      required this.alreadyWatch,
      required this.spacing,
      required this.strokeWidth,
      required this.seenColor,
      required this.unSeenColor});

  double doubleToAngle(double angle) => angle * pi / 180.0;

  void drawArcWithRadius(
      Canvas canvas,
      Offset center,
      double radius,
      double angle,
      Paint seenPaint,
      Paint unSeenPaint,
      double start,
      double spacing,
      int number,
      int alreadyWatch) {
    for (var i = 0; i < number; i++) {
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          doubleToAngle(start + ((angle + spacing) * i)),
          doubleToAngle(angle),
          false,
          alreadyWatch - 1 >= i ? seenPaint : unSeenPaint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2.0, size.height / 2.0);
    final double radius = size.width / 2.0;
    final double angle =
        numberOfArc == 1 ? 360.0 : (360.0 / numberOfArc - spacing);
    const startingAngle = 270.0;

    final Paint seenPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..color = seenColor;

    final Paint unSeenPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..color = unSeenColor;

    drawArcWithRadius(canvas, center, radius, angle, seenPaint, unSeenPaint,
        startingAngle, spacing, numberOfArc, alreadyWatch);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
