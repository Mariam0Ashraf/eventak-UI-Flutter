import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class GuestActionToolbar extends StatelessWidget {
  final VoidCallback onImportFile;
  final VoidCallback onDownloadTemplate;
  final VoidCallback onAddManual;

  const GuestActionToolbar({
    super.key,
    required this.onImportFile,
    required this.onDownloadTemplate,
    required this.onAddManual,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onDownloadTemplate,
              icon: const Icon(Icons.download, size: 18),
              label: const Text("Template", style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(foregroundColor: AppColor.primary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onImportFile,
              icon: const Icon(Icons.upload_file, size: 18),
              label: const Text("Import", style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(foregroundColor: AppColor.primary),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onAddManual,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(10),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}