import 'package:eventak/customer-UI/features/tools/timeline/data/timeline_model.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/timeline_service.dart';

class CreateTimelineDialog extends StatefulWidget {
  final int eventId;
  final int lastOrder;
  final VoidCallback onSuccess;
  final TimelineItem? timeline;

  const CreateTimelineDialog({
    super.key,
    required this.eventId,
    required this.lastOrder,
    required this.onSuccess,
    this.timeline,
  });

  @override
  State<CreateTimelineDialog> createState() => _CreateTimelineDialogState();
}

class _CreateTimelineDialogState extends State<CreateTimelineDialog> {
  final _service = TimelineService();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _timeController;
  late TextEditingController _durationController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.timeline?.title ?? '');
    _descController = TextEditingController(text: widget.timeline?.description ?? '');
    _timeController = TextEditingController(text: widget.timeline?.startTime ?? '');
    _durationController = TextEditingController(
        text: widget.timeline != null ? widget.timeline!.duration.toString() : '30');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: widget.timeline != null 
          ? TimeOfDay(
              hour: int.parse(widget.timeline!.startTime.split(':')[0]), 
              minute: int.parse(widget.timeline!.startTime.split(':')[1]))
          : TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _timeController.text = 
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00";
      });
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _timeController.text.isEmpty) return;

    setState(() => _isSubmitting = true);

    final data = {
      "title": _titleController.text.trim(),
      "description": _descController.text.trim(),
      "start_time": _timeController.text,
      "duration_minutes": int.tryParse(_durationController.text) ?? 30,
      "order": widget.timeline?.order ?? (widget.lastOrder + 1),
    };

    bool success;
    if (widget.timeline != null) {
      success = await _service.updateTimelineItem(widget.eventId, widget.timeline!.id, data);
    } else {
      success = await _service.createTimelineItem(widget.eventId, data);
    }

    if (success && mounted) {
      widget.onSuccess();
      Navigator.pop(context);
    } else {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.timeline != null ? 'Update Timeline Item' : 'New Timeline Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController, 
              decoration: const InputDecoration(labelText: "Title")
            ),
            TextField(
              controller: _descController, 
              decoration: const InputDecoration(labelText: "Description")
            ),
            TextField(
              controller: _timeController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Start Time", 
                suffixIcon: Icon(Icons.access_time)
              ),
              onTap: _pickTime, 
            ),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Duration (minutes)"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text('Cancel')
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary, 
            foregroundColor: Colors.white
          ),
          child: _isSubmitting 
              ? const SizedBox(
                  height: 20, 
                  width: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                ) 
              : Text(widget.timeline != null ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}