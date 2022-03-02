import 'package:flutter/material.dart';

extension StringX on String {
  toColor() {
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }

  String adaptForOverflow() {
    return this.replaceAll('', '\u{200B}');
  }
}