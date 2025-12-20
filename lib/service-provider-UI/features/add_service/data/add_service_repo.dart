import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:eventak/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class AddServiceRepo {
  final Dio _dio = Dio();

  Future<List<Map<String, dynamic>>> getServiceCategories() async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/service-categories');

      if (response.statusCode == 200) {
        final rawData = response.data;
        if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
          return List<Map<String, dynamic>>.from(rawData['data']);
        }
        if (rawData is List) {
          return List<Map<String, dynamic>>.from(rawData);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      throw Exception('Failed to load categories');
    }
  }

  Future<bool> createService(Map<String, dynamic> serviceData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }
      
      final cleanToken = token.replaceAll('"', '');

      final response = await _dio.post(
        '${ApiConstants.baseUrl}/services',
        data: serviceData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $cleanToken', 
          },
        ),
      );

      return response.statusCode == 200 || response.statusCode == 201;

    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint('SERVER ERROR DATA: ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? 'Server Error: ${e.response?.statusCode}');
      }
      throw Exception('Connection failed. Please check your internet.');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}