import 'package:eventak/auth/widgets/auth_footer.dart';
import 'package:eventak/core/utils/app_alerts.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/auth/data/auth_service.dart';
import 'login_view.dart';

class SecondSignupPage extends StatefulWidget {
  final String email;
  const SecondSignupPage({super.key, required this.email});

  @override
  State<SecondSignupPage> createState() => _SecondSignupPageState();
}

class _SecondSignupPageState extends State<SecondSignupPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String _selectedRoleLabel = "Customer";

  static const Map<String, String> _roleLabelToBackend = {
    "Customer": "customer",
    "Service Provider": "provider",
  };

  bool _agreedToTerms = false;
  bool _isLoading = false;

  String? _firstNameError;
  String? _lastNameError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _generalError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEgyptianPhone(String v) {
    final phone = v.replaceAll(RegExp(r'\s+'), '');
    final regex = RegExp(r'^01[0-9]{9}$');
    return regex.hasMatch(phone);
  }

  String _toInternationalEgyptPhone(String input) {
    var phone = input.trim().replaceAll(RegExp(r'\s+'), '');

    if (phone.isEmpty) return phone;

    if (phone.startsWith('+')) return phone;

    if (phone.startsWith('00')) {
      return '+${phone.substring(2)}';
    }

    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }

    return '+20$phone';
  }

  void _register() async {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    final rawphone = phoneController.text.trim();
    final phone = _toInternationalEgyptPhone(rawphone);
    final pass = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    setState(() {
      _firstNameError = null;
      _lastNameError = null;
      _phoneError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _generalError = null;
    });

    bool hasError = false;

    if (first.isEmpty) {
      _firstNameError = "First name cannot be empty";
      hasError = true;
    }
    if (last.isEmpty) {
      _lastNameError = "Last name cannot be empty";
      hasError = true;
    }

    // Phone validation
    if (rawphone.isEmpty) {
      _phoneError = "Phone number cannot be empty";
      hasError = true;
    } else if (!_isValidEgyptianPhone(rawphone)) {
      _phoneError = "Enter a valid phone number (e.g. 01xxxxxxxxx)";
      hasError = true;
    }

    if (pass.isEmpty) {
      _passwordError = "Password cannot be empty";
      hasError = true;
    }
    if (confirm.isEmpty) {
      _confirmPasswordError = "Please confirm your password";
      hasError = true;
    } else if (pass != confirm) {
      _confirmPasswordError = "Passwords do not match";
      hasError = true;
    }

    if (pass.isNotEmpty) {
      final passwordRegex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{6,}$',
      );
      if (!passwordRegex.hasMatch(pass)) {
        _passwordError =
            "Password must include upper, lower, number & special character (min 6 chars)";
        hasError = true;
      }
    }

    if (!_agreedToTerms) {
      AppAlerts.showPopup(context, 'You must agree to the Terms & Conditions to register', isError: true);
      return;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String backendRole =
          _roleLabelToBackend[_selectedRoleLabel] ?? 'customer';

      final result = await AuthService().register(
        firstName: first,
        lastName: last,
        email: widget.email,
        phone: phone,
        password: pass,
        role: backendRole,
      );

      if (!mounted) return;

      AppAlerts.showPopup(context, 'Registration successful! Please login.');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      setState(() {
        _generalError = e.toString().replaceAll("Exception: ", "");
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration(
    String label, {
    bool hasEye = false,
    bool isVisible = false,
    VoidCallback? toggle,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      suffixIcon: hasEye
          ? IconButton(
              icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: toggle,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Create an account",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColor.blueFont,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Join Eventak for the first time",
                style: TextStyle(fontSize: 16, color: AppColor.primary),
              ),
              const SizedBox(height: 12),

              if (_generalError != null) ...[
                Text(
                  _generalError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        if (_firstNameError != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _firstNameError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        TextField(
                          controller: _firstNameController,
                          decoration: _inputDecoration("First Name"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        if (_lastNameError != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _lastNameError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        TextField(
                          controller: _lastNameController,
                          decoration: _inputDecoration("Last Name"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_phoneError != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _phoneError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration(
                  "Phone Number",
                  hint: "01xxxxxxxxx",
                ),
              ),

              const SizedBox(height: 16),

              if (_passwordError != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _passwordError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: _inputDecoration(
                  "Password",
                  hasEye: true,
                  isVisible: _isPasswordVisible,
                  toggle: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 8),
                child: Text(
                  "Password must be at least 6 characters and include uppercase, lowercase, number & special character",
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ),

              if (_confirmPasswordError != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _confirmPasswordError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: _inputDecoration(
                  "Confirm Password",
                  hasEye: true,
                  isVisible: _isConfirmPasswordVisible,
                  toggle: () => setState(
                    () =>
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedRoleLabel,
                items: const [
                  DropdownMenuItem(value: "Customer", child: Text("Customer")),
                  DropdownMenuItem(
                    value: "Service Provider",
                    child: Text("Service Provider"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRoleLabel = value ?? "Customer";
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Select Role",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (val) =>
                        setState(() => _agreedToTerms = val ?? false),
                  ),
                  Flexible(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _agreedToTerms = !_agreedToTerms),
                      child: const Text("I agree to the Terms & Conditions"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          "Register",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              AuthFooter(
                leadingText: "Already have an account?",
                actionText: "Login",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
