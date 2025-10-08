import 'package:example/utils/timer_controller.dart';
import 'package:flutter/material.dart';

class CircularTimer extends StatelessWidget {
  const CircularTimer({
    super.key,
    required this.timerController,
    required this.context,
  });

  final TimerController timerController;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 10,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          CircularProgressIndicator(
            value: timerController.progress,
            strokeWidth: 10,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(
              timerController.isCompleted
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              timerController.isCompleted
                  ? Icons.check_circle_outline_rounded
                  : timerController.isRunning
                  ? Icons.timer_rounded
                  : timerController.isPaused
                  ? Icons.pause_circle_outline_rounded
                  : Icons.timer_outlined,
              size: 56,
              color: timerController.isCompleted
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
