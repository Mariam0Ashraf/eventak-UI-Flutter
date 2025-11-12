
import 'package:eventak/core/constants/app-colors.dart';
import 'package:flutter/material.dart';

Future<String?> ShowEditDialogWidget(
    BuildContext context, String title, String initialValue) {
  final controller = TextEditingController(text: initialValue);

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        title,
        style: TextStyle(
          color: AppColor.blueFont,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'CANCEL',
            style: TextStyle(
              color: AppColor.blueFont,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, controller.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
          ),
          child: const Text(
            'SAVE',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
