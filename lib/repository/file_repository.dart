import 'dart:io';

import 'package:air_controller/repository/root_dir_type.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../model/file_item.dart';
import '../model/response_entity.dart';
import 'aircontroller_client.dart';

class FileRepository {
  final AirControllerClient client;

  FileRepository({required AirControllerClient client}) : this.client = client;

  Future<ResponseEntity> deleteFiles(List<String> paths) =>
      this.client.deleteFiles(paths);

  void copyFilesTo(
          {required List<String> paths,
          required String dir,
          Function(String fileName)? onDone,
          Function(String fileName, int current, int total)? onProgress,
          Function(String error)? onError,
          String? fileName = null}) =>
      this.client.copyFileTo(
          paths: paths,
          dir: dir,
          onDone: onDone,
          onError: onError,
          onProgress: onProgress,
          fileName: fileName);

  void cancelCopy() => this.client.cancelDownload();

  Future<List<FileItem>> getFiles(String? path) => this.client.getFiles(path);

  Future<List<FileItem>> getDownloadFiles() => this.client.getDownloadFiles();

  Future<ResponseEntity> rename(FileItem file, String newName) =>
      this.client.rename(file, newName);

  Future<CancelToken> uploadFiles(
          {required RootDirType rootDirType,
          required List<File> files,
          String? folder = null,
          Function()? onSuccess,
          Function(int, int)? onUploading,
          Function(String? error)? onError,
          VoidCallback? onCancel}) =>
      this.client.uploadFiles(
          rootDirType: rootDirType,
          files: files,
          folder: folder,
          onSuccess: onSuccess,
          onUploading: onUploading,
          onError: onError,
          onCancel: onCancel);
}
