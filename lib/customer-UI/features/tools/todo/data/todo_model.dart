class TodoItem {
  final int id;
  final String title;
  final String priority;
  final bool isCompleted;

  TodoItem({
    required this.id,
    required this.title,
    required this.priority,
    required this.isCompleted,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      priority: json['priority'] ?? 'low',
      isCompleted: json['is_completed'] ?? false,
    );
  }
}