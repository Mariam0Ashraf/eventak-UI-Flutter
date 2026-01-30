import 'dart:convert';
import 'package:eventak/core/constants/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:eventak/customer-UI/features/services/list_services/data/provider_model.dart';

class ProvidersService {
  static const String _baseUrl = '${ApiConstants.baseUrl}/services';

  Future<List<ServiceProvider>> fetchServices({
    int page = 1,
    int? typeId,
  }) async {
    try {
      String urlString = '$_baseUrl?page=$page';
      if (typeId != null && typeId != -1) {
        urlString += '&service_type_id=$typeId';
      }
      final url = Uri.parse(urlString);
      final response = await http.get(url);
      
      debugPrint('Calling URL: $url');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> dataList = jsonResponse['data'];

          return dataList
              .map((json) => ServiceProvider.fromJson(json))
              .toList();
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching services: $e');
    }
  }
}
