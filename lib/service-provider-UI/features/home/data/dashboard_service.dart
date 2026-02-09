import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eventak/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/service-provider-UI/features/show_package/data/package_details_model.dart';

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

  Future<List<Map<String, dynamic>>> fetchListData(String endpoint, int page) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/$endpoint?page=$page'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        
        if (decoded['data'] != null) {
          return List<Map<String, dynamic>>.from(decoded['data']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/auth/user'),
        headers: await _getHeaders(),
      );

      debugPrint("DEBUG: Profile Status Code: ${response.statusCode}");
      debugPrint("DEBUG: Profile Response Body: ${response.body}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        
        if (decoded != null && decoded['data'] != null) {
          return Map<String, dynamic>.from(decoded['data']);
        }
      }
      return {};
    } catch (e) {
      debugPrint("DEBUG: Error in getUserProfile: $e");
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
          List<Map<String, dynamic>> packages = List<Map<String, dynamic>>.from(decoded['data']);
          
          for (var p in packages) {
            p['price'] = p['base_price'] ?? p['price'] ?? 0;
            
            if (p['categories'] != null && p['categories'] is List) {
              p['display_categories'] = (p['categories'] as List)
                  .map((cat) => cat['name'].toString())
                  .join(', ');
            } else {
              p['display_categories'] = '';
            }
          }
          return packages;
        }
      }
      return [];
    } catch (e) {
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

  Future<void> addPackageItem(int packageId, int serviceId, int quantity) async {
    await http.post(
      Uri.parse('${ApiConstants.baseUrl}/packages/$packageId/items'),
      headers: await _getHeaders(),
      body: jsonEncode({"service_id": serviceId, "quantity": quantity}),
    );
  }

  Future<void> updatePackageItem(int packageId, int itemId, int quantity) async {
    await http.put(
      Uri.parse('${ApiConstants.baseUrl}/packages/$packageId/items/$itemId'),
      headers: await _getHeaders(),
      body: jsonEncode({"quantity": quantity}),
    );
  }

  Future<void> deletePackageItem(int packageId, int itemId) async {
    await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/packages/$packageId/items/$itemId'),
      headers: await _getHeaders(),
    );
  }
}