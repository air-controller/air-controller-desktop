
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class UnifiedDeleteButton extends StatelessWidget {
  final bool isEnable;
  final double iconSize;
  final double width;
  final double height;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Function()? onTap;
  bool _isDeleteBtnTapDown = false;

  static const _DEFAULT_ICON_SIZE = 10.0;
  static const _DEFAULT_WIDTH = 40.0;
  static const _DEFAULT_HEIGHT = 25.0;
  static const _DEFAULT_PADDING = const EdgeInsets.fromLTRB(8, 4.5, 8, 4.5);

  UnifiedDeleteButton({
    this.isEnable = true,
    this.iconSize = _DEFAULT_ICON_SIZE,
    this.width = _DEFAULT_WIDTH,
    this.height = _DEFAULT_HEIGHT,
    this.padding = _DEFAULT_PADDING,
    this.margin = EdgeInsets.zero,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      double opacity = _isDeleteBtnTapDown ? 0.8 : 1.0;

      if (!isEnable) {
        opacity = 0.6;
      }

      return GestureDetector(
        child: Opacity(
          opacity: opacity,
          child: Container(
              child: Image.asset("assets/icons/icon_delete.png",
                  width: iconSize,
                  height: iconSize),
              decoration: BoxDecoration(
                  color: Color(0xffcb6357),
                  border: new Border.all(
                      color: Color(0xffb43f32), width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(4.0))),
              width: width,
              height: height,
              padding: padding,
              margin: margin
          )
        ),
        onTap: () {
          onTap?.call();
        },
        onTapDown: (details) {
          if (isEnable) {
            setState(() {
              _isDeleteBtnTapDown = true;
            });
          }
        },
        onTapCancel: () {
          if (isEnable) {
            setState(() {
              _isDeleteBtnTapDown = false;
            });
          }
        },
        onTapUp: (details) {
          if (isEnable) {
            setState(() {
              _isDeleteBtnTapDown = false;
            });
          }
        },
      );
    });
  }

}