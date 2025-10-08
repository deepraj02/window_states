import 'package:example/utils/timer_controller.dart';
import 'package:flutter/material.dart';
import 'package:window_states/window_states.dart';

import '../widgets/widgets.dart';

class CollapsedTimerView extends StatelessWidget {
  final TimerController timerController;
  final TransitionController dimensionController;

  const CollapsedTimerView({
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
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.secondaryContainer,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        timerController.timeDisplay,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 4),
                      StatusChip(
                        timerController: timerController,
                        context: context,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 15,
                  left: 8,
                  right: 8,
                  child: ListenableBuilder(
                    listenable: dimensionController,
                    builder: (context, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          QuickActionButton(
                            context: context,
                            icon: timerController.isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            onPressed: dimensionController.isTransitioning
                                ? null
                                : () {
                                    if (timerController.isRunning) {
                                      timerController.pause();
                                    } else if (timerController.isPaused) {
                                      timerController.resume();
                                    } else {
                                      timerController.start();
                                    }
                                  },
                          ),
                          QuickActionButton(
                            context: context,
                            icon: Icons.open_in_full_rounded,
                            onPressed: dimensionController.isTransitioning
                                ? null
                                : () {
                                    TransitionManager.navigateToIndex(
                                      context,
                                      1,
                                    );
                                  },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
