import 'package:flutter/material.dart';

class OverlayMenuItem extends StatefulWidget {
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

  static const Color DEFAULT_TEXT_COLOR = const Color(0xff1f1f1f);
  static const Color DEFAULT_PRESS_TEXT_COLOR = Colors.black;
  static const Color DEFAULT_HOVER_TEXT_COLOR = Colors.black;

  static const Color DEFAULT_BACKGROUND_COLOR = Colors.white;
  static const Color DEFAULT_PRESS_BACKGROUND_COLOR =
      const Color.fromARGB(255, 145, 201, 247);
  static const Color DEFAULT_HOVER_BACKGROUND_COLOR =
      const Color.fromARGB(255, 145, 201, 247);

  OverlayMenuItem(
      {Key? key,
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
      this.onTap = null})
      : super(key: key);
  @override
  State<OverlayMenuItem> createState() {
    return OverlayMenuItemState();
  }
}

class OverlayMenuItemState extends State<OverlayMenuItem> {
  Color _textColor = OverlayMenuItem.DEFAULT_TEXT_COLOR;

  Color _backgroundColor = OverlayMenuItem.DEFAULT_BACKGROUND_COLOR;

  @override
  Widget build(BuildContext context) {
    _textColor = widget.defaultTextColor;
    _backgroundColor = widget.defaultBackgroundColor;

    return StatefulBuilder(
        builder: (context, setState) => MouseRegion(
              onHover: (event) {
                setState(() {
                  _backgroundColor = widget.hoverBackgroundColor;
                  _textColor = widget.hoverTextColor;
                });
              },
              onExit: (event) {
                setState(() {
                  _backgroundColor = widget.defaultBackgroundColor;
                  _textColor = widget.defaultTextColor;
                });
              },
              onEnter: (event) {},
              child: GestureDetector(
                child: Container(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: _textColor,
                        fontSize: widget.textSize,
                        overflow: TextOverflow.ellipsis,
                      ),
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: widget.borderRadius),
                  margin: widget.margin,
                  padding: widget.padding,
                ),
                onTapDown: (details) {
                  setState(() {
                    _backgroundColor = widget.pressBackgroundColor;
                    _textColor = widget.pressTextColor;
                  });
                },
                onTapUp: (details) {
                  _backgroundColor = widget.defaultBackgroundColor;
                  _textColor = widget.defaultTextColor;
                },
                onTapCancel: () {
                  _backgroundColor = widget.defaultBackgroundColor;
                  _textColor = widget.defaultTextColor;
                },
                onTap: () {
                  widget.onTap?.call();
                },
              ),
            ));
  }
}
