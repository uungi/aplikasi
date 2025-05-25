import 'package:flutter/material.dart';

class EnhancedButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final Color? primaryColor;
  final Color? onPrimaryColor;
  final Color? sideColor;

  const EnhancedButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.isPrimary = true,
    this.primaryColor,
    this.onPrimaryColor,
    this.sideColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isPrimary) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor ?? theme.primaryColor,
          foregroundColor: onPrimaryColor ?? theme.colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    } else {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor ?? theme.primaryColor,
          side: BorderSide(color: sideColor ?? theme.primaryColor),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }
  }
}
