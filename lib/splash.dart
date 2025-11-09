import 'package:eventak/core/constants/app-colors.dart';
import 'package:flutter/material.dart';

class splashView extends StatelessWidget {
  const splashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      body: Center(child: Image.asset("assets/logos/logo.jpg")),
    );
}
}