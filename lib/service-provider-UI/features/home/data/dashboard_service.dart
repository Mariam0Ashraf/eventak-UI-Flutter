import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eventak/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardService {
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

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/auth/user'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded != null && decoded['data'] != null && decoded['data']['user'] != null) {
          return Map<String, dynamic>.from(decoded['data']['user']);
        }
      }
      return {};
    } catch (e) {
      debugPrint('🔴 Profile Error: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getMyServices() async {
  try {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/my-services'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      
      if (decoded != null && decoded['data'] != null) {
        final List services = decoded['data'];
        return List<Map<String, dynamic>>.from(services);
      }
    }
    return []; 
  } catch (e) {
    debugPrint('🔴 Services Error: $e');
    return [];
  }
}

 Future<List<Map<String, dynamic>>> getPackages() async {
  try {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/packages'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);

      if (decoded != null && decoded['data'] != null) {
        final List packages = decoded['data'];
        return List<Map<String, dynamic>>.from(packages);
      }
    }
    return [];
  } catch (e) {
    debugPrint('🔴 Packages Error: $e');
    return [];
  }
}
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