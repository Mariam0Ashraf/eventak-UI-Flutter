import 'package:eventak/auth/data/auth_service.dart';
import 'package:eventak/auth/view/verify_otp.dart';
import 'package:eventak/core/utils/app_alerts.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';


class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;

  void _submit() async {
    if (_emailController.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      await _authService.sendForgotPasswordOtp(_emailController.text.trim());
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyOtpPage(email: _emailController.text.trim()),
          ),
        );
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
            Text('Forgot Password', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColor.blueFont)),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(hintText: 'Enter Email', filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
                child: _loading ? const CircularProgressIndicator() : const Text('Send Code', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}