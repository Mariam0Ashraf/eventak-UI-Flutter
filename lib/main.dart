import 'package:eventak/auth/view/login_view.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

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
      home: const LoginPage(),
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
      //home: const ServiceProviderHomeView(),
      //home: const HomeView(),
    );
  }
}
