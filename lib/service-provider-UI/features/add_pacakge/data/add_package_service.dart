import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eventak/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPackageService {
  Future<int> createPackage(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/packages'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.body);
    }

    final decoded = jsonDecode(response.body);
    debugPrint('🟢 createPackage response: $decoded');
    return decoded['data']['id'];
  }

  // ✅ NEW – does NOT affect existing logic
  Future<void> addPackageItem({
    required int packageId,
    required String itemDescription,
    required int serviceId,
    required int quantity,
    required double priceAdjustment,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/packages/$packageId/items'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "service_id": serviceId,
        "description": itemDescription,
        "quantity": quantity,
        "price_adjustment": priceAdjustment,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.body);
    }
  }
}
