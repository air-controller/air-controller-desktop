
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OverlayMenuItem extends StatelessWidget {
  final Color defaultTextColor;
  final Color pressTextColor;
  final Color hoverTextColor;
  final Color defaultBackgroundColor;
  final Color pressBackgroundColor;
  final Color hoverBackgroundColor;
  final String title;
  final double height;
  final double width;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final BorderRadius borderRadius;
  final double textSize;
  final Function()? onTap;

  static const Color DEFAULT_TEXT_COLOR = const Color(0xff212121);
  static const Color DEFAULT_PRESS_TEXT_COLOR = Colors.white;
  static const Color DEFAULT_HOVER_TEXT_COLOR = Colors.white;

  static const Color DEFAULT_BACKGROUND_COLOR = Colors.white;
  static const Color DEFAULT_PRESS_BACKGROUND_COLOR = const Color(0xffa6a7aa);
  static const Color DEFAULT_HOVER_BACKGROUND_COLOR = const Color(0xffa6a7aa);

  Color _textColor = DEFAULT_TEXT_COLOR;

  Color _backgroundColor = DEFAULT_BACKGROUND_COLOR;

  OverlayMenuItem({
    Key? key,
    this.defaultTextColor = DEFAULT_TEXT_COLOR,
    this.pressTextColor = DEFAULT_PRESS_TEXT_COLOR,
    this.hoverTextColor = DEFAULT_HOVER_TEXT_COLOR,
    this.defaultBackgroundColor = DEFAULT_BACKGROUND_COLOR,
    this.hoverBackgroundColor = DEFAULT_HOVER_BACKGROUND_COLOR,
    this.pressBackgroundColor = DEFAULT_PRESS_BACKGROUND_COLOR,
    this.title = '',
    required this.width,
    required this.height,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.borderRadius = BorderRadius.zero,
    this.textSize = 14.0,
    this.onTap = null
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _textColor = this.defaultTextColor;
    _backgroundColor = this.defaultBackgroundColor;

    return StatefulBuilder(builder: (context, setState) => MouseRegion(
      onHover: (event) {
        setState(() {
          _backgroundColor = this.hoverBackgroundColor;
          _textColor = this.hoverTextColor;
        });
      },
      onExit: (event) {
        setState(() {
          _backgroundColor = this.defaultBackgroundColor;
          _textColor = this.defaultTextColor;
        });
      },
      onEnter: (event) {},
      child: GestureDetector(
        child: Container(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(title, style: TextStyle(
                color: _textColor,
              fontSize: textSize,
              overflow: TextOverflow.ellipsis,
            ),
              textAlign: TextAlign.left,
              maxLines: 1,
              softWrap: false,
            ),
          ),
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: this.borderRadius
          ),
          margin: margin,
          padding: padding,
        ),
        onTapDown: (details) {
          setState(() {
            _backgroundColor = this.pressBackgroundColor;
            _textColor = this.pressTextColor;
          });
        },
        onTapUp: (details) {
          _backgroundColor = this.defaultBackgroundColor;
          _textColor = this.defaultTextColor;
        },
        onTapCancel: () {
          _backgroundColor = this.defaultBackgroundColor;
          _textColor = this.defaultTextColor;
        },
        onTap: () {
          onTap?.call();
        },
      ),
    ));
  }
}