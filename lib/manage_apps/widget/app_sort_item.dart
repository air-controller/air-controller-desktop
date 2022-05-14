import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppSortItem extends StatelessWidget {
  final String title;
  final double width;
  final double height;
  final bool isChecked;
  final bool isAscending;
  final Color color;
  final Color hoverColor;
  final Color pressColor;
  final Function()? onTap;

  bool _isHovered = false;
  bool _isTapDown = false;

  AppSortItem(
      {required this.title,
      required this.width,
      required this.height,
      this.isChecked = false,
      this.isAscending = false,
      this.color = Colors.white,
      this.hoverColor = const Color(0xfff5f5f5),
      this.pressColor = const Color(0xffeeeeee),
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: ((context, setState) {
      final labelWidth = 60.0;
      final checkedIconSize = 15.0;

      Color backgroundColor = color;

      if (_isTapDown) {
        backgroundColor = pressColor;
      } else if (_isHovered) {
        backgroundColor = hoverColor;
      }

      return InkResponse(
        autofocus: true,
        child: Container(
          child: Wrap(
            direction: Axis.horizontal,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Visibility(
                child: Container(
                  child: Image.asset(
                    "assets/icons/ic_checked_mark.png",
                    width: checkedIconSize,
                    height: checkedIconSize,
                  ),
                  margin: EdgeInsets.only(left: 10),
                ),
                visible: isChecked,
                maintainSize: true,
                maintainState: true,
                maintainAnimation: true,
              ),
              Container(
                child: Text(
                  title,
                  textAlign: TextAlign.start,
                ),
                margin: EdgeInsets.only(left: 10),
                width: labelWidth,
              ),
              Visibility(
                child: Container(
                  child: Icon(
                      isAscending
                          ? FontAwesomeIcons.arrowUp
                          : FontAwesomeIcons.arrowDown,
                      size: 15,
                      color: Color(0xff666666)),
                  margin: EdgeInsets.only(left: 30),
                ),
                visible: isChecked,
              )
            ],
          ),
          height: height,
          width: width,
          color: backgroundColor,
        ),
        onTap: () {
          onTap?.call();

          setState(() {
            _isTapDown = false;
          });
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
        onHover: (isHovered) {
          setState(() {
            _isHovered = isHovered;
          });
        },
      );
    }));
  }
}
