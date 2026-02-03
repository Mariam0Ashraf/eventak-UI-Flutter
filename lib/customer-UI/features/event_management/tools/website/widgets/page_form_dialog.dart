import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/event_website_service.dart';
import '../data/event_website_model.dart';

class PageFormDialog extends StatefulWidget {
  final int eventId;
  final WebsitePage? existingPage;

  const PageFormDialog({super.key, required this.eventId, this.existingPage});

  @override
  State<PageFormDialog> createState() => _PageFormDialogState();
}

class _PageFormDialogState extends State<PageFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _service = EventWebsiteService();
  bool _isLoading = false;

  late TextEditingController _titleController;
  late TextEditingController _slugController;
  late TextEditingController _contentController;
  late TextEditingController _orderController;
  late bool _showInMenu;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final p = widget.existingPage;
    _titleController = TextEditingController(text: p?.title ?? "");
    _slugController = TextEditingController(text: p?.slug ?? "");
    _contentController = TextEditingController(text: p?.content ?? "");
    _orderController = TextEditingController(text: "1");
    _showInMenu = p?.showInMenu ?? true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (widget.existingPage != null) {
        await _service.updateWebsitePage(
          eventId: widget.eventId,
          pageId: widget.existingPage!.id,
          title: _titleController.text,
          content: _contentController.text,
          showInMenu: _showInMenu,
        );
      } else {
        await _service.saveWebsitePage(
          eventId: widget.eventId,
          title: _titleController.text,
          slug: _slugController.text,
          content: _contentController.text,
          order: int.tryParse(_orderController.text) ?? 1, 
          isActive: _isActive,
          showInMenu: _showInMenu,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.existingPage != null;

    return AlertDialog(
      title: Text(isEditing ? "Update Website Page" : "Add Website Page"),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildField(_titleController, "Title"),
                if (!isEditing) _buildField(_slugController, "Slug"),
                _buildField(_contentController, "Content (HTML allowed)", maxLines: 5),
                if (!isEditing) _buildField(_orderController, "Order", isNumber: true),
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
          child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
            : const Text("Save Page", style: TextStyle(color: Colors.white)),
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