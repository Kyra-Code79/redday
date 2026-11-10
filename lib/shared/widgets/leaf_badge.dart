import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class LeafBadge extends StatelessWidget {
  const LeafBadge({
    super.key,
    this.size = 40,
    this.iconSize = 22,
    this.backgroundColor,
    this.iconColor,
  });

  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeColors = theme.extension<RedDayThemeColors>();

    final bg = backgroundColor ??
        (themeColors?.badgeBackground ?? colorScheme.primary);
    final ic = iconColor ??
        (themeColors?.badgeText ?? colorScheme.onPrimary);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.eco_rounded,
        size: iconSize,
        color: ic,
      ),
    );
  }
}
