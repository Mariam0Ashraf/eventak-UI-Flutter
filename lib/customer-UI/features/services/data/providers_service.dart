import 'dart:convert';
import 'package:eventak/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:eventak/customer-UI/features/services/data/provider_model.dart';

class ProvidersService {
  static const String _baseUrl = '${ApiConstants.baseUrl}/api/services';

  Future<List<ServiceProvider>> fetchServices() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> dataList = jsonResponse['data']['data'];
          
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