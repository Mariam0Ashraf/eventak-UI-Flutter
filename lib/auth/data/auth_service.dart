import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:eventak/auth/data/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:eventak/core/constants/api_constants.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    String role = "customer",
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/register');

    final bodyData = {
      'name': '$firstName $lastName',
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': password,
      'role': role,
    };

    try {
      final response = await http
          .post(url, headers: _headers, body: jsonEncode(bodyData))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
        return {'data': decoded};
      } else {
        dynamic decoded;
        try {
          decoded = jsonDecode(response.body);
        } catch (_) {
          decoded = null;
        }
        final message =
            _extractErrorMessage(decoded) ??
            'Failed to register. Please try again.';
        throw Exception(message);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } on FormatException {
      throw Exception('Invalid server response. Please try again later.');
    }
  }

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/login');
    final bodyData = {'identifier': identifier, 'password': password};

    try {
      final response = await http
          .post(url, headers: _headers, body: jsonEncode(bodyData))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
        return {'data': decoded};
      } else {
        dynamic decoded;
        try {
          decoded = jsonDecode(response.body);
        } catch (_) {
          decoded = null;
        }
        final message =
            _extractErrorMessage(decoded) ??
            'Failed to login. Please check your credentials.';
        throw Exception(message);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } on FormatException {
      throw Exception('Invalid server response. Please try again later.');
    }
  }

  Future<String?> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final oldToken = prefs.getString('auth_token');

    if (oldToken == null || oldToken.isEmpty) {
      return null;
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/auth/refresh');

    try {
      final response = await http
          .post(
            url,
            headers: {..._headers, 'Authorization': 'Bearer $oldToken'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          final success = decoded['success'] == true;
          final data = decoded['data'];

          if (success == true &&
              data is Map<String, dynamic> &&
              data['access_token'] != null) {
            final String newToken = data['access_token'].toString();

            await prefs.setString('auth_token', newToken);

            return newToken;
          }
        }

        return null;
      } else {
        await prefs.remove('auth_token');
        return null;
      }
    } on TimeoutException {
      throw Exception(
        'Token refresh timed out. Please check your internet connection.',
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> logout({String? token}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/logout');

    final Map<String, String> requestHeaders = Map.from(_headers);

    if (token == null) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('auth_token');
    }

    if (token != null && token.isNotEmpty) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http
          .post(url, headers: requestHeaders)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        dynamic decoded;
        try {
          decoded = jsonDecode(response.body);
        } catch (_) {
          decoded = null;
        }
        final message =
            _extractErrorMessage(decoded) ?? 'Logout failed on server.';
        throw Exception(message);
      }
    } on TimeoutException {
      throw Exception('Request timed out.');
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? phone,
    File? avatar,
    Uint8List? webImageBytes,
    String? currentPassword,
    String? password,
    String? confirmPassword,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/user');
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    // Use MultipartRequest for file uploads
    var request = http.MultipartRequest('POST', url);

    // Add Headers
    request.headers.addAll({
      ..._headers,
      if (token != null) 'Authorization': 'Bearer $token',
    });

    // Laravel/PHP often requires _method PUT when sending form-data via POST
    request.fields['_method'] = 'PUT';

    // Add Text Fields
    if (name != null) request.fields['name'] = name;
    if (email != null) request.fields['email'] = email;
    if (phone != null) request.fields['phone'] = phone;
    if (currentPassword != null && currentPassword.isNotEmpty) {
      request.fields['current_password'] = currentPassword;
      request.fields['password'] = password!;
      request.fields['confirm_password'] = confirmPassword!;
    }

    // Add Avatar File
    if (kIsWeb && webImageBytes != null) {
      // Use bytes for Web to avoid Unsupported operation error
      request.files.add(
        http.MultipartFile.fromBytes(
          'avatar',
          webImageBytes,
          filename: 'avatar.jpg',
        ),
      );
    } else if (!kIsWeb && avatar != null) {
      // Use path for Mobile
      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          avatar.path,
          filename: p.basename(avatar.path),
        ),
      );
    }

    try {
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return decoded;
      } else {
        // Specifically handle wrong password or validation errors
        final message = decoded['message'] ?? 'Update failed';
        throw Exception(message);
      }
    } on TimeoutException {
      throw Exception('Request timed out. Check your connection.');
    } catch (e) {
      rethrow;
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['message'] is String) return data['message'] as String;
      if (data['error'] is String) return data['error'] as String;

      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        if (errors.isNotEmpty) {
          final firstKey = errors.keys.first;
          final firstVal = errors[firstKey];
          if (firstVal is List && firstVal.isNotEmpty) {
            return firstVal.first.toString();
          } else if (firstVal is String) {
            return firstVal;
          }
        }
      }
    }
    return null;
  }

  Future<UserModel> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }

    final response = await http
        .get(
          Uri.parse('${ApiConstants.baseUrl}/auth/user'),
          headers: {..._headers, 'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded['success'] == true && decoded['data'] != null) {
        final user = UserModel.fromJson(decoded['data']);

        await prefs.setInt('user_id', user.id);
        await prefs.setString('user_name', user.name);
        await prefs.setString('user_email', user.email);
        await prefs.setString('user_phone', user.phone ?? '');
        await prefs.setInt('loyalty_points', user.loyaltyPoints);

        if (decoded['data']['avatar'] != null) {
          await prefs.setString('user_avatar', decoded['data']['avatar']);
        }

        return user;
      }
    }

    throw Exception('Failed to fetch user profile');
  }
  Future<String> sendForgotPasswordOtp(String email) async {
    final res = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/forgot-password'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return data['message'] ?? 'OTP sent';
    throw Exception(data['message'] ?? 'Failed to send OTP');
  }

  Future<String> verifyOtp(String email, String otp) async {
    final res = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/verify-otp'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return data['message'] ?? 'OTP Verified';
    throw Exception(data['message'] ?? 'Invalid OTP');
  }

  Future<String> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/reset-password'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': confirmPassword,
      }),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return data['message'] ?? 'Password reset success';
    throw Exception(data['message'] ?? 'Failed to reset password');
  }
}
