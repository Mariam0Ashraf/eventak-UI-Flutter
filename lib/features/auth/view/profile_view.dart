
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/features/auth/widgets/showEditDialogwidget.dart';
import 'package:eventak/shared/userField.dart';
import 'package:flutter/material.dart';

class dummyUser {
  String name;
  String email;
  String password; 

  dummyUser({
    this.name = 'Mariam Ashraf',
    this.email = 'Mariam00ashraf@gmail.com',
    this.password = 'password123',
  });
}

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final user = dummyUser(); 

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColor.primary; 
    final darkFont = AppColor.blueFont; 

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColor,
                    width: 5.0,
                  ),
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
                user.name,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: darkFont,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 40),

              UserField(
                label: 'NAME',
                value: user.name,
                icon: Icons.edit_outlined,
                onTap: () async {
                  final newName = await ShowEditDialogWidget(context, 'Edit Name', user.name);
                  if (newName != null && newName.isNotEmpty) {
                    setState(() => user.name = newName);
                  }
                },
                fieldColor: Colors.white,
                iconBackgroundColor: primaryColor,
              ),
              const SizedBox(height: 16),

              UserField(
                label: 'PASSWORD',
                value: '********',
                icon: Icons.edit_outlined,
                onTap: () async {
                  final newPassword = await ShowEditDialogWidget(context, 'Change Password', '');
                  if (newPassword != null && newPassword.isNotEmpty) {
                    setState(() => user.password = newPassword);
                  }
                },
                fieldColor: Colors.white,
                iconBackgroundColor: primaryColor,
              ),
              const SizedBox(height: 16),
             
              UserField(
                label: 'EMAIL',
                value: user.email,
                icon: Icons.edit_outlined,
                onTap: () async {
                  final newEmail = await ShowEditDialogWidget(context, 'Update Email', user.email);
                  if (newEmail != null && newEmail.isNotEmpty) {
                    setState(() => user.email = newEmail);
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
                  onPressed: () {
                    print('Saved Name: ${user.name}');
                    print('Saved Email: ${user.email}');
                    print('Saved Password: ${user.password}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'SAVE ALL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}