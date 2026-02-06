import 'package:eventak/core/constants/app-colors.dart';
import 'package:flutter/material.dart';

class GuestEmptyState extends StatelessWidget {
  final VoidCallback onAddManual;
  final VoidCallback onImport;

  const GuestEmptyState({
    super.key,
    required this.onAddManual,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      //  SingleChildScrollView to prevent overflow
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_add_outlined, size: 60, color: Colors.grey[200]),
              const SizedBox(height: 16),
              Text(
                "No Guests Yet",
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: AppColor.blueFont,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Add people manually or import an Excel file.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24), 
              SizedBox(
                width: 180, 
                child: ElevatedButton(
                  onPressed: onAddManual,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Add Manually", style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 180,
                child: OutlinedButton.icon(
                  onPressed: onImport,
                  icon: const Icon(Icons.upload_file, size: 16),
                  label: const Text("Import File", style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColor.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}