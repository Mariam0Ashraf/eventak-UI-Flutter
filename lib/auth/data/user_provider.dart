import 'package:flutter/material.dart';
import 'package:eventak/auth/data/user_model.dart';
import 'package:eventak/auth/data/auth_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  final AuthService _authService = AuthService();
  UserModel? get user => _user;
  void setUser(UserModel newUser) {
    _user = newUser;
    notifyListeners(); 
  }
  void clearUser() {
    _user = null;
    notifyListeners();
  }
  Future<void> refreshUser() async {
    try {
      _user = await _authService.getUserInfo();
      notifyListeners();
    } catch (e) {
      debugPrint("User refresh failed: $e");
    }
  }
}