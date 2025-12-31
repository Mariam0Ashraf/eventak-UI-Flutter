import 'dart:convert';
import 'package:eventak/service-provider-UI/features/show_package/data/package_details_model.dart';
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
      'Authorization': 'Bearer ${token.replaceAll('"', '')}',
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



  Future<List<Map<String, dynamic>>> getMyServices({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/my-services?page=$page'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded != null && decoded['data'] != null) {
          return List<Map<String, dynamic>>.from(decoded['data']);
        }
      }
      return [];
    } catch (e) {
      debugPrint('🔴 Services Error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPackages({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/my-packages?page=$page'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded != null && decoded['data'] != null) {
          return List<Map<String, dynamic>>.from(decoded['data']);
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
    final errorData = jsonDecode(response.body);
    throw Exception(errorData['message'] ?? 'Failed to delete package');
  }
}
 
 Future<PackageDetails> getPackageDetails(int id) async {
  final response = await http.get(
    Uri.parse('${ApiConstants.baseUrl}/packages/$id'),
    headers: await _getHeaders(),
  );
  if (response.statusCode == 200) {
    return PackageDetails.fromJson(jsonDecode(response.body)['data']);
  }
  throw Exception('Failed to load details');
}

Future<void> updatePackage(int id, Map<String, dynamic> data) async {
  await http.put(
    Uri.parse('${ApiConstants.baseUrl}/packages/$id'),
    headers: await _getHeaders(),
    body: jsonEncode(data),
  );
}
 
}