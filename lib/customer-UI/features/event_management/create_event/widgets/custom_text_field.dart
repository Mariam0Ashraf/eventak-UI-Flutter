import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:flutter/services.dart';

final Color lightFillColor = Colors.grey.shade100;

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final int maxLines;
  final IconData? suffixIcon;
  final Widget? customWidget;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool isRequired; 
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint = '',
    this.maxLines = 1,
    this.suffixIcon,
    this.customWidget,
    this.onTap,
    this.readOnly = false,
    this.isRequired = false, 
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColor.blueFont,
                fontSize: 14,
              ),
              /*children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
              ],*/
            ),
          ),
          const SizedBox(height: 6),
          customWidget ??
              TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                readOnly: readOnly,
                onTap: onTap,
                maxLines: maxLines,
                validator: validator, 
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  suffixIcon: suffixIcon != null
                      ? Icon(suffixIcon, color: AppColor.blueFont.withOpacity(0.6))
                      : null,
                  filled: true,
                  fillColor: lightFillColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  //  Handle Error Borders
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}