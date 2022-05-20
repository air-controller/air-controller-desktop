import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'bootstrap.dart';
import 'constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitleBarStyle(
        Platform.isMacOS ? TitleBarStyle.hidden : TitleBarStyle.normal);
    await windowManager.setMinimumSize(
        Size(Constant.MIN_WINDOW_WIDTH, Constant.MIN_WINDOW_HEIGHT));
    await windowManager.setSize(
        Size(Constant.DEFAULT_WINDOW_WIDTH, Constant.DEFAULT_WINDOW_HEIGHT));
    await windowManager.center();
    if (Platform.isMacOS || Platform.isWindows) {
    await windowManager.setHasShadow(true);
    await windowManager.setBrightness(Brightness.light);
    }
    await windowManager.show();
    await windowManager.setSkipTaskbar(false);
  });

  bootstrap();
}
