import 'dart:developer';
import 'dart:io';

import 'package:air_controller/l10n/l10n.dart';
import 'package:air_controller/repository/aircontroller_client.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../bootstrap.dart';
import '../constant.dart';
import '../widget/confirm_dialog_builder.dart';

class CommonUtil {
  static final _KB_BOUND = 1 * 1024;
  static final _MB_BOUND = 1 * 1024 * 1024;
  static final _GB_BOUND = 1 * 1024 * 1024 * 1024;

  static final _ONE_HOUR = 60 * 60 * 1000;
  static final _ONE_MINUTE = 60 * 1000;
  static final _ONE_SECOND = 1000;

  static String convertToReadableSize(int size) {
    if (size < _KB_BOUND) {
      return "${size} bytes";
    }
    if (size >= _KB_BOUND && size < _MB_BOUND) {
      return "${(size / 1024).toStringAsFixed(1)} KB";
    }

    if (size >= _MB_BOUND && size <= _GB_BOUND) {
      return "${(size / 1024 / 1024).toStringAsFixed(1)} MB";
    }

    return "${(size / 1024 / 1024 / 1024).toStringAsFixed(1)} GB";
  }

  static String formatTime(int time, String pattern) {
    final df = DateFormat(pattern);
    return df.format(new DateTime.fromMillisecondsSinceEpoch(time));
  }

  static void showConfirmDialog(
      BuildContext context,
      String content,
      String desc,
      String negativeText,
      String positiveText,
      Function(BuildContext context) onPositiveClick,
      Function(BuildContext context) onNegativeClick) {
    Dialog dialog = ConfirmDialogBuilder()
        .content(content)
        .desc(desc)
        .negativeBtnText(negativeText)
        .positiveBtnText(positiveText)
        .onPositiveClick(onPositiveClick)
        .onNegativeClick(onNegativeClick)
        .build();

    showDialog(
        context: context,
        builder: (context) {
          return dialog;
        },
        barrierColor: Colors.transparent,
        barrierDismissible: false);
  }

  static void openFilePicker(
      String title, void onSuccess(String dir), void onError(String error)) {
    FilePicker.platform
        .getDirectoryPath(dialogTitle: title, lockParentWindow: true)
        .then((value) {
      if (null == value) {
        onError.call("Dir is null");
      } else {
        onSuccess.call(value);
      }
    }).catchError((error) {
      onError.call(error.toString());
    });
  }

  static String convertToReadableDuration(BuildContext context, int duration) {
    if (duration >= _ONE_HOUR) {
      int hour = (duration / _ONE_HOUR).truncate();

      String durStr = context.l10n.placeholderH.replaceFirst("%s", "${hour}");

      if (duration - hour * _ONE_HOUR > 0) {
        int min = ((duration - hour * _ONE_HOUR) / _ONE_MINUTE).truncate();

        durStr = context.l10n.placeholderHM
            .replaceFirst("%s", "${hour}")
            .replaceFirst("%s", "${min}");

        if (duration - hour * _ONE_HOUR - min * _ONE_MINUTE > 0) {
          int sec =
              ((duration - hour * _ONE_HOUR - min * _ONE_MINUTE) / _ONE_SECOND)
                  .truncate();

          durStr = context.l10n.placeholderHMS
              .replaceFirst("%s", "${hour}")
              .replaceFirst("%s", "${min}")
              .replaceFirst("%s", "$sec");
        }
      }

      return durStr;
    } else if (duration < _ONE_HOUR && duration >= _ONE_MINUTE) {
      int min = (duration / _ONE_MINUTE).truncate();

      String durStr = context.l10n.placeholderM.replaceFirst("%s", "$min");

      if (duration - min * _ONE_MINUTE > 0) {
        int sec = ((duration - min * _ONE_MINUTE) / _ONE_SECOND).truncate();

        durStr = context.l10n.placeholderMS
            .replaceFirst("%s", "$min")
            .replaceFirst("%s", "$sec");
      }

      return durStr;
    } else {
      int sec = (duration / _ONE_SECOND).truncate();

      return context.l10n.placeholderS.replaceFirst("%s", "$sec");
    }
  }

  static Future<String> currentVersion() async {
    String appVersion = Constant.CURRENT_VERSION_NAME;

    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
    } catch (e) {
      log("CommonUtil: get the app version failure! error: ${e.toString()}");
    }

    return appVersion;
  }

  static Future<bool> zipFile(File file, Directory dir) async {
    try {
      final encoder = ZipFileEncoder();

      final fileName = file.path.split("/").last;
      encoder.create("${dir.path}/$fileName.zip");
      if (FileSystemEntity.typeSync(file.path) ==
          FileSystemEntityType.directory) {
        await encoder.addDirectory(Directory(file.path));
      } else {
        await encoder.addFile(file);
      }
      encoder.close();
      return true;
    } catch (e) {
      logger.e("zipFile: error: ${e.toString()}");
      return false;
    }
  }

  static String? convertHttpError(Exception ex) {
    if (ex is BusinessError) {
      return ex.message;
    }

    return ex.toString();
  }

  static bool isValidIP(String ip) {
    final ipRegex = RegExp(
        r"^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$");
    return ipRegex.hasMatch(ip);
  }
}
