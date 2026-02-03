import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/event_website_service.dart';

class PageFormDialog extends StatefulWidget {
  final int eventId;
  const PageFormDialog({super.key, required this.eventId});

  @override
  State<PageFormDialog> createState() => _PageFormDialogState();
}

class _PageFormDialogState extends State<PageFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _service = EventWebsiteService();
  bool _isLoading = false;

  final _titleController = TextEditingController();
  final _slugController = TextEditingController();
  final _contentController = TextEditingController();
  final _orderController = TextEditingController(text: "1");
  bool _isActive = true;
  bool _showInMenu = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _service.saveWebsitePage(
        eventId: widget.eventId,
        title: _titleController.text,
        slug: _slugController.text,
        content: _contentController.text,
        order: int.parse(_orderController.text),
        isActive: _isActive,
        showInMenu: _showInMenu,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Website Page"),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildField(_titleController, "Title (e.g., RSVP)"),
                _buildField(_slugController, "Slug (e.g., rsvp)"),
                _buildField(_contentController, "Content (HTML strings allowed)", maxLines: 5),
                _buildField(_orderController, "Display Order", isNumber: true),
                SwitchListTile(
                  title: const Text("Is Active", style: TextStyle(fontSize: 14)),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
                SwitchListTile(
                  title: const Text("Show in Menu", style: TextStyle(fontSize: 14)),
                  value: _showInMenu,
                  onChanged: (v) => setState(() => _showInMenu = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Save Page", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildField(TextEditingController controller, String label, {int maxLines = 1, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (v) => v!.isEmpty ? "Required" : null,
      ),
    );
  }
}