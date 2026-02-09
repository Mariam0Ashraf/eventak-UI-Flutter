import 'package:eventak/service-provider-UI/features/policy/data/policy_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/core/constants/api_constants.dart';

class PolicyPromptDialog extends StatefulWidget {
  final String itemName;
  final int itemId;
  final bool isPackage;

  const PolicyPromptDialog({
    super.key,
    required this.itemName,
    required this.itemId,
    required this.isPackage,
  });

  @override
  State<PolicyPromptDialog> createState() => _PolicyPromptDialogState();
}

class _PolicyPromptDialogState extends State<PolicyPromptDialog> {
  CancellationPolicy? globalPolicy;
  bool loading = true;

  @override
  void initState() {
    super.initState();
   
    _fetchGlobalPolicy();
  }

  Future<void> _fetchGlobalPolicy() async {
    try {
      final dio = Dio();
      final response = await dio.get('${ApiConstants.baseUrl}/cancellation-policies/global');
      
      if (mounted) {
        setState(() {
          final policyData = response.data['data']['policy']; 
          globalPolicy = CancellationPolicy.fromJson(policyData);
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("API Error: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text("Custom Cancellation Policy", 
          style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold)),
      content: loading
          ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Do you want to add a custom policy for the ${widget.itemName} ${widget.isPackage ? 'package' : 'service'}?"),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Our Global Policy:", style: TextStyle(fontWeight: FontWeight.bold)),
                        const Divider(),
                        if (globalPolicy != null) ...[
                          Text("• Minimum Notice: ${globalPolicy!.minimumNoticeHours} hours"),
                          const SizedBox(height: 8),
                          ...globalPolicy!.refundSchedule.map((rule) => 
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text("• ${rule.daysBefore} days before: ${rule.refundPercentage}% refund"),
                            )
                          ),
                        ] else 
                          const Text("No policy details available."),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () {
            debugPrint("Selected Global for ID: ${widget.itemId}");
            Navigator.pop(context, false);
          },
          child: const Text("Use Global", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
          ),
          onPressed: () {
            debugPrint("Selected Custom for ID: ${widget.itemId}");
            Navigator.pop(context, true);
          },
          child: const Text("Add Custom", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}