import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile_assistant_client/bootstrap.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setWindowMinSize(Size(1036, 687));
  bootstrap();
}
