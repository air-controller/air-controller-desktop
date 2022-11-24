import 'package:flutter/material.dart';

class AppSortItem extends StatefulWidget {
  final String title;
  final double width;
  final double height;
  final bool isChecked;
  final bool isAscending;
  final Color color;
  final Color hoverColor;
  final Color pressColor;
  final Function()? onTap;

  const AppSortItem(
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
  State<AppSortItem> createState() => _AppSortItemState();
}

class _AppSortItemState extends State<AppSortItem> {
  bool _isHovered = false;
  bool _isTapDown = false;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: ((context, setState) {
      final labelWidth = 60.0;
      final checkedIconSize = 18.0;

      Color backgroundColor = widget.color;

      if (_isTapDown) {
        backgroundColor = widget.pressColor;
      } else if (_isHovered) {
        backgroundColor = widget.hoverColor;
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
                    color: Color(0xff575757),
                  ),
                  margin: EdgeInsets.only(left: 10),
                ),
                visible: widget.isChecked,
                maintainSize: true,
                maintainState: true,
                maintainAnimation: true,
              ),
              Container(
                child: Text(
                  widget.title,
                  textAlign: TextAlign.start,
                ),
                margin: EdgeInsets.only(left: 15),
                width: labelWidth,
              ),
              Visibility(
                child: Container(
                  child: Image.asset(
                      widget.isAscending
                          ? "assets/icons/ic_arrow_up.png"
                          : "assets/icons/ic_arrow_down.png",
                      width: 16,
                      height: 16,
                      color: Color(0xff666666)),
                  margin: EdgeInsets.only(left: 70),
                ),
                visible: widget.isChecked,
              )
            ],
          ),
          height: widget.height,
          width: widget.width,
          color: backgroundColor,
        ),
        onTap: () {
          widget.onTap?.call();

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
