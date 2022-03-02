
import 'package:flutter/gestures.dart';

extension PointerDownEventX on PointerDownEvent {

  bool isRightMouseClick() {
    return this.kind == PointerDeviceKind.mouse &&
        this.buttons == kSecondaryMouseButton;
  }
}