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
  Future<Map<String, String>> fetchWebsiteFonts(int eventId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token')?.replaceAll('"', '');

  final response = await http.get(
    Uri.parse('${ApiConstants.baseUrl}/events/$eventId/website/fonts'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);
    return Map<String, String>.from(decoded['data'] ?? {}); //
  } else {
    throw Exception('Failed to load fonts');
  }
}
Future<bool> togglePublishStatus(int eventId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token')?.replaceAll('"', '');

  final response = await http.post(
    Uri.parse('${ApiConstants.baseUrl}/events/$eventId/website/toggle-publish'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);
    return decoded['data']['is_published'] ?? false; //
  } else {
    throw Exception('Failed to toggle publish status');
  }
}
Future<void> deleteWebsite(int eventId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token')?.replaceAll('"', '');

  final response = await http.delete(
    Uri.parse('${ApiConstants.baseUrl}/events/$eventId/website'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode != 200 && response.statusCode != 204) {
    final decoded = json.decode(response.body);
    throw Exception(decoded['message'] ?? 'Failed to delete website');
  }
}
Future<void> saveWebsitePage({
  required int eventId,
  required String title,
  required String slug,
  required String content,
  required int order,
  bool isActive = true,
  bool showInMenu = true,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token')?.replaceAll('"', '');

  final response = await http.post(
    Uri.parse('${ApiConstants.baseUrl}/events/$eventId/website/pages'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: json.encode({
      'title': title,
      'slug': slug,
      'content': content,
      'order': order,
      'is_active': isActive,
      'show_in_menu': showInMenu,
    }),
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception('Failed to save website page');
  }
}
Future<void> deleteWebsitePage(int eventId, int pageId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token')?.replaceAll('"', '');

  final response = await http.delete(
    Uri.parse('${ApiConstants.baseUrl}/events/$eventId/website/pages/$pageId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode != 200 && response.statusCode != 204) {
    throw Exception('Failed to delete page');
  }
}

}