import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_assistant_client/model/video_folder_item.dart';
import 'package:mobile_assistant_client/network/device_connection_manager.dart';

import '../../model/ResponseEntity.dart';

class VideoFolderManagerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _VideoFolderManagerState();
  }
}

class _VideoFolderManagerState extends State<VideoFolderManagerPage> {
  bool _isLoadingCompleted = true;

  final _BACKGROUND_ALBUM_SELECTED = Color(0xffe6e6e6);
  final _BACKGROUND_ALBUM_NORMAL = Colors.white;

  final _ALBUM_NAME_TEXT_COLOR_NORMAL = Color(0xff515151);
  final _ALBUM_IMAGE_NUM_TEXT_COLOR_NORMAL = Color(0xff929292);

  final _ALBUM_NAME_TEXT_COLOR_SELECTED = Colors.white;
  final _ALBUM_IMAGE_NUM_TEXT_COLOR_SELECTED = Colors.white;

  final _BACKGROUND_ALBUM_NAME_NORMAL = Colors.white;
  final _BACKGROUND_ALBUM_NAME_SELECTED = Color(0xff5d87ed);

  final _OUT_PADDING = 20.0;
  final _IMAGE_SPACE = 15.0;

  List<VideoFolderItem> _selectedVideoFolders = [];
  List<VideoFolderItem> _videoFolders = [];

  final _URL_SERVER = "http://${DeviceConnectionManager.instance.currentDevice?.ip}:8080";

  @override
  void initState() {
    super.initState();

    _getAllVideoFolders((videos) {
      setState(() {
        _videoFolders = videos;
      });
    }, (error) {

    });
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xff85a8d0);
    const spinKit = SpinKitCircle(color: color, size: 60.0);

    Widget content = _createGridContent();

    return Stack(children: [
      content,
      Visibility(
        child: Container(child: spinKit, color: Colors.white),
        maintainSize: false,
        visible: !_isLoadingCompleted,
      )
    ]);
  }

  Widget _createGridContent() {
    final imageWidth = 140.0;
    final imageHeight = 140.0;
    final imagePadding = 3.0;

    return Container(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 260,
            crossAxisSpacing: _IMAGE_SPACE,
            childAspectRatio: 1.0,
            mainAxisSpacing: _IMAGE_SPACE),
        itemBuilder: (BuildContext context, int index) {
          VideoFolderItem videoFolder = _videoFolders[index];

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                child: Container(
                  child: Stack(
                    children: [
                      Visibility(
                        child: RotationTransition(
                            turns: AlwaysStoppedAnimation(5 / 360),
                            child: Container(
                              width: imageWidth,
                              height: imageHeight,
                              padding: EdgeInsets.all(imagePadding),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Color(0xffdddddd), width: 1.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3.0))),
                            )),
                        visible: videoFolder.videoCount > 1 ? true : false,
                      ),
                      Visibility(
                        child: RotationTransition(
                            turns: AlwaysStoppedAnimation(-5 / 360),
                            child: Container(
                              width: imageWidth,
                              height: imageHeight,
                              padding: EdgeInsets.all(imagePadding),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Color(0xffdddddd), width: 1.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3.0))),
                            )),
                        visible: videoFolder.videoCount > 2 ? true : false,
                      ),
                      Container(
                        child: CachedNetworkImage(
                            imageUrl:
                                "${_URL_SERVER}/stream/video/thumbnail/${videoFolder.coverVideoId}/400/400"
                                    .replaceAll("storage/emulated/0/", ""),
                            fit: BoxFit.cover,
                            width: imageWidth,
                            height: imageWidth,
                            memCacheWidth: 400,
                            fadeOutDuration: Duration.zero,
                            fadeInDuration: Duration.zero),
                        padding: EdgeInsets.all(imagePadding),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: Color(0xffdddddd), width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(3.0))),
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                      color: _isContainsVideoFolder(_selectedVideoFolders, videoFolder)
                          ? _BACKGROUND_ALBUM_SELECTED
                          : _BACKGROUND_ALBUM_NORMAL,
                      borderRadius: BorderRadius.all(Radius.circular(4.0))),
                  padding: EdgeInsets.all(8),
                ),
                onTap: () {
                  setState(() {
                    // _setAlbumSelected(album);
                  });
                },
                onDoubleTap: () {
                  // _currentAlbum = album;
                  // _tryToOpenAlbumImages(album.id);
                },
              ),
              GestureDetector(
                child: Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        videoFolder.name,
                        style: TextStyle(
                            inherit: false,
                            color: _isContainsVideoFolder(_selectedVideoFolders, videoFolder)
                                ? _ALBUM_NAME_TEXT_COLOR_SELECTED
                                : _ALBUM_NAME_TEXT_COLOR_NORMAL),
                      ),
                      Container(
                        child: Text(
                          "(${videoFolder.videoCount})",
                          style: TextStyle(
                              inherit: false,
                              color: _isContainsVideoFolder(_selectedVideoFolders, videoFolder)
                                  ? _ALBUM_IMAGE_NUM_TEXT_COLOR_SELECTED
                                  : _ALBUM_IMAGE_NUM_TEXT_COLOR_NORMAL),
                        ),
                        margin: EdgeInsets.only(left: 3),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      color: _isContainsVideoFolder(_selectedVideoFolders, videoFolder)
                          ? _BACKGROUND_ALBUM_NAME_SELECTED
                          : _BACKGROUND_ALBUM_NAME_NORMAL),
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                ),
                onTap: () {
                  setState(() {
                    // _setAlbumSelected(album);
                  });
                },
              )
            ],
          );
        },
        itemCount: _videoFolders.length,
        shrinkWrap: true,
      ),
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(_OUT_PADDING, _OUT_PADDING, _OUT_PADDING, 0),
    );
  }

  bool _isContainsVideoFolder(List<VideoFolderItem> folders, VideoFolderItem current) {
    for (VideoFolderItem folder in folders) {
      if (folder.id == current.id) return true;
    }

    return false;
  }

  void _getAllVideoFolders(Function(List<VideoFolderItem> videos) onSuccess,
      Function(String error) onError) {
    var url = Uri.parse("${_URL_SERVER}/video/folders");
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
              .map((e) => VideoFolderItem.fromJson(e as Map<String, dynamic>))
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

}
