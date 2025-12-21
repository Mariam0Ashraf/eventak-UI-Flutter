import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eventak/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardService {
  /// Get auth headers from SharedPreferences
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// GET /auth/user
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/auth/user'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to load user profile');
    }

    final decoded = jsonDecode(response.body);
    // Backend structure: data.user
    return Map<String, dynamic>.from(decoded['data']['user']);
  }

  /// GET /my-services
  /// GET /my-services
  Future<List<Map<String, dynamic>>> getMyServices() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/my-services'),
      headers: await _getHeaders(),
    );
    //logging
      debugPrint('🟡 /my-services status: ${response.statusCode}');
      debugPrint('🟡 /my-services raw body: ${response.body}');


    if (response.statusCode != 200) {
      throw Exception('Failed to load services');
    }

    final decoded = jsonDecode(response.body);
    debugPrint('🟢 Decoded JSON: $decoded'); // logging

    // Backend structure: data.data[]
    final List services = decoded['data']['data'];
     debugPrint('🟢 Extracted services list: $services'); //logging
    return List<Map<String, dynamic>>.from(services);
  }

  /// GET /packages
  Future<List<Map<String, dynamic>>> getPackages() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/packages'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load packages');
    }

    final decoded = jsonDecode(response.body);

    // Backend structure: data.data[]
    final List packages = decoded['data']['data'];

    return List<Map<String, dynamic>>.from(packages);
  }

  /// DELETE /packages/{id}
  Future<void> deletePackage(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/packages/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete package');
    }
  }
}
