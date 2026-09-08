import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/task_item.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../screens/local_insights_screen.dart';

class StrategyInsightsDialog extends StatelessWidget {
  const StrategyInsightsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final metrics = provider.strategyMetrics;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.insights_rounded, color: AppTheme.primary, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Strategy Insights',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '100% On-Device • Zero Data Collected',
                        style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Open Full Screen',
                  icon: const Icon(Icons.fullscreen_rounded, size: 22),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LocalInsightsScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Key Metrics Grid
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Max Depth',
                    value: 'Level ${metrics.maxDepth}',
                    subtitle: 'Hierarchy depth',
                    icon: Icons.account_tree_outlined,
                    color: AppTheme.primary,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Avg Weight',
                    value: '${metrics.averageWeight.toStringAsFixed(1)}/10',
                    subtitle: 'Mean effort score',
                    icon: Icons.scale_outlined,
                    color: AppTheme.weightMedium,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Total Units',
                    value: '${metrics.totalTasks}',
                    subtitle: '${metrics.completedTasks} completed (${metrics.completionRate.toStringAsFixed(0)}%)',
                    icon: Icons.checklist_rtl_rounded,
                    color: AppTheme.weightLow,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Weighted Score',
                    value: '${(provider.overallProgress * 100).toStringAsFixed(0)}%',
                    subtitle: 'Total branch progress',
                    icon: Icons.pie_chart_outline_rounded,
                    color: AppTheme.primaryLight,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Effort Tier Breakdown
            const Text(
              'EFFORT TIER DISTRIBUTION',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 14,
                child: metrics.totalTasks == 0
                    ? Container(color: Colors.grey.withOpacity(0.2))
                    : Row(
                        children: [
                          if (metrics.minorCount > 0)
                            Expanded(
                              flex: metrics.minorCount,
                              child: Container(color: AppTheme.weightLow),
                            ),
                          if (metrics.moderateCount > 0)
                            Expanded(
                              flex: metrics.moderateCount,
                              child: Container(color: AppTheme.weightMedium),
                            ),
                          if (metrics.criticalCount > 0)
                            Expanded(
                              flex: metrics.criticalCount,
                              child: Container(color: AppTheme.weightHigh),
                            ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TierLegend(label: 'Minor 1–3', percent: metrics.minorPercent, color: AppTheme.weightLow),
                _TierLegend(label: 'Moderate 4–7', percent: metrics.moderatePercent, color: AppTheme.weightMedium),
                _TierLegend(label: 'Critical 8–10', percent: metrics.criticalPercent, color: AppTheme.weightHigh),
              ],
            ),
            const SizedBox(height: 24),

            // Founder Dialogue & Diagnostics
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppTheme.primary),
                      SizedBox(width: 8),
                      Text(
                        'Direct Founder Dialogue',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Have an idea for Nested or want a new feature? You can copy your anonymous stats to share with the developer without revealing any task names.',
                    style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text('Copy Metrics', style: TextStyle(fontSize: 12)),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: metrics.toDiagnosticString()));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Anonymous strategy metrics copied to clipboard!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.open_in_new_rounded, size: 16),
                          label: const Text('Send Ideas', style: TextStyle(fontSize: 12)),
                          onPressed: () {
                            // Show dialogue with GitHub repository link
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Feedback & Feature Requests'),
                                content: const SelectableText(
                                  'Share feature ideas or feedback directly with the founders at:\n\nhttps://github.com/studioxanywhere-hub/Nested-TaskStrategy/issues',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
              ),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TierLegend extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;

  const _TierLegend({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label (${percent.toStringAsFixed(0)}%)',
          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
