import 'package:example/utils/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:window_states/window_states.dart';

class DurationPresets extends StatelessWidget {
  final TransitionController dimensionController;

  final TimerController timerController;
  final BuildContext context;
  const DurationPresets({
    super.key,
    required this.dimensionController,
    required this.timerController,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final presets = [
      (5, '5min', Icons.coffee_rounded),
      (25, '25min', Icons.local_fire_department_rounded),
      (45, '45min', Icons.rocket_launch_rounded),
    ];

    return ListenableBuilder(
      listenable: dimensionController,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Text(
                  'Quick Durations',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
              Row(
                children: presets.map((preset) {
                  final (minutes, label, icon) = preset;
                  final isSelected =
                      timerController.initialSeconds == minutes * 60;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OutlinedButton(
                        onPressed:
                            dimensionController.isTransitioning ||
                                timerController.isRunning
                            ? null
                            : () => timerController.setDuration(minutes),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                          side: BorderSide(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                            width: isSelected ? 2 : 1,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 18),
                            const SizedBox(height: 2),
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
