import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../model/response_entity.dart';
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
    final ids = videos.map((video) => video.id).toList();
    String idsStr = Uri.encodeComponent(jsonEncode(ids));

    String api = "/video/downloadVideos?ids=$idsStr";
    return await this.client.readAsBytes(api);
  }

  Future<Uint8List> readVideoFoldersAsBytes(
      List<VideoFolderItem> videoFolders) async {
    final ids = videoFolders.map((videoFolder) => videoFolder.id).toList();
    String idsStr = Uri.encodeComponent(jsonEncode(ids));

    String api = "/video/downloadVideoFolders?ids=$idsStr";
    return await this.client.readAsBytes(api);
  }

  Future<ResponseEntity> deleteVideos(List<VideoItem> videos) async {
    return await this
        .client
        .deleteVideos(videos.map((e) => e.id.toString()).toList());
  }

  Future<ResponseEntity> deleteVideoFolders(
      List<VideoFolderItem> videoFolders) async {
    return await this
        .client
        .deleteVideoFolders(videoFolders.map((e) => e.id.toString()).toList());
  }

  Future<void> copyVideosTo(
      {required List<VideoItem> videos,
      required String dir,
      Function(String fileName)? onDone,
      Function(String fileName, int current, int total)? onProgress,
      Function(String error)? onError,
      String? fileName = null}) async {
    return this.client.copyVideosTo(
        videos: videos,
        dir: dir,
        onDone: onDone,
        onProgress: onProgress,
        onError: onError,
        fileName: fileName);
  }

  Future<void> copyVideoFoldersTo(
      {required List<VideoFolderItem> videoFolders,
      required String dir,
      Function(String fileName)? onDone,
      Function(String fileName, int current, int total)? onProgress,
      Function(String error)? onError,
      String? fileName = null}) async {
    return this.client.copyVideoFoldersTo(
        videoFolders: videoFolders,
        dir: dir,
        onDone: onDone,
        onProgress: onProgress,
        onError: onError,
        fileName: fileName);
  }
}
