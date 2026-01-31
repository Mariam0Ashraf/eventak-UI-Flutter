import 'package:eventak/auth/data/auth_service.dart';
import 'package:eventak/auth/view/login_view.dart';
import 'package:eventak/auth/view/profile_view.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/booking/bookings/view/bookings_list_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class CustomHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomHomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  Future<void> _handleLogout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final AuthService authService = AuthService();
      final prefs = await SharedPreferences.getInstance();
      
    
      final String? token = prefs.getString('auth_token'); 

      if (token != null) {
        await authService.logout(token: token).timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            debugPrint("Logout server request timed out. Proceeding to local logout.");
          },
        );
      } else {
        debugPrint("No token found locally. Skipping server logout.");
      }

      await prefs.remove('auth_token');

    } catch (e) {
      debugPrint("Logout warning: $e");
    } finally {
      if (!context.mounted) return;

        // removes ALL previous screens (including MainPage and the Nav Bar)
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false, // This condition 'false' ensures no previous routes remain
        );
    }
  }

  Future<String?> _getUserAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_avatar');
  }


  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.menu_rounded, color: AppColor.blueFont),
        onPressed: () {
          /*Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const BookingsListView(),
            ),
          );*/
        },),
      title: Image.asset(
        'assets/App_photos/eventak_logo.png',
        height: 40,
        fit: BoxFit.contain,
        errorBuilder: (c, o, s) => Text(
          "Eventak", 
          style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold)
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: PopupMenuButton<String>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            icon: FutureBuilder<String?>(
              future: _getUserAvatar(),
              builder: (context, snapshot) {
                final avatarUrl = snapshot.data;

                return CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade300,
                  child: ClipOval(
                    child: Image.network(
                      avatarUrl!,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const Icon(Icons.person, color: Colors.white);
                      },
                    ),
                  ),
                );

              },
            ),

            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserProfilePage()),
                );
              } else if (value == 'logout') {
                _handleLogout(context); 
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: Colors.black54, size: 20),
                    SizedBox(width: 10),
                    Text('View Profile'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.redAccent, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}