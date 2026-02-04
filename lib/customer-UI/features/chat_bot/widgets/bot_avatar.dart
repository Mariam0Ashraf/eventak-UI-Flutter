import 'package:flutter/material.dart';

class BotAvatar extends StatelessWidget {
  final double size;
  const BotAvatar({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Image.asset(
          'assets/logos/chatbot_icon.png', 
          fit: BoxFit.fill, 
        ),
      ),
    );
  }
}