import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    this.size,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final double? size;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return IconButton(
      onPressed: onPressed,
      icon: FaIcon(
        icon,
        size: size,
        color: colorScheme.onSurface,
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: colorScheme.onSurface,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
