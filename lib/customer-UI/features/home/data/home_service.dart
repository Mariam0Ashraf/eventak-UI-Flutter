// lib/features/home/data/home_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eventak/core/constants/api_constants.dart';

class HomeService {
  Future<List<Map<String, dynamic>>> getServiceCategories() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/service-categories'),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseMap = json.decode(response.body);

      if (responseMap.containsKey('data') && responseMap['data'] is List) {
        final List<dynamic> jsonList = responseMap['data'];

        debugPrint(
          'Parsing Success: Extracted ${jsonList.length} service categories.',
        );

        return jsonList.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception(
          'API response missing "data" list or format is incorrect.',
        );
      }
    } else {
      throw Exception(
        'Failed to load service categories. Status Code: ${response.statusCode}',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getServiceTypes() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/service-types'),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseMap = json.decode(response.body);

      if (responseMap.containsKey('data') && responseMap['data'] is List) {
        final List<dynamic> jsonList = responseMap['data'];

        debugPrint(
          'Parsing Success: Extracted ${jsonList.length} service types.',
        );

        return jsonList.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception(
          'API response missing "data" list or format is incorrect.',
        );
      }
    } else {
      throw Exception(
        'Failed to load service types. Status Code: ${response.statusCode}',
      );
    }
  }

  // get packages
  Future<List<Map<String, dynamic>>> getPackages() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/packages'),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      // ⚠️ خلي بالك: بعض الـ APIs بترجع { data: [...] } زي categories
      final decoded = json.decode(response.body);

      if (decoded is List) {
        return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      if (decoded is Map<String, dynamic> &&
          decoded['data'] != null &&
          decoded['data'] is List) {
        final List<dynamic> list = decoded['data'];
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      throw Exception('Unexpected packages response format.');
    } else {
      throw Exception(
        'Failed to load packages. Status Code: ${response.statusCode}',
      );
    }
  }
}
