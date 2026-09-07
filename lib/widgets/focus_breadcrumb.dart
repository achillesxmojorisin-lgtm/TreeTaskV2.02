import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class FocusBreadcrumbBar extends StatelessWidget {
  const FocusBreadcrumbBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final stack = provider.breadcrumbStack;
    final theme = Theme.of(context);

    if (stack.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_center_focus, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  InkWell(
                    onTap: () => provider.navigateToBreadcrumbIndex(-1),
                    child: Text(
                      'All Projects',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  for (int i = 0; i < stack.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.chevron_right, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                    ),
                    InkWell(
                      onTap: () => provider.navigateToBreadcrumbIndex(i),
                      child: Text(
                        stack[i].name,
                        style: TextStyle(
                          fontSize: 13,
                          color: (i == stack.length - 1)
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.primary,
                          fontWeight: (i == stack.length - 1) ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Exit Focus Mode',
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => provider.navigateToBreadcrumbIndex(-1),
          ),
        ],
      ),
    );
  }
}
