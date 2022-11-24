import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import '../model/album_item.dart';
import '../model/image_item.dart';
import '../model/response_entity.dart';
import 'aircontroller_client.dart';
import 'package:dio/dio.dart' as DioCore;

class ImageRepository {
  final AirControllerClient client;

  ImageRepository({required AirControllerClient client}) : this.client = client;

  Future<List<ImageItem>> getAllImages() => this.client.getAllImages();

  Future<List<ImageItem>> getCameraImages() => this.client.getCameraImages();

  Future<ResponseEntity> deleteImages(List<ImageItem> images) =>
      this.client.deleteFiles(images.map((image) => image.path).toList());

  void copyImagesTo(
          {required List<ImageItem> images,
          required String dir,
          Function(String fileName)? onDone,
          Function(String fileName, int current, int total)? onProgress,
          Function(String error)? onError}) =>
      this.client.copyFileTo(
          paths: images.map((image) => image.path).toList(),
          dir: dir,
          onDone: onDone,
          onError: onError,
          onProgress: onProgress);

  void cancelCopy() => this.client.cancelDownload();

  Future<List<AlbumItem>> getAllAlbums() => this.client.getAllAlbums();

  Future<List<ImageItem>> getImagesInAlbum(AlbumItem albumItem) =>
      this.client.getImagesInAlbum(albumItem);

  DioCore.CancelToken uploadPhotos(
          {required int pos,
          required List<File> photos,
          String? path,
          Function(List<ImageItem>)? onSuccess,
          Function(int, int)? onUploading,
          Function(String? error)? onError,
          VoidCallback? onCancel}) =>
      this.client.uploadPhotos(
          pos: pos,
          photos: photos,
          path: path,
          onError: onError,
          onSuccess: onSuccess,
          onUploading: onUploading,
          onCancel: onCancel);

  Future<Uint8List> readImagesAsBytes(List<ImageItem> images) async {
    final paths = images.map((image) => image.path).toList();
    String pathsStr = Uri.encodeComponent(jsonEncode(paths));

    String api = "/stream/download?paths=$pathsStr";
    return await this.client.readAsBytes(api);
  }

  Future<Uint8List> readAlbumsAsBytes(List<AlbumItem> albums) async {
    final paths = albums.map((album) => album.path).toList();
    String pathsStr = Uri.encodeComponent(jsonEncode(paths));

    String api = "/stream/download?paths=$pathsStr";
    return await this.client.readAsBytes(api);
  }
}
