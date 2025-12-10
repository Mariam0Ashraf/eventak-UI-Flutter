import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/auth/data/reset_password.dart';
import 'package:eventak/auth/view/login_view.dart'; 
import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email; 

  const ResetPasswordPage({
    super.key, 
    required this.email, 
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _service = ResetPassword();

  bool _loading = false;
  String? _message;
  String? _error;

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Basic validations
    if (_tokenController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter the reset token.');
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _error = 'Please enter a new password.');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
      _error = null;
    });

    try {
      final result = await _service.resetPassword(
        email: widget.email,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        token: _tokenController.text.trim(),
      );

      setState(() => _message = result);

      if (mounted) {
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _buildInputDecoration(
    String label,
    bool isVisible,
    VoidCallback? toggleVisibility,
  ) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      labelText: label,
      labelStyle: TextStyle(color: AppColor.blueFont.withOpacity(0.7)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      suffixIcon: toggleVisibility != null
          ? IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: AppColor.secondaryBlue,
              ),
              onPressed: toggleVisibility,
            )
          : null,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColor.primary, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColor.secondaryBlue.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              color: AppColor.beige,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Reset Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColor.blueFont,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColor.secondaryBlue.withOpacity(0.3))
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_circle, size: 16, color: AppColor.blueFont),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              widget.email, 
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColor.blueFont,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_message != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          _message!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.green, fontSize: 14),
                        ),
                      ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),

                    TextField(
                      controller: _tokenController,
                      decoration: _buildInputDecoration(
                        'Reset Token / Code',
                        true,
                        null,
                      ).copyWith(
                        hintText: 'Paste code here',
                        suffixIcon: const Icon(Icons.vpn_key, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _passwordController,
                      obscureText: !_isNewPasswordVisible,
                      decoration: _buildInputDecoration(
                        'New Password',
                        _isNewPasswordVisible,
                        () {
                          setState(() {
                            _isNewPasswordVisible = !_isNewPasswordVisible;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CONFIRM PASSWORD
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: _buildInputDecoration(
                        'Confirm New Password',
                        _isConfirmPasswordVisible,
                        () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Set New Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      child: Text(
                        'Back to Login',
                        style: TextStyle(
                          color: AppColor.secondaryBlue,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColor.secondaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}