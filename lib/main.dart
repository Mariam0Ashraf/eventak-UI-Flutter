import 'dart:async';
import 'package:eventak/auth/data/user_provider.dart';
import 'package:eventak/customer-UI/features/booking/bookings/data/bookings_provider.dart';
import 'package:eventak/customer-UI/features/event_management/event_dashboard/data/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/auth/view/login_view.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_service.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CartProvider(
            CartService(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()..refreshUser()),
        ChangeNotifierProvider(create: (_) => BookingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventak',
      debugShowCheckedModeBanner: false,
      home: const SplashView(), 
      theme: ThemeData(
        primaryColor: AppColor.primary,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColor.primary,
          elevation: 0,
          centerTitle: true,
        ),
      ),
    );
  }
}


class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      body: Center(
        child: Image.asset(
          "assets/logos/logo.png",
          width: 250, 
        ),
      ),
    );
  }
}