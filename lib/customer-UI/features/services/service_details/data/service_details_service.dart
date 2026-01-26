import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eventak/core/constants/api_constants.dart';


class ServiceDetailsService {

  Future<Map<String, dynamic>> getService(int id) async {
    debugPrint(' GET ${ApiConstants.baseUrl}');

    final res = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/services/$id'),
    );
     debugPrint('Status Code: ${res.statusCode}');
    debugPrint('Response Body: ${res.body}');

     if (res.statusCode != 200) {
      throw Exception('Failed to load service');
    }

    return json.decode(res.body);
  }
}