import 'dart:convert';
import 'package:http/http.dart' as http;

class ForgotPassword {
  final String _baseUrl = 'http://127.0.0.1:8000/api/auth/forgot-password';

  Future<String> sendResetLink(String email) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['message'] ?? 'Password reset link sent to your email';
      } 
      
      else if (response.statusCode == 422) {
        String errorMessage = data['message'];
        
        if (data['errors'] != null && data['errors']['email'] != null) {
           errorMessage = data['errors']['email'][0];
        }
        
        throw Exception(errorMessage);
      } 
      
      else {
        throw Exception(data['message'] ?? 'An unexpected error occurred.');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}