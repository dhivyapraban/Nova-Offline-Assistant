import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable card widget with Nothing OS glassmorphism aesthetic
class NovaCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double borderRadius;
  final bool showBorder;
  final bool enableGlow;

  const NovaCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius = 16,
    this.showBorder = true,
    this.enableGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = color ?? (isDark ? NovaColors.darkSurface : NovaColors.lightSurface);
    final borderColor = isDark ? NovaColors.darkOutline : NovaColors.lightOutline;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder ? Border.all(color: borderColor, width: 1) : null,
        boxShadow: enableGlow
            ? [
                BoxShadow(
                  color: NovaColors.primary.withValues(alpha: 0.1),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
