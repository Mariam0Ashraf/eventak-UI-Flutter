import 'package:eventak/service-provider-UI/features/policy/data/policy_repo.dart';
import 'package:eventak/service-provider-UI/features/policy/view/create_policy_view.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/policy/data/policy_model.dart';
import 'package:eventak/core/utils/app_alerts.dart';

class PolicyDetailsPage extends StatefulWidget {
  final int serviceId;
  final CancellationPolicy initialPolicy;
  final bool isProviderLevel;

  const PolicyDetailsPage({
    super.key,
    required this.serviceId,
    required this.initialPolicy,
    this.isProviderLevel = false,
  });

  @override
  State<PolicyDetailsPage> createState() => _PolicyDetailsPageState();
}

class _PolicyDetailsPageState extends State<PolicyDetailsPage> {
  late CancellationPolicy _currentPolicy;
  final CancellationPolicyRepo _repo = CancellationPolicyRepo();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentPolicy = widget.initialPolicy;
  }

  Future<void> _refreshPolicy() async {
    setState(() => _isLoading = true);
    try {
      final updatedPolicy = widget.isProviderLevel 
          ? await _repo.getProviderPolicy() 
          : await _repo.getServicePolicy(widget.serviceId);
      
      if (updatedPolicy != null && mounted) {
        setState(() => _currentPolicy = updatedPolicy);
      }
    } catch (e) {
      debugPrint("Refresh error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Policy?"),
        content: const Text("Are you sure you want to delete this custom policy? It will revert to the default settings."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      if (widget.isProviderLevel) {
        await _repo.deleteProviderPolicy();
      } else {
        await _repo.deleteServicePolicy(widget.serviceId);
      }
      
      if (mounted) {
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) AppAlerts.showPopup(context, "Failed to delete: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePolicyView(
          itemId: widget.serviceId,
          isPackage: false,
          isProviderLevel: widget.isProviderLevel,
          existingPolicy: _currentPolicy,
        ),
      ),
    );
    if (result == true) await _refreshPolicy();
  }

  @override
  Widget build(BuildContext context) {
    final p = _currentPolicy;
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("Policy Details", style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: AppColor.blueFont),
        actions: [
          if (!_isLoading) ...[
            IconButton(onPressed: _onDelete, icon: const Icon(Icons.delete_outline, color: Colors.redAccent)),
            IconButton(onPressed: _onEdit, icon: Icon(Icons.edit_outlined, color: AppColor.primary)),
          ]
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPolicy,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading) const LinearProgressIndicator(),
              const SizedBox(height: 8),
              _buildSectionCard(
                title: "General Constraints",
                child: _buildInfoRow(Icons.history_toggle_off, "Minimum Notice Hours", "${p.minimumNoticeHours} Hours"),
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: "Refund Schedule",
                child: Column(
                  children: p.refundSchedule.map((rule) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          CircleAvatar(radius: 18, backgroundColor: AppColor.primary.withOpacity(0.1), child: Icon(Icons.calendar_month, size: 18, color: AppColor.primary)),
                          const SizedBox(width: 12),
                          Text("${rule.daysBefore} days before event", style: const TextStyle(fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Text("${rule.refundPercentage}%", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (p.customNote != null && p.customNote!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildSectionCard(title: "Custom Conditions", child: Text(p.customNote!, style: TextStyle(color: AppColor.blueFont.withOpacity(0.7), height: 1.5))),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold, fontSize: 15)), const Divider(height: 24), child]),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(children: [Icon(icon, color: AppColor.primary, size: 20), const SizedBox(width: 10), Text(label, style: const TextStyle(fontWeight: FontWeight.w500)), const Spacer(), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]);
  }
}