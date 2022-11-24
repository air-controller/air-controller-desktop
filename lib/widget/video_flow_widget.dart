import 'package:air_controller/widget/simple_gesture_detector.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../model/video_item.dart';
import '../model/video_order_type.dart';

class VideoFlowWidget extends StatefulWidget {
  final String rootUrl;
  final List<VideoItem> videos;

  final List<VideoItem> selectedVideos;
  final VideoOrderType sortOrder;

  final Color backgroundColor;
  final Function(VideoItem video)? onVideoTap;
  final Function()? onOutsideTap;
  final Function(bool isTotalVisible, bool isPartOfVisible)? onVisibleChange;
  final Function(VideoItem video)? onVideoDoubleTap;
  final Function(PointerDownEvent event, VideoItem videoItem)? onPointerDown;

  VideoFlowWidget(
      {this.backgroundColor = Colors.white,
      required this.rootUrl,
      this.videos = const [],
      this.selectedVideos = const [],
      this.sortOrder = VideoOrderType.createTime,
      required this.onVideoTap,
      this.onOutsideTap,
      this.onVisibleChange,
      this.onVideoDoubleTap,
      this.onPointerDown});

  @override
  State<VideoFlowWidget> createState() {
    return _VideoFlowWidgetState();
  }
}

class _VideoFlowWidgetState extends State<VideoFlowWidget> {
  final _OUT_PADDING = 20.0;
  final _IMAGE_SPACE = 10.0;
  List<VideoItem> _videos = [];
  final _VIDEO_GRID_RADIUS_CHECKED = 5.0;
  final _VIDEO_GRID_BORDER_WIDTH_CHECKED = 3.4;

  final _VIDEO_GRID_RADIUS = 1.0;
  final _VIDEO_GRID_BORDER_WIDTH = 1.0;

  final _CHECKED_BORDER_COLOR = Color(0xff5d86ec);
  final _BORDER_COLOR = Color(0xffdedede);

  List<VideoItem> _selectedVideos = [];

  @override
  Widget build(BuildContext context) {
    var sortedVideos = [..._videos];

    if (widget.sortOrder == VideoOrderType.createTime) {
      sortedVideos.sort((a, b) {
        return b.createTime - a.createTime;
      });
    } else {
      sortedVideos.sort((a, b) {
        return b.duration - a.duration;
      });
    }

    Widget content = Container(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 160,
            crossAxisSpacing: _IMAGE_SPACE,
            childAspectRatio: 1.0,
            mainAxisSpacing: _IMAGE_SPACE),
        itemBuilder: (BuildContext context, int index) {
          VideoItem videoItem = sortedVideos[index];
          String duration = _convertToReadableTime(videoItem.duration);

          return Listener(
            child: Stack(
              children: [
                Container(
                  child: SimpleGestureDetector(
                    child: Container(
                        child: CachedNetworkImage(
                          imageUrl:
                              "${widget.rootUrl}/stream/video/thumbnail/${videoItem.id}/200/200",
                          fit: BoxFit.cover,
                          width: 160,
                          height: 160,
                          memCacheWidth: 400,
                          fadeOutDuration: Duration.zero,
                          fadeInDuration: Duration.zero,
                        ),
                        decoration: BoxDecoration(
                            border: new Border.all(
                                color: _isChecked(videoItem)
                                    ? _CHECKED_BORDER_COLOR
                                    : _BORDER_COLOR,
                                width: _VIDEO_GRID_BORDER_WIDTH),
                            borderRadius: new BorderRadius.all(
                                Radius.circular(_VIDEO_GRID_RADIUS)))),
                    onTap: () {
                      widget.onVideoTap?.call(videoItem);
                    },
                    onDoubleTap: () {
                      widget.onVideoDoubleTap?.call(videoItem);
                    },
                  ),
                  decoration: BoxDecoration(
                      border: new Border.all(
                          color: _isChecked(videoItem)
                              ? _CHECKED_BORDER_COLOR
                              : Colors.transparent,
                          width: _VIDEO_GRID_BORDER_WIDTH_CHECKED),
                      borderRadius: new BorderRadius.all(
                          Radius.circular(_VIDEO_GRID_RADIUS_CHECKED))),
                ),
                Container(
                  child: Align(
                    child: Row(
                      children: [
                        Image.asset("assets/icons/ic_video_indictor.png",
                            width: 20, height: 20),
                        Container(
                          child: Text(duration,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                        offset: Offset(0, 0),
                                        blurRadius: 3.0,
                                        color: Colors.black)
                                  ])),
                          margin: EdgeInsets.only(left: 5),
                        )
                      ],
                    ),
                    alignment: Alignment.bottomLeft,
                  ),
                  margin: EdgeInsets.only(left: 10, bottom: 10),
                )
              ],
            ),
            onPointerDown: (event) {
              widget.onPointerDown?.call(event, videoItem);
            },
          );
        },
        itemCount: sortedVideos.length,
        shrinkWrap: true,
        primary: false,
      ),
      color: widget.backgroundColor,
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.fromLTRB(_OUT_PADDING, _OUT_PADDING, _OUT_PADDING, 0),
    );

    return VisibilityDetector(
        key: Key("all_video_manager"),
        child: GestureDetector(
          child: content,
          onTap: () {
            widget.onOutsideTap?.call();
          },
        ),
        onVisibilityChanged: (info) {
          widget.onVisibleChange?.call(info.visibleFraction >= 1.0,
              info.visibleFraction > 0 && info.visibleFraction < 1.0);
        });
  }

  // 转换为更可读时间，单位：s
  String _convertToReadableTime(int duration) {
    double secDur = duration / 1000;
    int hour = secDur ~/ (60 * 60);

    int min = (secDur - hour * 60 * 60) ~/ 60;

    int sec = (secDur - hour * 60 * 60 - min * 60).toInt();

    if (hour > 0) {
      return "$hour:${min < 10 ? "0${min}" : min}:${sec < 10 ? "0${sec}" : sec}";
    } else {
      return "$min:${sec < 10 ? "0${sec}" : sec}";
    }
  }

  bool _isChecked(VideoItem video) {
    return _selectedVideos.contains(video);
  }
}
