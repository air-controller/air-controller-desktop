import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as DioCore;
import 'package:flutter/foundation.dart';

import '../model/app_info.dart';
import '../model/mobile_info.dart';
import '../model/response_entity.dart';
import 'aircontroller_client.dart';

class CommonRepository {
  final AirControllerClient client;

  CommonRepository({required AirControllerClient client})
      : this.client = client;

  Future<MobileInfo> getMobileInfo() => this.client.getMobileInfo();

  Future<List<AppInfo>> getInstalledApps() => this.client.getInstalledApps();

  Future<DioCore.CancelToken> uploadAndInstall(
      {required bool isFromWeb,
      File? bundle,
      String? fileName,
      Uint8List? bytes,
      Function(int sent, int total)? onUploadProgress,
      VoidCallback? onSuccess,
      Function(String? error)? onError,
      VoidCallback? onCancel}) {
    return this.client.uploadAndInstall(
        isFromWeb: isFromWeb,
        bundle: bundle,
        fileName: fileName,
        bytes: bytes,
        onUploadProgress: onUploadProgress,
        onSuccess: onSuccess,
        onError: onError,
        onCancel: onCancel);
  }

  Future<DioCore.CancelToken> tryToInstallFromCache(
      {required String fileName,
      required String md5,
      VoidCallback? onSuccess,
      Function(String? error)? onError,
      VoidCallback? onCancel}) {
    return this.client.tryToInstallFromCache(
        fileName: fileName,
        md5: md5,
        onSuccess: onSuccess,
        onCancel: onCancel,
        onError: onError);
  }

  void exportApk(
      {required String packageName,
      required String dir,
      required String fileName,
      Function(int current, int total)? onExportProgress,
      Function(String dir, String name)? onSuccess,
      Function(String error)? onError}) {
    return this.client.exportApk(
        packageName: packageName,
        dir: dir,
        fileName: fileName,
        onExportProgress: onExportProgress,
        onSuccess: onSuccess,
        onError: onError);
  } 

  Future<DioCore.CancelToken> exportApks(
      {required List<String> packages,
      required String dir,
      required String fileName,
      Function(int current, int total)? onExportProgress,
      Function(String dir, String name)? onSuccess,
      Function()? onCancel,
      Function(String error)? onError}) {
    return this.client.exportApks(
        packages: packages,
        dir: dir,
        fileName: fileName,
        onExportProgress: onExportProgress,
        onCancel: onCancel,
        onSuccess: onSuccess,
        onError: onError);
  }

  Future<DioCore.CancelToken> batchUninstall(
      {required List<String> packages,
      Function()? onSuccess,
      Function()? onCancel,
      Function(String error)? onError}) {
    return this.client.batchUninstall(
        packages: packages,
        onError: onError,
        onCancel: onCancel,
        onSuccess: onSuccess);
  }

  Future<ResponseEntity> connect(String? pwd) => this.client.connect(pwd);

  Future<Uint8List> readPackagesAsBytes(List<AppInfo> apps) {
    String packagesStr = Uri.encodeComponent(
        jsonEncode(apps.map((e) => e.packageName).toList()));

    return this
        .client
        .readAsBytes("/stream/downloadApks?packages=$packagesStr");
  }
}
