import 'package:eventak/service-provider-UI/features/policy/data/policy_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/core/constants/api_constants.dart';
import 'package:eventak/core/utils/app_alerts.dart';

class RefundRow {
  TextEditingController daysController;
  TextEditingController percentController;
  RefundRow({required this.daysController, required this.percentController});
}

class CreatePolicyView extends StatefulWidget {
  final int itemId;
  final bool isPackage;
  final CancellationPolicy? existingPolicy; 

  const CreatePolicyView({
    super.key, 
    required this.itemId, 
    required this.isPackage, 
    this.existingPolicy,
  });

  @override
  State<CreatePolicyView> createState() => _CreatePolicyViewState();
}

class _CreatePolicyViewState extends State<CreatePolicyView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _noticeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final List<RefundRow> _refundRows = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.existingPolicy != null) {
      _noticeController.text = widget.existingPolicy!.minimumNoticeHours?.toString() ?? "";
      _noteController.text = widget.existingPolicy!.customNote ?? "";
      
      if (widget.existingPolicy!.refundSchedule.isNotEmpty) {
        for (var rule in widget.existingPolicy!.refundSchedule) {
          _refundRows.add(RefundRow(
            daysController: TextEditingController(text: rule.daysBefore.toString()),
            percentController: TextEditingController(text: rule.refundPercentage.toString()),
          ));
        }
      } else {
        _addRule();
      }
    } else {
      _addRule();
    }
  }

  void _addRule() {
    setState(() {
      _refundRows.add(RefundRow(
        daysController: TextEditingController(),
        percentController: TextEditingController(),
      ));
    });
  }

  @override
  void dispose() {
    _noticeController.dispose();
    _noteController.dispose();
    for (var row in _refundRows) {
      row.daysController.dispose();
      row.percentController.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_refundRows.isEmpty) {
      AppAlerts.showPopup(context, "Please add at least one refund rule", isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token')?.replaceAll('"', '');

      final List<Map<String, dynamic>> refundScheduleData = _refundRows.map((row) {
        return {
          "days_before": int.tryParse(row.daysController.text) ?? 0,
          "refund_percentage": int.tryParse(row.percentController.text) ?? 0,
        };
      }).toList();

      final String type = widget.isPackage ? 'packages' : 'services';
      final url = '${ApiConstants.baseUrl}/cancellation-policies/$type/${widget.itemId}';

      final Map<String, dynamic> data = {
        "minimum_notice_hours": int.parse(_noticeController.text.trim()),
        "refund_schedule": refundScheduleData,
        "custom_conditions": {"note": _noteController.text.trim()}
      };

      await Dio().post(
        url,
        data: data,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        }),
      );

      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text("Success"),
              ],
            ),
            content: Text(widget.existingPolicy != null 
                ? "Policy updated successfully!" 
                : "New policy added successfully!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); 
                  Navigator.pop(context); 
                },
                child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint("Save Error: $e");
      if (mounted) {
        AppAlerts.showPopup(context, "Failed to save policy. Please try again.", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.existingPolicy != null;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditing ? "Edit Custom Policy" : "Create Custom Policy"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Minimum Notice (Hours)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noticeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "e.g. 24",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 24),
              const Text("Refund Schedule", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _refundRows.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _refundRows[index].daysController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "Days Before", border: OutlineInputBorder()),
                            validator: (v) => v!.isEmpty ? "!" : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _refundRows[index].percentController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "Refund %", border: OutlineInputBorder()),
                            validator: (v) => v!.isEmpty ? "!" : null,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            if (_refundRows.length > 1) {
                              setState(() => _refundRows.removeAt(index));
                            } else {
                              AppAlerts.showPopup(context, "You must have at least one rule", isError: true);
                            }
                          },
                        )
                      ],
                    ),
                  );
                },
              ),
              TextButton.icon(
                onPressed: _addRule,
                icon: const Icon(Icons.add),
                label: const Text("Add Rule"),
              ),
              const SizedBox(height: 24),
              const Text("Custom Conditions Note", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Extra terms...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _handleSave,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEditing ? "Update Policy" : "Save Custom Policy",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}