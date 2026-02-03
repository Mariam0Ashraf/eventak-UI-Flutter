import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/core/constants/api_constants.dart';
import 'event_website_model.dart';

class EventWebsiteService {
  Future<EventWebsite?> fetchWebsiteDetails(int eventId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token')?.replaceAll('"', '');

  final response = await http.get(
    Uri.parse('${ApiConstants.baseUrl}/events/$eventId/website'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return EventWebsite.fromJson(data['data']);
  } else if (response.statusCode == 404) {
    return null;
  } else {
    throw Exception('Failed to load website management data');
  }
}
  Future<Map<String, String>> fetchWebsiteTemplates(int eventId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token')?.replaceAll('"', '');

  final response = await http.get(
    Uri.parse('${ApiConstants.baseUrl}/events/$eventId/website/templates'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);
    return Map<String, String>.from(decoded['data'] ?? {});
  } else {
    throw Exception('Failed to load templates');
  }
}
}