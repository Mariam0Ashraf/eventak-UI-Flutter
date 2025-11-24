import 'package:eventak/core/constants/app-colors.dart';
import 'package:flutter/material.dart';
//never used and need to be edited

class Appbarwidget extends StatelessWidget implements PreferredSizeWidget {
  final Widget?
  leading; // Accepts an optional custom leading widget (like menu or back button)
  final VoidCallback? onProfileTap; // Optional callback for profile tap

  //initialize the final fields
  const Appbarwidget({super.key, this.leading, this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,

      leading: leading,

      title: Image.asset(
        'assets/App_photos/eventak_logo.png',
        height: 40,
        fit: BoxFit.contain,
      ),
      centerTitle: true,

      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: GestureDetector(
            onTap: onProfileTap,
            child: const CircleAvatar(
              radius: 16,

              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
