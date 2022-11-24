import 'package:flutter/material.dart';

/**
 * 自定义等边三角形
 *
 * @author Houjun Yuan 2022/01/23 18:22
 */
class TrianglePainter extends CustomPainter {
  Color color;
  Color dividerColor;
  double dividerWidth;
  bool isUpward;

  late Paint _paint;
  late Path _path;

  TrianglePainter(
      {required this.color,
      this.dividerColor = Colors.black,
      this.dividerWidth = 1.0,
      required this.isUpward}) {
    _paint = Paint()
      ..strokeWidth = 1.0
      ..color = color
      ..isAntiAlias = true;
    _path = Path();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width;
    final y = size.height;

    if (isUpward) {
      _path.moveTo(x * 0.5, 0);
      _path.lineTo(x, y);
      _path.lineTo(0, y);

      _paint.color = color;
      _paint.strokeWidth = 1;
      canvas.drawPath(_path, _paint);

      _paint.color = dividerColor;
      _paint.strokeWidth = dividerWidth;

      canvas.drawLine(Offset(0, y), Offset(0.5 * x, 0), _paint);
      canvas.drawLine(Offset(0.5 * x, 0), Offset(x, y), _paint);
    } else {
      _path.moveTo(0, 0);
      _path.lineTo(0.5 * x, y);
      _path.lineTo(x, 0);

      _paint.color = color;
      _paint.strokeWidth = 1;
      canvas.drawPath(_path, _paint);

      _paint.color = dividerColor;
      _paint.strokeWidth = dividerWidth;

      canvas.drawLine(Offset(0, 0), Offset(0.5 * x, y), _paint);
      canvas.drawLine(Offset(0.5 * x, y), Offset(x, 0), _paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class Triangle extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final Color dividerColor;
  final bool isUpward;

  Triangle(
      {required Key key,
      required this.width,
      required this.height,
      this.color = Colors.white,
      this.dividerColor = Colors.black,
      this.isUpward = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TriangleState();
  }
}

class TriangleState extends State<Triangle> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      child: CustomPaint(
          painter: TrianglePainter(
              color: widget.color,
              dividerColor: widget.dividerColor,
              isUpward: widget.isUpward)),
    );
  }
}
