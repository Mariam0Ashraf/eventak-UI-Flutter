import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eventak/core/constants/api_constants.dart';

class ServiceDetailsService {
  Future<Map<String, dynamic>> getService(int id) async {
    final String url = '${ApiConstants.baseUrl}/services/$id';
    
    debugPrint('Fetching Service Details from: $url');

    try {
      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('Status Code: ${res.statusCode}');
      
      if (res.statusCode == 200) {
        return json.decode(res.body);
      } else {
        debugPrint('Error Response: ${res.body}');
        throw Exception('Failed to load service: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Network Error in ServiceDetailsService: $e');
      rethrow; 
    }
  }
}