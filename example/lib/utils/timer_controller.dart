import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TimerState { idle, running, paused, completed }

class TimerController extends ChangeNotifier {
  Timer? _timer;
  int _remainingSeconds = 25 * 60;
  int _initialSeconds = 25 * 60;
  TimerState _state = TimerState.idle;

  int get initialSeconds => _initialSeconds;
  bool get isCompleted => _state == TimerState.completed;
  bool get isIdle => _state == TimerState.idle;

  bool get isPaused => _state == TimerState.paused;
  bool get isRunning => _state == TimerState.running;
  double get progress {
    if (_initialSeconds == 0) return 0;
    return (_initialSeconds - _remainingSeconds) / _initialSeconds;
  }

  int get remainingSeconds => _remainingSeconds;

  TimerState get state => _state;

  String get timeDisplay {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void pause() {
    if (_state != TimerState.running) return;

    _timer?.cancel();
    _state = TimerState.paused;
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _remainingSeconds = _initialSeconds;
    _state = TimerState.idle;
    notifyListeners();
  }

  void resume() {
    if (_state != TimerState.paused) return;
    start();
  }

  void setDuration(int minutes) {
    if (_state == TimerState.running) return;

    _initialSeconds = minutes * 60;
    _remainingSeconds = _initialSeconds;
    _state = TimerState.idle;
    notifyListeners();
  }

  void start() {
    if (_state == TimerState.running) return;

    _state = TimerState.running;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _complete();
      }
    });
  }

  void _complete() {
    _timer?.cancel();
    _state = TimerState.completed;
    _remainingSeconds = 0;
    notifyListeners();

    SystemSound.play(SystemSoundType.alert);
  }
}
