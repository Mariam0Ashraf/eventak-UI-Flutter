import 'package:eventak/customer-UI/features/event_management/create_event/data/create_event_service.dart';
import 'package:eventak/customer-UI/features/event_management/create_event/data/event_model.dart';
import 'package:eventak/customer-UI/features/event_management/create_event/data/event_types_model.dart';
import 'package:eventak/customer-UI/features/event_management/create_event/widgets/basic_details_section.dart';
import 'package:eventak/customer-UI/features/event_management/create_event/widgets/date_time_location_section.dart';
import 'package:eventak/customer-UI/features/event_management/create_event/widgets/section_header.dart';
import 'package:eventak/customer-UI/features/event_management/create_event/data/list_event_types.dart';

import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/core/utils/app_alerts.dart';

class CreateEventView extends StatefulWidget {
  const CreateEventView({super.key});

  @override
  State<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<CreateEventView> {
  // Form key
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _guestsController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _otherTypeController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _areaController = TextEditingController();

  DateTime? _eventDate;
  TimeOfDay? _eventTime;
  List<Map<String, dynamic>> _areas = [];
  int? _selectedAreaId;
  EventType? _selectedEventType;
  List<EventType> _eventTypes = [];

  // Loading state
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadEventTypes();
    _loadAreas();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _guestsController.dispose();
    _areaController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _otherTypeController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _loadAreas() async {
    try {
      final tree = await CreateEventService().getAreasTree();
      if (mounted) {
        setState(() => _areas = tree);
      }
    } catch (e) {
      debugPrint("Error loading areas: $e");
    }
  }

  Future<void> _loadEventTypes() async {
    try {
      final types = await ListEventTypes().fetchEventTypes();
      types.sort((a, b) {
        if (a.slug == 'other') return 1;
        if (b.slug == 'other') return -1;
        return a.name.compareTo(b.name);
      });
      if (mounted) setState(() => _eventTypes = types);
    } catch (e) {
      debugPrint("Error loading types: $e");
    }
  }

  DateTime _combineDateTime() {
    return DateTime(
      _eventDate!.year,
      _eventDate!.month,
      _eventDate!.day,
      _eventTime!.hour,
      _eventTime!.minute,
    );
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
                  final city = _areas[index];
                  final children = city['children'] as List? ?? [];

                  return ExpansionTile(
                    title: Text(city['name'] ?? ''),
                    children: children
                        .map(
                          (area) => ListTile(
                            title: Text(area['name'] ?? ''),
                            onTap: () {
                              setState(() {
                                _selectedAreaId = area['id'];
                                _areaController.text =
                                    "${city['name']} - ${area['name']}";
                              });
                              Navigator.pop(context);
                            },
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: AppColor.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _eventDate = picked;
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: AppColor.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _eventTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final event = EventData(
        name: _titleController.text.trim(),
        eventTypeId: _selectedEventType!.id,
        eventDate: _combineDateTime(),
        areaId: _selectedAreaId,
        location: _locationController.text.trim(),
        address: _addressController.text.trim(),
        description: _descriptionController.text.trim(),
        estimatedBudget: double.tryParse(_budgetController.text.trim()) ?? 0,
        guestCount: int.tryParse(_guestsController.text.trim()) ?? 0,
        status: 'planning',
      );

      try {
        await CreateEventService().createEvent(event);

        if (mounted) {
          AppAlerts.showPopup(context, 'Event created successfully!');
          await Future.delayed(const Duration(seconds: 3));

          if (mounted) Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          AppAlerts.showPopup(
            context,
            'Failed to create event: $e',
            isError: true,
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColor.blueFont,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Event',
          style: TextStyle(
            color: AppColor.blueFont,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SectionHeader(title: 'Basic Event Details'),
              BasicDetailsWidget(
                titleController: _titleController,
                descriptionController: _descriptionController,
                budgetController: _budgetController,
                guestsController: _guestsController,
                selectedCategory: _selectedEventType,
                categories: _eventTypes,
                onCategoryChanged: (val) =>
                    setState(() => _selectedEventType = val),
                showOtherField: _selectedEventType?.slug == 'other',
                otherTypeController: _otherTypeController,
              ),
              const Divider(),
              const SectionHeader(title: 'When and Where'),
              DateTimeLocationWidget(
                eventDate: _eventDate,
                onDateChanged: () => _pickDate(context),
                eventTime: _eventTime,
                onTimeChanged: () => _pickTime(context),
                dateController: _dateController,
                timeController: _timeController,
                areaController: _areaController,
                onAreaTap: _showAreaPicker,
                locationController: _locationController,
                addressController: _addressController,
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _submitForm,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Start Event Planning',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
