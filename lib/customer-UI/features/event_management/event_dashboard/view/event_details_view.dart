import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/event_management/event_dashboard/data/event_provider.dart';
import 'package:eventak/customer-UI/features/event_management/event_dashboard/widgets/event_details_widgets.dart';
import 'package:eventak/customer-UI/features/event_management/create_event/data/create_event_service.dart'; // Import service
import 'package:eventak/shared/app_bar_widget.dart'; 
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eventak/core/utils/app_alerts.dart';
import 'package:eventak/customer-UI/features/event_management/event_dashboard/data/event_service.dart';
import 'package:eventak/customer-UI/features/event_management/event_dashboard/data/event_list_model.dart';
import 'package:provider/provider.dart';

class EventDetailsView extends StatefulWidget {
  final int eventId;
  const EventDetailsView({super.key, required this.eventId});

  @override
  State<EventDetailsView> createState() => _EventDetailsViewState();
}

class _EventDetailsViewState extends State<EventDetailsView> {
  final EventService _eventService = EventService();
  final CreateEventService _createEventService = CreateEventService(); // For Area Tree
  
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
        _areaController = TextEditingController(text: event!.area?.name ?? ""); // Store Name for display
        _addressController = TextEditingController(text: event!.address);
        _guestController = TextEditingController(text: event!.guestCount.toString());
        _budgetController = TextEditingController(text: event!.estimatedBudget.toString());
        isLoading = false;
      });
    }
  }

  // --- AREA PICKER LOGIC ---
  void _showAreaPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Select Area", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _areas.length,
                itemBuilder: (context, index) {
                  final country = _areas[index];
                  final governorates = country['children'] as List? ?? [];
                  return Column(
                    children: governorates.map((gov) {
                      final districts = gov['children'] as List? ?? [];
                      return ExpansionTile(
                        title: Text(gov['name'] ?? ''),
                        children: districts.map((dist) => ListTile(
                          title: Text(dist['name']),
                          onTap: () {
                            setState(() {
                              _selectedAreaId = dist['id'];
                              _areaController.text = "${gov['name']} - ${dist['name']}";
                            });
                            Navigator.pop(context);
                          },
                        )).toList(),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
      };

      final success = await _eventService.updateEvent(widget.eventId, updatedData);
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
        content: const Text("Are you sure you want to delete this event? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), 
            child: const Text("Cancel")
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final success = await _eventService.deleteEvent(widget.eventId);
              
              if (success && mounted) {
                // 1. Refresh the Global Provider so the dashboard list updates
                context.read<EventProvider>().triggerRefresh();
                
                // 2. Close the Dialog
                Navigator.pop(dialogContext); 
                
                // 3. Close the EventDetailsView to return to Dashboard
                Navigator.pop(context); 
                
                AppAlerts.showPopup(context, "Event deleted successfully");
              } else {
                AppAlerts.showPopup(context, "Failed to delete event", isError: true);
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
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final dateStr = DateFormat('EEEE, dd MMM yyyy').format(_selectedDate!);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const CustomHomeAppBar(), 
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- ACTION HEADER (BACK, NAME, EDIT, DELETE) ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: AppColor.blueFont, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      isEditing ? "Editing Event" : event!.name,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.blueFont),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(isEditing ? Icons.check_circle : Icons.edit_outlined),
                    color: isEditing ? Colors.green : AppColor.primary,
                    onPressed: _handleEditToggle,
                  ),
                  if (!isEditing)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.redAccent,
                      onPressed: _confirmDelete,
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  EventInfoCard(
                    type: event!.eventType.name,
                    status: event!.statusLabel,
                    date: dateStr,
                    eventDate: _selectedDate!,
                    isEditing: isEditing,
                    onPickDate: _pickDate,
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
                  const SizedBox(height: 24),
                  const EventTabsPlaceholder(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}