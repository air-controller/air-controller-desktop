import 'package:flutter/material.dart';

class UnifiedIconButton extends StatelessWidget {
  final double width;
  final double height;
  final String iconPath;
  final Color color;
  final Color hoverColor;
  final Color pressedColor;
  final Color disableColor;
  final EdgeInsetsGeometry padding;
  final bool enable;
  final VoidCallback? onTap;

  bool _isHover = false;
  bool _isTapDown = false;

  UnifiedIconButton(
      {required this.width,
      required this.height,
      required this.iconPath,
      this.color = const Color(0xff575757),
      this.hoverColor = const Color(0xff333333),
      this.pressedColor = const Color(0x88575757),
      this.disableColor = const Color(0xffcdcdcd),
      this.padding = EdgeInsets.zero,
      this.enable = true,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: ((context, setState) {
      Color color = _isHover ? hoverColor : this.color;
      color = _isTapDown ? pressedColor : this.color;

      if (!enable) {
        color = this.disableColor;
      }

      return GestureDetector(
        child: Container(
          child: Image.asset(
            iconPath,
            width: width,
            height: height,
            color: color,
          ),
          padding: padding,
        ),
        onTap: () {
          if (enable) {
            onTap?.call();
          }
        },
        onTapDown: (details) {
          setState(() {
            _isTapDown = true;
          });
        },
        onTapCancel: () {
            setState(() {
            _isTapDown = false;
          });
        },
        onTapUp: (details) {
            setState(() {
            _isTapDown = false;
          });
        },
      );
    }));
  }
}
