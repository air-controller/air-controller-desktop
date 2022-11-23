import 'dart:convert';
import 'dart:io';

import 'package:air_controller/bootstrap.dart';
import 'package:air_controller/model/app_info.dart';
import 'package:air_controller/model/contact_basic_info.dart';
import 'package:air_controller/model/contact_data_type_map.dart';
import 'package:air_controller/model/contact_detail.dart';
import 'package:air_controller/model/delete_contacts_request_entity.dart';
import 'package:air_controller/model/update_contact_request_entity.dart';
import 'package:air_controller/util/common_util.dart';
import 'package:dio/dio.dart' as DioCore;
import 'package:flowder/flowder.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'package:path_provider/path_provider.dart';

import '../constant.dart';
import '../enter/view/enter_page.dart';
import '../model/album_item.dart';
import '../model/audio_item.dart';
import '../model/accounts_and_groups.dart';
import '../model/file_item.dart';
import '../model/image_item.dart';
import '../model/mobile_info.dart';
import '../model/new_contact_request_entity.dart';
import '../model/response_entity.dart';
import '../model/video_folder_item.dart';
import '../model/video_item.dart';
import 'root_dir_type.dart';

class BusinessError implements Exception {
  final String? message;

  BusinessError(this.message);

  toString() => message ?? 'BusinessError';
}

class AirControllerClient {
  final String _domain;
  DownloaderCore? _downloaderCore;
  late DioCore.Dio dio;

  AirControllerClient({required String domain}) : _domain = domain {
    dio = DioCore.Dio();
    dio.options.baseUrl = domain;
    dio.options.connectTimeout = 5000;
    dio.options.receiveTimeout = 3000;
  }

  Future<List<ImageItem>> getAllImages() async {
    var uri = Uri.parse("${_domain}/image/all");
    Response response =
        await post(uri, headers: _commonHeaders(), body: json.encode({}));

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
    Response response =
        await post(uri, headers: _commonHeaders(), body: json.encode({}));

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
    Response response =
        await post(uri, headers: _commonHeaders(), body: json.encode({}));

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
    Response response =
        await post(url, headers: _commonHeaders(), body: json.encode({}));

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
        headers: _commonHeaders(), body: json.encode({"id": albumItem.id}));

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
        headers: _commonHeaders(), body: json.encode({"paths": paths}));

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
    Response response =
        await post(url, headers: _commonHeaders(), body: json.encode({}));

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
    Response response =
        await post(url, headers: _commonHeaders(), body: json.encode({}));

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
    Response response =
        await post(url, headers: _commonHeaders(), body: json.encode({}));

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
        headers: _commonHeaders(), body: json.encode({"folderId": folderId}));

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
    Response response =
        await post(url, headers: _commonHeaders(), body: json.encode({}));

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

  Future<List<AppInfo>> getInstalledApps() async {
    var url = Uri.parse("${_domain}/common/installedApps");
    Response response =
        await post(url, headers: _commonHeaders(), body: json.encode({}));

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
            .map((e) => AppInfo.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw BusinessError(httpResponseEntity.msg == null
            ? "Unknown error"
            : httpResponseEntity.msg!);
      }
    }
  }

  Future<DioCore.CancelToken> uploadAndInstall(
      {required File bundle,
      Function(int sent, int total)? onUploadProgress,
      VoidCallback? onSuccess,
      Function(String? error)? onError,
      VoidCallback? onCancel}) async {
    final headers = _commonHeaders();
    headers.remove("Content-Type");

    final digest = await md5.bind(bundle.openRead()).first;
    final md5Sum = hex.encode(digest.bytes);

    final formData = DioCore.FormData.fromMap({
      "bundle": await DioCore.MultipartFile.fromFile(bundle.path),
      "md5": md5Sum
    });

    final cancelToken = DioCore.CancelToken();
    dio.post("/common/install",
        data: formData, options: DioCore.Options(headers: headers),
        onSendProgress: (int sent, int total) {
      onUploadProgress?.call(sent, total);
    }, cancelToken: cancelToken).then((response) {
      if (response.statusCode != 200) {
        onError?.call("${response.statusMessage}");
      } else {
        final map = response.data;
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          onSuccess?.call();
        } else {
          onError?.call(httpResponseEntity.msg == null
              ? "Unknown error"
              : httpResponseEntity.msg!);
        }
      }
    }).onError((error, stackTrace) {
      if (error is DioCore.DioError &&
          error.type == DioCore.DioErrorType.cancel) {
        onCancel?.call();
      } else {
        onError?.call(error?.toString());
      }
    });

    return cancelToken;
  }

  Future<DioCore.CancelToken> tryToInstallFromCache(
      {required File bundle,
      VoidCallback? onSuccess,
      Function(String? error)? onError,
      VoidCallback? onCancel}) async {
    final headers = _commonHeaders();
    headers.remove("Content-Type");

    final digest = await md5.bind(bundle.openRead()).first;
    final md5Sum = hex.encode(digest.bytes);

    int pointIndex = bundle.path.lastIndexOf(".");
    String name = bundle.path;

    if (pointIndex >= 0) {
      name = bundle.path.substring(pointIndex + 1);
    }

    final formData =
        DioCore.FormData.fromMap({"fileName": name, "md5": md5Sum});

    final cancelToken = DioCore.CancelToken();
    dio
        .post("/common/tryToInstallFromCache",
            data: formData,
            options: DioCore.Options(headers: headers),
            cancelToken: cancelToken)
        .then((response) {
      if (response.statusCode != 200) {
        onError?.call("${response.statusMessage}");
      } else {
        final map = response.data;
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          onSuccess?.call();
        } else {
          onError?.call(httpResponseEntity.msg == null
              ? "Unknown error"
              : httpResponseEntity.msg!);
        }
      }
    }).onError((error, stackTrace) {
      if (error is DioCore.DioError &&
          error.type == DioCore.DioErrorType.cancel) {
        onCancel?.call();
      } else {
        onError?.call(error?.toString());
      }
    });

    return cancelToken;
  }

  void exportApk(
      {required String packageName,
      required String dir,
      required String fileName,
      Function(int current, int total)? onExportProgress,
      Function(String dir, String name)? onSuccess,
      Function(String error)? onError}) async {
    final response = await dio.download(
        "$_domain/stream/downloadApk?package=$packageName", "$dir/$fileName",
        deleteOnError: false, options: DioCore.Options(receiveTimeout: 0),
        onReceiveProgress: (count, total) {
      onExportProgress?.call(count, total);
    });

    if (response.statusCode == 200) {
      onSuccess?.call(dir, fileName);
    } else {
      onError?.call("Export apk file failure.");
    }
  }

  Future<DioCore.CancelToken> exportApks(
      {required List<String> packages,
      required String dir,
      required String fileName,
      Function(int current, int total)? onExportProgress,
      Function(String dir, String name)? onSuccess,
      Function()? onCancel,
      Function(String error)? onError}) async {
    String packagesStr = Uri.encodeComponent(jsonEncode(packages));

    final cancelToken = DioCore.CancelToken();

    dio.download(
        "$_domain/stream/downloadApks?packages=$packagesStr", "$dir/$fileName",
        deleteOnError: false,
        options: DioCore.Options(receiveTimeout: 0),
        cancelToken: cancelToken, onReceiveProgress: (count, total) {
      onExportProgress?.call(count, total);
    }).then((response) {
      if (response.statusCode == 200) {
        onSuccess?.call(dir, fileName);
      } else {
        onError?.call("Export apk files failure.");
      }
    }).onError((error, stackTrace) {
      logger.e("Export apks failure, error: ${error.toString()}");

      if (error is DioCore.DioError &&
          error.type == DioCore.DioErrorType.cancel) {
        onCancel?.call();
      } else {
        onError?.call("Export apk files failure.");
      }
    });

    return cancelToken;
  }

  Future<DioCore.CancelToken> batchUninstall(
      {required List<String> packages,
      Function()? onSuccess,
      Function()? onCancel,
      Function(String error)? onError}) async {
    final cancelToken = DioCore.CancelToken();

    dio
        .post("/common/uninstall",
            data: packages,
            options: DioCore.Options(receiveTimeout: 0),
            cancelToken: cancelToken)
        .then((response) {
      if (response.statusCode == 200) {
        final map = response.data;
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          onSuccess?.call();
        } else {
          onError?.call(httpResponseEntity.msg == null
              ? "Unknown error"
              : httpResponseEntity.msg!);
        }
      } else {
        onError?.call("Batch uninstall failure.");
      }
    }).onError((error, stackTrace) {
      logger.e("Batch uninstall failure, error: ${error.toString()}");

      if (error is DioCore.DioError &&
          error.type == DioCore.DioErrorType.cancel) {
        onCancel?.call();
      } else {
        onError?.call("Batch uninstall failure.");
      }
    });

    return cancelToken;
  }

  Future<AccountsAndGroups> getContactAccounts() async {
    String errorMsg = "";

    try {
      final response = await dio.post("/contact/accountsAndGroups",
          options:
              DioCore.Options(receiveTimeout: 0, headers: _commonHeaders()));
      if (response.statusCode == 200) {
        final body = response.data;
        final httpResponseEntity = ResponseEntity.fromJson(body);

        if (httpResponseEntity.isSuccessful()) {
          final data = httpResponseEntity.data as Map<String, dynamic>;

          return AccountsAndGroups.fromJson(data);
        } else {
          errorMsg = httpResponseEntity.msg == null
              ? "Unknown error"
              : httpResponseEntity.msg!;
        }
      } else {
        errorMsg = "Get contact accounts failure.";
      }
    } catch (e) {
      logger.e("${e.toString()}");

      errorMsg = "Get contact accounts failure.";
    }

    throw BusinessError(errorMsg);
  }

  Future<List<ContactBasicInfo>> getAllContacts() async {
    String errorMsg = "";

    try {
      final response = await dio.post("/contact/allContacts",
          options:
              DioCore.Options(receiveTimeout: 0, headers: _commonHeaders()));
      if (response.statusCode == 200) {
        final map = response.data;
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          final list = httpResponseEntity.data as List;
          return list.map((e) => ContactBasicInfo.fromJson(e)).toList();
        } else {
          errorMsg = httpResponseEntity.msg == null
              ? "Unknown error"
              : httpResponseEntity.msg!;
        }
      } else {
        errorMsg = "Get all contacts failure.";
      }
    } catch (e) {
      errorMsg = "Get all contacts failure.";
    }

    throw BusinessError(errorMsg);
  }

  Future<List<ContactBasicInfo>> getContactsByAccount(
      String name, String type) async {
    String errorMsg = "";

    try {
      final response = await dio.post("/contact/contactsByAccount",
          data: {"name": name, "type": type},
          options:
              DioCore.Options(receiveTimeout: 0, headers: _commonHeaders()));
      if (response.statusCode == 200) {
        final map = response.data;
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          final list = httpResponseEntity.data as List;
          return list.map((e) => ContactBasicInfo.fromJson(e)).toList();
        } else {
          errorMsg = httpResponseEntity.msg == null
              ? "Unknown error"
              : httpResponseEntity.msg!;
        }
      } else {
        errorMsg = "Get contacts failure.";
      }
    } catch (e) {
      errorMsg = "Get contacts failure.";
    }

    throw BusinessError(errorMsg);
  }

  Future<List<ContactBasicInfo>> getContactsByGroupId(int groupId) async {
    String errorMsg = "";

    try {
      final response = await dio.post("/contact/contactsByGroupId",
          data: {"id": groupId},
          options:
              DioCore.Options(receiveTimeout: 0, headers: _commonHeaders()));
      if (response.statusCode == 200) {
        final map = response.data;
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          final list = httpResponseEntity.data as List;
          return list.map((e) => ContactBasicInfo.fromJson(e)).toList();
        } else {
          errorMsg = httpResponseEntity.msg == null
              ? "Unknown error"
              : httpResponseEntity.msg!;
        }
      } else {
        errorMsg = "Get contacts failure.";
      }
    } catch (e) {
      errorMsg = "Get contacts failure.";
    }

    throw BusinessError(errorMsg);
  }

  Future<ContactDetail> getContactDetail(int id) async {
    String errorMsg = "";

    try {
      final response = await dio.post("/contact/contactDetail",
          data: {"id": id},
          options:
              DioCore.Options(receiveTimeout: 0, headers: _commonHeaders()));
      if (response.statusCode == 200) {
        final map = response.data;
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          final map = response.data;
          final httpResponseEntity = ResponseEntity.fromJson(map);

          final dataMap = httpResponseEntity.data as Map<String, dynamic>;
          return ContactDetail.fromJson(dataMap);
        } else {
          errorMsg = httpResponseEntity.msg == null
              ? "Unknown error"
              : httpResponseEntity.msg!;
        }
      } else {
        errorMsg = "Get contact detail failure.";
      }
    } catch (e) {
      errorMsg = "Get contact detail failure.";
    }

    throw BusinessError(errorMsg);
  }

  Future<ContactDataTypeMap> getContactDataTypes() async {
    String errorMsg = "";

    try {
      final response = await dio.post("/contact/contactDataTypes",
          options:
              DioCore.Options(receiveTimeout: 0, headers: _commonHeaders()));
      if (response.statusCode == 200) {
        final map = response.data;
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          final dataMap = httpResponseEntity.data as Map<String, dynamic>;
          return ContactDataTypeMap.fromJson(dataMap);
        } else {
          errorMsg = httpResponseEntity.msg == null
              ? "Unknown error"
              : httpResponseEntity.msg!;
        }
      } else {
        errorMsg = "Get contact data types failure.";
      }
    } catch (e) {
      errorMsg = "Get contact data types failure.";
    }

    throw BusinessError(errorMsg);
  }

  Future<ContactDetail> createNewContact(
      NewContactRequestEntity requestEntity) async {
    String errorMsg = "";

    try {
      final response = await dio.post("/contact/createNewContact",
          data: requestEntity.toJson(),
          options:
              DioCore.Options(receiveTimeout: 0, headers: _commonHeaders()));
      if (response.statusCode == 200) {
        final map = response.data;
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          final map = response.data;
          final httpResponseEntity = ResponseEntity.fromJson(map);

          final dataMap = httpResponseEntity.data as Map<String, dynamic>;
          return ContactDetail.fromJson(dataMap);
        } else {
          errorMsg = httpResponseEntity.msg == null
              ? "Unknown error"
              : httpResponseEntity.msg!;
        }
      } else {
        errorMsg = "Create new contact failure.";
      }
    } catch (e) {
      errorMsg = "Create new contact failure.";
    }
    throw BusinessError(errorMsg);
  }

  Future<ContactDetail> uploadPhotoAndNewContact(File photo) async {
    String errorMsg = "";

    try {
      final formData = DioCore.FormData.fromMap(
          {"avatar": await DioCore.MultipartFile.fromFile(photo.path)});
      final headers = _commonHeaders();
      headers.remove("Content-Type");
      final response = await dio.post("/contact/uploadPhotoAndNewContract",
          data: formData, options: DioCore.Options(headers: headers));
      if (response.statusCode == 200) {
        final map = response.data;
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          final dataMap = httpResponseEntity.data as Map<String, dynamic>;
          return ContactDetail.fromJson(dataMap);
        } else {
          errorMsg = httpResponseEntity.msg == null
              ? "Unknown error"
              : httpResponseEntity.msg!;
        }
      } else {
        errorMsg = "Upload photo failure.";
      }
    } catch (e) {
      errorMsg = "Upload photo failure.";
    }
    throw BusinessError(errorMsg);
  }

  Future<ContactDetail> updatePhotoForContact(
      {required File photo, required int id}) async {
    String errorMsg = "";

    try {
      final formData = DioCore.FormData.fromMap({
        "avatar": await DioCore.MultipartFile.fromFile(photo.path),
        "id": id
      });
      final headers = _commonHeaders();
      headers.remove("Content-Type");
      final response = await dio.post("/contact/updatePhotoForContact",
          data: formData, options: DioCore.Options(headers: headers));
      if (response.statusCode == 200) {
        final map = response.data;
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          final dataMap = httpResponseEntity.data as Map<String, dynamic>;
          return ContactDetail.fromJson(dataMap);
        } else {
          errorMsg = httpResponseEntity.msg == null
              ? "Unknown error"
              : httpResponseEntity.msg!;
        }
      } else {
        errorMsg = "Upload photo failure.";
      }
    } catch (e) {
      errorMsg = "Upload photo failure.";
    }

    throw BusinessError(errorMsg);
  }

  Future<void> updateNewContact(
      UpdateContactRequestEntity requestEntity) async {
    String errorMsg = "";

    try {
      final response = await dio.post("/contact/updateContact",
          data: requestEntity.toJson(),
          options:
              DioCore.Options(receiveTimeout: 0, headers: _commonHeaders()));
      if (response.statusCode == 200) {
        final map = response.data;
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          return;
        } else {
          errorMsg = httpResponseEntity.msg == null
              ? "Unknown error"
              : httpResponseEntity.msg!;
        }
      } else {
        errorMsg = "Update contact failure.";
      }
    } catch (e) {
      errorMsg = "Update contact failure.";
    }

    throw BusinessError(errorMsg);
  }

  Future<void> deleteRawContacts(
      DeleteContactsRequestEntity requestEntity) async {
    String errorMsg = "";

    try {
      final response = await dio.post("/contact/deleteRawContact",
          data: requestEntity.toJson(),
          options:
              DioCore.Options(receiveTimeout: 0, headers: _commonHeaders()));
      if (response.statusCode == 200) {
        final map = response.data;
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          return;
        } else {
          errorMsg = httpResponseEntity.msg == null
              ? "Unknown error"
              : httpResponseEntity.msg!;
        }
      } else {
        errorMsg = "Delete contacts failure.";
      }
    } catch (e) {
      errorMsg = "Delete contact failure.";
    }

    throw BusinessError(errorMsg);
  }

  DioCore.CancelToken uploadPhotos(
      {required int pos,
      required List<File> photos,
      String? path,
      Function(List<ImageItem>)? onSuccess,
      Function(int, int)? onUploading,
      Function(String? error)? onError,
      VoidCallback? onCancel}) {
    final cancelToken = DioCore.CancelToken();
    final formData = DioCore.FormData();
    formData.fields.add(MapEntry("pos", pos.toString()));
    formData.fields.add(MapEntry("path", path ?? "Empty"));

    photos.forEach((photo) {
      formData.files.add(
          MapEntry("photos", DioCore.MultipartFile.fromFileSync(photo.path)));
    });

    final headers = _commonHeaders();
    headers.remove("Content-Type");

    dio.post("/image/uploadPhotos",
        data: formData,
        options: DioCore.Options(headers: headers, receiveTimeout: 0),
        onSendProgress: (int sent, int total) {
      onUploading?.call(sent, total);
    }, cancelToken: cancelToken).then((response) {
      if (response.statusCode != 200) {
        onError?.call("${response.statusMessage}");
      } else {
        final map = response.data;
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          final data = httpResponseEntity.data as List;
          final images = data.map((e) => ImageItem.fromJson(e)).toList();
          onSuccess?.call(images);
        } else {
          onError?.call(httpResponseEntity.msg == null
              ? "Unknown error"
              : httpResponseEntity.msg!);
        }
      }
    }).onError((error, stackTrace) {
      if (error is DioCore.DioError &&
          error.type == DioCore.DioErrorType.cancel) {
        onCancel?.call();
      } else {
        onError?.call(error?.toString());
      }
    });

    return cancelToken;
  }

  DioCore.CancelToken uploadAudios(
      {required List<File> audios,
      Function()? onSuccess,
      Function(int, int)? onUploading,
      Function(String? error)? onError,
      VoidCallback? onCancel}) {
    final cancelToken = DioCore.CancelToken();
    final formData = DioCore.FormData();

    audios.forEach((audio) {
      formData.files.add(
          MapEntry("audios", DioCore.MultipartFile.fromFileSync(audio.path)));
    });

    final headers = _commonHeaders();
    headers.remove("Content-Type");

    dio.post("/audio/uploadAudios",
        data: formData,
        options: DioCore.Options(headers: headers, receiveTimeout: 0),
        onSendProgress: (int sent, int total) {
      onUploading?.call(sent, total);
    }, cancelToken: cancelToken).then((response) {
      if (response.statusCode != 200) {
        onError?.call("${response.statusMessage}");
      } else {
        final map = response.data;
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          onSuccess?.call();
        } else {
          onError?.call(httpResponseEntity.msg == null
              ? "Unknown error"
              : httpResponseEntity.msg!);
        }
      }
    }).onError((error, stackTrace) {
      if (error is DioCore.DioError &&
          error.type == DioCore.DioErrorType.cancel) {
        onCancel?.call();
      } else {
        onError?.call(error?.toString());
      }
    });

    return cancelToken;
  }

  DioCore.CancelToken uploadVideos(
      {required List<File> videos,
      String? folder = null,
      Function()? onSuccess,
      Function(int, int)? onUploading,
      Function(String? error)? onError,
      VoidCallback? onCancel}) {
    final cancelToken = DioCore.CancelToken();
    final formData = DioCore.FormData();

    formData.fields.add(MapEntry("folder", "$folder"));

    videos.forEach((video) {
      formData.files.add(
          MapEntry("videos", DioCore.MultipartFile.fromFileSync(video.path)));
    });

    final headers = _commonHeaders();
    headers.remove("Content-Type");

    dio.post("/video/uploadVideos",
        data: formData,
        options: DioCore.Options(headers: headers, receiveTimeout: 0),
        onSendProgress: (int sent, int total) {
      onUploading?.call(sent, total);
    }, cancelToken: cancelToken).then((response) {
      if (response.statusCode != 200) {
        onError?.call("${response.statusMessage}");
      } else {
        final map = response.data;
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          onSuccess?.call();
        } else {
          onError?.call(httpResponseEntity.msg == null
              ? "Unknown error"
              : httpResponseEntity.msg!);
        }
      }
    }).onError((error, stackTrace) {
      if (error is DioCore.DioError &&
          error.type == DioCore.DioErrorType.cancel) {
        onCancel?.call();
      } else {
        onError?.call(error?.toString());
      }
    });

    return cancelToken;
  }

  Future<DioCore.CancelToken> uploadFiles(
      {required RootDirType rootDirType,
      required List<File> files,
      String? folder = null,
      Function()? onSuccess,
      Function(int, int)? onUploading,
      Function(String? error)? onError,
      VoidCallback? onCancel}) async {
    final cancelToken = DioCore.CancelToken();
    final formData = DioCore.FormData();

    formData.fields.add(MapEntry("rootDirType", rootDirType.value.toString()));
    formData.fields.add(MapEntry("folder", "$folder"));

    Map<String, bool> zipInfo = Map<String, bool>();
    Directory tempDir = await getTemporaryDirectory();

    await Future.forEach(files, (File file) async {
      if (FileSystemEntity.typeSync(file.path) ==
          FileSystemEntityType.directory) {
        Directory tempZipDir = Directory("${tempDir.path}/zip");
        if (!tempZipDir.existsSync()) {
          tempZipDir.createSync();
        }

        bool isSuccess = await CommonUtil.zipFile(file, tempZipDir);

        final newFileName = "${file.path.split("/").last}.zip";
        logger.d(
            "uploadFiles zipFile: $isSuccess, directory: ${tempZipDir.path}, filename: $newFileName");

        zipInfo[newFileName] = true;

        formData.files.add(MapEntry(
            "files",
            DioCore.MultipartFile.fromFileSync(
                "${tempZipDir.path}/$newFileName")));
      } else {
        formData.files.add(
            MapEntry("files", DioCore.MultipartFile.fromFileSync(file.path)));
      }
    });

    formData.fields.add(MapEntry("zipInfo", jsonEncode(zipInfo)));

    final headers = _commonHeaders();
    headers.remove("Content-Type");

    dio.post("/file/uploadFiles",
        data: formData,
        options: DioCore.Options(headers: headers, receiveTimeout: 0),
        onSendProgress: (int sent, int total) {
      onUploading?.call(sent, total);
    }, cancelToken: cancelToken).then((response) {
      if (response.statusCode != 200) {
        onError?.call("${response.statusMessage}");
      } else {
        final map = response.data;
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          onSuccess?.call();
        } else {
          onError?.call(httpResponseEntity.msg == null
              ? "Unknown error"
              : httpResponseEntity.msg!);
        }
      }
    }).onError((error, stackTrace) {
      if (error is DioCore.DioError &&
          error.type == DioCore.DioErrorType.cancel) {
        onCancel?.call();
      } else {
        onError?.call(error?.toString());
      }
    });

    return cancelToken;
  }

  Future<ResponseEntity> connect(String? pwd) async {
    String errorMsg = "";

    try {
      final response = await dio.post("/common/connect",
          data: {"passwd": pwd ?? ""},
          options:
              DioCore.Options(receiveTimeout: 0, headers: _commonHeaders()));
      if (response.statusCode == 200) {
        final map = response.data;
        final httpResponseEntity = ResponseEntity.fromJson(map);

        return httpResponseEntity;
      } else {
        errorMsg = "Connect failure, status code: ${response.statusCode}";
      }
    } catch (e) {
      errorMsg = "Connect failure, reason: ${e.toString()}";
    }

    throw BusinessError(errorMsg);
  }

  Map<String, String> _commonHeaders() {
    BuildContext? context = EnterPage.enterKey.currentContext;

    String languageCode = Constant.DEFAULT_LANGUAGE_CODE;
    if (null != context) {
      languageCode = Localizations.localeOf(context).languageCode;
    }

    return {"Content-Type": "application/json", "languageCode": languageCode};
  }
}
