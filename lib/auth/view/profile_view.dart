import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/core/constants/custom_nav_bar.dart';
import 'package:eventak/auth/data/user_model.dart';
import 'package:eventak/auth/data/auth_service.dart'; 
import 'package:eventak/auth/widgets/custom_dialog.dart';
import 'package:eventak/auth/widgets/showEditDialogwidget.dart';
import 'package:eventak/shared/UserField.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  UserModel? user;
  int _selectedBottomIndex = 4;
  bool _isLoading = false; 

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      user = UserModel(
        id: prefs.getInt('user_id') ?? 0,
        name: prefs.getString('user_name') ?? 'NO Name',
        email: prefs.getString('user_email') ?? 'email@.com',
      );
    });
  }

  bool _validateInputs() {
    if (user == null) return false;

    if (user!.name.trim().isEmpty) {
      showCustomDialog(context, 'Name cannot be empty.');
      return false;
    }

    if (user!.email.trim().isEmpty) {
      showCustomDialog(context, 'Email cannot be empty.');
      return false;
    }

    final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(user!.email.trim())) {
      showCustomDialog(context, 'Please enter a valid email address.');
      return false;
    }

    return true;
  }

  Future<void> _saveChanges() async {
    if (user == null) return;

    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final oldName = prefs.getString('user_name');
      final oldEmail = prefs.getString('user_email');

      String? nameToSend;
      String? emailToSend;

      if (user!.name != oldName) {
        nameToSend = user!.name;
      }
      if (user!.email != oldEmail) {
        emailToSend = user!.email;
      }

      if (nameToSend == null && emailToSend == null) {
        showCustomDialog(context, 'No changes detected.');
        setState(() => _isLoading = false);
        return;
      }

      final authService = AuthService();
      await authService.updateProfile(name: nameToSend, email: emailToSend);

      if (nameToSend != null) await prefs.setString('user_name', nameToSend);
      if (emailToSend != null) await prefs.setString('user_email', emailToSend);

      if (mounted) {
        showCustomDialog(context, 'Profile updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll("Exception:", "")}'), 
            backgroundColor: Colors.red
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onNavBarTap(int index) {
    setState(() => _selectedBottomIndex = index);
    if (index == 0) {
      Navigator.pop(context);
    } 
  }

  Widget _buildAppBar() {
    final darkFont = AppColor.blueFont;
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.menu_rounded, color: darkFont),
        onPressed: () => debugPrint('menu tapped'),
      ),
      title: Image.asset(
        'assets/App_photos/eventak_logo.png',
        height: 40,
        fit: BoxFit.contain,
        errorBuilder: (c, o, s) => Text("Eventak", style: TextStyle(color: darkFont)),
      ),
      centerTitle: true,
      actions: const [Padding(padding: EdgeInsets.only(right: 12.0))],
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    final primaryColor = AppColor.primary;
    final darkFont = AppColor.blueFont;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 5.0),
              ),
              child: ClipOval(
                child: Image.asset(
                  "assets/user/mariam.jpg",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.person, size: 80, color: darkFont.withOpacity(0.5));
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              user!.name,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkFont, letterSpacing: 1.2),
            ),
            const SizedBox(height: 40),

            UserField(
              label: 'NAME',
              value: user!.name,
              icon: Icons.edit_outlined,
              onTap: () async {
                final newName = await ShowEditDialogWidget(context, 'Edit Name', user!.name);
                if (newName != null) {
                  setState(() => user!.name = newName);
                }
              },
              fieldColor: Colors.white,
              iconBackgroundColor: primaryColor,
            ),
            const SizedBox(height: 16),

            UserField(
              label: 'PASSWORD',
              value: '****',
              icon: Icons.edit_outlined,
              onTap: () async {
                final newPassword = await ShowEditDialogWidget(context, 'Change Password', '');
                if (newPassword != null && newPassword.isNotEmpty) {
                   setState(() => user!.password = newPassword);
                }
              },
              fieldColor: Colors.white,
              iconBackgroundColor: primaryColor,
            ),
            const SizedBox(height: 16),

            UserField(
              label: 'EMAIL',
              value: user!.email,
              icon: Icons.edit_outlined,
              onTap: () async {
                final newEmail = await ShowEditDialogWidget(context, 'Update Email', user!.email);
                if (newEmail != null) {
                  setState(() => user!.email = newEmail);
                }
              },
              fieldColor: Colors.white,
              iconBackgroundColor: primaryColor,
            ),
            const SizedBox(height: 60),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'SAVE ALL',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(preferredSize: const Size.fromHeight(64), child: _buildAppBar()),
      body: _buildProfileContent(context),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedBottomIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}