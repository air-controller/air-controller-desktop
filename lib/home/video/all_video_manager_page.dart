import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_assistant_client/model/video_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile_assistant_client/network/device_connection_manager.dart';
import 'package:http/http.dart' as http;
import '../../model/ResponseEntity.dart';

class AllVideoManagerPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _AllVideoManagerState();
  }
}

class _AllVideoManagerState extends State<AllVideoManagerPage> {
  final _OUT_PADDING = 20.0;
  final _IMAGE_SPACE = 15.0;
  List<VideoItem> _videos = [];
  final _IMAGE_GRID_RADIUS_SELECTED = 5.0;
  final _IMAGE_GRID_RADIUS = 1.0;

  final _IMAGE_GRID_BORDER_WIDTH_SELECTED = 4.0;
  final _IMAGE_GRID_BORDER_WIDTH = 1.0;

  List<VideoItem> _selectedVideos = [];
  final _URL_SERVER = "http://${DeviceConnectionManager.instance.currentDevice?.ip}:8080";

  @override
  void initState() {
    super.initState();

    _getAllVideos((videos) {
      setState(() {
        _videos = videos;
      });
    }, (error) {
      developer.log("_getAllVideos, error: $error");
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
        debugPrint("Get all image list, body: $body");

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
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            crossAxisSpacing: _IMAGE_SPACE,
            childAspectRatio: 1.0,
            mainAxisSpacing: _IMAGE_SPACE),
        itemBuilder: (BuildContext context, int index) {
          VideoItem videoItem = _videos[index];

          return Container(
            child: GestureDetector(
              child: CachedNetworkImage(
                imageUrl:
                "http://${DeviceConnectionManager.instance.currentDevice?.ip}:8080/stream/video/thumbnail/${videoItem.id}/200/200"
                    .replaceAll("storage/emulated/0/", ""),
                fit: BoxFit.cover,
                width: 200,
                height: 200,
                memCacheWidth: 400,
                fadeOutDuration: Duration.zero,
                fadeInDuration: Duration.zero,
              ),
              onTap: () {
              },
              onDoubleTap: () {
                debugPrint("双击");
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
          );
        },
        itemCount: _videos.length,
        shrinkWrap: true,
      ),
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(_OUT_PADDING, _OUT_PADDING, _OUT_PADDING, 0),
    );
  }

  bool _isContainsVideo(List<VideoItem> images, VideoItem current) {
    for (VideoItem imageItem in images) {
      if (imageItem.id == current.id) return true;
    }

    return false;
  }
}