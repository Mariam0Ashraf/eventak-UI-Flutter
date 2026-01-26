import 'dart:io';
import 'dart:typed_data';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/auth/data/user_model.dart';
import 'package:eventak/auth/data/auth_service.dart';
import 'package:eventak/auth/widgets/custom_dialog.dart';
import 'package:eventak/auth/widgets/showEditDialogwidget.dart';
import 'package:eventak/shared/UserField.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  UserModel? user;
  int _selectedBottomIndex = 4; 
  bool _isLoading = false;

  File? _imageFile;
  Uint8List? _webImage;
  String? _savedAvatarUrl;
  String? _currentPassword, _newPassword, _confirmPassword;

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
        name: prefs.getString('user_name') ?? 'No Name',
        email: prefs.getString('user_email') ?? 'email@.com',
      );
      _savedAvatarUrl = prefs.getString('user_avatar');
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _webImage = bytes;
          _imageFile = File(image.path);
        });
      } else {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    }
  }

  Widget _buildAvatarImage() {
    if (kIsWeb && _webImage != null) return Image.memory(_webImage!, fit: BoxFit.cover);
    if (!kIsWeb && _imageFile != null) return Image.file(_imageFile!, fit: BoxFit.cover);

    if (_savedAvatarUrl != null && _savedAvatarUrl!.isNotEmpty) {
      return Image.network(
        _savedAvatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.person, size: 80, color: AppColor.blueFont.withOpacity(0.5));
        },
      );
    }

    return Icon(Icons.person, size: 80, color: AppColor.blueFont.withOpacity(0.5));
  }

  void _showPasswordDialog() {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Change Password',
            style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password'),
            ),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
            onPressed: () {
              setState(() {
                _currentPassword = currentController.text;
                _newPassword = newController.text;
                _confirmPassword = confirmController.text;
              });
              Navigator.pop(ctx);
            },
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (user == null) return;
    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final response = await authService.updateProfile(
        name: user!.name,
        email: user!.email,
        avatar: _imageFile,
        webImageBytes: _webImage,
        currentPassword: _currentPassword,
        password: _newPassword,
        confirmPassword: _confirmPassword,
      );

      _currentPassword = null;
      _newPassword = null;
      _confirmPassword = null;

      if (response['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        
        await prefs.setString('user_name', user!.name);
        await prefs.setString('user_email', user!.email);
        
        if (response['data'] != null && response['data']['avatar'] != null) {
          String newAvatarUrl = response['data']['avatar'];
          await prefs.setString('user_avatar', newAvatarUrl);
          
          setState(() {
            _savedAvatarUrl = newAvatarUrl;
            _imageFile = null;
            _webImage = null;
          });
        }
        
        if (mounted) showCustomDialog(context, 'Profile updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString().replaceAll("Exception:", "");
        if (errorMsg.contains('password')) {
          showCustomDialog(context, 'Current password is incorrect.');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $errorMsg'), backgroundColor: Colors.red),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColor.primary;
    final darkFont = AppColor.blueFont;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64), child: _buildAppBar()),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 150, height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor, width: 5.0),
                        ),
                        child: ClipOval(child: _buildAvatarImage()),
                      ),
                      Positioned(
                        bottom: 5, right: 5,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            backgroundColor: primaryColor,
                            radius: 18,
                            child: const Icon(Icons.edit, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(user!.name,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: darkFont)),
                  const SizedBox(height: 40),

                  UserField(
                    label: 'NAME',
                    value: user!.name,
                    icon: Icons.edit_outlined,
                    onTap: () async {
                      final newName = await ShowEditDialogWidget(context, 'Edit Name', user!.name);
                      if (newName != null) setState(() => user!.name = newName);
                    },
                    fieldColor: Colors.white,
                    iconBackgroundColor: primaryColor,
                  ),
                  const SizedBox(height: 16),

                  UserField(
                    label: 'PASSWORD',
                    value: '********',
                    icon: Icons.edit_outlined,
                    onTap: _showPasswordDialog,
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
                      if (newEmail != null) setState(() => user!.email = newEmail);
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('SAVE ALL',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
      /*bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _selectedBottomIndex,
        onItemSelected: (idx) {
          setState(() {
            _selectedBottomIndex = idx;
          });
         
        },
      ),*/
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Image.asset('assets/App_photos/eventak_logo.png', height: 40),
      centerTitle: true,
    );
  }
}