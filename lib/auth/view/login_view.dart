import 'package:eventak/auth/widgets/auth_footer.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/auth/view/first_signup_view.dart';
import 'package:eventak/auth/data/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/customer-UI/features/home/view/home_view.dart'
    as customer_ui;
import 'package:eventak/service-provider-UI/features/home/views/service_provider_home_view.dart'
    as provider_ui;
import 'package:eventak/auth/view/forgot_password_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  String? _emailError;
  String? _passwordError;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    _checkLoggedIn();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final savedRole = prefs.getString('user_role')?.toLowerCase();

    if (token != null && token.isNotEmpty && mounted) {
      Widget home;
      if (savedRole == 'provider') {
        home = const provider_ui.ServiceProviderHomeView();
      } else {
        home = const customer_ui.HomeView();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => home),
      );
    }
  }

  void _login() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });

    if (email.isEmpty) {
      setState(() => _emailError = "Email cannot be empty");
      return;
    }

    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email)) {
      setState(() => _emailError = "Invalid email format");
      return;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = "Password cannot be empty");
      return;
    }

    if (password.length < 6) {
      setState(() => _passwordError = "Password must be at least 6 characters");
      return;
    }

    if (password.length > 50) {
      setState(() => _passwordError = "Password is too long");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final result = await authService.login(email, password);

      final dynamic data = result['data'] ?? result;

      final token = data['access_token'];
      final user = data['user'];

      if (token != null && user != null) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('auth_token', token.toString());
        await prefs.setString('user_name', user['name']?.toString() ?? '');
        await prefs.setString('user_email', user['email']?.toString() ?? '');
        await prefs.setString('user_avatar', user['avatar']?.toString() ?? '');

        final userId = user['id'];
        if (userId is int) {
          await prefs.setInt('user_id', userId);
        } else {
          final parsedId = int.tryParse(userId.toString());
          if (parsedId != null) {
            await prefs.setInt('user_id', parsedId);
          }
        }

        final dynamic roleValue = user['role'] ?? user['roles'];

        String? primaryRole;

        if (roleValue is List && roleValue.isNotEmpty) {
          final first = roleValue.first;
          if (first is Map<String, dynamic>) {
            primaryRole = first['name']?.toString();
          } else {
            primaryRole = first.toString();
          }
        } else if (roleValue is Map<String, dynamic>) {
          primaryRole = roleValue['name']?.toString();
        } else if (roleValue is String) {
          primaryRole = roleValue;
        }

        primaryRole = primaryRole?.toLowerCase();

        if (primaryRole != null) {
          await prefs.setString('user_role', primaryRole);
        }

        if (!mounted) return;

        Widget home;
        if (primaryRole == 'provider') {
          home = const provider_ui.ServiceProviderHomeView();
        } else {
          home = const customer_ui.HomeView();
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => home),
        );
      } else {
        setState(() {
          _generalError = "Invalid email or password";
        });
      }
    } catch (e) {
      final raw = e.toString().replaceAll("Exception: ", "");
      final lower = raw.toLowerCase();

      String friendly;
      if (lower.contains('credential')) {
        friendly = "Invalid email or password";
      } else if (lower.contains('timeout') ||
          lower.contains('timed out') ||
          lower.contains('time out') ||
          lower.contains('connection')) {
        friendly =
            "Connection issue. Please check your internet and try again.";
      } else if (lower.contains('invalid') &&
          (lower.contains('login') || lower.contains('password'))) {
        friendly = "Invalid email or password";
      } else {
        friendly = raw.isEmpty
            ? "Something went wrong. Please try again."
            : raw;
      }

      setState(() {
        _generalError = friendly;
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
    String? errorText,
  }) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      errorText: errorText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  "assets/App_photos/eventak_logo.png",
                  width: 120,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Welcome back!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColor.blueFont,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Please enter your credentials",
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

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onSubmitted: (_) => _login(),
                onChanged: (value) {
                  if (value.contains(' ')) {
                    final clean = value.replaceAll(' ', '');
                    _emailController.value = TextEditingValue(
                      text: clean,
                      selection: TextSelection.fromPosition(
                        TextPosition(offset: clean.length),
                      ),
                    );
                  }
                  if (_emailError != null || _generalError != null) {
                    setState(() {
                      _emailError = null;
                      _generalError = null;
                    });
                  }
                },
                decoration: _inputDecoration(
                  "Email Address",
                  errorText: _emailError,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                onSubmitted: (_) => _login(),
                onChanged: (_) {
                  if (_passwordError != null || _generalError != null) {
                    setState(() {
                      _passwordError = null;
                      _generalError = null;
                    });
                  }
                },
                decoration: _inputDecoration(
                  "Password",
                  hasEye: true,
                  isVisible: _isPasswordVisible,
                  toggle: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                  errorText: _passwordError,
                ),
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  child: const Text("Forgot password?"),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              AuthFooter(
              leadingText: "Don't have an account?",
              actionText: "Sign Up",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FirstSignupPage()),
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
