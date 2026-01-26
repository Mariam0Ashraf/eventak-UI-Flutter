import 'package:eventak/customer-UI/features/services/service_details/data/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/services/service_details/data/service_model.dart';
import 'package:eventak/core/utils/app_alerts.dart';

class BookServiceTab extends StatefulWidget {
  final ServiceData service;
  const BookServiceTab({super.key, required this.service});

  @override
  State<BookServiceTab> createState() => _BookServiceTabState();
}

class _BookServiceTabState extends State<BookServiceTab> {
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  int capacity = 1;
  bool _isLoading = false;
  final TextEditingController notesController = TextEditingController();
  final _cartService = CartService();

  String _formatTime(TimeOfDay? time) {
    if (time == null) return "Not set";
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _handleAddToCart() async {
    if (selectedDate == null) {
      AppAlerts.showPopup(context, 'Please select a date', isError: true);
      return;
    }

    if (startTime != null && endTime != null) {
      final startMinutes = startTime!.hour * 60 + startTime!.minute;
      final endMinutes = endTime!.hour * 60 + endTime!.minute;
      final durationMinutes = endMinutes - startMinutes;

      if (durationMinutes < 120) {
        AppAlerts.showPopup(context, 'The duration must be at least 2 hours', isError: true);
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final dateStr = "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

      await _cartService.addToCart(
        bookableId: widget.service.id,
        eventDate: dateStr,
        startTime: startTime != null ? _formatTime(startTime) : null,
        endTime: endTime != null ? _formatTime(endTime) : null,
        capacity: !widget.service.fixedCapacity ? capacity : null,
        areaId: widget.service.areaId,
        notes: notesController.text.trim(),
      );

      if (mounted) {
        AppAlerts.showPopup(context, 'Added to cart successfully!');
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showPopup(context, e.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Date', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildPickerTile(
                    icon: Icons.calendar_today,
                    text: selectedDate == null ? 'Choose Date' : "${selectedDate!.toLocal()}".split(' ')[0],
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (date != null) setState(() => selectedDate = date);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildTimeCol("Start Time", startTime, (t) => setState(() => startTime = t))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTimeCol("End Time", endTime, (t) => setState(() => endTime = t))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Capacity / Guests ${widget.service.fixedCapacity ? "(Fixed)" : "(Required)"}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (widget.service.fixedCapacity)
                    Text('${widget.service.capacity} Persons (Fixed)', style: const TextStyle(color: Colors.grey))
                  else
                    _capacityCounter(),
                  const SizedBox(height: 20),
                  const Text('Additional Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Any special requests?'),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
              onPressed: _isLoading ? null : _handleAddToCart,
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text('Add to Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCol(String label, TimeOfDay? time, Function(TimeOfDay) onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        _buildPickerTile(
          icon: Icons.access_time,
          text: _formatTime(time),
          onTap: () async {
            final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
            if (t != null) onPick(t);
          },
        ),
      ],
    );
  }

  Widget _buildPickerTile({required IconData icon, required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
        child: Row(children: [Icon(icon, size: 20), const SizedBox(width: 10), Text(text)]),
      ),
    );
  }

  Widget _capacityCounter() {
    return Row(
      children: [
        IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: capacity > 1 ? () => setState(() => capacity--) : null),
        Text('$capacity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => capacity++)),
      ],
    );
  }
}