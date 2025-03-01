import 'dart:async';

class TimerDifferenceHandler {
  static late DateTime endingTime;

  static final TimerDifferenceHandler _instance = TimerDifferenceHandler();

  static TimerDifferenceHandler get instance => _instance;

  int get remainingSeconds {
    final DateTime dateTimeNow = DateTime.now();
    final Duration remainingTime = endingTime.difference(dateTimeNow);
    // Return in seconds
    print(
        'TimerDifferenceHandler  -remaining second = ${remainingTime.inSeconds}');

    return remainingTime.inSeconds;
  }

  void setEndingTime(int durationToEnd) {
    final DateTime dateTimeNow = DateTime.now();
    // Ending time is the current time plus the remaining duration.
    endingTime = dateTimeNow.add(
      Duration(
        seconds: durationToEnd,
      ),
    );
    print(
        'TimerDifferenceHandler  -setEndingTime = ${endingTime.toLocal().toString()}');
  }
}

class CountdownTimer {
  int _countdownSeconds;
  late Timer _timer;
  final Function(int)? _onTick;
  final Function()? _onFinished;
  final timerHandler = TimerDifferenceHandler.instance;
  bool onPausedCalled = false;

  CountdownTimer({
    required int seconds,
    Function(int)? onTick,
    Function()? onFinished,
  })  : _countdownSeconds = seconds,
        _onTick = onTick,
        _onFinished = onFinished;

  //this will start the timer
  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _countdownSeconds--;

      if (_onTick != null) {
        _onTick!(_countdownSeconds);
      }

      if (_countdownSeconds <= 0) {
        stop();
        if (_onFinished != null) {
          _onFinished!();
        }
      }
    });
  }

  //on pause current remaining time will be marked as end time in timerHandler class
  void pause(int endTime) {
    onPausedCalled = true;
    stop();
    timerHandler.setEndingTime(endTime); //setting end time
  }

  //on resume, the diff between current time and marked end time will be get from timerHandler class
  void resume() {
    if (!onPausedCalled) {
      //if on pause not called, instead resumed will called directly.. so no need to do any operations
      return;
    }
    if (timerHandler.remainingSeconds > 0) {
      _countdownSeconds = timerHandler.remainingSeconds;
      start();
    } else {
      stop();
      _onTick!(_countdownSeconds); //callback
    }
    onPausedCalled = false;
  }

  void stop() {
    _timer.cancel();
    _countdownSeconds = 0;
  }
}
