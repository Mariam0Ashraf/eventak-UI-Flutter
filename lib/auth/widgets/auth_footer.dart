import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/auth/view/login_view.dart';

class AuthFooter extends StatelessWidget {
  final String leadingText;
  final String actionText;
  final VoidCallback onPressed;

  const AuthFooter({
    super.key,
    required this.leadingText,
    required this.actionText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          leadingText,
          //style:  TextStyle(fontSize: 14, color: AppColor.grey),
          style:  const TextStyle(fontSize: 14, color: Color.fromARGB(225, 158, 158, 158) ),

        ),
        const SizedBox(width: 6), 
        TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              // Adding horizontal padding gives the ripple (hover) more width
              // Adding vertical padding gives the ripple more height
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16), 
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.padded, 
              foregroundColor: AppColor.blueFont,
          ),
          child: Text(
            actionText,
            style: TextStyle(
              color: AppColor.primary,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}