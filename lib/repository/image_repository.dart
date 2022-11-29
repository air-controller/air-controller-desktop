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
    final ids = albums.map((album) => album.id).toList();
    String idsStr = Uri.encodeComponent(jsonEncode(ids));

    String api = "/image/downloadAlbums?ids=$idsStr";
    return await this.client.readAsBytes(api);
  }

  Future<ResponseEntity> deleteImages(List<ImageItem> images) async {
    return await this.client.deleteImages(images.map((e) => e.id).toList());
  }

  Future<ResponseEntity> deleteAlbums(List<AlbumItem> albums) async {
    return await this.client.deleteAlbums(albums.map((e) => e.id).toList());
  }

  Future<void> copyImagesTo(
      {required List<ImageItem> images,
      required String dir,
      Function(String fileName)? onDone,
      Function(String fileName, int current, int total)? onProgress,
      Function(String error)? onError,
      String? fileName = null}) async {
    return await this.client.copyImagesTo(
        dir: dir,
        images: images,
        onDone: onDone,
        onProgress: onProgress,
        onError: onError,
        fileName: fileName);
  }

  Future<void> copyImageAlbumsTo(
      {required List<AlbumItem> albums,
      required String dir,
      Function(String fileName)? onDone,
      Function(String fileName, int current, int total)? onProgress,
      Function(String error)? onError,
      String? fileName = null}) async {
    return await this.client.copyImageAlbumsTo(
        albums: albums,
        dir: dir,
        onDone: onDone,
        onProgress: onProgress,
        onError: onError,
        fileName: fileName);
  }

  void cancelCopy() => this.client.cancelDownload();
}
