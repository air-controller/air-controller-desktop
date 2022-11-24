import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/audio_item.dart';
import '../model/file_item.dart';
import '../model/video_item.dart';
import '../network/device_connection_manager.dart';

class SystemAppLauncher {
  static void openVideo(VideoItem videoItem) async {
    String videoUrl =
        "${DeviceConnectionManager.instance.rootURL}/video/item/${videoItem.id}";

    if (!await launchUrl(Uri.parse(videoUrl))) {
      debugPrint("Open video: $videoUrl fail");
    } else {
      debugPrint("Open video: $videoUrl success");
    }
  }

  static void openAudio(AudioItem audioItem) async {
    String audioUrl =
        "${DeviceConnectionManager.instance.rootURL}/audio/item/${audioItem.id}";

    if (!await launchUrl(Uri.parse(audioUrl))) {
      debugPrint("Open audio: $audioUrl fail");
    } else {
      debugPrint("Open audio: $audioUrl success");
    }
  }

  static void openFile(FileItem item) async {
    String encodedPath = Uri.encodeFull("${item.folder}/${item.name}");
    String url =
        "${DeviceConnectionManager.instance.rootURL}/stream/file?path=$encodedPath";

    if (!await launchUrl(Uri.parse(url))) {
      debugPrint("Open file: $url fail");
    } else {
      debugPrint("Open file: $url success");
    }
  }

  static void openUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      debugPrint("Open url: $url fail");
    } else {
      debugPrint("Open url: $url success");
    }
  }
}
