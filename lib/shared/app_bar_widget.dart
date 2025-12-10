// lib/shared/app_bar_widget.dart

import 'package:eventak/core/constants/app-colors.dart';
import 'package:flutter/material.dart';

class CustomHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomHomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.menu_rounded, color: AppColor.blueFont),
        onPressed: () => debugPrint('menu tapped'),
      ),
      title: Image.network(
       
        'assets/App_photos/eventak_logo.png', 
        height: 40,
        fit: BoxFit.contain,
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
        ),
      ],
    );
  }

 
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}