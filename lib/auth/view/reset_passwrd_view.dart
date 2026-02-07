import 'package:eventak/auth/data/auth_service.dart';
import 'package:eventak/core/utils/app_alerts.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String otp;
  const ResetPasswordPage({super.key, required this.email, required this.otp});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;

  void _reset() async {
    if (_passController.text != _confirmController.text) return;
    setState(() => _loading = true);
    try {
      await _authService.resetPassword(
        email: widget.email,
        otp: widget.otp,
        password: _passController.text,
        confirmPassword: _confirmController.text,
      );
      if (mounted) {
        AppAlerts.showPopup(context, 'Password reset successful! Please login with your new password.');
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      AppAlerts.showPopup(context, e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.beige,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('New Password', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColor.blueFont)),
            const SizedBox(height: 30),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: InputDecoration(hintText: 'New Password', filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: InputDecoration(hintText: 'Confirm Password', filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _reset,
                style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
                child: _loading ? const CircularProgressIndicator() : const Text('Reset', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}