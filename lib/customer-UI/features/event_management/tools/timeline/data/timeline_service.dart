import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/core/constants/api_constants.dart';
import 'timeline_model.dart';

class TimelineService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token')?.replaceAll('"', '');
  }

  Future<List<TimelineItem>> fetchTimeline(int eventId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/events/$eventId/timeline'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final List<dynamic> list = decoded['data']['timeline_items'];
      return list.map((item) => TimelineItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load timeline');
    }
  }

  Future<bool> createTimelineItem(int eventId, Map<String, dynamic> data) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/events/$eventId/timeline'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> updateTimelineItem(int eventId, int timelineId, Map<String, dynamic> data) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/events/$eventId/timeline/$timelineId'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

 Future<bool> deleteTimelineItem(int eventId, int timelineId) async {
  final token = await _getToken();
  final url = '${ApiConstants.baseUrl}/events/$eventId/timeline/${timelineId.toString()}';
  
  final response = await http.delete(
    Uri.parse(url),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  return response.statusCode == 200 || response.statusCode == 204;
}

  Future<bool> reorderTimeline(int eventId, List<int> orderedIds) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/events/$eventId/timeline/reorder'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"ordered_ids": orderedIds}),
    );
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> getPrintableTimeline(int eventId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/events/$eventId/timeline/print'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to fetch printable timeline');
    }
  }
}