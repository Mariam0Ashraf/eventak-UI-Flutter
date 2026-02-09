import 'package:eventak/service-provider-UI/features/policy/data/policy_model.dart';
import 'package:eventak/service-provider-UI/features/policy/view/policy_details_view.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/show_service/widgets/show_service_widgets.dart';

class PolicyStatusCard extends StatelessWidget {
  final int serviceId; 
  final CancellationPolicy? policy;
  final VoidCallback onAdd;
  final VoidCallback onEdit;
  final bool isLoading;

  const PolicyStatusCard({
    super.key,
    required this.serviceId, 
    required this.policy,
    required this.onAdd,
    required this.onEdit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ServiceDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cancellation Policy',
                  style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold, fontSize: 14)),
              if (policy != null && !isLoading)
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_note_outlined, color: AppColor.primary, size: 24),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (isLoading)
            const LinearProgressIndicator()
          else
            SizedBox(
              width: double.infinity,
              child: policy == null ? _buildAddButton() : _buildShowButton(context),
            ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton.icon(
      onPressed: onAdd,
      icon: const Icon(Icons.add_circle_outline, size: 18),
      label: const Text("Create Custom Policy"),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.primary.withOpacity(0.1),
        foregroundColor: AppColor.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildShowButton(BuildContext context) {
    return ElevatedButton.icon(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PolicyDetailsPage(
                serviceId: serviceId,
                initialPolicy: policy!,
              ),
            ),
          );
          if (result == true) {
            onAdd(); 
          }
        },
      icon: const Icon(Icons.visibility_outlined, size: 18),
      label: const Text("Show My Policy"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.withOpacity(0.1),
        foregroundColor: Colors.green,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}