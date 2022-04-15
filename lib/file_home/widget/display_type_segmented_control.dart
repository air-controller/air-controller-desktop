import 'package:flutter/material.dart';

import '../../model/display_type.dart';

// ignore: must_be_immutable
class DisplayTypeSegmentedControl extends StatelessWidget {
  DisplayType displayType;
  final Function(DisplayType displayType)? onChange;

  DisplayTypeSegmentedControl(
      {Key? key, this.displayType = DisplayType.icon, this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconSize = 10.0;
    final padding = EdgeInsets.fromLTRB(8, 6, 8, 6);
    final radius = 4.0;
    final width = 32.0;
    final height = 26.0;

    return StatefulBuilder(builder: (context, setState) {
      return Container(
        child: Row(
            children: [
              GestureDetector(
                child: Container(
                    child: Container(
                      child: Image.asset(
                          _isChecked(DisplayType.icon)
                              ? "assets/icons/icon_image_text_selected.png"
                              : "assets/icons/icon_image_text_normal.png",
                          width: iconSize,
                          height: iconSize),
                      decoration: BoxDecoration(
                          color: _isChecked(DisplayType.icon)
                              ? Color(0xffc1c1c1)
                              : Color(0xfff5f6f5),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(radius),
                              bottomLeft: Radius.circular(radius))),
                      height: height,
                      width: width,
                      padding: padding,
                      margin: EdgeInsets.only(left: 1, top: 1, bottom: 1),
                    ),
                    decoration: BoxDecoration(
                        color: _isChecked(DisplayType.icon)
                            ? Color(0xffabaaab)
                            : Color(0xffdedede),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(radius),
                            bottomLeft: Radius.circular(radius)))),
                onTap: () {
                  setState(() {
                    if (this.displayType != DisplayType.icon) {
                      this.displayType = DisplayType.icon;
                      onChange?.call(displayType);
                    }
                  });
                },
              ),
              Container(
                width: 1,
                height: double.infinity,
                color: Color(0xffabaaab),
              ),
              GestureDetector(
                child: Container(
                    child: Container(
                      child: Image.asset(
                          _isChecked(DisplayType.list)
                              ? "assets/icons/icon_list_selected.png"
                              : "assets/icons/icon_list_normal.png",
                          width: iconSize,
                          height: iconSize),
                      decoration: BoxDecoration(
                          color: _isChecked(DisplayType.list)
                              ? Color(0xffc1c1c1)
                              : Color(0xfff5f6f5),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(radius),
                              bottomRight: Radius.circular(radius))),
                      height: height,
                      width: width,
                      padding: padding,
                      margin: EdgeInsets.only(right: 1, top: 1, bottom: 1),
                    ),
                    decoration: BoxDecoration(
                        color: _isChecked(DisplayType.list)
                            ? Color(0xffabaaab)
                            : Color(0xffdedede),
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(radius),
                            bottomRight: Radius.circular(radius)))),
                onTap: () {
                  setState(() {
                    if (this.displayType != DisplayType.list) {
                      this.displayType = DisplayType.list;
                      onChange?.call(displayType);
                    }
                  });
                },
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center),
        height: 28,
      );
    });
  }

  bool _isChecked(DisplayType displayType) {
    return this.displayType == displayType;
  }
}
