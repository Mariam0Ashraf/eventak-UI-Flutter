import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/package_model.dart';
import 'package:eventak/core/utils/app_alerts.dart';
import '../data/package_details_service.dart';

class BookPackageSheet extends StatefulWidget {
  final PackageData package;
  const BookPackageSheet({super.key, required this.package});

  @override
  State<BookPackageSheet> createState() => _BookPackageSheetState();
}

class _BookPackageSheetState extends State<BookPackageSheet> {
  final _api = PackageDetailsService();
  final _notesController = TextEditingController();
  
  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int? _capacity; 
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return "Not selected";
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _handleAddToCart() async {
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final String formattedDate = 
          "${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}";

      await _api.addToCart(
        packageId: widget.package.id,
        eventDate: formattedDate,
        startTime: _startTime != null ? _formatTime(_startTime) : null,
        endTime: _endTime != null ? _formatTime(_endTime) : null,
        capacity: _capacity,
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        AppAlerts.showPopup(context, 'Added to cart successfully!');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Book ${widget.package.name}', 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColor.blueFont)),
            const SizedBox(height: 16),

            _buildListTile(
              Icons.calendar_today, 
              'Select Date', 
              _date == null ? 'Choose' : "${_date!.year}-${_date!.month}-${_date!.day}",
              () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                );
                if (picked != null) setState(() => _date = picked);
              }
            ),

            Row(
              children: [
                Expanded(
                  child: _buildListTile(
                    Icons.access_time, 
                    'Start Time', 
                    _formatTime(_startTime), 
                    () async {
                      final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (picked != null) setState(() => _startTime = picked);
                    }
                  ),
                ),
                Expanded(
                  child: _buildListTile(
                    Icons.access_time_filled, 
                    'End Time (Opt)', 
                    _formatTime(_endTime), 
                    () async {
                      final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (picked != null) setState(() => _endTime = picked);
                    }
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Capacity (Optional)', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => setState(() => _capacity = (_capacity ?? 1) > 1 ? _capacity! - 1 : null),
                ),
                Text(_capacity?.toString() ?? 'Default', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => _capacity = (_capacity ?? 0) + 1),
                ),
                if (_capacity != null)
                  TextButton(onPressed: () => setState(() => _capacity = null), child: const Text('Clear', style: TextStyle(color: Colors.red))),
              ],
            ),

            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Additional notes...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true, fillColor: Colors.grey[50],
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleAddToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Add to Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String value, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 12)),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: onTap,
    );
  }
}