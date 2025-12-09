import 'dart:convert';
import 'package:http/http.dart' as http;

class ResetPassword {
  
  final String _baseUrl = 'http://127.0.0.1:8000/api/auth/reset-password';

  Future<String> resetPassword({
    required String email,
    required String password,
    required String confirmPassword,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'token': token,
          'password': password,
          'password_confirmation': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['message'] ?? 'Password reset successfully';
      }
      else if (response.statusCode == 422) {
        String errorMessage = data['message'];

        if (data['errors'] != null) {
          if (data['errors']['email'] != null) {
            errorMessage = data['errors']['email'][0];
          } else if (data['errors']['token'] != null) {
            errorMessage = data['errors']['token'][0];
          } else if (data['errors']['password'] != null) {
            errorMessage = data['errors']['password'][0];
          }
        }
        
        throw Exception(errorMessage);
      }
      else {
        throw Exception(data['message'] ?? 'Something went wrong.');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}