import 'package:flutter/material.dart';

class UnifiedIconButtonWithText extends StatelessWidget {
  final String iconPath;
  final String text;
  final double fontSize;
  final Color color;
  final Color hoverColor;
  final Color disableColor;
  final Color backgroundColor;
  final Color pressedBackgroundColor;
  final double iconSize;
  final double space;
  final EdgeInsetsGeometry? margin;
  final bool enable;
  final bool isIconAtLeft;
  final Function()? onTap;

  bool _isHovered = false;
  bool _isPressed = false;

  UnifiedIconButtonWithText(
      {required this.iconPath,
      required this.text,
      this.fontSize = 14,
      this.color = const Color(0xff575757),
      this.hoverColor = const Color(0xff333333),
      this.disableColor = const Color(0xffcdcdcd),
      this.backgroundColor = Colors.white,
      this.pressedBackgroundColor = const Color(0xfff5f5f5),
      this.iconSize = 20,
      this.space = 5,
      this.margin = EdgeInsets.zero,
      this.enable = true,
      this.isIconAtLeft = true,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: ((context, setState) {
      Color color = _isHovered ? hoverColor : this.color;
      if (!enable) color = disableColor;

      Color backgroundColor =
          _isPressed ? pressedBackgroundColor : this.backgroundColor;
      if (!enable) backgroundColor = Colors.transparent;

      return InkResponse(
        child: Container(
          child: Row(
            children: childWidgets(color, isIconAtLeft),
          ),
          color: backgroundColor,
          padding: EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 3),
          margin: margin,
        ),
        onTap: () {
          if (!enable) return;

          onTap?.call();

          setState(() {
            _isPressed = false;
          });
        },
        onTapDown: (details) {
          if (!enable) return;

          setState(() {
            _isPressed = true;
          });
        },
        onTapCancel: () {
          if (!enable) return;

          setState(() {
            _isPressed = false;
          });
        },
        onHover: (isHovered) {
          if (!enable) return;

          setState(() {
            _isHovered = isHovered;
          });
        },
      );
    }));
  }

  List<Widget> childWidgets(Color color, bool isIconAtLeft) {
    if (isIconAtLeft) {
      return [
        Image.asset(
          iconPath,
          width: iconSize,
          height: iconSize,
          color: color,
        ),
        Container(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: color,
            ),
          ),
          margin: EdgeInsets.only(left: space),
        )
      ];
    } else {
      return [
        Text(text,
            style: TextStyle(
              fontSize: fontSize,
              color: color,
            )),
        Container(
          child: Image.asset(
            iconPath,
            width: iconSize,
            height: iconSize,
            color: color,
          ),
          margin: EdgeInsets.only(left: space),
        )
      ];
    }
  }
}
