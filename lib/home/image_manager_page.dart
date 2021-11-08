import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:mobile_assistant_client/constant.dart';

class ImageManagerPage extends StatefulWidget {
  ImageManagerPage();

  @override
  State<StatefulWidget> createState() {
    return _ImageManagerState();
  }
}

class _ImageManagerState extends State<ImageManagerPage> {
  static final _INDEX_ALL_IMAGE = 0;
  static final _INDEX_CAMERA_ALBUM = 1;
  static final _INDEX_ALL_ALBUM = 2;

  int _currentIndex = _INDEX_ALL_IMAGE;
  final _divider_line_color = Color(0xffe0e0e0);

  @override
  Widget build(BuildContext context) {
    Color getSegmentBtnColor(int index) {
      if (index == _currentIndex) {
        return Color(0xffffffff);
      } else {
        return Color(0xff5b5c62);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          child: Expanded(
            child: Stack(children: [
              Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: MaterialSegmentedControl<int>(
                      children: {
                        _INDEX_ALL_IMAGE: Container(
                          child: Text("所有图片",
                              style: TextStyle(
                                  inherit: false,
                                  fontSize: 12,
                                  color: getSegmentBtnColor(_INDEX_ALL_IMAGE))),
                          padding: EdgeInsets.only(left: 10, right: 10),
                        ),
                        _INDEX_CAMERA_ALBUM: Container(
                          child: Text("相机相册",
                              style: TextStyle(
                                  inherit: false,
                                  fontSize: 12,
                                  color: getSegmentBtnColor(_INDEX_CAMERA_ALBUM))),
                        ),
                        _INDEX_ALL_ALBUM: Container(
                            child: Text("所有相册",
                                style: TextStyle(
                                    inherit: false,
                                    fontSize: 12,
                                    color: getSegmentBtnColor(_INDEX_ALL_ALBUM))))
                      },
                      selectionIndex: _currentIndex,
                      borderColor: Color(0xffdedede),
                      selectedColor: Color(0xffc3c3c3),
                      unselectedColor: Color(0xfff7f5f6),
                      borderRadius: 3.0,
                      verticalOffset: 0,
                      disabledChildren: [],
                      onSegmentChosen: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                    height: 30,
                  )
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(

                ),
              )
            ],
            ),
          ),
          height: Constant.HOME_NAVI_BAR_HEIGHT,
          color: Color(0xfff6f6f6),
        ),

        Divider(
            color: _divider_line_color,
            height: 1.0,
            thickness: 1.0
        ),

      ],
    );
  }
}
