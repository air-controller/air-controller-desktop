import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../model/video_folder_item.dart';
import '../model/video_item.dart';
import 'aircontroller_client.dart';

class VideoRepository {
  final AirControllerClient client;

  VideoRepository({required AirControllerClient client}) : this.client = client;

  Future<List<VideoItem>> getAllVideos() => this.client.getAllVideos();

  Future<List<VideoFolderItem>> getAllVideoFolders() =>
      this.client.getAllVideoFolders();

  Future<List<VideoItem>> getVideosInFolder(String folderId) =>
      this.client.getVideosInFolder(folderId);

  CancelToken uploadVideos(
          {required List<File> videos,
          String? folder = null,
          Function()? onSuccess,
          Function(int, int)? onUploading,
          Function(String? error)? onError,
          VoidCallback? onCancel}) =>
      this.client.uploadVideos(
          videos: videos,
          folder: folder,
          onSuccess: onSuccess,
          onUploading: onUploading,
          onError: onError,
          onCancel: onCancel);

  Future<Uint8List> readVideosAsBytes(List<VideoItem> videos) async {
    final paths = videos.map((video) => video.path).toList();
    String pathsStr = Uri.encodeComponent(jsonEncode(paths));

    String api = "/stream/download?paths=$pathsStr";
    return await this.client.readAsBytes(api);
  }

  Future<Uint8List> readVideoFoldersAsBytes(
      List<VideoFolderItem> videoFolders) async {
    final paths = videoFolders.map((videoFolder) => videoFolder.path).toList();
    String pathsStr = Uri.encodeComponent(jsonEncode(paths));

    String api = "/stream/download?paths=$pathsStr";
    return await this.client.readAsBytes(api);
  }
}
