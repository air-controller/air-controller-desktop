import 'package:flutter/material.dart';

class UnifiedIconButton extends StatefulWidget {
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

  const UnifiedIconButton(
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
  State<StatefulWidget> createState() {
    return _UnifiedIconButtonState();
  }
}

class _UnifiedIconButtonState extends State<UnifiedIconButton> {
  bool _isHover = false;
  bool _isTapDown = false;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: ((context, setState) {
      Color color = _isHover ? widget.hoverColor : widget.color;
      color = _isTapDown ? widget.pressedColor : widget.color;

      if (!widget.enable) {
        color = widget.disableColor;
      }

      return GestureDetector(
        child: Container(
          child: Image.asset(
            widget.iconPath,
            width: widget.width,
            height: widget.height,
            color: color,
          ),
          padding: widget.padding,
        ),
        onTap: () {
          if (widget.enable) {
            widget.onTap?.call();
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
