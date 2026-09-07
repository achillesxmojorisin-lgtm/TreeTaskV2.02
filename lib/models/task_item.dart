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
