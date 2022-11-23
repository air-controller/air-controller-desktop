import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart' as DioCore;

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
      {required File bundle,
      Function(int sent, int total)? onUploadProgress,
      VoidCallback? onSuccess,
      Function(String? error)? onError,
      VoidCallback? onCancel}) {
    return this.client.uploadAndInstall(
        bundle: bundle,
        onUploadProgress: onUploadProgress,
        onSuccess: onSuccess,
        onError: onError,
        onCancel: onCancel);
  }

  Future<DioCore.CancelToken> tryToInstallFromCache(
      {required File bundle,
      VoidCallback? onSuccess,
      Function(String? error)? onError,
      VoidCallback? onCancel}) {
    return this.client.tryToInstallFromCache(
        bundle: bundle,
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
}
