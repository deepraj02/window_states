import 'package:example/utils/timer_controller.dart';
import 'package:flutter/material.dart';

class StatusText extends StatelessWidget {
  const StatusText({
    super.key,
    required this.timerController,
    required this.context,
  });

  final TimerController timerController;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    String status;
    Color color;

    switch (timerController.state) {
      case TimerState.running:
        status = 'Stay focused! 🎯';
        color = Colors.green;
        break;
      case TimerState.paused:
        status = 'Take a breath 💭';
        color = Colors.orange;
        break;
      case TimerState.completed:
        status = 'Great work! 🎉';
        color = Colors.blue;
        break;
      case TimerState.idle:
        status = 'Ready to focus? 🚀';
        color = Colors.grey;
        break;
    }

    return Text(
      status,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color),
    );
  }
}
