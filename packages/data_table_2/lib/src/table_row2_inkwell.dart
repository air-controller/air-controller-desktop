import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_assistant_client/util/count_down_timer.dart';

// ignore: must_be_immutable
class TableRow2InkWell extends StatelessWidget {
  final Widget? child;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final ValueChanged<bool>? onHighlightChanged;
  final MaterialStateProperty<Color?>? overlayColor;

  final int doubleTapDuration;
  CountDownTimer? _countDownTimer;
  int _tapCount = 0;
  bool _isCountDownStarted = false;
  int _lastTapTime = -1;

  TableRow2InkWell(
      {Key? key,
      this.child,
      this.doubleTapDuration = 200,
      this.onTap,
      this.onDoubleTap,
      this.onLongPress,
      this.onHighlightChanged,
      this.overlayColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableRowInkWell(
      child: child,
      onTap: () {
        _tapCount++;

        if (_tapCount == 1) {
          _lastTapTime = _currentTimeInMills();

          if (!_isCountDownStarted) {
            _startCountDownTimer();
          }
        }

        onTap?.call();

        if (_tapCount >= 2) {
          int currentTime = _currentTimeInMills();
          if (currentTime - _lastTapTime <= doubleTapDuration) {
            onDoubleTap?.call();
            log("TableRow2InkWell, hit onDoubleTap!!!");
          }
        }
      },
      onLongPress: this.onLongPress,
      onHighlightChanged: this.onHighlightChanged,
      overlayColor: this.overlayColor,
    );
  }

  int _currentTimeInMills() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  void _startCountDownTimer() {
    _countDownTimer =
        CountDownTimer(doubleTapDuration, doubleTapDuration ~/ 10);
    _countDownTimer?.onFinish(() {
      _countDownTimer = null;
      _isCountDownStarted = false;
      _tapCount = 0;
      _lastTapTime = -1;
    });

    _countDownTimer?.start();

    _isCountDownStarted = true;
  }
}
