import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  final BuildContext context;

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  const ControlButton({
    super.key,
    required this.context,
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onPressed,
            icon: Icon(icon, size: 28),
            color: onPressed == null ? Theme.of(context).disabledColor : color,
            style: IconButton.styleFrom(
              backgroundColor: onPressed == null
                  ? null
                  : color.withOpacity(0.1),
              padding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: onPressed == null
                  ? Theme.of(context).disabledColor
                  : Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
