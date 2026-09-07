import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WeightBadge extends StatelessWidget {
  final int weight;
  final double? contributionPercent;
  final bool compact;

  const WeightBadge({
    super.key,
    required this.weight,
    this.contributionPercent,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getWeightColor(weight);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'W: $weight',
            style: TextStyle(
              color: color,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (contributionPercent != null && !compact) ...[
            const SizedBox(width: 4),
            Text(
              '(${contributionPercent!.toStringAsFixed(0)}%)',
              style: TextStyle(
                color: color.withOpacity(0.85),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
