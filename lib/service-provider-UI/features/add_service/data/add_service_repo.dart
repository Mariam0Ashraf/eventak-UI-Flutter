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
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Map<String, dynamic>>> getServiceTypes() async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/service-types');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching service types: $e');
      throw Exception('Failed to load service types');
    }
  }

Future<Map<String, dynamic>> createService(FormData serviceData) async {
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
          'Accept': 'application/json',
          'Authorization': 'Bearer $cleanToken', 
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data; 
    } else {
      throw Exception('Failed to create service');
    }
  } on DioException catch (e) {
    if (e.response != null) {
      throw Exception(e.response?.data['message'] ?? 'Server Error');
    }
    throw Exception('Connection failed');
  } catch (e) {
    throw Exception('An unexpected error occurred: $e');
  }
}

  Future<bool> updateService(int serviceId, FormData serviceData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

      final cleanToken = token.replaceAll('"', '');

      final response = await _dio.post(
        '${ApiConstants.baseUrl}/services/$serviceId',
        data: serviceData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $cleanToken',
          },
        ),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Update failed');
      }
      throw Exception('Connection failed');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAreasTree() async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}/areas');
      if (response.statusCode == 200 && response.data['success'] == true) {
        List<dynamic> flatList = response.data['data'];
        return _buildTree(flatList);
      }
      return [];
    } catch (e) {
      debugPrint('Error processing areas tree: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _buildTree(List<dynamic> flatList) {
    Map<int, Map<String, dynamic>> mapping = {
      for (var item in flatList) item['id']: Map<String, dynamic>.from(item)
    };
    List<Map<String, dynamic>> tree = [];
    for (var item in flatList) {
      var id = item['id'];
      var parentId = item['parent_id'];
      if (parentId == null) {
        tree.add(mapping[id]!);
      } else if (mapping.containsKey(parentId)) {
        mapping[parentId]!['children'] ??= [];
        (mapping[parentId]!['children'] as List).add(mapping[id]);
      }
    }
    return tree;
  }
}