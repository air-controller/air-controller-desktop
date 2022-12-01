import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../bootstrap.dart';
import '../constant.dart';

Future<bool> init() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _setUpWindowManager();
  bootstrap();

  return true;
}

Future<void> _setUpWindowManager() async {
  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitleBarStyle(
        Platform.isMacOS ? TitleBarStyle.hidden : TitleBarStyle.normal);
    await windowManager.setMinimumSize(
        Size(Constant.minWindowWidth, Constant.minWindowHeight));
    await windowManager.setSize(
        Size(Constant.defaultWindowWidth, Constant.defaultWindowHeight));
    await windowManager.center();
    if (Platform.isMacOS || Platform.isWindows) {
      await windowManager.setHasShadow(true);
      await windowManager.setBrightness(Brightness.light);
    }
    await windowManager.show();
    await windowManager.setSkipTaskbar(false);
  });
}
