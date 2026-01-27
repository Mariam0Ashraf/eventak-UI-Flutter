import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/todo_service.dart';

class CreateTodoDialog extends StatefulWidget {
  final int eventId;
  final int currentTaskCount;
  final VoidCallback onSuccess;

  const CreateTodoDialog({
    super.key,
    required this.eventId,
    required this.currentTaskCount,
    required this.onSuccess,
  });

  @override
  State<CreateTodoDialog> createState() => _CreateTodoDialogState();
}

class _CreateTodoDialogState extends State<CreateTodoDialog> {
  final _todoService = TodoService();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  String _selectedPriority = "high";
  bool _isSubmitting = false;

  Future<void> _selectDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (date != null && mounted) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        final DateTime fullDateTime = DateTime(
          date.year, date.month, date.day, time.hour, time.minute,
        );
        setState(() {
          _dateController.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(fullDateTime);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Event Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: "Description")),
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Due Date & Time",
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: _selectDateTime,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(labelText: "Priority"),
              items: ["high", "medium", "low"].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (val) => setState(() => _selectedPriority = val!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _dateController.text.isEmpty) return;

    setState(() => _isSubmitting = true);
    
    int nextOrder = widget.currentTaskCount + 1;

    final success = await _todoService.createTodo(widget.eventId, {
      "title": _titleController.text.trim(),
      "description": _descController.text.trim(),
      "due_date": _dateController.text.trim(),
      "priority": _selectedPriority,
      "order": nextOrder
    });

    if (success && mounted) {
      widget.onSuccess();
      Navigator.pop(context);
    } else {
      setState(() => _isSubmitting = false);
    }
  }
}