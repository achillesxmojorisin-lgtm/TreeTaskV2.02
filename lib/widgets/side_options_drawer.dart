import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../screens/local_insights_screen.dart';

class SideOptionsDrawer extends StatefulWidget {
  const SideOptionsDrawer({super.key});

  @override
  State<SideOptionsDrawer> createState() => _SideOptionsDrawerState();
}

class _SideOptionsDrawerState extends State<SideOptionsDrawer> {
  String _selectedCategory = 'idea';
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _includeStats = true;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String _formatFeedback(TaskProvider provider) {
    final metrics = provider.strategyMetrics;
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    final catLabel = _selectedCategory == 'idea'
        ? 'Feature Request / Idea'
        : _selectedCategory == 'bug'
            ? 'Bug Report'
            : 'User Feedback';

    final buffer = StringBuffer();
    buffer.writeln('### [Nested $catLabel] ${subject.isEmpty ? "Untitled" : subject}');
    buffer.writeln();
    buffer.writeln(message.isEmpty ? 'No description provided.' : message);
    buffer.writeln();

    if (_includeStats) {
      buffer.writeln('---');
      buffer.writeln('**Anonymous Strategy Diagnostics (Zero PII)**:');
      buffer.writeln('• Strategy Profile: ${metrics.strategyArchetype}');
      buffer.writeln('• Total Tasks: ${metrics.totalTasks} (${metrics.completedTasks} completed, ${metrics.completionRate.toStringAsFixed(1)}%)');
      buffer.writeln('• Deepest Nested Level: Level ${metrics.maxDepth}');
      buffer.writeln('• Average Task Weight: ${metrics.averageWeight.toStringAsFixed(1)} / 10');
      buffer.writeln('• Milestones: ${metrics.completedMilestones} / ${metrics.totalMilestones}');
      buffer.writeln('• Effort Tiers: Minor ${metrics.minorPercent.toStringAsFixed(0)}% | Moderate ${metrics.moderatePercent.toStringAsFixed(0)}% | Critical ${metrics.criticalPercent.toStringAsFixed(0)}%');
      buffer.writeln('• Platform: Android / Flutter (Nested: Task Strategy v2.1.0)');
      buffer.writeln('• 100% computed on-device with zero tracking or telemetry.');
    }

    return buffer.toString();
  }

  void _copyFeedbackMessage(BuildContext context, TaskProvider provider) {
    final formatted = _formatFeedback(provider);
    Clipboard.setData(ClipboardData(text: formatted));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Formatted message copied to clipboard! Ready to paste.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSubmissionDialog(BuildContext context, TaskProvider provider) {
    final formatted = _formatFeedback(provider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.launch_rounded, color: AppTheme.primary, size: 20),
            SizedBox(width: 8),
            Text('Submit Your Feedback', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your formatted message is ready. You can submit it via GitHub Issues or email directly:',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: const SelectableText(
                'GitHub: https://github.com/studioxanywhere-hub/Nested-TaskStrategy/issues\n\n'
                'Email: studioxanywhere@gmail.com',
                style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: formatted));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Message copied to clipboard!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Copy Message & Close'),
          ),
        ],
      ),
    );
  }

  void _exportTasksJson(BuildContext context, TaskProvider provider) {
    try {
      final jsonList = provider.tasks.map((t) => t.toJson()).toList();
      final jsonStr = const JsonEncoder.withIndent('  ').convert(jsonList);
      Clipboard.setData(ClipboardData(text: jsonStr));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Full tasks backup JSON copied to clipboard!'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export JSON: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final metrics = provider.strategyMetrics;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth > 1200
        ? screenWidth * 0.25
        : (screenWidth > 400 ? 360.0 : screenWidth * 0.88);

    return Drawer(
      width: drawerWidth,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ideas & Options',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Feedback • Diagnostics • Tools',
                          style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Direct Founder Dialogue Section
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'DIRECT FOUNDER DIALOGUE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                                color: AppTheme.primary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.secondary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Zero PII',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Share ideas, feature requests, or bug reports directly with the developers.',
                          style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.3),
                        ),
                        const SizedBox(height: 12),

                        // Category Chips
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ChoiceChip(
                              label: const Text('💡 Idea / Request', style: TextStyle(fontSize: 11)),
                              selected: _selectedCategory == 'idea',
                              onSelected: (_) => setState(() => _selectedCategory = 'idea'),
                            ),
                            ChoiceChip(
                              label: const Text('🐛 Bug Report', style: TextStyle(fontSize: 11)),
                              selected: _selectedCategory == 'bug',
                              onSelected: (_) => setState(() => _selectedCategory = 'bug'),
                            ),
                            ChoiceChip(
                              label: const Text('💬 Feedback', style: TextStyle(fontSize: 11)),
                              selected: _selectedCategory == 'feedback',
                              onSelected: (_) => setState(() => _selectedCategory = 'feedback'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Subject input
                        TextField(
                          controller: _subjectController,
                          decoration: InputDecoration(
                            hintText: _selectedCategory == 'idea'
                                ? 'Summary (e.g. Add recurring tasks)...'
                                : _selectedCategory == 'bug'
                                    ? 'Bug summary (e.g. Subtask does not collapse)...'
                                    : 'Subject...',
                            hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.black26 : Colors.white,
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 8),

                        // Message input
                        TextField(
                          controller: _messageController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: _selectedCategory == 'idea'
                                ? 'Describe what you would like to see, workflow ideas, or improvements...'
                                : _selectedCategory == 'bug'
                                    ? 'Describe what happened, expected behavior, and steps to reproduce...'
                                    : 'Share your thoughts, suggestions, or feedback...',
                            hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.black26 : Colors.white,
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 10),

                        // Anonymous Stats Switch
                        InkWell(
                          onTap: () => setState(() => _includeStats = !_includeStats),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: _includeStats,
                                  onChanged: (val) => setState(() => _includeStats = val ?? true),
                                  activeColor: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Attach anonymous strategy diagnostics (zero task names)',
                                  style: TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.copy_rounded, size: 15),
                                label: const Text('Copy Message', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                onPressed: () => _copyFeedbackMessage(context, provider),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.send_rounded, size: 15),
                                label: const Text('Submit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                onPressed: () => _showSubmissionDialog(context, provider),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Strategy Snapshot Section
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'STRATEGY SNAPSHOT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                                color: AppTheme.primary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                metrics.strategyArchetype,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${metrics.completionRate.toStringAsFixed(0)}% Completed',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Level ${metrics.maxDepth} • ${metrics.totalTasks} Tasks',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LocalInsightsScreen()),
                                );
                              },
                              child: const Text('Full Insights →', style: TextStyle(fontSize: 11)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Effort Weights Philosophy Section
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'WEIGHT PHILOSOPHY (1–10)',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildWeightBullet(
                          color: AppTheme.weightLow,
                          title: '1–3 Minor:',
                          desc: 'Quick wins, small errands (< 1 hour)',
                        ),
                        const SizedBox(height: 6),
                        _buildWeightBullet(
                          color: AppTheme.weightMedium,
                          title: '4–7 Moderate:',
                          desc: 'Core workload, deliverables (half-day to days)',
                        ),
                        const SizedBox(height: 6),
                        _buildWeightBullet(
                          color: AppTheme.weightHigh,
                          title: '8–10 Critical:',
                          desc: 'High-impact milestones, architecture',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Data Tools & Backup Section
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DATA TOOLS & BACKUP',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Copy complete offline JSON backup of all tasks and branches.',
                          style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.3),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.backup_outlined, size: 16),
                            label: const Text('Copy Tasks Backup (JSON)', style: TextStyle(fontSize: 12)),
                            onPressed: () => _exportTasksJson(context, provider),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Privacy & Lineage Footer
                  Center(
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shield_outlined, size: 14, color: AppTheme.secondary),
                            SizedBox(width: 4),
                            Text(
                              '100% On-Device • Zero Telemetry',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Nested: Task Strategy v2.1.0',
                          style: TextStyle(fontSize: 10, color: Colors.grey.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightBullet({
    required Color color,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.3),
              children: [
                TextSpan(
                  text: '$title ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
