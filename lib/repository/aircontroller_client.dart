import 'dart:convert';
import 'dart:io';

import 'package:flowder/flowder.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import '../constant.dart';
import '../enter/view/enter_page.dart';
import '../model/AlbumItem.dart';
import '../model/AudioItem.dart';
import '../model/FileItem.dart';
import '../model/ImageItem.dart';
import '../model/ResponseEntity.dart';
import '../model/mobile_info.dart';
import '../model/video_folder_item.dart';
import '../model/video_item.dart';

class BusinessError implements Exception {
  final String? message;

  BusinessError(this.message);
}

class AirControllerClient {
  final String _domain;
  DownloaderCore? _downloaderCore;

  AirControllerClient({required String domain}) : _domain = domain;

  Future<List<ImageItem>> getAllImages() async {

    var uri = Uri.parse("${_domain}/image/all");
    Response response = await post(uri,
        headers: _commonHeaders(), body: json.encode({}));

    if (response.statusCode == 200) {
      var body = response.body;

      final map = jsonDecode(body);
      final httpResponseEntity = ResponseEntity.fromJson(map);

      if (httpResponseEntity.isSuccessful()) {
        final data = httpResponseEntity.data as List<dynamic>;

        final images = data
            .map((e) => ImageItem.fromJson(e as Map<String, dynamic>))
            .toList();
        return images;
      } else {
        throw BusinessError(httpResponseEntity.msg == null
            ? "Unknown error"
            : httpResponseEntity.msg);
      }
    } else {
      throw BusinessError(response.reasonPhrase != null
          ? response.reasonPhrase!
          : "Unknown error");
    }
  }

  Future<MobileInfo> getMobileInfo() async {
    var uri = Uri.parse("${_domain}/common/mobileInfo");
    Response response = await post(uri,
        headers: _commonHeaders(), body: json.encode({}));

    if (response.statusCode == 200) {
      var body = response.body;

      final map = jsonDecode(body);
      final httpResponseEntity = ResponseEntity.fromJson(map);

      if (httpResponseEntity.isSuccessful()) {
        final map = httpResponseEntity.data as Map<String, dynamic>;

        final mobileInfo = MobileInfo.fromJson(map);
        return mobileInfo;
      } else {
        throw BusinessError(httpResponseEntity.msg == null
            ? "Unknown error"
            : httpResponseEntity.msg);
      }
    } else {
      throw BusinessError(response.reasonPhrase != null
          ? response.reasonPhrase!
          : "Unknown error");
    }
  }

  Future<List<ImageItem>> getCameraImages() async {
    var uri = Uri.parse("${_domain}/image/albumImages");
    Response response = await post(uri,
        headers: _commonHeaders(), body: json.encode({}));

    if (response.statusCode == 200) {
      var body = response.body;

      final map = jsonDecode(body);
      final httpResponseEntity = ResponseEntity.fromJson(map);

      if (httpResponseEntity.isSuccessful()) {
        final data = httpResponseEntity.data as List<dynamic>;

        final images = data
            .map((e) => ImageItem.fromJson(e as Map<String, dynamic>))
            .toList();
        return images;
      } else {
        throw BusinessError(httpResponseEntity.msg == null
            ? "Unknown error"
            : httpResponseEntity.msg);
      }
    } else {
      throw BusinessError(response.reasonPhrase != null
          ? response.reasonPhrase!
          : "Unknown error");
    }
  }

  @Deprecated("Use deleteFiles instead!")
  Future<List<ImageItem>> deleteImages(List<ImageItem> images) async {
    var url = Uri.parse("${_domain}/image/delete");
    Response response = await post(url,
        headers: _commonHeaders(),
        body:
            json.encode({"paths": images.map((image) => image.path).toList()}));

    if (response.statusCode == 200) {
      var body = response.body;

      final map = jsonDecode(body);
      final httpResponseEntity = ResponseEntity.fromJson(map);

      if (httpResponseEntity.isSuccessful()) {
        return images;
      } else {
        throw BusinessError(httpResponseEntity.msg == null
            ? "Unknown error"
            : httpResponseEntity.msg);
      }
    } else {
      throw BusinessError(response.reasonPhrase != null
          ? response.reasonPhrase!
          : "Unknown error");
    }
  }

  void copyFileTo(
      {required List<String> paths,
      required String dir,
      Function(String fileName)? onDone,
      Function(String fileName, int current, int total)? onProgress,
      Function(String error)? onError,
      String? fileName = null}) async {
    String name = "";

    if (fileName == null) {
      if (paths.length <= 1) {
        int index = paths.single.lastIndexOf("/");

        if (index != -1) {
          name = paths.single.substring(index + 1);
        }
      } else {
        final df = DateFormat("yyyyMd_HHmmss");

        String formatTime = df.format(new DateTime.fromMillisecondsSinceEpoch(
            DateTime.now().millisecondsSinceEpoch));

        name = "AirController_${formatTime}.zip";
      }
    } else {
      name = fileName;
    }

    var options = DownloaderUtils(
        progress: ProgressImplementation(),
        file: File("$dir/$name"),
        onDone: () {
          onDone?.call(name);
        },
        progressCallback: (current, total) {
          onProgress?.call(name, current, total);
        });

    String pathsStr = Uri.encodeComponent(jsonEncode(paths));

    String api = "${_domain}/stream/download?paths=$pathsStr";

    try {
      if (null == _downloaderCore) {
        _downloaderCore = await Flowder.download(api, options);
      } else {
        _downloaderCore?.download(api, options);
      }
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  // Solving this problem like this is not so good, improve it later.
  void cancelDownload() {
    _downloaderCore?.cancel();
  }

  Future<List<AlbumItem>> getAllAlbums() async {
    var url = Uri.parse("${_domain}/image/albums");
    Response response = await post(url,
        headers: _commonHeaders(), body: json.encode({}));

    if (response.statusCode == 200) {
      var body = response.body;

      final map = jsonDecode(body);
      final httpResponseEntity = ResponseEntity.fromJson(map);

      if (httpResponseEntity.isSuccessful()) {
        final data = httpResponseEntity.data as List<dynamic>;
        final albums = data
            .map((e) => AlbumItem.fromJson(e as Map<String, dynamic>))
            .toList();
        return albums;
      } else {
        throw BusinessError(httpResponseEntity.msg == null
            ? "Unknown error"
            : httpResponseEntity.msg);
      }
    } else {
      throw BusinessError(response.reasonPhrase != null
          ? response.reasonPhrase!
          : "Unknown error");
    }
  }

  Future<List<ImageItem>> getImagesInAlbum(AlbumItem albumItem) async {
    var url = Uri.parse("${_domain}/image/imagesOfAlbum");
    Response response = await post(url,
        headers: _commonHeaders(),
        body: json.encode({"id": albumItem.id}));

    if (response.statusCode == 200) {
      var body = response.body;

      final map = jsonDecode(body);
      final httpResponseEntity = ResponseEntity.fromJson(map);

      if (httpResponseEntity.isSuccessful()) {
        final data = httpResponseEntity.data as List<dynamic>;
        final images = data
            .map((e) => ImageItem.fromJson(e as Map<String, dynamic>))
            .toList();
        return images;
      } else {
        throw BusinessError(httpResponseEntity.msg == null
            ? "Unknown error"
            : httpResponseEntity.msg);
      }
    } else {
      throw BusinessError(response.reasonPhrase != null
          ? response.reasonPhrase!
          : "Unknown error");
    }
  }

  Future<ResponseEntity> deleteFiles(List<String> paths) async {
    var url = Uri.parse("${_domain}/file/deleteMulti");
    Response response = await post(url,
        headers: _commonHeaders(),
        body: json.encode({"paths": paths}));

    if (response.statusCode != 200) {
      throw BusinessError(response.reasonPhrase != null
          ? response.reasonPhrase!
          : "Unknown error");
    } else {
      var body = response.body;

      final map = jsonDecode(body);
      final httpResponseEntity = ResponseEntity.fromJson(map);

      if (httpResponseEntity.isSuccessful()) {
        return httpResponseEntity;
      } else {
        throw BusinessError(httpResponseEntity.msg == null
            ? "Unknown error"
            : httpResponseEntity.msg!);
      }
    }
  }

  Future<List<AudioItem>> getAllAudios() async {
    var url = Uri.parse("$_domain/audio/all");
    Response response = await post(url,
        headers: _commonHeaders(), body: json.encode({}));

    if (response.statusCode != 200) {
      throw BusinessError(response.reasonPhrase != null
          ? response.reasonPhrase!
          : "Unknown error");
    } else {
      var body = response.body;

      final map = jsonDecode(body);
      final httpResponseEntity = ResponseEntity.fromJson(map);

      if (httpResponseEntity.isSuccessful()) {
        final data = httpResponseEntity.data as List<dynamic>;

        return data
            .map((e) => AudioItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw BusinessError(httpResponseEntity.msg == null
            ? "Unknown error"
            : httpResponseEntity.msg!);
      }
    }
  }

  Future<List<VideoItem>> getAllVideos() async {
    var url = Uri.parse("${_domain}/video/videos");
    Response response = await post(url,
        headers: _commonHeaders(), body: json.encode({}));

    if (response.statusCode != 200) {
      throw BusinessError(response.reasonPhrase != null
          ? response.reasonPhrase!
          : "Unknown error");
    } else {
      var body = response.body;

      final map = jsonDecode(body);
      final httpResponseEntity = ResponseEntity.fromJson(map);

      if (httpResponseEntity.isSuccessful()) {
        final data = httpResponseEntity.data as List<dynamic>;

        return data
            .map((e) => VideoItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw BusinessError(httpResponseEntity.msg == null
            ? "Unknown error"
            : httpResponseEntity.msg!);
      }
    }
  }

  Future<List<VideoFolderItem>> getAllVideoFolders() async {
    var url = Uri.parse("${_domain}/video/folders");
    Response response = await post(url,
        headers: _commonHeaders(), body: json.encode({}));

    if (response.statusCode != 200) {
      throw BusinessError(response.reasonPhrase != null
          ? response.reasonPhrase!
          : "Unknown error");
    } else {
      var body = response.body;

      final map = jsonDecode(body);
      final httpResponseEntity = ResponseEntity.fromJson(map);

      if (httpResponseEntity.isSuccessful()) {
        final data = httpResponseEntity.data as List<dynamic>;

        return data
            .map((e) => VideoFolderItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw BusinessError(httpResponseEntity.msg == null
            ? "Unknown error"
            : httpResponseEntity.msg!);
      }
    }
  }

  Future<List<VideoItem>> getVideosInFolder(String folderId) async {
    var url = Uri.parse("${_domain}/video/videosInFolder");
    Response response = await post(url,
        headers: _commonHeaders(),
        body: json.encode({"folderId": folderId}));

    if (response.statusCode != 200) {
      throw BusinessError(response.reasonPhrase != null
          ? response.reasonPhrase!
          : "Unknown error");
    } else {
      var body = response.body;

      final map = jsonDecode(body);
      final httpResponseEntity = ResponseEntity.fromJson(map);

      if (httpResponseEntity.isSuccessful()) {
        final data = httpResponseEntity.data as List<dynamic>;

        return data
            .map((e) => VideoItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw BusinessError(httpResponseEntity.msg == null
            ? "Unknown error"
            : httpResponseEntity.msg!);
      }
    }
  }

  Future<List<FileItem>> getFiles(String? path) async {
    var url = Uri.parse("${_domain}/file/list");
    Response response = await post(url,
        headers: _commonHeaders(),
        body: json.encode({"path": path == null ? "" : path}));

    if (response.statusCode != 200) {
      throw BusinessError(response.reasonPhrase != null
          ? response.reasonPhrase!
          : "Unknown error");
    } else {
      var body = response.body;

      final map = jsonDecode(body);
      final httpResponseEntity = ResponseEntity.fromJson(map);

      if (httpResponseEntity.isSuccessful()) {
        final data = httpResponseEntity.data as List<dynamic>;

        return data
            .map((e) => FileItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw BusinessError(httpResponseEntity.msg == null
            ? "Unknown error"
            : httpResponseEntity.msg!);
      }
    }
  }

  Future<List<FileItem>> getDownloadFiles() async {
    var url = Uri.parse("${_domain}/file/downloadedFiles");
    Response response = await post(url,
        headers: _commonHeaders(), body: json.encode({}));

    if (response.statusCode != 200) {
      throw BusinessError(response.reasonPhrase != null
          ? response.reasonPhrase!
          : "Unknown error");
    } else {
      var body = response.body;

      final map = jsonDecode(body);
      final httpResponseEntity = ResponseEntity.fromJson(map);

      if (httpResponseEntity.isSuccessful()) {
        final data = httpResponseEntity.data as List<dynamic>;

        return data
            .map((e) => FileItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw BusinessError(httpResponseEntity.msg == null
            ? "Unknown error"
            : httpResponseEntity.msg!);
      }
    }
  }

  Future<ResponseEntity> rename(FileItem file, String newName) async {
    var url = Uri.parse("${_domain}/file/rename");
    Response response = await post(url,
        headers: _commonHeaders(),
        body: json.encode({
          "folder": file.folder,
          "file": file.name,
          "newName": newName,
          "isDir": file.isDir
        }));

    if (response.statusCode != 200) {
      throw BusinessError(response.reasonPhrase != null
          ? response.reasonPhrase!
          : "Unknown error");
    } else {
      var body = response.body;

      final map = jsonDecode(body);
      final httpResponseEntity = ResponseEntity.fromJson(map);

      if (httpResponseEntity.isSuccessful()) {
        return httpResponseEntity;
      } else {
        throw BusinessError(httpResponseEntity.msg == null
            ? "Unknown error"
            : httpResponseEntity.msg!);
      }
    }
  }

  Map<String, String> _commonHeaders() {
    BuildContext? context = EnterPage.enterKey.currentContext;

    String languageCode = Constant.DEFAULT_LANGUAGE_CODE;
    if (null != context) {
      languageCode = Localizations.localeOf(context).languageCode;
    }

    return {
      "Content-Type": "application/json",
      "languageCode": languageCode
    };
  }
}
