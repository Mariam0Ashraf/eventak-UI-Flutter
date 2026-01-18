import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/core/constants/api_constants.dart';
import 'package:eventak/auth/view/login_view.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_service.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_provider.dart';

void main() {
  // Required for accessing SharedPreferences during startup if needed
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          // Only 1 argument: the Service. Token is handled inside the provider.
          create: (_) => CartProvider(
            CartService(ApiConstants.baseUrl),
          ),
        ),
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
      home: const LoginPage(), // Your teammate's login page remains untouched
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