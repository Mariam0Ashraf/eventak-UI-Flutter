import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eventak/core/constants/api_constants.dart';

class AuthService {
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String role = "User",
    String? serviceName,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/register');

    final bodyData = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'role': role,
      if (serviceName != null) 'service_name': serviceName,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(bodyData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }
}
