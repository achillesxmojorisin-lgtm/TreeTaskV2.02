import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WeightedProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double? earnedPoints;
  final int? totalWeight;
  final double height;
  final bool showLabel;

  const WeightedProgressBar({
    super.key,
    required this.progress,
    this.earnedPoints,
    this.totalWeight,
    this.height = 6,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final percentText = '${(clamped * 100).toInt()}%';
    final isDone = clamped >= 0.999;
    final color = isDone ? AppTheme.secondary : AppTheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (earnedPoints != null && totalWeight != null)
                  Text(
                    '${earnedPoints!.toStringAsFixed(1)} / $totalWeight pts',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Text(
                  percentText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: Container(
            height: height,
            width: double.infinity,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: clamped,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDone
                        ? [AppTheme.secondary, const Color(0xFF34D399)]
                        : [AppTheme.primary, AppTheme.primaryLight],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
