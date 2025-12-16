// lib/features/home/data/home_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;
import 'package:eventak/core/constants/api_constants.dart';


class HomeService {
  Future<List<Map<String, dynamic>>> getServiceCategories() async {
    final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/service-categories'));

    if (response.statusCode == 200) {
      // 1. Decode the entire response body (which is a Map/JSON object)
      final Map<String, dynamic> responseMap = json.decode(response.body); 

      // 2. Check if the 'data' key exists and is a List
      if (responseMap.containsKey('data') && responseMap['data'] is List) {
        // 3. Extract the List from the 'data' field
        final List<dynamic> jsonList = responseMap['data']; 
        
        // Optional Log
        debugPrint('Parsing Success: Extracted ${jsonList.length} service categories.');

        return jsonList.cast<Map<String, dynamic>>();
      } else {
        // Handle case where 'data' key is missing or not a list
        throw Exception('API response missing "data" list or format is incorrect.');
      }
    } else {
      throw Exception(
        'Failed to load service categories. Status Code: ${response.statusCode}',
      );
    }
  }
    

  //get pacakges
  Future<List<Map<String, dynamic>>> getPackages() async {
    final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/packages'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.cast<Map<String, dynamic>>();
    } else {
      throw Exception(
        'Failed to load packages. Status Code: ${response.statusCode}',
      );
    }
  }
}
