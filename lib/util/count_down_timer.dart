import 'dart:async';

class CountDownTimer {
    final int millisInFuture;
    final int countDownInterval;

    bool _isCancelled = false;
    Timer? _internalTimer;
    int _currentTime = 0;

    Function(int millisUntilFinished)? _onTick;
    Function()? _onFinish;

    CountDownTimer(this.millisInFuture, this.countDownInterval);

    void start() {
      final duration = Duration(milliseconds: countDownInterval);
      _internalTimer = Timer.periodic(duration, (timer) {
        if (_currentTime >= millisInFuture) {
          _onFinish?.call();

          _internalTimer?.cancel();
        } else {
          _currentTime += countDownInterval;
          _onTick?.call(millisInFuture - _currentTime);
        }
      });
      _isCancelled = false;
    }

    void onTick(Function(int millisUntilFinished) callback) {}

    void onFinish(Function() callback) {}

    void cancel() {
      _internalTimer?.cancel();
      _isCancelled = true;
    }

    bool isCancelled() {
      return _isCancelled;
    }
}