import 'dart:convert';
import 'package:eventak/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class ResetPasswordService {
  final String _url = '${ApiConstants.baseUrl}/auth/reset-password';

  Future<String> resetPassword({
    required String email,
    required String password,
    required String confirmPassword,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp, 
          'password': password,
          'password_confirmation': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['message'] ?? 'Password reset successfully';
      } else if (response.statusCode == 422) {
        if (data['errors'] != null) {
          var firstError = (data['errors'] as Map).values.first;
          throw Exception(firstError is List ? firstError[0] : firstError);
        }
        throw Exception(data['message']);
      } else {
        throw Exception(data['message'] ?? 'Something went wrong.');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}