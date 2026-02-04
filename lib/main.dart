import 'dart:async';
import 'package:eventak/auth/data/user_provider.dart';
import 'package:eventak/customer-UI/features/booking/bookings/data/bookings_provider.dart';
import 'package:eventak/customer-UI/features/event_management/event_dashboard/data/event_provider.dart';
import 'package:eventak/splash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventak/core/constants/app-colors.dart';
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