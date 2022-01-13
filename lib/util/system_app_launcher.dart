import 'package:flutter/cupertino.dart';
import 'package:mobile_assistant_client/model/AudioItem.dart';
import 'package:mobile_assistant_client/model/FileItem.dart';
import 'package:mobile_assistant_client/model/video_item.dart';
import 'package:mobile_assistant_client/network/device_connection_manager.dart';
import 'package:mobile_assistant_client/util/file_util.dart';
import 'package:url_launcher/url_launcher.dart';

class SystemAppLauncher {
  static void openVideo(VideoItem videoItem) async {
    String videoUrl =
        "http://${DeviceConnectionManager.instance.currentDevice?.ip}:8080/video/item/${videoItem.id}";

    if (!await launch(videoUrl, universalLinksOnly: true)) {
      debugPrint("Open video: $videoUrl fail");
    } else {
      debugPrint("Open video: $videoUrl success");
    }
  }

  static void openAudio(AudioItem audioItem) async {
    String audioUrl =
        "http://${DeviceConnectionManager.instance.currentDevice?.ip}:8080/audio/item/${audioItem.id}";

    if (!await launch(audioUrl, universalLinksOnly: true)) {
      debugPrint("Open audio: $audioUrl fail");
    } else {
      debugPrint("Open audio: $audioUrl success");
    }
  }

  static void openFile(FileItem item) async {
    String url =
        "http://${DeviceConnectionManager.instance.currentDevice?.ip}:8080/stream/file?path=${item.folder}/${item.name}";

    if (!await launch(url, universalLinksOnly: true)) {
      debugPrint("Open file: $url fail");
    } else {
      debugPrint("Open file: $url success");
    }
  }
}
