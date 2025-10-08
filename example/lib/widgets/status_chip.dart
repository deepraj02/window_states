import 'package:example/utils/timer_controller.dart';
import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final TimerController timerController;

  final BuildContext context;
  const StatusChip({
    super.key,
    required this.timerController,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    String status;
    Color color;

    switch (timerController.state) {
      case TimerState.running:
        status = 'Running';
        color = Colors.green;
        break;
      case TimerState.paused:
        status = 'Paused';
        color = Colors.orange;
        break;
      case TimerState.completed:
        status = 'Completed!';
        color = Colors.blue;
        break;
      case TimerState.idle:
        status = 'Ready';
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
