import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/core/constants/api_constants.dart';
import 'event_list_model.dart';

class EventService {
  Future<List<EventListItem>> fetchEvents({int page = 1}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token')?.replaceAll('"', '');

      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/events?page=$page'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List data = jsonData['data'];
        return data.map((e) => EventListItem.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  Future<void> deleteEvent(int eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token')?.replaceAll('"', '');

    await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/events/$eventId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}
