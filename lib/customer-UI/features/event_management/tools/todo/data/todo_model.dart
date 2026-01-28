class TodoItem {
  final int id;
  final String title;
  final String description;
  final String dueDate; 
  final String priority;
  final bool isCompleted;
  final int order;

  TodoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
    required this.order,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['due_date'] ?? '', 
      priority: json['priority'] ?? 'low',
      isCompleted: json['is_completed'] ?? false,
      order: json['order'] ?? 0,
    );
  }
}