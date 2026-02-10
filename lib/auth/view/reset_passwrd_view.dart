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
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  void _reset() async {
    if (_passController.text.isEmpty || _confirmController.text.isEmpty) {
      AppAlerts.showPopup(context, 'Please fill in all fields', isError: true);
      return;
    }

    if (_passController.text != _confirmController.text) {
      AppAlerts.showPopup(context, 'Passwords do not match', isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      await _authService.resetPassword(
        email: widget.email,
        otp: widget.otp,
        password: _passController.text,
        confirmPassword: _confirmController.text,
      );

      if (mounted) {
        AppAlerts.showPopup(context, 'Password reset successful! Please login.');
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showPopup(
          context, 
          e.toString().replaceAll('Exception: ', ''), 
          isError: true
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.beige,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Reset Password', style: TextStyle(color: AppColor.blueFont)),
        iconTheme: IconThemeData(color: AppColor.blueFont),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                'New Password', 
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: AppColor.blueFont
                )
              ),
              const SizedBox(height: 10),
              const Text(
                'Please enter your new password below.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              
              TextField(
                controller: _passController,
                obscureText: _obscurePass,
                decoration: InputDecoration(
                  hintText: 'New Password', 
                  filled: true, 
                  fillColor: Colors.white,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePass ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _obscurePass = !_obscurePass);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), 
                    borderSide: BorderSide.none
                  ),
                ),
              ),
              const SizedBox(height: 15),
              
              TextField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  hintText: 'Confirm Password', 
                  filled: true, 
                  fillColor: Colors.white,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), 
                    borderSide: BorderSide.none
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _reset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Update Password', 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}