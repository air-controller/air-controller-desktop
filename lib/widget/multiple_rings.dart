import 'package:flutter/material.dart';

class MultipleRingsPainter extends CustomPainter {
  Color lineColor;
  double lineWidth;
  double minRadius;
  double radiusStep;

  late Paint _paint;

  MultipleRingsPainter(
      {required this.lineColor,
      required this.lineWidth,
      required this.minRadius,
      required this.radiusStep}) {
    _paint = Paint()
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..color = lineColor
      ..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width;
    double height = size.height;

    double maxRadius = width > height ? width / 2 : height / 2;

    double radius = minRadius;
    Offset c = Offset(width / 2, height / 2);

    while (radius < maxRadius) {
      canvas.drawCircle(c, radius, _paint);

      // canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint)

      radius += radiusStep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class MultipleRings extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final Color lineColor;
  final double lineWidth;
  final double minRadius;
  final double radiusStep;

  const MultipleRings(
      {Key? key,
      required this.width,
      required this.height,
      this.color = Colors.white,
      this.lineColor = Colors.black,
      this.lineWidth = 1.0,
      required this.minRadius,
      required this.radiusStep})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MultipleRingsState();
  }
}

class MultipleRingsState extends State<MultipleRings> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.height,
        width: widget.width,
        child: CustomPaint(
            painter: MultipleRingsPainter(
                lineColor: widget.lineColor,
                lineWidth: widget.lineWidth,
                minRadius: widget.minRadius,
                radiusStep: widget.radiusStep)),
        color: widget.color);
  }
}
