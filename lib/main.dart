import 'package:eventak/auth/data/reset_password.dart';
import 'package:eventak/auth/view/forgot_password_view.dart';
import 'package:eventak/auth/view/login_view.dart';
import 'package:eventak/auth/view/profile_view.dart';
import 'package:eventak/auth/view/reset_passwrd_view.dart';
import 'package:eventak/splash.dart';
import 'package:flutter/material.dart';

import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/home/view/home_view.dart';
import 'package:eventak/service-provider-UI/features/home/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColor.primary,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColor.primary,
          elevation: 0,
          centerTitle: true,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: AppColor.blueFont),
          titleLarge: TextStyle(
            color: AppColor.blueFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: AppColor.secondaryBlue,
        ),
      ),
      //home: const ForgotPasswordPage(),
      home: const HomeView()
    );
  }
}
