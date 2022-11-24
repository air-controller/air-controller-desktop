import 'package:flutter/material.dart';

class UnifiedIconButtonWithText extends StatefulWidget {
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
  State<UnifiedIconButtonWithText> createState() {
    return UnifiedIconButtonWithTextState();
  }
}

class UnifiedIconButtonWithTextState extends State<UnifiedIconButtonWithText> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: ((context, setState) {
      Color color = _isHovered ? widget.hoverColor : widget.color;
      if (!widget.enable) color = widget.disableColor;

      Color backgroundColor =
          _isPressed ? widget.pressedBackgroundColor : widget.backgroundColor;
      if (!widget.enable) backgroundColor = Colors.transparent;

      return InkResponse(
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          child: Row(
            children: childWidgets(color, widget.isIconAtLeft),
          ),
          color: backgroundColor,
          padding: EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 3),
          margin: widget.margin,
        ),
        onTap: () {
          if (!widget.enable) return;

          widget.onTap?.call();

          setState(() {
            _isPressed = false;
          });
        },
        onTapDown: (details) {
          if (!widget.enable) return;

          setState(() {
            _isPressed = true;
          });
        },
        onTapCancel: () {
          if (!widget.enable) return;

          setState(() {
            _isPressed = false;
          });
        },
        onHover: (isHovered) {
          if (!widget.enable) return;

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
          widget.iconPath,
          width: widget.iconSize,
          height: widget.iconSize,
          color: color,
        ),
        Container(
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: widget.fontSize,
              color: color,
            ),
          ),
          margin: EdgeInsets.only(left: widget.space),
        )
      ];
    } else {
      return [
        Text(widget.text,
            style: TextStyle(
              fontSize: widget.fontSize,
              color: color,
            )),
        Container(
          child: Image.asset(
            widget.iconPath,
            width: widget.iconSize,
            height: widget.iconSize,
            color: color,
          ),
          margin: EdgeInsets.only(left: widget.space),
        )
      ];
    }
  }
}
