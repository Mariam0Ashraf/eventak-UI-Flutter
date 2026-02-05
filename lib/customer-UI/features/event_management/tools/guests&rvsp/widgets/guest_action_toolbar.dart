import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class GuestActionToolbar extends StatelessWidget {
  final VoidCallback onImportFile;
  final VoidCallback onDownloadTemplate;
  final VoidCallback onAddManual;
  final VoidCallback onSendAll;

  const GuestActionToolbar({
    super.key,
    required this.onImportFile,
    required this.onDownloadTemplate,
    required this.onAddManual,
    required this.onSendAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildActionButton(onDownloadTemplate, Icons.download, "Template"),
          const SizedBox(width: 8),
          _buildActionButton(onImportFile, Icons.upload_file, "Import"),
          const SizedBox(width: 8),
          _buildActionButton(onSendAll, Icons.send_rounded, "Send All", isPrimary: true),
          
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

  Widget _buildActionButton(VoidCallback onTap, IconData icon, String label, {bool isPrimary = false}) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: isPrimary ? Colors.blue : AppColor.primary),
        label: Text(label, style: TextStyle(fontSize: 11, color: isPrimary ? Colors.blue : AppColor.primary)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: isPrimary ? Colors.blue : AppColor.primary),
        ),
      ),
    );
  }
}