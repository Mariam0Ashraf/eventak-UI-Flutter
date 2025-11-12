import 'package:eventak/features/auth/data/reset_password.dart';
import 'package:eventak/features/auth/view/forgot_password_view.dart';
import 'package:eventak/features/auth/view/profile_view.dart';
import 'package:eventak/features/auth/view/reset_passwrd_view.dart';
import 'package:eventak/splash.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eventak',
      
      home: UserProfilePage(),
    );
  }
}
