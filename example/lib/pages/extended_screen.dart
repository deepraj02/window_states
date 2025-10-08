import 'package:example/utils/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:window_states/window_states.dart';

import '../widgets/widgets.dart';

class ExpandedTimerView extends StatelessWidget {
  final TimerController timerController;
  final TransitionController dimensionController;

  const ExpandedTimerView({
    super.key,
    required this.timerController,
    required this.dimensionController,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: timerController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.3),
                  Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withOpacity(0.3),
                ],
              ),
            ),
            child: Column(
              children: [
                TimerHeader(
                  dimensionController: dimensionController,
                  context: context,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        CircularTimer(
                          timerController: timerController,
                          context: context,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          timerController.timeDisplay,
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 12),
                        StatusText(
                          timerController: timerController,
                          context: context,
                        ),
                        const SizedBox(height: 30),
                        _buildControls(context),
                        const SizedBox(height: 24),
                        DurationPresets(
                          dimensionController: dimensionController,
                          timerController: timerController,
                          context: context,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls(BuildContext context) {
    return ListenableBuilder(
      listenable: dimensionController,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ControlButton(
                context: context,
                icon: Icons.refresh_rounded,
                label: 'Reset',
                onPressed: dimensionController.isTransitioning
                    ? null
                    : () => timerController.reset(),
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 16),
              MainActionButton(
                timerController: timerController,
                dimensionController: dimensionController,
                context: context,
              ),
              const SizedBox(width: 16),
              ControlButton(
                context: context,
                icon: Icons.skip_next_rounded,
                label: 'Skip',
                onPressed:
                    dimensionController.isTransitioning ||
                        timerController.isIdle ||
                        timerController.isCompleted
                    ? null
                    : () => timerController.reset(),
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ],
          ),
        );
      },
    );
  }
}
