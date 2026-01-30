import 'package:eventak/customer-UI/features/event_management/event_dashboard/widgets/event_manage_fab.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:eventak/core/utils/app_alerts.dart';
import 'package:eventak/customer-UI/features/event_management/event_dashboard/data/event_provider.dart';
import 'package:eventak/customer-UI/features/event_management/event_dashboard/widgets/event_details_widgets.dart';
import 'package:eventak/customer-UI/features/event_management/create_event/data/create_event_service.dart';
import 'package:eventak/customer-UI/features/event_management/event_dashboard/data/event_service.dart';
import 'package:eventak/customer-UI/features/event_management/event_dashboard/data/event_list_model.dart';
import 'package:eventak/shared/app_bar_widget.dart';

class EventDetailsView extends StatefulWidget {
  final int eventId;
  const EventDetailsView({super.key, required this.eventId});

  @override
  State<EventDetailsView> createState() => _EventDetailsViewState();
}

class _EventDetailsViewState extends State<EventDetailsView> {
  final EventService _eventService = EventService();
  final CreateEventService _createEventService = CreateEventService();

  EventListItem? event;
  bool isLoading = true;
  bool isEditing = false;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _locationController;
  late TextEditingController _areaController;
  late TextEditingController _addressController;
  late TextEditingController _guestController;
  late TextEditingController _budgetController;

  DateTime? _selectedDate;
  int? _selectedAreaId;
  List<Map<String, dynamic>> _areas = [];

  @override
  void initState() {
    super.initState();
    _loadEvent();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    try {
      final tree = await _createEventService.fetchAreasTree();
      if (mounted) setState(() => _areas = tree);
    } catch (e) {
      debugPrint("Error loading areas: $e");
    }
  }

  Future<void> _loadEvent() async {
    setState(() => isLoading = true);
    final data = await _eventService.fetchEventById(widget.eventId);
    if (mounted && data != null) {
      setState(() {
        event = data;
        _selectedDate = event!.eventDate;
        _selectedAreaId = event!.area?.id;
        _nameController = TextEditingController(text: event!.name);
        _descController = TextEditingController(text: event!.description);
        _locationController = TextEditingController(text: event!.location);
        _areaController = TextEditingController(text: event!.area?.name ?? "");
        _addressController = TextEditingController(text: event!.address);
        _guestController = TextEditingController(
          text: event!.guestCount.toString(),
        );
        _budgetController = TextEditingController(
          text: event!.estimatedBudget.toString(),
        );
        isLoading = false;
      });
    }
  }

  void _showAreaPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Select Area",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _areas.length,
                itemBuilder: (context, index) {
                  final country = _areas[index];
                  final governorates = country['children'] as List? ?? [];

                  return ExpansionTile(
                    key: PageStorageKey(country['id']),
                    leading: const Icon(Icons.public, size: 20),
                    title: Text(
                      country['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                        title: Text("${country['name']}"),
                        onTap: () =>
                            _updateSelectedArea(country['id'], country['name']),
                      ),
                      ...governorates.map((gov) {
                        final districts = gov['children'] as List? ?? [];
                        return ExpansionTile(
                          key: PageStorageKey(gov['id']),
                          title: Text(gov['name'] ?? ''),
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.only(left: 32),
                              leading: const Icon(
                                Icons.subdirectory_arrow_right,
                                size: 18,
                              ),
                              title: Text("${gov['name']}"),
                              onTap: () => _updateSelectedArea(
                                gov['id'],
                                "${country['name']} - ${gov['name']}",
                              ),
                            ),
                            ...districts
                                .map(
                                  (dist) => ListTile(
                                    contentPadding: const EdgeInsets.only(
                                      left: 48,
                                    ),
                                    title: Text(dist['name']),
                                    onTap: () => _updateSelectedArea(
                                      dist['id'],
                                      "${gov['name']} - ${dist['name']}",
                                    ),
                                  ),
                                )
                                .toList(),
                          ],
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateSelectedArea(int id, String displayName) {
    setState(() {
      _selectedAreaId = id;
      _areaController.text = displayName;
    });
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _handleEditToggle() async {
    if (isEditing) {
      final updatedData = {
        "name": _nameController.text,
        "description": _descController.text,
        "location": _locationController.text,
        "address": _addressController.text,
        "event_date": _selectedDate?.toIso8601String(),
        "guest_count": int.tryParse(_guestController.text),
        "estimated_budget": double.tryParse(_budgetController.text),
        "area_id": _selectedAreaId,
        "status": event!.status,
      };

      final success = await _eventService.updateEvent(
        widget.eventId,
        updatedData,
      );
      if (success && mounted) {
        context.read<EventProvider>().triggerRefresh();
        AppAlerts.showPopup(context, "Updated successfully");
        setState(() => isEditing = false);
        _loadEvent();
      }
    } else {
      setState(() => isEditing = true);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Event"),
        content: const Text(
          "Are you sure you want to delete this event? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
            ),
            onPressed: () async {
              final success = await _eventService.deleteEvent(widget.eventId);
              if (success && mounted) {
                context.read<EventProvider>().triggerRefresh();
                Navigator.pop(dialogContext);
                Navigator.pop(context);
                AppAlerts.showPopup(context, "Event deleted successfully");
              } else {
                AppAlerts.showPopup(
                  context,
                  "Failed to delete event",
                  isError: true,
                );
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final dateStr = DateFormat('EEEE, dd MMM yyyy').format(_selectedDate!);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const CustomHomeAppBar(),

      floatingActionButton: EventManagementFab(
        eventId: widget.eventId,
        eventTitle: '',
        activeIndex: 0,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            EventManagementHeader(
              title: event!.name,
              isEditing: isEditing,
              onBack: () => Navigator.pop(context),
              onEditToggle: _handleEditToggle,
              onDelete: _confirmDelete,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Inside EventDetailsView's build method:
                  EventInfoCard(
                    type: event!.eventType.name,
                    statusLabel: event!.statusLabel,
                    currentStatus: event!.status,
                    date: dateStr,
                    eventDate: _selectedDate!,
                    isEditing: isEditing,
                    onPickDate: _pickDate,
                    // Add this callback:
                    onStatusChanged: (String? newValue) {
                      if (newValue != null && mounted) {
                        setState(() {
                          // This ensures the _handleEditToggle function sees the new status
                          event!.status = newValue; 
                          
                          event!.statusLabel = newValue.split('_').map((e) => 
                            e[0].toUpperCase() + e.substring(1)).join(' ');
                        });
                      }
                    },
                  ),
                  EventDescriptionCard(
                    description: event!.description,
                    isEditing: isEditing,
                    nameController: _nameController,
                    descController: _descController,
                  ),
                  EventLocationCard(
                    location: event!.location,
                    area: event!.area?.name,
                    address: event!.address,
                    isEditing: isEditing,
                    locationController: _locationController,
                    areaController: _areaController,
                    addressController: _addressController,
                    onAreaTap: _showAreaPicker,
                  ),
                  EventStatsRow(
                    guests: event!.guestCount,
                    budget: event!.estimatedBudget,
                    completion: event!.completionPercentage,
                    isEditing: isEditing,
                    guestController: _guestController,
                    budgetController: _budgetController,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
