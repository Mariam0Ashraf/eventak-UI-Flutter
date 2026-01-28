import 'package:flutter/material.dart';
import 'event_list_model.dart';
import 'event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();
  
  List<EventListItem> _events = [];
  bool _isLoading = false;

  List<EventListItem> get events => _events;
  bool get isLoading => _isLoading;

  // Fetch Events
  Future<void> fetchEvents() async {
    _isLoading = true;
    notifyListeners(); // Tell the UI to show loading

    try {
      _events = await _eventService.fetchEvents(page: 1);
    } catch (e) {
      debugPrint("Provider fetch error: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // Tell UI to show data
    }
  }

  // Called after Create, Update, or Delete
  void triggerRefresh() {
    fetchEvents();
  }
}