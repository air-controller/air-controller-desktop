import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constant.dart';
import '../model/AudioItem.dart';
import '../model/FileItem.dart';
import '../model/video_item.dart';
import '../network/device_connection_manager.dart';

class SystemAppLauncher {
  static void openVideo(VideoItem videoItem) async {
    String videoUrl =
        "http://${DeviceConnectionManager.instance.currentDevice?.ip}:${Constant.PORT_HTTP}/video/item/${videoItem.id}";

    if (!await launch(videoUrl, universalLinksOnly: true)) {
      debugPrint("Open video: $videoUrl fail");
    } else {
      debugPrint("Open video: $videoUrl success");
    }
  }

  static void openAudio(AudioItem audioItem) async {
    String audioUrl =
        "http://${DeviceConnectionManager.instance.currentDevice?.ip}:${Constant.PORT_HTTP}/audio/item/${audioItem.id}";

    if (!await launch(audioUrl, universalLinksOnly: true)) {
      debugPrint("Open audio: $audioUrl fail");
    } else {
      debugPrint("Open audio: $audioUrl success");
    }
  }

  static void openFile(FileItem item) async {
    String encodedPath = Uri.encodeFull("${item.folder}/${item.name}");
    String url =
        "http://${DeviceConnectionManager.instance.currentDevice?.ip}:${Constant.PORT_HTTP}/stream/file?path=$encodedPath";

    if (!await launch(url, universalLinksOnly: true)) {
      debugPrint("Open file: $url fail");
    } else {
      debugPrint("Open file: $url success");
    }
  }

  static void openUrl(String url) async {
    if (!await launch(url, universalLinksOnly: true)) {
      debugPrint("Open url: $url fail");
    } else {
      debugPrint("Open url: $url success");
    }
  }
}
