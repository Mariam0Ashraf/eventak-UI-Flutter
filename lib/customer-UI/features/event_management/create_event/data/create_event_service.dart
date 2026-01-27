import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/core/constants/api_constants.dart';
import 'event_model.dart';

class CreateEventService {


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
