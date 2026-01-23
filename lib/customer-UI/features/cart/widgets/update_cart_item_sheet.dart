import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_item_model.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateCartItemSheet extends StatefulWidget {
  final CartItem item;
  const UpdateCartItemSheet({super.key, required this.item});

  @override
  State<UpdateCartItemSheet> createState() => _UpdateCartItemSheetState();
}

class _UpdateCartItemSheetState extends State<UpdateCartItemSheet> {
  late TextEditingController _notesController;
  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int? _capacity;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(
      text: widget.item.options['notes'] ?? "",
    );
    _capacity = widget.item.capacity ?? 1;

    if (widget.item.options['event_date'] != null) {
      _date = DateTime.tryParse(widget.item.options['event_date']);
    }
    _startTime = _parseTime(widget.item.options['start_time']);
    _endTime = _parseTime(widget.item.options['end_time']);
  }

  TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null || !timeStr.contains(':')) return null;
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return "Not selected";
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit ${widget.item.name}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColor.blueFont,
              ),
            ),
            const SizedBox(height: 20),

            // Date Selection
            _buildListTile(
              Icons.calendar_month,
              'Event Date',
              _date == null
                  ? 'Choose Date'
                  : "${_date!.year}-${_date!.month}-${_date!.day}",
              () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      _date ?? DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),

            // Time Selection
            Row(
              children: [
                Expanded(
                  child: _buildListTile(
                    Icons.access_time,
                    'Start',
                    _formatTime(_startTime),
                    () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _startTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) setState(() => _startTime = picked);
                    },
                  ),
                ),
                Expanded(
                  child: _buildListTile(
                    Icons.access_time_filled,
                    'End',
                    _formatTime(_endTime),
                    () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _endTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) setState(() => _endTime = picked);
                    },
                  ),
                ),
              ],
            ),

            const Divider(height: 30),

            // CAPACITY 
            const Text(
              'Guests / Capacity',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.remove_circle,
                          color: AppColor.primary,
                        ),
                        onPressed: () => setState(() {
                          if ((_capacity ?? 1) > 1) _capacity = _capacity! - 1;
                        }),
                      ),
                      Text(
                        '$_capacity',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: AppColor.primary),
                        onPressed: () =>
                            setState(() => _capacity = (_capacity ?? 0) + 1),
                      ),
                    ],
                  ),
                  const Text('Persons', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // NOTES 
            const Text(
              'Additional Notes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Dietary requirements, preferred colors...',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // UPDATE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(
    IconData icon,
    String title,
    String value,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColor.primary.withOpacity(0.1),
        child: Icon(icon, size: 18, color: AppColor.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      onTap: onTap,
    );
  }

  Future<void> _handleUpdate() async {
    setState(() => _isSubmitting = true);
    try {
      final String? formattedDate = _date != null
          ? "${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}"
          : null;

      await context.read<CartProvider>().updateCartItemFull(
        cartItemId: widget.item.cartItemId,
        eventDate: formattedDate,
        startTime: _startTime != null ? _formatTime(_startTime) : null,
        endTime: _endTime != null ? _formatTime(_endTime) : null,
        capacity: _capacity,
        notes: _notesController.text.trim(),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
