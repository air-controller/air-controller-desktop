import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile_assistant_client/bootstrap.dart';
import 'package:window_size/window_size.dart';

import 'constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Screen? screen = await getCurrentScreen();

  if (null != screen) {
    log("Screen frame: ${screen.frame}");

    double screenWidth = screen.frame.right - screen.frame.left;
    double screenHeight = screen.frame.bottom - screen.frame.top;

    double left = (screenWidth - Constant.DEFAULT_WINDOW_WIDTH) / 2;
    double top = (screenHeight - Constant.DEFAULT_WINDOW_HEIGHT) / 2;
    double right = left + Constant.DEFAULT_WINDOW_WIDTH;
    double bottom = top + Constant.DEFAULT_WINDOW_HEIGHT;

    setWindowFrame(Rect.fromLTRB(left, top, right, bottom));
  }
  setWindowMinSize(Size(Constant.MIN_WINDOW_WIDTH, Constant.MIN_WINDOW_HEIGHT));

  bootstrap();
}
