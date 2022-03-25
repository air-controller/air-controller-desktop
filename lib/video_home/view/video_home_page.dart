
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:mobile_assistant_client/all_videos/view/all_videos_page.dart';
import 'package:mobile_assistant_client/l10n/l10n.dart';
import 'package:mobile_assistant_client/model/video_order_type.dart';
import 'package:mobile_assistant_client/video_folders/view/video_folders_page.dart';
import 'package:mobile_assistant_client/video_home/bloc/video_home_bloc.dart';

import '../../constant.dart';
import '../../widget/unified_delete_button.dart';

class VideoHomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VideoHomeBloc>(
        create: (context) => VideoHomeBloc(),
      child: VideoHomeView(),
    );
  }
}

class VideoHomeView extends StatelessWidget {
  bool _isBackBtnDown = false;

  @override
  Widget build(BuildContext context) {
    VideoHomeTab currentTab = context.select((VideoHomeBloc bloc) => bloc.state.tab);
    VideoOrderType currentOrderType = context.select((VideoHomeBloc bloc) => bloc.state.orderType);
    VideoHomeItemCount itemCount = context.select((VideoHomeBloc bloc) => bloc.state.itemCount);
    bool isBackVisible = context.select((VideoHomeBloc bloc) => bloc.state.isBackVisible);
    bool isOrderTypeVisible = context.select((VideoHomeBloc bloc) => bloc.state.isOrderTypeVisible);
    bool isDeleteEnabled = context.select((VideoHomeBloc bloc) => bloc.state.isDeleteEnabled);

    Color getSegmentBtnColor(VideoHomeTab tab) {
      if (tab == currentTab) {
        return Color(0xffffffff);
      } else {
        return Color(0xff5b5c62);
      }
    }

    String _getSortOrderIcon(VideoOrderType orderType) {
      if (orderType == VideoOrderType.createTime) {
        if (currentOrderType == orderType) {
          return "assets/icons/icon_grid_selected.png";
        } else {
          return "assets/icons/icon_grid_normal.png";
        }
      }

      if (currentOrderType == orderType) {
        return "assets/icons/icon_monthly_selected.png";
      } else {
        return "assets/icons/icon_monthly_normal.png";
      }
    }

    Color _getSortOrderBgColor(VideoOrderType orderType) {
      if (currentOrderType == orderType) {
        return Color(0xffc2c2c2);
      } else {
        return Color(0xfff5f5f5);
      }
    }

    String itemNumStr = context.l10n.placeHolderItemCount01.replaceFirst("%d", "${itemCount.totalCount}");
    if (itemCount.checkedCount > 0) {
      itemNumStr = context.l10n.placeHolderItemCount02.replaceFirst("%d", "${itemCount.checkedCount}")
          .replaceFirst("%d", "${itemCount.totalCount}");
    }


    final _divider_line_color = Color(0xffe0e0e0);

    return MultiBlocListener(
        listeners: [
          BlocListener<VideoHomeBloc, VideoHomeState>(listener: (context, state) {
          },
            listenWhen: (previous, current) => previous.tab != current.tab,
          )
        ],
        child: Column(
          children: [
            Container(
              child: Stack(
                children: [
                  StatefulBuilder(builder: (context, setState) {
                    return GestureDetector(
                      child: Visibility(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            child: Row(
                              children: [
                                Image.asset("assets/icons/icon_right_arrow.png",
                                    width: 12, height: 12),
                                Container(
                                  child: Text(context.l10n.back,
                                      style: TextStyle(
                                          color: Color(0xff5c5c62),
                                          fontSize: 13)),
                                  margin: EdgeInsets.only(left: 3),
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                                color: _isBackBtnDown
                                    ? Color(0xffe8e8e8)
                                    : Color(0xfff3f3f4),
                                borderRadius:
                                BorderRadius.all(Radius.circular(3.0)),
                                border: Border.all(
                                    color: Color(0xffdedede), width: 1.0)),
                            height: 25,
                            width: 50,
                            margin: EdgeInsets.only(left: 15),
                          ),
                        ),
                        visible: isBackVisible,
                      ),
                      onTap: () {
                        context.read<VideoHomeBloc>().add(VideoHomeBackTapStatusChanged(VideoHomeBackTapStatus.tap));
                      },
                      onTapDown: (detail) {
                        setState(() {
                          _isBackBtnDown = true;
                        });
                      },
                      onTapCancel: () {
                        setState(() {
                          _isBackBtnDown = false;
                        });
                      },
                      onTapUp: (detail) {
                        setState(() {
                          _isBackBtnDown = false;
                        });
                      },
                    );
                  }),

                  Align(
                      alignment: Alignment.center,
                      child: Container(
                        child: MaterialSegmentedControl<int>(
                          children: {
                            VideoHomeTab.allVideos.index: Container(
                              child: Text(context.l10n.allVideos,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: getSegmentBtnColor(VideoHomeTab.allVideos))),
                              padding: EdgeInsets.only(left: 10, right: 10),
                            ),
                            VideoHomeTab.videoFolders.index: Container(
                              child: Text(context.l10n.videoFolders,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color:
                                      getSegmentBtnColor(VideoHomeTab.videoFolders))),
                              padding: EdgeInsets.only(left: 10, right: 10),
                            ),
                          },
                          selectionIndex: currentTab.index,
                          borderColor: Color(0xffdedede),
                          selectedColor: Color(0xffc3c3c3),
                          unselectedColor: Color(0xfff7f5f6),
                          borderRadius: 3.0,
                          verticalOffset: 0,
                          disabledChildren: [],
                          onSegmentChosen: (index) {
                            context.read<VideoHomeBloc>().add(VideoHomeTabChanged(
                              VideoHomeTabX.convertToTab(index)
                            ));
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
                                          _getSortOrderIcon(VideoOrderType.createTime),
                                          width: 20,
                                          height: 20),
                                      padding: EdgeInsets.fromLTRB(13, 3, 13, 3),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Color(0xffdddedf), width: 1.0),
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(4.0),
                                            bottomLeft: Radius.circular(4.0)),
                                        color: _getSortOrderBgColor(VideoOrderType.createTime),
                                      ),
                                    ),
                                    onTap: () {
                                      VideoOrderType currentOderType = context.read<VideoHomeBloc>().state.orderType;
                                      if (currentOderType != VideoOrderType.createTime) {
                                        context.read<VideoHomeBloc>().add(
                                            VideoHomeOderTypeChanged(
                                                VideoOrderType.createTime));
                                      }
                                    },
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      child: Image.asset(
                                          _getSortOrderIcon(VideoOrderType.duration),
                                          width: 20,
                                          height: 20),
                                      padding: EdgeInsets.fromLTRB(13, 3, 13, 3),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Color(0xffdddedf), width: 1.0),
                                        color: _getSortOrderBgColor(VideoOrderType.duration),
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(4.0),
                                            bottomRight: Radius.circular(4.0)),
                                      ),
                                    ),
                                    onTap: () {
                                      VideoOrderType currentOderType = context.read<VideoHomeBloc>().state.orderType;
                                      if (currentOderType != VideoOrderType.duration) {
                                        context.read<VideoHomeBloc>().add(
                                            VideoHomeOderTypeChanged(
                                                VideoOrderType.duration));
                                      }
                                    },
                                  ),
                                ],
                              ),
                              maintainSize: true,
                              maintainState: true,
                              maintainAnimation: true,
                              visible: isOrderTypeVisible
                          ),
                          UnifiedDeleteButton(
                            isEnable: isDeleteEnabled,
                            contentDescription: context.l10n.delete,
                            onTap: () {
                              if (isDeleteEnabled) {
                                context.read<VideoHomeBloc>().add(VideoHomeDeleteTapped());
                              }
                            },
                            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                          ),
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
              child: IndexedStack(
                index: currentTab.index,
                children: [
                  AllVideosPage(),
                  VideoFoldersPage()
                ],
              ),
            ),
            Divider(color: _divider_line_color, height: 1.0, thickness: 1.0),
            Container(
              child: Align(
                alignment: Alignment.center,
                child: Text(itemNumStr,
                    style: TextStyle(
                        fontSize: 12, color: Color(0xff646464))),
              ),
              height: 20,
              color: Color(0xfffafafa),
            )
          ],
        )
    );
  }
}