import 'dart:html' as html;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'bootstrap.dart';
import 'constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await _setUpWindowManager();
  } else {
    html.window.document.onContextMenu.listen((evt) => evt.preventDefault());
  }

  bootstrap();
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
