import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/core/constants/api_constants.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../data/event_website_model.dart';
import '../data/event_website_service.dart';

class WebsiteFormDialog extends StatefulWidget {
  final int eventId;
  final EventWebsite? existingWebsite;

  const WebsiteFormDialog({super.key, required this.eventId, this.existingWebsite});

  @override
  State<WebsiteFormDialog> createState() => _WebsiteFormDialogState();
}

class _WebsiteFormDialogState extends State<WebsiteFormDialog> {
  final EventWebsiteService _service = EventWebsiteService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late Future<Map<String, String>> _templatesFuture;
  late Future<Map<String, String>> _fontsFuture; //

  late TextEditingController _slug, _mTitle, _mDesc, _welcomeMsg;
  String? _selectedTemplate;
  String? _selectedFont; //
  Color _primaryColor = const Color(0xFF4F46E5);
  Color _secondaryColor = const Color(0xFF10B981);
  bool _showRsvp = true, _showTimeline = true;

  @override
  void initState() {
    super.initState();
    _templatesFuture = _service.fetchWebsiteTemplates(widget.eventId);
    _fontsFuture = _service.fetchWebsiteFonts(widget.eventId); //

    final w = widget.existingWebsite;
    _slug = TextEditingController(text: w?.slug ?? "");
    _selectedTemplate = w?.design.template;
    _selectedFont = w?.design.fontFamily; //

    if (w?.design.primaryColor != null && w!.design.primaryColor.isNotEmpty) {
      _primaryColor = _parseColor(w.design.primaryColor);
    }
    if (w?.design.secondaryColor != null && w!.design.secondaryColor.isNotEmpty) {
      _secondaryColor = _parseColor(w.design.secondaryColor);
    }

    _mTitle = TextEditingController(text: w?.seo.metaTitle ?? "");
    _mDesc = TextEditingController(text: w?.seo.metaDescription ?? "");
    _welcomeMsg = TextEditingController(text: w?.content.welcomeMessage ?? "");
    _showRsvp = w?.features.showRsvp ?? true;
    _showTimeline = w?.features.showTimeline ?? true;
  }

  Color _parseColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  String _colorToHex(Color color) => '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

  void _pickColor(bool isPrimary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isPrimary ? 'Pick Primary Color' : 'Pick Secondary Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: isPrimary ? _primaryColor : _secondaryColor,
            onColorChanged: (color) => setState(() {
              if (isPrimary) _primaryColor = color; else _secondaryColor = color;
            }),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Select'))],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token')?.replaceAll('"', '');
      var request = http.MultipartRequest('POST', Uri.parse('${ApiConstants.baseUrl}/events/${widget.eventId}/website'));
      request.headers.addAll({'Authorization': 'Bearer $token', 'Accept': 'application/json'});

      request.fields.addAll({
        'slug': _slug.text,
        'template': _selectedTemplate ?? "classic",
        'primary_color': _colorToHex(_primaryColor),
        'secondary_color': _colorToHex(_secondaryColor),
        'font_family': _selectedFont ?? "Inter", //
        'meta_title': _mTitle.text,
        'meta_description': _mDesc.text,
        'show_rsvp': _showRsvp ? "1" : "0",
        'show_timeline': _showTimeline ? "1" : "0",
        'welcome_message': _welcomeMsg.text,
      });

      var response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingWebsite == null ? "Create Website" : "Update Website"),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildInput(_slug, "Slug"),
                _buildDropdown(_templatesFuture, "Select Template", _selectedTemplate, (v) => setState(() => _selectedTemplate = v)), //
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildColorTile("Primary", _primaryColor, () => _pickColor(true))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildColorTile("Secondary", _secondaryColor, () => _pickColor(false))),
                  ],
                ),
                const SizedBox(height: 8),
                _buildDropdown(_fontsFuture, "Select Font Family", _selectedFont, (v) => setState(() => _selectedFont = v)), //
                _buildInput(_mTitle, "Meta Title"),
                _buildInput(_mDesc, "Meta Description", maxLines: 2),
                _buildInput(_welcomeMsg, "Welcome Message"),
                SwitchListTile(title: const Text("Show RSVP"), value: _showRsvp, onChanged: (v) => setState(() => _showRsvp = v)),
                SwitchListTile(title: const Text("Show Timeline"), value: _showTimeline, onChanged: (v) => setState(() => _showTimeline = v)),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Save", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildDropdown(Future<Map<String, String>> future, String label, String? currentVal, Function(String?) onChanged) {
    return FutureBuilder<Map<String, String>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
        final items = snapshot.data ?? {};
        return DropdownButtonFormField<String>(
          value: items.containsKey(currentVal) ? currentVal : (items.isNotEmpty ? items.keys.first : null),
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
          items: items.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? "Required" : null,
        );
      },
    );
  }

  Widget _buildInput(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (v) => v!.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildColorTile(String label, Color color, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 45,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
            child: const Center(child: Icon(Icons.colorize, color: Colors.white, size: 20)),
          ),
        ),
      ],
    );
  }
}