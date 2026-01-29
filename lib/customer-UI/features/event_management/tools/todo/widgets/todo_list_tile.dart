import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/todo_model.dart';

class TodoListTile extends StatelessWidget {
  final TodoItem todo;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final int index;

  const TodoListTile({
    super.key,
    required this.todo,
    required this.onDelete,
    required this.onToggle,
    required this.onEdit,
    required this.index,
  });

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return Colors.redAccent;
      case 'medium': return Colors.orangeAccent;
      case 'low': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: GestureDetector(
          onTap: onToggle,
          child: Icon(
            todo.isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: todo.isCompleted ? Colors.green : Colors.grey,
            size: 26,
          ),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: todo.isCompleted ? Colors.grey : AppColor.blueFont,
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description.isNotEmpty)
              Text(
                todo.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getPriorityColor(todo.priority).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                todo.priority.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _getPriorityColor(todo.priority),
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: onDelete,
            ),
            ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.reorder, color: Colors.grey, size: 20
                
              ),
            ),
          ],
        ),
      ),
    );
  }
}