import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eventak/core/constants/api_constants.dart';
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
    String role = "customer", 
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/register');

    final bodyData = {
      'name': '$firstName $lastName',
      'email': email,
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
        final message = _extractErrorMessage(decoded) ??
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

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/login');
    final bodyData = {'email': email, 'password': password};

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
        final message = _extractErrorMessage(decoded) ??
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
            headers: {
              ..._headers,
              'Authorization': 'Bearer $oldToken',
            },
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
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/user');
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    final headers = {
      ..._headers,
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };

    final Map<String, dynamic> bodyData = {};
    if (name != null) bodyData['name'] = name;
    if (email != null) bodyData['email'] = email;

    if (bodyData.isEmpty) {
      throw Exception('No changes detected to save.');
    }

    try {
      final response = await http
          .put(url, headers: headers, body: jsonEncode(bodyData))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded;
      } else {
        dynamic decoded;
        try {
          decoded = jsonDecode(response.body);
        } catch (_) {}
        throw Exception(decoded?['message'] ?? 'Failed to update profile');
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
}
