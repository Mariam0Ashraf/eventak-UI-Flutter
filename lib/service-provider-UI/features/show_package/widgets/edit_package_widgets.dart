import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/add_service/widgets/form_widgets.dart';

class EditSectionCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final Color? titleColor;

  const EditSectionCard({super.key, this.title, required this.child, this.titleColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: titleColor != null ? Border.all(color: titleColor!.withOpacity(0.1)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: TextStyle(fontWeight: FontWeight.bold, color: titleColor ?? Colors.black)),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}

class PricingConfigFields extends StatelessWidget {
  final bool isFixed;
  final TextEditingController overtimeRate;
  final TextEditingController capacityStep;
  final TextEditingController stepFee;
  final TextEditingController maxCapacity; 
  final TextEditingController maxDuration;

  const PricingConfigFields({
    super.key,
    required this.isFixed,
    required this.overtimeRate,
    required this.capacityStep,
    required this.stepFee,
    required this.maxCapacity,
    required this.maxDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: CustomTextField(controller: overtimeRate, label: 'Overtime Rate*', keyboardType: TextInputType.number)),
            const SizedBox(width: 16),
            Expanded(child: CustomTextField(controller: maxDuration, label: 'Max Duration (Hrs)', keyboardType: TextInputType.number)),
          ],
        ),
        
        CustomTextField(controller: maxCapacity, label: 'Max Capacity (Optional)', keyboardType: TextInputType.number),
        
        if (!isFixed) ...[
          const Divider(height: 32),
          Row(
            children: [
              Expanded(child: CustomTextField(controller: capacityStep, label: 'Capacity Step*', keyboardType: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(child: CustomTextField(controller: stepFee, label: 'Step Fee*', keyboardType: TextInputType.number)),
            ],
          ),
        ],
      ],
    );
  }
}