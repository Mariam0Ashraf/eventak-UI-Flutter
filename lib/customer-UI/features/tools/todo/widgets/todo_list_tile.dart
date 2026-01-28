import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/todo_model.dart';

class TodoListTile extends StatelessWidget {
  final TodoItem todo;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final int index; 

  const TodoListTile({
    super.key,
    required this.todo,
    required this.onDelete,
    required this.onToggle,
    required this.index,
  });

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
            color: todo.isCompleted ? Colors.grey : const Color(0xFF1A1A1A),
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: onDelete,
            ),
            ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}