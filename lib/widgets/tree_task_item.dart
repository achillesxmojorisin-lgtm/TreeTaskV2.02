import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_item.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import 'weight_badge.dart';
import 'weighted_progress_bar.dart';
import 'edit_task_dialog.dart';

class TreeTaskItem extends StatelessWidget {
  final TaskItem task;
  final int depth;
  final int? parentTotalWeight;

  const TreeTaskItem({
    super.key,
    required this.task,
    this.depth = 0,
    this.parentTotalWeight,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    final hasChildren = task.children.isNotEmpty;
    final isDone = task.progress >= 0.999;
    final contribution = parentTotalWeight != null ? task.contributionPercentage(parentTotalWeight!) : null;

    return Padding(
      padding: EdgeInsets.only(
        left: depth > 0 ? 16.0 : 0.0,
        top: 3.0,
        bottom: 3.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                if (hasChildren) {
                  provider.toggleExpand(task.id);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Transform.scale(
                          scale: 1.1,
                          child: Checkbox(
                            value: hasChildren ? (task.progress >= 0.999) : task.isDone,
                            activeColor: AppTheme.secondary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            onChanged: (val) {
                              provider.toggleTaskDone(task.id, cascade: true);
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.name,
                                style: TextStyle(
                                  fontSize: depth == 0 ? 15 : 14,
                                  fontWeight: depth == 0 ? FontWeight.w700 : FontWeight.w600,
                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                  color: isDone
                                      ? theme.colorScheme.onSurface.withOpacity(0.5)
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              if (task.description.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  task.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        WeightBadge(
                          weight: task.weight,
                          contributionPercent: contribution,
                          compact: depth > 1,
                        ),
                        const SizedBox(width: 4),
                        if (hasChildren)
                          IconButton(
                            icon: AnimatedRotation(
                              turns: task.isExpanded ? 0.25 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: const Icon(Icons.chevron_right, size: 20),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => provider.toggleExpand(task.id),
                          ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onSelected: (action) {
                            if (action == 'add_child') {
                              showDialog(
                                context: context,
                                builder: (ctx) => EditTaskDialog(
                                  parentName: task.name,
                                  onSave: (name, desc, weight, deadline) {
                                    provider.addSubTask(
                                      parentId: task.id,
                                      name: name,
                                      description: desc,
                                      weight: weight,
                                      deadline: deadline,
                                    );
                                  },
                                ),
                              );
                            } else if (action == 'focus') {
                              provider.drillDown(task);
                            } else if (action == 'edit') {
                              showDialog(
                                context: context,
                                builder: (ctx) => EditTaskDialog(
                                  initialTask: task,
                                  onSave: (name, desc, weight, deadline) {
                                    provider.updateTask(
                                      id: task.id,
                                      name: name,
                                      description: desc,
                                      weight: weight,
                                      deadline: deadline,
                                    );
                                  },
                                ),
                              );
                            } else if (action == 'delete') {
                              provider.deleteTask(task.id);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'add_child',
                              child: Row(
                                children: [
                                  Icon(Icons.subdirectory_arrow_right, size: 18),
                                  SizedBox(width: 8),
                                  Text('Add Subtask'),
                                ],
                              ),
                            ),
                            if (hasChildren)
                              const PopupMenuItem(
                                value: 'focus',
                                child: Row(
                                  children: [
                                    Icon(Icons.filter_center_focus, size: 18),
                                    SizedBox(width: 8),
                                    Text('Focus on Branch'),
                                  ],
                                ),
                              ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit Task'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (hasChildren) ...[
                      const SizedBox(height: 8),
                      WeightedProgressBar(
                        progress: task.progress,
                        earnedPoints: task.earnedWeightedPoints,
                        totalWeight: task.directChildrenTotalWeight,
                        showLabel: true,
                        height: 5,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (hasChildren && task.isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Stack(
                children: [
                  Positioned(
                    left: 2,
                    top: 0,
                    bottom: 12,
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: task.children
                        .map((child) => TreeTaskItem(
                              task: child,
                              depth: depth + 1,
                              parentTotalWeight: task.directChildrenTotalWeight,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
