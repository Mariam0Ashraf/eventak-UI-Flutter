import 'package:eventak/auth/view/reset_passwrd_view.dart';
import 'package:eventak/core/utils/app_alerts.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/auth/data/auth_service.dart';


class VerifyOtpPage extends StatefulWidget {
  final String email;
  const VerifyOtpPage({super.key, required this.email});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _otpController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;

  void _verify() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      AppAlerts.showPopup(context, "Please enter the OTP code", isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final message = await _authService.verifyOtp(widget.email, otp);
      if (mounted) {
        AppAlerts.showPopup(context, message);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResetPasswordPage(
                  email: widget.email,
                  otp: otp,
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showPopup(context, e.toString().replaceAll('Exception: ', ''), isError: true);
      }
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
            Text('Verify Code', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColor.blueFont)),
            const SizedBox(height: 30),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: 'Enter OTP', filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _verify,
                style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
                child: _loading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Verify', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}