import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/core/constants/api_constants.dart';
import 'package:eventak/service-provider-UI/features/show_service/data/show_service_data.dart';

class MyServicesService {
  static const Duration _timeout = Duration(seconds: 15);

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _buildHeaders() async {
    final token = await _getToken();
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${token.replaceAll('"', '')}';
    }
    return headers;
  }

  Future<List<MyService>> listServices({int page = 1}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/my-services?page=$page');
    final headers = await _buildHeaders();

    final response = await http.get(uri, headers: headers).timeout(_timeout);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      dynamic data = decoded['data'] ?? decoded;

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map<MyService>((e) => MyService.fromJson(e))
            .toList();
      }
      throw Exception('Unexpected services response shape.');
    } else {
      throw Exception('Failed to load services: ${response.statusCode}');
    }
  }

  Future<MyService> getService(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/services/$id');
    final headers = await _buildHeaders();

    final response = await http.get(uri, headers: headers).timeout(_timeout);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] ?? decoded;

      if (data is Map<String, dynamic>) {
        return MyService.fromJson(data);
      }
      throw Exception('Unexpected service details response shape.');
    } else {
      throw Exception('Failed to load service: ${response.statusCode}');
    }
  }

  Future<MyService> updateService(MyService service) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/services/${service.id}');
    final headers = await _buildHeaders();
    final body = jsonEncode(service.toJson());

    final response = await http.put(uri, headers: headers, body: body).timeout(_timeout);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] ?? decoded;
      return MyService.fromJson(data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update service: ${response.statusCode}');
    }
  }

  Future<void> deleteService(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/services/$id');
    final headers = await _buildHeaders();
    final response = await http.delete(uri, headers: headers).timeout(_timeout);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete service');
    }
  }
}