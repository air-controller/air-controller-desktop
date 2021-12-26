import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_assistant_client/event/update_delete_btn_status.dart';
import 'package:mobile_assistant_client/event/update_video_sort_order.dart';
import 'package:mobile_assistant_client/home/video_manager_page.dart';
import 'package:mobile_assistant_client/model/video_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile_assistant_client/network/device_connection_manager.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../model/ResponseEntity.dart';
import '../../util/event_bus.dart';
import 'package:mobile_assistant_client/event/update_bottom_item_num.dart';
import 'package:mobile_assistant_client/util/event_bus.dart';

import '../file_manager.dart';

class AllVideoManagerPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _AllVideoManagerState();
  }
}

class _AllVideoManagerState extends State<AllVideoManagerPage> with AutomaticKeepAliveClientMixin {
  final _OUT_PADDING = 20.0;
  final _IMAGE_SPACE = 15.0;
  List<VideoItem> _videos = [];
  final _IMAGE_GRID_RADIUS_SELECTED = 5.0;
  final _IMAGE_GRID_RADIUS = 1.0;

  final _IMAGE_GRID_BORDER_WIDTH_SELECTED = 4.0;
  final _IMAGE_GRID_BORDER_WIDTH = 1.0;

  List<VideoItem> _selectedVideos = [];
  final _URL_SERVER = "http://${DeviceConnectionManager.instance.currentDevice?.ip}:8080";

  // 当前排序方式
  int _currentSortOrder = VideoManagerState.SORT_ORDER_CREATE_TIME;

  StreamSubscription<UpdateVideoSortOrder>? _updateVideoSortOrderStream;
  
  late Function() _ctrlAPressedCallback;

  bool _isPageVisible = false;

  @override
  void initState() {
    super.initState();

    _ctrlAPressedCallback = () {
      if (_isPageVisible) {
        _setAllSelected();
      }
      debugPrint("Ctrl + A pressed...");
    };

    _addCtrlAPressedCallback(_ctrlAPressedCallback);

    _registerEventBus();

    _getAllVideos((videos) {
      _updateVideos(videos);
      updateBottomItemNum();
    }, (error) {
      developer.log("_getAllVideos, error: $error");
    });
  }

  void _setAllSelected() {
    setState(() {
      _selectedVideos.clear();
      _selectedVideos.addAll(_videos);
      updateBottomItemNum();
      _setDeleteBtnEnabled(true);
    });
  }

  void _setDeleteBtnEnabled(bool enable) {
    eventBus.fire(UpdateDeleteBtnStatus(enable));
  }

  void _reSortVideos() {
    _updateVideos(_videos);
  }

  void _registerEventBus() {
    _updateVideoSortOrderStream = eventBus.on<UpdateVideoSortOrder>().listen((event) {
      if (event.type == UpdateVideoSortOrder.TYPE_CREATE_TIME) {
        setState(() {
          _currentSortOrder = VideoManagerState.SORT_ORDER_CREATE_TIME;
        });
      } else {
        setState(() {
          _currentSortOrder = VideoManagerState.SORT_ORDER_SIZE;
        });
      }
      _reSortVideos();
    });
  }

  void _unRegisterEventBus() {
    _updateVideoSortOrderStream?.cancel();
  }
  
  void _updateVideos(List<VideoItem> videos) {
    var sortedVideos = videos;

    if (_currentSortOrder == VideoManagerState.SORT_ORDER_CREATE_TIME) {
      sortedVideos.sort((a, b) {
        return b.createTime - a.createTime;
      });
    } else {
      sortedVideos.sort((a, b) {
        return b.duration - a.duration;
      });
    }

    setState(() {
      _videos = sortedVideos;
    });
  }

  void _getAllVideos(Function(List<VideoItem> videos) onSuccess,
      Function(String error) onError) {
    var url = Uri.parse("${_URL_SERVER}/video/videos");
    http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({}))
        .then((response) {
      if (response.statusCode != 200) {
        onError.call(response.reasonPhrase != null
            ? response.reasonPhrase!
            : "Unknown error");
      } else {
        var body = response.body;
        debugPrint("Get all videos list, body: $body");

        final map = jsonDecode(body);
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          final data = httpResponseEntity.data as List<dynamic>;

          onSuccess.call(data
              .map((e) => VideoItem.fromJson(e as Map<String, dynamic>))
              .toList());
        } else {
          onError.call(httpResponseEntity.msg == null
              ? "Unknown error"
              : httpResponseEntity.msg!);
        }
      }
    }).catchError((error) {
      onError.call(error.toString());
    });
  }

  bool _isControlDown() {
    FileManagerPage? fileManagerPage =
    context.findAncestorWidgetOfExactType<FileManagerPage>();
    return fileManagerPage?.state?.isControlDown() == true;
  }

  bool _isShiftDown() {
    FileManagerPage? fileManagerPage =
    context.findAncestorWidgetOfExactType<FileManagerPage>();
    return fileManagerPage?.state?.isShiftDown() == true;
  }

  void _addCtrlAPressedCallback(Function() callback) {
    FileManagerPage? fileManagerPage =
    context.findAncestorWidgetOfExactType<FileManagerPage>();
    fileManagerPage?.state?.addCtrlAPressedCallback(callback);
  }

  void _removeCtrlAPressedCallback(Function() callback) {
    FileManagerPage? fileManagerPage =
    context.findAncestorWidgetOfExactType<FileManagerPage>();
    fileManagerPage?.state?.addCtrlAPressedCallback(callback);
  }

  void _setVideoSelected(VideoItem video) {
    debugPrint("Shift key down status: ${_isShiftDown()}");
    debugPrint("Control key down status: ${_isControlDown()}");

    if (!_isContainsVideo(_selectedVideos, video)) {
      if (_isControlDown()) {
        setState(() {
          _selectedVideos.add(video);
        });
      } else if (_isShiftDown()) {
        if (_selectedVideos.length == 0) {
          setState(() {
            _selectedVideos.add(video);
          });
        } else if (_selectedVideos.length == 1) {
          int index = _videos.indexOf(_selectedVideos[0]);

          int current = _videos.indexOf(video);

          if (current > index) {
            setState(() {
              _selectedVideos = _videos.sublist(index, current + 1);
            });
          } else {
            setState(() {
              _selectedVideos = _videos.sublist(current, index + 1);
            });
          }
        } else {
          int maxIndex = 0;
          int minIndex = 0;

          for (int i = 0; i < _selectedVideos.length; i++) {
            VideoItem current = _selectedVideos[i];
            int index = _videos.indexOf(current);
            if (index < 0) {
              debugPrint("Error image");
              continue;
            }

            if (index > maxIndex) {
              maxIndex = index;
            }

            if (index < minIndex) {
              minIndex = index;
            }
          }

          debugPrint("minIndex: $minIndex, maxIndex: $maxIndex");

          int current = _videos.indexOf(video);

          if (current >= minIndex && current <= maxIndex) {
            setState(() {
              _selectedVideos = _videos.sublist(current, maxIndex + 1);
            });
          } else if (current < minIndex) {
            setState(() {
              _selectedVideos = _videos.sublist(current, maxIndex + 1);
            });
          } else if (current > maxIndex) {
            setState(() {
              _selectedVideos = _videos.sublist(minIndex, current + 1);
            });
          }
        }
      } else {
        setState(() {
          _selectedVideos.clear();
          _selectedVideos.add(video);
        });
      }
    } else {
      debugPrint("It's already contains this image, id: ${video.id}");

      if (_isControlDown()) {
        setState(() {
          _selectedVideos.remove(video);
        });
      } else if (_isShiftDown()) {
        setState(() {
          _selectedVideos.remove(video);
        });
      }
    }

    _setDeleteBtnEnabled(_selectedVideos.length > 0);
    updateBottomItemNum();
  }

  void _clearSelectedVideos() {
    setState(() {
      _selectedVideos.clear();
      updateBottomItemNum();
      _setDeleteBtnEnabled(false);
    });
  }

  void _openVideoWithSystemApp(VideoItem videoItem) async {
    String encodedPath = Uri.encodeComponent(videoItem.path);
    String videoUrl = "http://${DeviceConnectionManager.instance.currentDevice?.ip}:8080/stream/file?path=${encodedPath}";

    if (!await launch(
        videoUrl,
      universalLinksOnly: true
    )) {
      debugPrint("Open video: $videoUrl fail");
    } else {
      debugPrint("Open video: $videoUrl success");
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            crossAxisSpacing: _IMAGE_SPACE,
            childAspectRatio: 1.0,
            mainAxisSpacing: _IMAGE_SPACE),
        itemBuilder: (BuildContext context, int index) {
          VideoItem videoItem = _videos[index];
          String duration = _convertToReadableTime(videoItem.duration);

          return Stack(
            children: [
              Container(
                child: GestureDetector(
                  child: CachedNetworkImage(
                    imageUrl:
                    "http://${DeviceConnectionManager.instance.currentDevice?.ip}:8080/stream/video/thumbnail/${videoItem.id}/200/200",
                    fit: BoxFit.cover,
                    width: 200,
                    height: 200,
                    memCacheWidth: 400,
                    fadeOutDuration: Duration.zero,
                    fadeInDuration: Duration.zero,
                  ),
                  onTap: () {
                    _setVideoSelected(videoItem);
                  },
                  onDoubleTap: () {
                    debugPrint("双击");
                    _openVideoWithSystemApp(videoItem);
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
                            color: Colors.white
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
          );
        },
        itemCount: _videos.length,
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
            _clearSelectedVideos();
          },
        ),
        onVisibilityChanged: (info) {
          _isPageVisible = info.visibleFraction >= 1.0;

          if (_isPageVisible) {
            updateBottomItemNum();
          }
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

  void updateBottomItemNum() {
    eventBus.fire(UpdateBottomItemNum(_videos.length, _selectedVideos.length));
  }

  @override
  void dispose() {
    super.dispose();

    _removeCtrlAPressedCallback(_ctrlAPressedCallback);
    _unRegisterEventBus();
  }

  @override
  bool get wantKeepAlive => true;
}