import 'package:eventak/customer-UI/features/event_management/create_event/data/event_types_model.dart';
import 'package:eventak/customer-UI/features/event_management/create_event/data/list_event_types.dart';
import 'package:eventak/customer-UI/features/event_management/event_dashboard/data/event_list_model.dart';
import 'package:eventak/customer-UI/features/event_management/event_dashboard/data/event_provider.dart';
import 'package:eventak/customer-UI/features/event_management/event_dashboard/view/event_details_view.dart';
import 'package:eventak/customer-UI/features/event_management/event_dashboard/widgets/empty_events.dart';
import 'package:eventak/shared/app_bar_widget.dart';
import 'package:flutter/material.dart';
import '../widgets/event_card.dart';
import '../widgets/event_filter_bar.dart';
import 'package:provider/provider.dart';

class EventDashboardView extends StatefulWidget {
  const EventDashboardView({super.key});

  @override
  State<EventDashboardView> createState() => _EventDashboardViewState();
}

class _EventDashboardViewState extends State<EventDashboardView> {
  final ListEventTypes _typeService = ListEventTypes();

  List<EventType> types = [];
  EventType? selectedType;
  bool isLoadingMore = false;
  int currentPage = 1;
  int lastPage = 1;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Initial data fetch through Provider and local type service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EventProvider>().fetchEvents();
        _loadTypes();
      }
    });

    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        currentPage < lastPage) {
      // ToDo: Add pagination logic to EventProvider
    }
  }

  Future<void> _loadTypes() async {
    try {
      final fetchedTypes = await _typeService.fetchEventTypes();
      if (mounted) {
        setState(() {
          types = fetchedTypes;
        });
      }
    } catch (e) {
      debugPrint("Dashboard types load error: $e");
    }
  }

  List<EventListItem> _getFilteredEvents(List<EventListItem> allEvents) {
    if (selectedType == null) return allEvents;
    return allEvents.where((e) => e.eventType.id == selectedType!.id).toList();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final filteredEvents = _getFilteredEvents(eventProvider.events);

    return Scaffold(
      appBar: const CustomHomeAppBar(showBackButton: true,),
      body: eventProvider.isLoading
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
                          onRefresh: () => eventProvider.fetchEvents(),
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: filteredEvents.length + (isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == filteredEvents.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }

                              final event = filteredEvents[index];

                              return EventCard(
                                event: event,
                                onTap: () async {
                                  // Navigate to details
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EventDetailsView(eventId: event.id),
                                    ),
                                  );
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