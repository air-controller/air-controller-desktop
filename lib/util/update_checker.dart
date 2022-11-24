import 'dart:convert';
import 'dart:developer';

import 'package:async/async.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constant.dart';
import 'package:http/http.dart';

class UpdateAsset {
  final String name;
  final String url;
  final int size;

  const UpdateAsset(this.name, this.url, this.size);
}

abstract class UpdateChecker {
  void onUpdateAvailable(
      Function(int publishTime, String version, List<UpdateAsset> assets,
              String updateInfo)
          callback);

  void onNoUpdateAvailable(Function() callback);

  void onCheckFailure(Function(String error) callback);

  void check();

  void quit();

  static UpdateChecker create() => UpdateCheckerImpl._();
}

class UpdateCheckerImpl extends UpdateChecker {
  Function(int publishTime, String version, List<UpdateAsset> assets,
      String updateInfo)? _onUpdateAvailable;
  Function()? _onNoUpdateAvailable;
  Function(String error)? _onCheckFailure;

  CancelableCompleter? _checkUpdateFuture;

  UpdateCheckerImpl._() {}

  @override
  void check() async {
    var uri = Uri.parse(Constant.URL_UPDATE_CHECK);

    _checkUpdateFuture = CancelableCompleter(onCancel: () {
      log("UpdateChecker, cancel");
    });

    _checkUpdateFuture?.complete(get(uri));

    _checkUpdateFuture?.operation.value.then((value) async {
      Response response = value as Response;
      String body = response.body;
      log("UpdateChecker, body: $body");

      final data = jsonDecode(body);
      String version = data["name"];

      String currentVersion = Constant.CURRENT_VERSION_NAME;

      try {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        currentVersion = packageInfo.version;
      } catch (e) {
        log("UpdateChecker, get current version failure!");
      }

      int versionCode = int.parse(version.replaceAll(".", ""));
      int currentVersionCode = int.parse(currentVersion.replaceAll(".", ""));

      log("UpdateChecker, versionCode: $versionCode, currentVersionCode: $currentVersionCode");

      if (versionCode > currentVersionCode) {
        List<dynamic> assets = data["assets"];

        List<UpdateAsset> updateAssets = [];

        assets.forEach((asset) {
          String name = asset["name"];
          String url = asset["browser_download_url"];
          int size = asset["size"];
          UpdateAsset updateAsset = UpdateAsset(name, url, size);
          updateAssets.add(updateAsset);
        });

        String updateInfo = data["body"];

        String publishTime = data["published_at"];
        final dateTime = DateTime.parse(publishTime);

        log("UpdateChecker, check, time: ${dateTime.millisecondsSinceEpoch}");
        _onUpdateAvailable?.call(
            dateTime.millisecondsSinceEpoch, version, updateAssets, updateInfo);
      } else {
        _onNoUpdateAvailable?.call();
      }
    }, onError: (error) {
      log("UpdateChecker, error: $error");
      _onCheckFailure?.call(error.toString());
    });
  }

  @override
  void onCheckFailure(Function(String error) callback) {
    _onCheckFailure = callback;
  }

  @override
  void onNoUpdateAvailable(Function() callback) {
    _onNoUpdateAvailable = callback;
  }

  @override
  void onUpdateAvailable(
      Function(int publishTime, String version, List<UpdateAsset> assets,
              String updateInfo)
          callback) {
    _onUpdateAvailable = callback;
  }

  @override
  void quit() {
    _checkUpdateFuture?.operation.cancel();
  }
}
