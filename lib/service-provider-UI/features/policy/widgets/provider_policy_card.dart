import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/policy/data/policy_model.dart';

class ProviderPolicyCard extends StatelessWidget {
  final CancellationPolicy? policy;
  final VoidCallback onTap;
  final bool isLoading;

  const ProviderPolicyCard({
    super.key, 
    required this.policy, 
    required this.onTap, 
    this.isLoading = false
  });

  @override
  Widget build(BuildContext context) {
    bool hasPolicy = policy != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasPolicy ? Colors.green.withOpacity(0.05) : AppColor.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: hasPolicy ? Colors.green.withOpacity(0.2) : AppColor.primary.withOpacity(0.2)
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasPolicy ? Icons.verified_user_outlined : Icons.gavel_outlined,
                color: hasPolicy ? Colors.green : AppColor.primary,
              ),
              const SizedBox(width: 10),
              const Text(
                "Global Cancellation Policy",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasPolicy 
              ? "You have a custom global policy active for all your services."
              : "Using system default policy. Create your own to set custom rules.",
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: hasPolicy ? Colors.green : AppColor.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(hasPolicy ? "Show My Policy" : "Create Custom Policy"),
            ),
          ),
        ],
      ),
    );
  }
}