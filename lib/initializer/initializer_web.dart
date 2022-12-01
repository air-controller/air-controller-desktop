import 'dart:html' as html;
import 'package:air_controller/bootstrap.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future<bool> init() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();
  html.window.document.onContextMenu.listen((evt) => evt.preventDefault());
  bootstrap();
  
  return true;
}
