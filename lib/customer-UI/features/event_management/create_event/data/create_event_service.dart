import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eventak/customer-UI/features/event_management/create_event/data/event_model.dart';
import 'package:eventak/customer-UI/features/event_management/create_event/data/event_types_model.dart';

class CreateEventService {
  final String baseUrl;

  CreateEventService(this.baseUrl);

  Future<List<EventType>> fetchEventTypes() async {
    final res = await http.get(Uri.parse('$baseUrl/event-types'));

    final List data = jsonDecode(res.body);
    return data.map((e) => EventType.fromJson(e)).toList();
  }

  Future<void> createEvent(EventData request) async {
    await http.post(
      Uri.parse('$baseUrl/events'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
  }
}
