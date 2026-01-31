import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eventak/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPackageService {
  Future<List<Map<String, dynamic>>> fetchListData(String endpoint, int page) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token')?.replaceAll('"', '');
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/$endpoint?page=$page'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(decoded['data']);
    }
    return [];
  }

  Future<bool> createPackage(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token')?.replaceAll('"', '');
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/packages'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      final error = jsonDecode(response.body)['message'] ?? 'Failed to create package';
      throw Exception(error);
    }
  }

  Future<List<Map<String, dynamic>>> getAreasTree() async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/areas'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          return _buildTree(decoded['data']);
        }
      }
      return [];
    } catch (e) {
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