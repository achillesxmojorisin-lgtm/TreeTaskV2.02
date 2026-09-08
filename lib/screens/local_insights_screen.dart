import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/task_item.dart';
import '../providers/task_provider.dart';

class LocalInsightsScreen extends StatelessWidget {
  const LocalInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Insights'),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.shield_outlined, size: 14, color: Colors.green),
                SizedBox(width: 4),
                Text(
                  '100% On-Device',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          final metrics = TaskStrategyMetrics.compute(provider.tasks);

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 1. Hero Strategy Card (Archetype & High-Level Execution)
              _buildHeroArchetypeCard(theme, metrics, isDark),
              const SizedBox(height: 16),

              // 2. Section Header: My Strategy Stats
              Row(
                children: [
                  Icon(Icons.auto_graph_rounded, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'My Strategy Stats',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 3. 2x2 Grid of Core Behavioral Metrics
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      theme: theme,
                      label: 'Average Task Weight',
                      value: '${metrics.averageWeight.toStringAsFixed(1)} / 10',
                      subtitle: _getWeightDescription(metrics.averageWeight),
                      icon: Icons.scale_rounded,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      theme: theme,
                      label: 'Deepest Nested Level',
                      value: 'Level ${metrics.maxDepth}',
                      subtitle: metrics.maxDepth <= 1
                          ? 'Flat structure'
                          : '${metrics.maxDepth} tiers of subtasks',
                      icon: Icons.account_tree_rounded,
                      color: const Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      theme: theme,
                      label: 'Milestones Completed',
                      value: '${metrics.completedMilestones}',
                      subtitle: 'of ${metrics.totalMilestones} strategic goals',
                      icon: Icons.flag_rounded,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      theme: theme,
                      label: 'Total Tasks',
                      value: '${metrics.totalTasks}',
                      subtitle: '${metrics.completedTasks} completed (${metrics.completionRate.toStringAsFixed(0)}%)',
                      icon: Icons.checklist_rounded,
                      color: const Color(0xFF0EA5E9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. Effort Weight Distribution (1–10 Scale)
              _buildTierBreakdownCard(theme, metrics, isDark),
              const SizedBox(height: 16),

              // 5. Zero-Data Guarantee & Founder Dialogue
              _buildPrivacyAndDialogueCard(context, theme, metrics, isDark),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroArchetypeCard(ThemeData theme, TaskStrategyMetrics metrics, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF312E81), const Color(0xFF1E1B4B)]
              : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.psychology_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Strategy Profile',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      metrics.strategyArchetype,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${metrics.overallWeightedScore.toStringAsFixed(0)}% Score',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            metrics.archetypeDescription,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? Colors.white70 : const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (metrics.overallWeightedScore / 100.0).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required ThemeData theme,
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierBreakdownCard(ThemeData theme, TaskStrategyMetrics metrics, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Effort Distribution (Scale 1–10)',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${metrics.totalTasks} Tasks',
                style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: metrics.totalTasks == 0
                  ? Container(color: theme.dividerColor.withOpacity(0.15))
                  : Row(
                      children: [
                        if (metrics.minorCount > 0)
                          Expanded(
                            flex: metrics.minorCount,
                            child: Container(color: const Color(0xFF10B981)),
                          ),
                        if (metrics.moderateCount > 0)
                          Expanded(
                            flex: metrics.moderateCount,
                            child: Container(color: const Color(0xFFF59E0B)),
                          ),
                        if (metrics.criticalCount > 0)
                          Expanded(
                            flex: metrics.criticalCount,
                            child: Container(color: const Color(0xFFEF4444)),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 14),
          _buildTierRow(
            color: const Color(0xFF10B981),
            name: 'Minor (1–3)',
            description: 'Quick wins, chores, simple steps',
            count: metrics.minorCount,
            percent: metrics.minorPercent,
          ),
          const Divider(height: 16),
          _buildTierRow(
            color: const Color(0xFFF59E0B),
            name: 'Moderate (4–7)',
            description: 'Standard work, core deliverables',
            count: metrics.moderateCount,
            percent: metrics.moderatePercent,
          ),
          const Divider(height: 16),
          _buildTierRow(
            color: const Color(0xFFEF4444),
            name: 'Critical (8–10)',
            description: 'High-leverage strategic milestones',
            count: metrics.criticalCount,
            percent: metrics.criticalPercent,
          ),
        ],
      ),
    );
  }

  Widget _buildTierRow({
    required Color color,
    required String name,
    required String description,
    required int count,
    required double percent,
  }) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text(
                description,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
        Text(
          '$count (${percent.toStringAsFixed(0)}%)',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPrivacyAndDialogueCard(
    BuildContext context,
    ThemeData theme,
    TaskStrategyMetrics metrics,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lock_outline_rounded, size: 16, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Let the User See Their Own Data',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'All metrics are calculated locally inside your device. We do not track you, collect cookies, or store your tasks in the cloud. You own 100% of your data.',
            style: TextStyle(
              fontSize: 11,
              height: 1.4,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.copy_rounded, size: 14),
                  label: const Text('Copy My Stats', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: metrics.toDiagnosticString()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Anonymous stats copied to clipboard! (Zero PII)'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.feedback_outlined, size: 14),
                  label: const Text('Send Ideas', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Direct Founder Dialogue'),
                        content: const SelectableText(
                          'Share feature requests or feedback directly with the creators on GitHub:\n\nhttps://github.com/studioxanywhere-hub/Nested-TaskStrategy/issues',
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
    );
  }

  String _getWeightDescription(double weight) {
    if (weight <= 3.5) return 'Lightweight chores';
    if (weight <= 7.0) return 'Standard effort';
    return 'Heavy strategic milestones';
  }
}
