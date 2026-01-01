import 'package:flutter/material.dart';

Future<Map<String, String>?> showPasswordDialog(BuildContext context) {
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showDialog<Map<String, String>>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: currentController, decoration: const InputDecoration(labelText: 'Current Password'), obscureText: true),
            TextFormField(controller: newController, decoration: const InputDecoration(labelText: 'New Password'), obscureText: true),
            TextFormField(controller: confirmController, decoration: const InputDecoration(labelText: 'Confirm New Password'), obscureText: true),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'current': currentController.text,
            'new': newController.text,
            'confirm': confirmController.text,
          }),
          child: const Text('SAVE'),
        ),
      ],
    ),
  );
}