import 'package:flutter/material.dart';

/**
 * 自定义等边三角形
 *
 * @author Houjun Yuan 2022/01/23 18:22
 */
class UpwardTrianglePainter extends CustomPainter {
  Color color;
  Color dividerColor;
  double dividerWidth;

  late Paint _paint;
  late Path _path;

  UpwardTrianglePainter({required this.color, this.dividerColor = Colors.black, this.dividerWidth = 1.0}) {
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

    _path.moveTo(x * 0.5, 0);
    _path.lineTo(x, y);
    _path.lineTo(0, y);

    _paint.color = color;
    _paint.strokeWidth = 10;
    canvas.drawPath(_path, _paint);

    _paint.color = dividerColor;
    _paint.strokeWidth = 1;

    canvas.drawLine(Offset(0, y), Offset(0.5 * x, 0), _paint);
    canvas.drawLine(Offset(0.5 * x, 0), Offset(x, y), _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class UpwardTriangle extends StatefulWidget {
  double width;
  double height;
  Color color;
  Color dividerColor;

  UpwardTriangle({required Key key, required this.width, required this.height, this.color = Colors.white, this.dividerColor = Colors.black}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UpwardTriangleState();
  }
}

class UpwardTriangleState extends State<UpwardTriangle> {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      child: CustomPaint(
        painter: UpwardTrianglePainter(color: widget.color, dividerColor: widget.dividerColor)
      ),
    );
  }
}