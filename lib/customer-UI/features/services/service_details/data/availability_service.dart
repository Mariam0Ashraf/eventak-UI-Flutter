import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eventak/core/constants/api_constants.dart';

class Slot {
  final String startTime;
  final String endTime;
  final bool isAvailable;

  Slot({required this.startTime, required this.endTime, required this.isAvailable});

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      startTime: json['start_time'] ?? "",
      endTime: json['end_time'] ?? "",
      isAvailable: json['is_available'] ?? false,
    );
  }
}

class AvailabilityService {
  Future<List<Slot>> getReservedSlots(int bookableId, String date, String type) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/availability/$type/$bookableId?from_date=$date&to_date=$date'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List reservedSlots = data['data']['reserved_slots'] ?? [];
      if (reservedSlots.isEmpty) return [];
      
      final List slotsJson = reservedSlots[0]['slots'] ?? [];
      return slotsJson.map((s) => Slot.fromJson(s)).toList();
    } else {
      throw Exception('Failed to fetch availability');
    }
  }
}