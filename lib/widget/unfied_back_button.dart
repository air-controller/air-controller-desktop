import 'package:flutter/material.dart';

// ignore: must_be_immutable
class UnifiedBackButton extends StatelessWidget {
  final String title;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color pressedBackgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Function()? onTap;

  bool _isBackBtnDown = false;

  UnifiedBackButton(
      {required this.title,
      required this.width,
      required this.height,
      this.backgroundColor = const Color(0xfff3f3f4),
      this.pressedBackgroundColor = const Color(0xffe8e8e8),
      this.borderRadius = const BorderRadius.all(Radius.circular(3.0)),
      this.border = const Border.fromBorderSide(BorderSide(
          color: const Color(0xffdedede),
          width: 1.0,
          style: BorderStyle.solid)),
      this.padding = const EdgeInsets.only(right: 6, left: 2),
      this.margin = null,
      this.onTap = null});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (context, setState) => GestureDetector(
              child: Container(
                child: Row(
                  children: [
                    Image.asset("assets/icons/icon_right_arrow.png",
                        width: 12, height: 12),
                    Container(
                      child: Text(title,
                          style: TextStyle(
                              color: Color(0xff5c5c62), fontSize: 13)),
                      margin: EdgeInsets.only(left: 3),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                    color: _isBackBtnDown
                        ? pressedBackgroundColor
                        : backgroundColor,
                    borderRadius: borderRadius,
                    border: border),
                width: width,
                height: height,
                padding: padding,
                margin: margin,
              ),
              onTap: () {
                onTap?.call();
              },
              onTapDown: (detail) {
                setState(() {
                  _isBackBtnDown = true;
                });
              },
              onTapCancel: () {
                setState(() {
                  _isBackBtnDown = false;
                });
              },
              onTapUp: (detail) {
                setState(() {
                  _isBackBtnDown = false;
                });
              },
            ));
  }
}
