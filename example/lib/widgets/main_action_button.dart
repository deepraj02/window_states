import 'package:example/utils/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:window_states/window_states.dart';

class MainActionButton extends StatelessWidget {
  final TimerController timerController;

  final TransitionController dimensionController;
  final BuildContext context;
  const MainActionButton({
    super.key,
    required this.timerController,
    required this.dimensionController,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String label;
    VoidCallback? onPressed;

    if (timerController.isRunning) {
      icon = Icons.pause_rounded;
      label = 'Pause';
      onPressed = () => timerController.pause();
    } else if (timerController.isPaused) {
      icon = Icons.play_arrow_rounded;
      label = 'Resume';
      onPressed = () => timerController.resume();
    } else if (timerController.isCompleted) {
      icon = Icons.replay_rounded;
      label = 'Restart';
      onPressed = () => timerController.reset();
    } else {
      icon = Icons.play_arrow_rounded;
      label = 'Start';
      onPressed = () => timerController.start();
    }

    return SizedBox(
      width: 90,
      height: 90,
      child: ElevatedButton(
        onPressed: dimensionController.isTransitioning ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: const CircleBorder(),
          elevation: 8,
          padding: EdgeInsets.zero,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
