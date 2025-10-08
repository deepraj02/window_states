import 'package:flutter/material.dart';
import 'package:window_states/window_states.dart';

class TimerHeader extends StatelessWidget {
  const TimerHeader({
    super.key,
    required this.dimensionController,
    required this.context,
  });

  final TransitionController dimensionController;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Focus Timer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          ListenableBuilder(
            listenable: dimensionController,
            builder: (context, _) {
              return IconButton(
                onPressed: dimensionController.isTransitioning
                    ? null
                    : () {
                        TransitionManager.navigateToIndex(context, 0);
                      },
                icon: const Icon(Icons.close_fullscreen_rounded),
                tooltip: 'Collapse',
                iconSize: 20,
              );
            },
          ),
        ],
      ),
    );
  }
}
