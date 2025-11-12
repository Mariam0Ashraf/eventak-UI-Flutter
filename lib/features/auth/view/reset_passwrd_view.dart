import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/features/auth/data/reset_password.dart';
import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _emailController = TextEditingController(text: 'user@example.com'); 
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _tokenController = TextEditingController(text: '123456'); 
  final _service = ResetPassword();

  bool _loading = false;
  String? _message;
  String? _error;

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      setState(() => _error = 'Please enter and confirm your new password.');
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
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        token: _tokenController.text,
      );
      setState(() => _message = result);
      _passwordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      setState(() => _error = 'Failed to reset password. Please check your details and try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  InputDecoration _buildInputDecoration(
    String label, 
    bool isVisible, 
    VoidCallback toggleVisibility,
  ) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white, 
      labelText: label,
      labelStyle: TextStyle(color: AppColor.blueFont.withOpacity(0.7)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      suffixIcon: IconButton(
        icon: Icon(
          isVisible ? Icons.visibility : Icons.visibility_off,
          color: AppColor.secondaryBlue,
        ),
        onPressed: toggleVisibility,
      ),
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
                    const SizedBox(height: 8),
                    Text(
                      'Enter and confirm your new password below',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColor.blueFont.withOpacity(0.6),
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
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
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
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
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