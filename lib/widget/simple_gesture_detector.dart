import 'package:flutter/cupertino.dart';

import '../util/count_down_timer.dart';

// ignore: must_be_immutable
class SimpleGestureDetector extends StatelessWidget {
  final Widget? child;
  final Function()? onTap;
  final Function()? onDoubleTap;
  final Function(TapDownDetails details)? onTapDown;
  final Function(TapUpDetails tapUpDetails)? onTapUp;
  final Function()? onTapCancel;
  final int doubleTapDuration;
  CountDownTimer? _countDownTimer;
  int _tapCount = 0;
  bool _isCountDownStarted = false;
  int _lastTapTime = -1;

  SimpleGestureDetector({
    Key? key,
    this.child,
    this.onTap,
    this.onDoubleTap,
    this.onTapDown,
    this.onTapCancel,
    this.onTapUp,
    this.doubleTapDuration = 200
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: child,
      onTap: () {
        _tapCount ++;

        Future.delayed(Duration.zero);

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
          }
        }
      },
      onTapUp: (details) {
        onTapUp?.call(details);
      },
      onTapCancel: () {
        onTapCancel?.call();
      },
      onTapDown: (details) {
        onTapDown?.call(details);
      },
    );
  }

  int _currentTimeInMills() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  void _startCountDownTimer() {
    _countDownTimer = CountDownTimer(doubleTapDuration, doubleTapDuration ~/ 10);
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