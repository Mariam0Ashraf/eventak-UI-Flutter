import 'dart:convert';
import 'package:eventak/core/constants/api_constants.dart';
import 'package:eventak/customer-UI/features/event_management/create_event/data/event_types_model.dart';
import 'package:eventak/customer-UI/features/event_management/create_event/data/list_event_types.dart';
import 'package:eventak/customer-UI/features/event_management/event_dashboard/widgets/empty_events.dart';
import 'package:eventak/shared/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/event_service.dart';
import '../data/event_list_model.dart';
import '../widgets/event_card.dart';
import '../widgets/event_filter_bar.dart';

class EventDashboardView extends StatefulWidget {
  const EventDashboardView({super.key});

  @override
  State<EventDashboardView> createState() => _EventDashboardViewState();
}

class _EventDashboardViewState extends State<EventDashboardView> {
  final EventService _eventService = EventService();
  final ListEventTypes _typeService = ListEventTypes();

  List<EventListItem> events = [];
  List<EventType> types = [];
  EventType? selectedType;

  bool isLoading = true;
  bool isLoadingMore = false;

  int currentPage = 1;
  int lastPage = 1;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          currentPage < lastPage) {
        _loadMore();
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final fetchedEvents = await _eventService.fetchEvents(page: 1);
      final fetchedTypes = await _typeService.fetchEventTypes();

      // Get last page from meta
      lastPage = await _getLastPage();

      setState(() {
        events = fetchedEvents;
        types = fetchedTypes;
        currentPage = 1;
        isLoading = false;
      });
    } catch (e) {
      print("Dashboard load error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<int> _getLastPage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token')?.replaceAll('"', '');
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/events?page=1'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return jsonData['meta']['last_page'] ?? 1;
      }
      return 1;
    } catch (e) {
      return 1;
    }
  }

  Future<void> _loadMore() async {
    if (currentPage >= lastPage) return;

    setState(() => isLoadingMore = true);

    final nextPage = currentPage + 1;
    final fetchedEvents = await _eventService.fetchEvents(page: nextPage);

    setState(() {
      events.addAll(fetchedEvents);
      currentPage = nextPage;
      isLoadingMore = false;
    });
  }

  List<EventListItem> get filteredEvents {
    if (selectedType == null) return events;
    return events.where((e) => e.eventType.id == selectedType!.id).toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHomeAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 4),
                EventFilterBar(
                  types: types,
                  selected: selectedType,
                  onSelect: (type) {
                    setState(() => selectedType = type);
                  },
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filteredEvents.isEmpty
                      ? const EmptyEventsWidget()
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: filteredEvents.length +
                                (isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == filteredEvents.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              }

                              final event = filteredEvents[index];

                              return EventCard(
                                event: event,
                                onTap: () {
                                  // TODO: navigate to Event Details page
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
