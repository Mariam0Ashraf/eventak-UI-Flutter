import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; //
import 'package:eventak/core/constants/app-colors.dart';
import '../data/event_website_model.dart';
import '../data/event_website_service.dart';

class WebsiteSettingsDialog extends StatefulWidget {
  final int eventId;
  final EventWebsite website;

  const WebsiteSettingsDialog({
    super.key,
    required this.eventId,
    required this.website,
  });

  @override
  State<WebsiteSettingsDialog> createState() => _WebsiteSettingsDialogState();
}

class _WebsiteSettingsDialogState extends State<WebsiteSettingsDialog> {
  final _service = EventWebsiteService();
  bool _isLoading = false;

  late Color _pickerColor; 
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    String hexColor = widget.website.design.primaryColor.replaceAll('#', '');
    _pickerColor = Color(int.parse("FF$hexColor", radix: 16));
    _titleController = TextEditingController(text: widget.website.seo.metaTitle);
  }

  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _pickerColor,
            onColorChanged: (color) => setState(() => _pickerColor = color),
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Done'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    try {
      await _service.updateWebsiteSettings(
        eventId: widget.eventId,
        primaryColor: colorToHex(_pickerColor), 
        metaTitle: _titleController.text,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Website Settings"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Primary Color", style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _showColorPicker,
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _pickerColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(width: 12),
                Text(colorToHex(_pickerColor), style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                const Icon(Icons.colorize, size: 20, color: Colors.blue),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: "Meta Title",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSave,
          style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
          child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("Save Settings", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}