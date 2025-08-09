import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.child,
    this.onPressed,
    this.isOutlined = false,
  });

  final Widget? child;
  final VoidCallback? onPressed;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: const Offset(2, 2),
            color: isOutlined ? colorScheme.primary : Colors.black,
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined
              ? colorScheme.surface
              : colorScheme.primary,
          foregroundColor: isOutlined
              ? colorScheme.primary
              : colorScheme.onPrimary,
          disabledBackgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
          disabledForegroundColor: isDark ? Colors.white : Colors.black,
          side: BorderSide(
            color: isOutlined ? colorScheme.primary : Colors.black,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: child,
      ),
    );
  }
}
