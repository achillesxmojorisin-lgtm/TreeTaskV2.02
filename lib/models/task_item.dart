import 'dart:math';

class TaskItem {
  final String id;
  String? parentId;
  String name;
  String description;
  int weight; // scale 1 to 10
  bool isDone;
  int createdAt;
  int? deadline;
  List<TaskItem> children;
  bool isExpanded;

  TaskItem({
    required this.id,
    this.parentId,
    required this.name,
    this.description = '',
    int weight = 5,
    this.isDone = false,
    int? createdAt,
    this.deadline,
    List<TaskItem>? children,
    this.isExpanded = true,
  })  : weight = weight.clamp(1, 10),
        createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
        children = children ?? [];

  // Total weight of direct children
  int get directChildrenTotalWeight {
    if (children.isEmpty) return 0;
    return children.fold(0, (sum, child) => sum + child.weight);
  }

  // Recursive weighted progress (0.0 to 1.0)
  double get progress {
    if (children.isEmpty) {
      return isDone ? 1.0 : 0.0;
    }
    final totalWeight = directChildrenTotalWeight;
    if (totalWeight == 0) return isDone ? 1.0 : 0.0;

    final weightedSum = children.fold(
      0.0,
      (sum, child) => sum + (child.progress * child.weight),
    );
    return (weightedSum / totalWeight).clamp(0.0, 1.0);
  }

  // Weighted points earned vs total possible for direct children
  double get earnedWeightedPoints {
    if (children.isEmpty) {
      return isDone ? weight.toDouble() : 0.0;
    }
    return children.fold(
      0.0,
      (sum, child) => sum + (child.progress * child.weight),
    );
  }

  // Percentage relative to parent
  double contributionPercentage(int parentTotalWeight) {
    if (parentTotalWeight <= 0) return 0.0;
    return (weight / parentTotalWeight) * 100.0;
  }

  // Count total subtasks recursively
  int get recursiveSubtaskCount {
    int count = children.length;
    for (final child in children) {
      count += child.recursiveSubtaskCount;
    }
    return count;
  }

  // Count completed subtasks recursively
  int get recursiveCompletedCount {
    int count = 0;
    for (final child in children) {
      if (child.children.isEmpty) {
        if (child.isDone) count++;
      } else {
        if (child.progress >= 0.999) count++;
        count += child.recursiveCompletedCount;
      }
    }
    return count;
  }

  // Deep clone
  TaskItem copyWith({
    String? id,
    String? parentId,
    String? name,
    String? description,
    int? weight,
    bool? isDone,
    int? createdAt,
    int? deadline,
    List<TaskItem>? children,
    bool? isExpanded,
  }) {
    return TaskItem(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      description: description ?? this.description,
      weight: weight ?? this.weight,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      children: children ?? this.children.map((c) => c.copyWith()).toList(),
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  // Toggle completion cascading to children
  void setDoneRecursive(bool done) {
    isDone = done;
    for (final child in children) {
      child.setDoneRecursive(done);
    }
  }

  // JSON Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentId': parentId,
      'name': name,
      'description': description,
      'weight': weight,
      'isDone': isDone,
      'createdAt': createdAt,
      'deadline': deadline,
      'isExpanded': isExpanded,
      'children': children.map((c) => c.toJson()).toList(),
    };
  }

  // Maximum nesting depth of this subtree (1 if leaf)
  int get maxDepth {
    if (children.isEmpty) return 1;
    int maxChildDepth = 0;
    for (final child in children) {
      final d = child.maxDepth;
      if (d > maxChildDepth) maxChildDepth = d;
    }
    return 1 + maxChildDepth;
  }

  // Flattened list of this item and all descendants
  List<TaskItem> get allDescendantsAndSelf {
    final list = <TaskItem>[this];
    for (final child in children) {
      list.addAll(child.allDescendantsAndSelf);
    }
    return list;
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    var rawChildren = json['children'] as List<dynamic>?;
    List<TaskItem> parsedChildren = [];
    if (rawChildren != null) {
      parsedChildren = rawChildren
          .map((c) => TaskItem.fromJson(c as Map<String, dynamic>))
          .toList();
    }

    return TaskItem(
      id: json['id'] as String,
      parentId: json['parentId'] as String?,
      name: json['name'] as String? ?? 'Untitled Task',
      description: json['description'] as String? ?? '',
      weight: (json['weight'] as num?)?.toInt() ?? 5,
      isDone: json['isDone'] as bool? ?? false,
      createdAt: (json['createdAt'] as num?)?.toInt(),
      deadline: (json['deadline'] as num?)?.toInt(),
      isExpanded: json['isExpanded'] as bool? ?? true,
      children: parsedChildren,
    );
  }
}

class TaskStrategyMetrics {
  final int totalTasks;
  final int completedTasks;
  final int maxDepth;
  final double averageWeight;
  final int minorCount; // 1-3
  final int moderateCount; // 4-7
  final int criticalCount; // 8-10
  final int totalMilestones;
  final int completedMilestones;
  final double overallWeightedScore;

  const TaskStrategyMetrics({
    required this.totalTasks,
    required this.completedTasks,
    required this.maxDepth,
    required this.averageWeight,
    required this.minorCount,
    required this.moderateCount,
    required this.criticalCount,
    required this.totalMilestones,
    required this.completedMilestones,
    required this.overallWeightedScore,
  });

  double get minorPercent => totalTasks == 0 ? 0.0 : (minorCount / totalTasks) * 100;
  double get moderatePercent => totalTasks == 0 ? 0.0 : (moderateCount / totalTasks) * 100;
  double get criticalPercent => totalTasks == 0 ? 0.0 : (criticalCount / totalTasks) * 100;
  double get completionRate => totalTasks == 0 ? 0.0 : (completedTasks / totalTasks) * 100;
  double get milestoneCompletionRate => totalMilestones == 0 ? 0.0 : (completedMilestones / totalMilestones) * 100;

  String get strategyArchetype {
    if (totalTasks == 0) return 'Strategic Novice';
    if (maxDepth >= 4) return 'Deep Architect';
    if (criticalPercent >= 40) return 'High-Impact Focus';
    if (minorPercent >= 50) return 'Agile Sprinter';
    return 'Balanced Strategist';
  }

  String get archetypeDescription {
    switch (strategyArchetype) {
      case 'Deep Architect':
        return 'You organize vision into deep, structured hierarchical branches.';
      case 'High-Impact Focus':
        return 'You dedicate maximum energy to high-weight, high-leverage milestones.';
      case 'Agile Sprinter':
        return 'You excel at breaking challenges down into fast, bite-sized tasks.';
      case 'Balanced Strategist':
        return 'You maintain a balanced harmony between major goals and quick wins.';
      default:
        return 'Start adding and nesting tasks to unlock your strategy insights.';
    }
  }

  String toDiagnosticString() {
    return 'Nested: Task Strategy Local Insights [Zero PII]\n'
        '• Archetype: $strategyArchetype\n'
        '• Average Task Weight: ${averageWeight.toStringAsFixed(1)} / 10\n'
        '• Deepest Nested Level: Level $maxDepth\n'
        '• Milestones Completed: $completedMilestones / $totalMilestones (${milestoneCompletionRate.toStringAsFixed(0)}%)\n'
        '• Total Tasks: $totalTasks ($completedTasks completed, ${completionRate.toStringAsFixed(1)}%)\n'
        '• Effort Tiers: Minor ${minorPercent.toStringAsFixed(0)}% | Moderate ${moderatePercent.toStringAsFixed(0)}% | Critical ${criticalPercent.toStringAsFixed(0)}%\n'
        '• 100% computed on-device with zero tracking or telemetry.';
  }

  factory TaskStrategyMetrics.compute(List<TaskItem> roots) {
    if (roots.isEmpty) {
      return const TaskStrategyMetrics(
        totalTasks: 0,
        completedTasks: 0,
        maxDepth: 0,
        averageWeight: 0.0,
        minorCount: 0,
        moderateCount: 0,
        criticalCount: 0,
        totalMilestones: 0,
        completedMilestones: 0,
        overallWeightedScore: 0.0,
      );
    }

    int maxD = 0;
    for (final r in roots) {
      final d = r.maxDepth;
      if (d > maxD) maxD = d;
    }

    final allTasks = <TaskItem>[];
    for (final r in roots) {
      allTasks.addAll(r.allDescendantsAndSelf);
    }

    int completed = 0;
    int totalWeight = 0;
    int minor = 0;
    int moderate = 0;
    int critical = 0;
    int milestones = 0;
    int milestonesDone = 0;
    double weightedProgressSum = 0.0;

    for (final t in allTasks) {
      final isDone = t.isDone || (t.children.isNotEmpty && t.progress >= 0.999);
      if (isDone) {
        completed++;
      }
      totalWeight += t.weight;
      weightedProgressSum += (t.weight * t.progress);

      if (t.weight <= 3) {
        minor++;
      } else if (t.weight <= 7) {
        moderate++;
      } else {
        critical++;
      }

      // Milestones: high-weight items (8-10) or parent projects
      if (t.weight >= 8 || t.children.isNotEmpty) {
        milestones++;
        if (isDone) {
          milestonesDone++;
        }
      }
    }

    final avgWeight = allTasks.isEmpty ? 0.0 : totalWeight / allTasks.length;
    final overallWeightedScore = totalWeight == 0 ? 0.0 : (weightedProgressSum / totalWeight) * 100;

    return TaskStrategyMetrics(
      totalTasks: allTasks.length,
      completedTasks: completed,
      maxDepth: maxD,
      averageWeight: avgWeight,
      minorCount: minor,
      moderateCount: moderate,
      criticalCount: critical,
      totalMilestones: milestones,
      completedMilestones: milestonesDone,
      overallWeightedScore: overallWeightedScore,
    );
  }
}
