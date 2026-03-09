import 'package:flutter/material.dart';

class FrostedGlass extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color? tintColor;
  final double tintOpacity;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const FrostedGlass({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.blur = 20,
    this.tintColor,
    this.tintOpacity = 0.12,
    this.border,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTint = isDark
        ? Colors.white.withValues(alpha: tintOpacity)
        : Colors.white.withValues(alpha: tintOpacity + 0.4);

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: tintColor ?? defaultTint,
        borderRadius: BorderRadius.circular(borderRadius),
        border:
            border ??
            Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.6),
              width: 1.2,
            ),
      ),
      child: child,
    );
  }
}
