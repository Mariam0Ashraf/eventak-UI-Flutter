import 'package:eventak/auth/view/login_view.dart';
import 'package:eventak/auth/widgets/auth_footer.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'second_signup_view.dart';

class FirstSignupPage extends StatefulWidget {
  const FirstSignupPage({super.key});

  @override
  State<FirstSignupPage> createState() => _FirstSignupPageState();
}

class _FirstSignupPageState extends State<FirstSignupPage> {
  final _emailController = TextEditingController();
  String? _emailError;

  void _continue() {
    final email = _emailController.text.trim();

    setState(() {
      _emailError = null;
    });

    if (email.isEmpty) {
      setState(() => _emailError = "Email cannot be empty");
      return;
    }

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _emailError = "Invalid email format");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SecondSignupPage(email: email)),
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
                "Create an account!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColor.blueFont,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Enter your email to sign up for Eventak",
                style: TextStyle(fontSize: 16, color: AppColor.primary),
              ),
              const SizedBox(height: 24),

              if (_emailError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    _emailError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              AuthFooter(
                leadingText: "Already have an acccount?",
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
