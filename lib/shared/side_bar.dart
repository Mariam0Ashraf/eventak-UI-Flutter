import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/auth/data/auth_service.dart';
import 'package:eventak/auth/view/login_view.dart';
import 'package:eventak/auth/view/profile_view.dart';
import 'package:url_launcher/url_launcher.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final authService = AuthService();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token')?.replaceAll('"', '');

      if (token != null) {
        await authService.logout(token: token).timeout(
          const Duration(seconds: 3),
          onTimeout: () => debugPrint("Logout timeout — local only"),
        );
      }
      await prefs.remove('auth_token');
    } catch (e) {
      debugPrint("Logout error: $e");
    } finally {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  Future<Map<String, String?>> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name'),
      'email': prefs.getString('user_email'),
      'avatar': prefs.getString('user_avatar'),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85, 
      child: Drawer(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildHeaderModern(),
            const SizedBox(height: 10),
            _buildMenuItem(
              icon: Icons.home_rounded,
              label: "Home",
              onTap: () => Navigator.pop(context),
            ),
            _buildMenuItem(
              icon: Icons.person_rounded,
              label: "My Profile",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserProfilePage()),
                );
              },
            ),
  
            _buildMenuItem(
              icon: Icons.info_outline_rounded,
              label: "Send Feedback",
              onTap: () {
                Navigator.pop(context); 
                _launchURL("https://eventak.elshamel.online/contact-us");
              },
            ),
            _buildMenuItem(
              icon: Icons.privacy_tip_outlined,
              label: "Privacy and Policy",
              onTap: () {
                Navigator.pop(context);
                _launchURL("https://eventak.elshamel.online/privacy-policy");
              },
            ),
            _buildMenuItem(
              icon: Icons.description_outlined, 
              label: "Term of Service",
              onTap: () {
                Navigator.pop(context);
                _launchURL("https://eventak.elshamel.online/terms-of-service");
              },
            ),
            _buildMenuItem(
              icon: Icons.info_outline_rounded,
              label: "About Us",
              onTap: () {
                Navigator.pop(context);
                _launchURL("https://eventak.elshamel.online/about-us");
              },
            ),
            const Spacer(),
            const Divider(indent: 20, endIndent: 20),
            _buildMenuItem(
              icon: Icons.logout_rounded,
              label: "Logout",
              color: Colors.redAccent,
              onTap: () {
                Navigator.pop(context);
                _handleLogout(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
    Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }


  Widget _buildHeaderModern() {
    return FutureBuilder<Map<String, String?>>(
      future: _getUserData(),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColor.primary, AppColor.secondaryBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(bottomRight: Radius.circular(20)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                backgroundImage: data['avatar'] != null ? NetworkImage(data['avatar']!) : null,
                child: data['avatar'] == null ? Icon(Icons.person, size: 30, color: AppColor.primary) : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'] ?? "User",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      data['email'] ?? "",
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColor.blueFont),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? AppColor.blueFont,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}