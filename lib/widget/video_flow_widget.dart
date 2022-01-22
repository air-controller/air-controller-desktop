
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_assistant_client/model/video_item.dart';
import 'package:mobile_assistant_client/network/device_connection_manager.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../constant.dart';

class VideoFlowWidget extends StatelessWidget {
  final _OUT_PADDING = 20.0;
  final _IMAGE_SPACE = 10.0;
  List<VideoItem> _videos = [];
  final _IMAGE_GRID_RADIUS_SELECTED = 5.0;
  final _IMAGE_GRID_RADIUS = 1.0;

  final _IMAGE_GRID_BORDER_WIDTH_SELECTED = 4.0;
  final _IMAGE_GRID_BORDER_WIDTH = 1.0;

  List<VideoItem> _selectedVideos = [];
  final _URL_SERVER = "http://${DeviceConnectionManager.instance.currentDevice?.ip}:${Constant.PORT_HTTP}";

  // 当前排序方式
  int _currentSortOrder = SORT_ORDER_CREATE_TIME;

  Function(VideoItem video)? _onVideoTap;
  Function()? _onOutsideTap;
  Function(bool isTotalVisible, bool isPartOfVisible)? _onVisibleChange;
  Function(VideoItem video)? _onVideoDoubleTap;
  Function(PointerDownEvent event, VideoItem videoItem)? _onPointerDown;

  static final SORT_ORDER_CREATE_TIME = 1;
  static final SORT_ORDER_DURATION = 2;

  VideoFlowWidget({
    required List<VideoItem> videos,
    required List<VideoItem> selectedVideos,
    required int sortOrder,
    required Function(VideoItem video)? onVideoTap,
    required Function()? onOutsideTap,
    required Function(bool isTotalVisible, bool isPartOfVisible)? onVisibleChange,
    required Function(VideoItem video)? onVideoDoubleTap,
    required Function(PointerDownEvent event, VideoItem videoItem) onPointerDown
}) {
    _videos = videos;
    _selectedVideos = selectedVideos;
    _currentSortOrder = sortOrder;
    _onVideoTap = onVideoTap;
    _onOutsideTap = onOutsideTap;
    _onVisibleChange = onVisibleChange;
    _onVideoDoubleTap = onVideoDoubleTap;
    _onPointerDown = onPointerDown;
  }

  @override
  Widget build(BuildContext context) {
    var sortedVideos = _videos;

    if (_currentSortOrder == SORT_ORDER_CREATE_TIME) {
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
                  child: GestureDetector(
                    child: CachedNetworkImage(
                      imageUrl:
                      "${_URL_SERVER}/stream/video/thumbnail/${videoItem.id}/200/200",
                      fit: BoxFit.cover,
                      width: 160,
                      height: 160,
                      memCacheWidth: 400,
                      fadeOutDuration: Duration.zero,
                      fadeInDuration: Duration.zero,
                    ),
                    onTap: () {
                      _onVideoTap?.call(videoItem);
                    },
                    onDoubleTap: () {
                      debugPrint("双击");
                      _onVideoDoubleTap?.call(videoItem);
                    },
                  ),
                  decoration: BoxDecoration(
                      border: new Border.all(
                          color: _isContainsVideo(_selectedVideos, videoItem)
                              ? Color(0xff5d86ec)
                              : Color(0xffdedede),
                          width: _isContainsVideo(_selectedVideos, videoItem)
                              ? _IMAGE_GRID_BORDER_WIDTH_SELECTED
                              : _IMAGE_GRID_BORDER_WIDTH),
                      borderRadius: new BorderRadius.all(Radius.circular(
                          _isContainsVideo(_selectedVideos, videoItem)
                              ? _IMAGE_GRID_RADIUS_SELECTED
                              : _IMAGE_GRID_RADIUS))),
                ),
                Container(
                  child: Align(
                    child: Row(
                      children: [
                        Image.asset("icons/ic_video_indictor.png", width: 20, height: 20),

                        Container(
                          child: Text(duration, style: TextStyle(
                              inherit: false,
                              fontSize: 14,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                    offset: Offset(0, 0),
                                    blurRadius: 3.0,
                                    color: Colors.black
                                )
                              ]
                          )),
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
              _onPointerDown?.call(event, videoItem);
            },
          );
        },
        itemCount: sortedVideos.length,
        shrinkWrap: true,
      ),
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(_OUT_PADDING, _OUT_PADDING, _OUT_PADDING, 0),
    );

    return VisibilityDetector(
        key: Key("all_video_manager"),
        child: GestureDetector(
          child: content,
          onTap: () {
            _onOutsideTap?.call();
          },
        ),
        onVisibilityChanged: (info) {
          _onVisibleChange?.call(info.visibleFraction >= 1.0, info.visibleFraction > 0 && info.visibleFraction < 1.0);
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

  bool _isContainsVideo(List<VideoItem> images, VideoItem current) {
    for (VideoItem imageItem in images) {
      if (imageItem.id == current.id) return true;
    }

    return false;
  }
}