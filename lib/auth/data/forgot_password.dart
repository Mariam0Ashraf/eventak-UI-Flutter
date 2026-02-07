import 'dart:convert';
import 'package:eventak/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ForgotPasswordService {
  final String _url = '${ApiConstants.baseUrl}/auth/forgot-password';

  Future<String> sendResetLink(String email) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['message'] ?? 'OTP sent to your email';
      } else if (response.statusCode == 422) {
        if (data['errors'] != null && data['errors']['email'] != null) {
          throw Exception(data['errors']['email'][0]);
        }
        throw Exception(data['message']);
      } else {
        throw Exception(data['message'] ?? 'An unexpected error occurred.');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}