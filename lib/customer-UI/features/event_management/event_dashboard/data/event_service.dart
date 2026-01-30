import 'dart:convert';
import 'package:eventak/core/constants/api_constants.dart';
import 'package:eventak/customer-UI/features/event_management/event_dashboard/data/event_list_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EventService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token')?.replaceAll('"', '');
    return token;
  }

  // Fetch all events with pagination
  Future<List<EventListItem>> fetchEvents({int page = 1}) async {
    try {
      final token = await _getToken();
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

  // Fetch a single event by ID
  Future<EventListItem?> fetchEventById(int id) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/events/$id'
          '?include_event_type=true'
          '&include_budget=false'
          '&include_todos=false'
          '&include_timeline=false'
          '&include_area=true'
        ),

        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final eventData = jsonData['data'];
        return EventListItem.fromJson(eventData);
        
      }
      return null;
    } catch (e) {
      print('Error fetching event by ID: $e');
      return null;
    }
  }

  // Update an existing event
  Future<bool> updateEvent(int id, Map<String, dynamic> updatedData) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/events/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedData), 
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('Update failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating event: $e');
      return false;
    }
  }

  // Delete an event
  Future<bool> deleteEvent(int id) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/events/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting event: $e');
      return false;
    }
  }
  Future<Map<String, dynamic>> fetchBudgetSummary(int eventId) async {
  final token = await _getToken();
  final response = await http.get(
    Uri.parse('${ApiConstants.baseUrl}/events/$eventId/budget/summary'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body)['data'];
  } else {
    throw Exception('Failed to load budget summary');
  }
}
}