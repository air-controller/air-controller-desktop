import 'package:flutter/material.dart';

extension ScaffoldMessengerStateX on ScaffoldMessengerState {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBarText(
      String content) {
    this.hideCurrentSnackBar();
    return this.showSnackBar(SnackBar(content: Text(content)));
  }
}
