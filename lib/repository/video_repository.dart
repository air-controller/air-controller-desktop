import 'dart:io';

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
}
