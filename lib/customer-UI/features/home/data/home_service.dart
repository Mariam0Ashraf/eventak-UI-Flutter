// lib/features/home/data/home_service.dart
import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:eventak/core/constants/api_constants.dart';


class HomeService {
  Future<List<Map<String, dynamic>>> getServiceCategories() async {
    final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/service-categories'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);

      return jsonList.cast<Map<String, dynamic>>();
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
