import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/core/constants/api_constants.dart';
import 'event_model.dart';
import 'event_types_model.dart';

class CreateEventService {

  // ===============================
  // FETCH EVENT TYPES (WITH TOKEN)
  // ===============================
  Future<List<EventType>> fetchEventTypes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token')?.replaceAll('"', '');

      if (token == null) {
        print('No auth token found');
        return [];
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/event-types'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      //print('Event types status: ${response.statusCode}');
      //print('Event types body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List data = jsonData['data'];
        return data.map((e) => EventType.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      print('Error fetching event types: $e');
      return [];
    }
  }

  // ===============================
  // CREATE EVENT (WITH TOKEN)
  // ===============================
  Future<void> createEvent(EventData event) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token')?.replaceAll('"', '');

    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/events'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(event.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      print('Create event error: ${response.body}');
      throw Exception('Failed to create event');
    }
  }
}
