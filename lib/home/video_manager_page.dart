import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mobile_assistant_client/constant.dart';
import 'package:flutter/material.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:mobile_assistant_client/event/update_video_sort_order.dart';
import 'package:mobile_assistant_client/home/video/all_video_manager_page.dart';
import 'package:mobile_assistant_client/home/video/video_folder_manager_page.dart';
import '../event/update_bottom_item_num.dart';
import 'package:mobile_assistant_client/util/event_bus.dart';

class VideoManagerPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return VideoManagerState();
  }
}

class VideoManagerState extends State<VideoManagerPage> {
  final _divider_line_color = Color(0xffe0e0e0);

  static final int INDEX_ALL_VIDEOS = 0;
  static final int INDEX_VIDEO_FOLDERS = 1;
  int _currentIndex = INDEX_ALL_VIDEOS;
  bool _isDeleteBtnEnabled = false;

  // 按创建时间排序
  static final int SORT_ORDER_CREATE_TIME = 1;
  // 按视频大小排序
  static final int SORT_ORDER_SIZE = 2;
  int _sortOrder = SORT_ORDER_CREATE_TIME;

  final _allVideoManagerPage = AllVideoManagerPage();
  final _videoFolderManagerPage = VideoFolderManagerPage();
  int _allItemNum = 0;
  int _selectedItemNum = 0;

  StreamSubscription<UpdateBottomItemNum>? _updateBottomItemNumStream;

  void _registerEventBus() {
    _updateBottomItemNumStream = eventBus.on<UpdateBottomItemNum>().listen((event) {
      updateBottomItemNumber(event.totalNum, event.selectedNum);
    });
  }

  void _unRegisterEventBus() {
    _updateBottomItemNumStream?.cancel();
  }

  @override
  void initState() {
    super.initState();
    _registerEventBus();
  }

  @override
  Widget build(BuildContext context) {
    final pageController = PageController(initialPage: 0);

    Color getSegmentBtnColor(int index) {
      if (index == _currentIndex) {
        return Color(0xffffffff);
      } else {
        return Color(0xff5b5c62);
      }
    }

    String _getSortOrderIcon(int sortOrder) {
      if (sortOrder == SORT_ORDER_CREATE_TIME) {
        if (_sortOrder == sortOrder) {
          return "icons/icon_grid_selected.png";
        } else {
          return "icons/icon_grid_normal.png";
        }
      }

      if (_sortOrder == sortOrder) {
        return "icons/icon_monthly_selected.png";
      } else {
        return "icons/icon_monthly_normal.png";
      }
    }

    Color _getSortOrderBgColor(int sortOrder) {
      if (_sortOrder == sortOrder) {
        return Color(0xffc2c2c2);
      } else {
        return Color(0xfff5f5f5);
      }
    }

    String itemNumStr = "共${_allItemNum}项";
    if (_selectedItemNum > 0) {
      itemNumStr = "$itemNumStr (选中${_selectedItemNum}项)";
    }

    return Column(
      children: [
        Container(
          child: Stack(
            children: [
              Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: MaterialSegmentedControl<int>(
                      children: {
                        INDEX_ALL_VIDEOS: Container(
                          child: Text("所有视频",
                              style: TextStyle(
                                  inherit: false,
                                  fontSize: 12,
                                  color: getSegmentBtnColor(INDEX_ALL_VIDEOS))),
                          padding: EdgeInsets.only(left: 10, right: 10),
                        ),
                        INDEX_VIDEO_FOLDERS: Container(
                          child: Text("视频文件夹",
                              style: TextStyle(
                                  inherit: false,
                                  fontSize: 12,
                                  color:
                                  getSegmentBtnColor(INDEX_VIDEO_FOLDERS))),
                          padding: EdgeInsets.only(left: 10, right: 10),
                        ),
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
                          pageController.jumpToPage(_currentIndex);
                        });
                      },
                    ),
                    height: 30,
                  )),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  child: Row(
                    children: [
                      Visibility(
                        child: Row(
                          children: [
                            GestureDetector(
                              child: Container(
                                child: Image.asset(
                                    _getSortOrderIcon(SORT_ORDER_CREATE_TIME),
                                    width: 20,
                                    height: 20),
                                padding: EdgeInsets.fromLTRB(13, 3, 13, 3),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color(0xffdddedf), width: 1.0),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4.0),
                                      bottomLeft: Radius.circular(4.0)),
                                  color: _getSortOrderBgColor(SORT_ORDER_CREATE_TIME),
                                ),
                              ),
                              onTap: () {
                                if (_sortOrder != SORT_ORDER_CREATE_TIME) {
                                  setState(() {
                                    _sortOrder = SORT_ORDER_CREATE_TIME;
                                    eventBus.fire(UpdateVideoSortOrder(UpdateVideoSortOrder.TYPE_CREATE_TIME));
                                  });
                                }
                              },
                            ),
                            GestureDetector(
                              child: Container(
                                child: Image.asset(
                                    _getSortOrderIcon(SORT_ORDER_SIZE),
                                    width: 20,
                                    height: 20),
                                padding: EdgeInsets.fromLTRB(13, 3, 13, 3),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color(0xffdddedf), width: 1.0),
                                  color: _getSortOrderBgColor(SORT_ORDER_SIZE),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(4.0),
                                      bottomRight: Radius.circular(4.0)),
                                ),
                              ),
                              onTap: () {
                                if (_sortOrder != SORT_ORDER_SIZE) {
                                  setState(() {
                                    _sortOrder = SORT_ORDER_SIZE;
                                    eventBus.fire(UpdateVideoSortOrder(UpdateVideoSortOrder.TYPE_VIDEO_SIZE));
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        maintainSize: true,
                        maintainState: true,
                        maintainAnimation: true,
                        visible: _currentIndex != INDEX_VIDEO_FOLDERS
                      ),
                      Container(
                          child: GestureDetector(
                            child: Opacity(
                              opacity: _isDeleteBtnEnabled ? 1.0 : 0.6,
                              child: Container(
                                child: Image.asset("icons/icon_delete.png",
                                    width: 10, height: 10),
                                decoration: BoxDecoration(
                                    color: Color(0xffcb6357),
                                    border: new Border.all(
                                        color: Color(0xffb43f32), width: 1.0),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(4.0))),
                                width: 40,
                                height: 25,
                                padding:
                                EdgeInsets.fromLTRB(6.0, 4.0, 6.0, 4.0),
                              ),
                            ),
                            onTap: () {
                              debugPrint("当前删除按钮点击状态: $_isDeleteBtnEnabled");

                              if (_isDeleteBtnEnabled) {

                              }
                            },
                          ),
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 0))
                    ],
                  ),
                  width: 160,
                ),
              )
            ],
          ),
          height: Constant.HOME_NAVI_BAR_HEIGHT,
          color: Color(0xfff6f6f6),
        ),
        Divider(color: _divider_line_color, height: 1.0, thickness: 1.0),
        Expanded(
          child: PageView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              _allVideoManagerPage,
              _videoFolderManagerPage
            ],
            onPageChanged: (index) {
              debugPrint("onPageChanged, index: $index");
              setState(() {
              });
            },
            controller: pageController,
          ),
        ),
        Divider(color: _divider_line_color, height: 1.0, thickness: 1.0),
        Container(
          child: Align(
            alignment: Alignment.center,
            child: Text(itemNumStr,
                style: TextStyle(
                    inherit: false, fontSize: 12, color: Color(0xff646464))),
          ),
          height: 20,
          color: Color(0xfffafafa),
        )
      ],
    );
  }

  void updateBottomItemNumber(int allItemNum, int selectedItemNum) {
    setState(() {
      _allItemNum = allItemNum;
      _selectedItemNum = selectedItemNum;
    });
  }

  @override
  void dispose() {
    super.dispose();

    _unRegisterEventBus();
  }
}