import 'package:flutter/material.dart';

class UnifiedIconButtonWithText extends StatelessWidget {
  final IconData iconData;
  final String text;
  final double fontSize;
  final Color color;
  final Color hoverColor;
  final Color backgroundColor;
  final Color pressedBackgroundColor;
  final double iconSize;
  final double space;
  final EdgeInsetsGeometry? margin;
  final Function()? onTap;

  bool _isHovered = false;
  bool _isPressed = false;

  UnifiedIconButtonWithText(
      {required this.iconData,
      required this.text,
      this.fontSize = 14,
      this.color = const Color(0xff575757),
      this.hoverColor = const Color(0xff333333),
      this.backgroundColor = Colors.white,
      this.pressedBackgroundColor = const Color(0xfff5f5f5),
      this.iconSize = 20,
      this.space = 5,
      this.margin = EdgeInsets.zero,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: ((context, setState) {
      return InkResponse(
        child: Container(
          child: Row(
            children: [
              Icon(
                iconData,
                size: iconSize,
                color: _isHovered ? hoverColor : color,
              ),
              Container(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: _isHovered ? hoverColor : color,
                  ),
                ),
                margin: EdgeInsets.only(left: space),
              )
            ],
          ),
          color: _isPressed ? pressedBackgroundColor : backgroundColor,
          padding: EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 3),
          margin: margin,
        ),
        hoverColor: Colors.red,
        splashColor: pressedBackgroundColor,
        onTap: () {
          onTap?.call();

          setState(() {
            _isPressed = false;
          });
        },
        onTapDown: (details) {
          setState(() {
            _isPressed = true;
          });
        },
        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
        },
        onHover: (isHovered) {
          setState(() {
            _isHovered = isHovered;
          });
        },
      );
    }));
  }
}
