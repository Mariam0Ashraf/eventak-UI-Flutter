import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:eventak/core/constants/api_constants.dart';

class ChatbotApiService {
  static const String _baseUrl = "${ApiConstants.baseUrl}/ai";

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token')?.replaceAll('"', '');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> sendMessage(String text, String? sessionId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat'),
      headers: await _getHeaders(),
      body: json.encode({
        'message': text,
        if (sessionId != null) 'session_id': sessionId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body)['data'];
    }
    throw Exception('Failed to send message: ${response.body}');
  }

  Future<Map<String, dynamic>> getMessages(String sessionId, {int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/sessions/$sessionId/messages?page=$page'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body)['data']; 
    }
    throw Exception('Failed to load messages: ${response.body}');
  }


Future<bool> deleteSession(String sessionId) async {
  try {
    final response = await http.delete(
      Uri.parse('$_baseUrl/sessions/$sessionId'),
      headers: await _getHeaders(), 
    );
    
    return response.statusCode == 200 || response.statusCode == 204;
  } catch (e) {
    debugPrint("API Delete Error: $e");
    return false;
  }
}
Future<Map<String, dynamic>> getAllSessions({int page = 1}) async {
  final response = await http.get(
    Uri.parse('$_baseUrl/sessions?page=$page'),
    headers: await _getHeaders(),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body)['data'];
  }
  throw Exception('Failed to load sessions');
}
}