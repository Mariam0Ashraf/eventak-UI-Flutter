import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/core/constants/api_constants.dart';
import 'package:eventak/customer-UI/features/event_management/create_event/data/event_types_model.dart';
import 'event_model.dart';

class CreateEventService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token')?.replaceAll('"', '');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> createEvent(EventData event) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/events'),
      headers: await _getHeaders(),
      body: jsonEncode(event.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create event: ${response.body}');
    }
  }

  Future<List<EventType>> fetchEventTypes() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/event-types'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((e) => EventType.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchAreasTree() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/areas'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    }
    return [];
  }
}
