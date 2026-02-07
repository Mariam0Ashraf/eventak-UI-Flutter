import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // [FOR MOBILE & WEB] To define file types
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/core/constants/api_constants.dart';
import 'guest_model.dart';


class GuestService {
  static const String _baseUrl = ApiConstants.baseUrl;

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token')?.replaceAll('"', '');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Fetch Guest List with Pagination and Filters 
  Future<Map<String, dynamic>> fetchGuests(int eventId, {
    int page = 1,
    String? rsvpStatus,
    bool? invitationSent,
    String? search,
  }) async {
    final queryParams = {
      'page': page.toString(),
      if (rsvpStatus != null) 'rsvp_status': rsvpStatus,
      if (invitationSent != null) 'invitation_sent': invitationSent.toString(),
      if (search != null) 'search': search,
    };

    final uri = Uri.parse('$_baseUrl/events/$eventId/guests')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return {
        'guests': (decoded['data'] as List)
            .map((item) => GuestItem.fromJson(item))
            .toList(),
        'last_page': decoded['meta']['last_page'],
        'current_page': decoded['meta']['current_page'],
      };
    }
    throw Exception('Failed to load guests');
  }

  Future<GuestItem> fetchGuestById(int eventId, int guestId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/events/$eventId/guests/$guestId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return GuestItem.fromJson(json.decode(response.body)['data']);
    }
    throw Exception('Failed to load guest details');
  }

  // RSVP Statistics 
  Future<RSVPStatistics> fetchStatistics(int eventId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/events/$eventId/guests/statistics'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return RSVPStatistics.fromJson(json.decode(response.body)['data']);
    }
    throw Exception('Failed to load statistics');
  }

  // Create Individual Guest 
  Future<bool> createGuest(int eventId, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/events/$eventId/guests'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  //update guest
  Future<bool> updateGuest(int eventId, int guestId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/events/$eventId/guests/$guestId'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );
    return response.statusCode == 200;
  }

  // Delete Guest 
  Future<bool> deleteGuest(int eventId, int guestId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/events/$eventId/guests/$guestId'),
      headers: await _getHeaders(),
    );
    return response.statusCode == 200;
  }

  // Send Email Invitation
  Future<bool> sendEmailInvite(int eventId, int guestId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/events/$eventId/guests/$guestId/send-invitation'),
      headers: await _getHeaders(),
    );
    return response.statusCode == 200;
  }

  // Send SMS Invitation
  Future<bool> sendSmsInvite(int eventId, int guestId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/events/$eventId/guests/$guestId/send-invitation-sms'),
      headers: await _getHeaders(),
    );
    return response.statusCode == 200;
  }

  // Send All Invitations (Multi-Channel)
  Future<Map<String, dynamic>> sendAllMultiChannel(int eventId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/events/$eventId/guests/send-all-invitations-multi'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) return json.decode(response.body)['data'];
    throw Exception("Failed to send bulk invites");
  }

  // bulk import guests list
  Future<bool> bulkImportGuests(int eventId, List<Map<String, String>> guests) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/events/$eventId/guests/bulk-import'),
      headers: await _getHeaders(),
      body: json.encode({"guests": guests}),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // [FOR MOBILE & WEB] Universal Download Template
  Future<Uint8List> downloadGuestTemplate(int eventId) async {
    final url = Uri.parse('$_baseUrl/events/$eventId/guests/import-template');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to download template: ${response.statusCode}');
    }
  }

  // [FOR MOBILE & WEB] Universal Bulk Import
  Future<bool> uploadGuestFile({
    required int eventId,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/events/$eventId/guests/bulk-import-file'),
      );
      request.headers.addAll(await _getHeaders());

      // Using fromBytes makes this work on both Laptop and Mobile
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
          contentType: fileName.endsWith('.csv')
              ? MediaType('text', 'csv')
              : MediaType('application', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Upload Error: $e");
      return false;
    }
  }
}