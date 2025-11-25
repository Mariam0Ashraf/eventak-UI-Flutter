import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/features/auth/data/auth_service.dart';
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
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _serviceNameController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _role = "User";
  bool _showServiceField = false;
  bool _agreedToTerms = false;

  String? _firstNameError;
  String? _lastNameError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _serviceNameError;

  void _register() async {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    final pass = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();
    final service = _serviceNameController.text.trim();

    setState(() {
      _firstNameError = null;
      _lastNameError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _serviceNameError = null;
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
    if (_showServiceField && service.isEmpty) {
      _serviceNameError = "Service name required";
      hasError = true;
    }
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must agree to the Terms & Conditions"),
        ),
      );
      return;
    }
    if (hasError) {
      setState(() {});
      return;
    }

    try {
      final result = await AuthService().register(
        firstName: first,
        lastName: last,
        email: widget.email,
        password: pass,
        role: _role,
        serviceName: _showServiceField ? service : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? "Account created successfully"),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      setState(() {
        _passwordError = e.toString().replaceAll("Exception: ", "");
      });
    }
  }

  InputDecoration _inputDecoration(
    String label, {
    bool hasEye = false,
    bool isVisible = false,
    VoidCallback? toggle,
  }) {
    return InputDecoration(
      labelText: label,
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
      backgroundColor: AppColor.beige,
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
              const SizedBox(height: 20),

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

              // Role
              DropdownButtonFormField<String>(
                value: _role,
                items: const [
                  DropdownMenuItem(value: "User", child: Text("User")),
                  DropdownMenuItem(
                    value: "Service Provider",
                    child: Text("Service Provider"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _role = value!;
                    _showServiceField = _role == "Service Provider";
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Select Role",
                  border: OutlineInputBorder(),
                ),
              ),

              if (_showServiceField) ...[
                const SizedBox(height: 16),
                if (_serviceNameError != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _serviceNameError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                TextField(
                  controller: _serviceNameController,
                  decoration: _inputDecoration("Service Name"),
                ),
              ],

              const SizedBox(height: 16),

              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (val) => setState(() => _agreedToTerms = val!),
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
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                  ),
                  child: const Text(
                    "Register",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
