import 'package:eventak/customer-UI/features/event_management/create_event/data/create_event_service.dart';
import 'package:eventak/customer-UI/features/event_management/create_event/data/event_model.dart';
import 'package:eventak/customer-UI/features/event_management/create_event/data/event_types_model.dart';
import 'package:eventak/customer-UI/features/event_management/create_event/widgets/basic_details_section.dart';
import 'package:eventak/customer-UI/features/event_management/create_event/widgets/date_time_location_section.dart';
import 'package:eventak/customer-UI/features/event_management/create_event/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

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

  DateTime? _eventDate;
  TimeOfDay? _eventTime;

  EventType? _selectedEventType;
  List<EventType> _eventTypes = [];

  @override
  void initState() {
    super.initState();
    _loadEventTypes();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _guestsController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _otherTypeController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _loadEventTypes() async {
    final types = await CreateEventService().fetchEventTypes();
    // Move "Other" to the end
    types.sort((a, b) {
      if (a.slug == 'other') return 1;
      if (b.slug == 'other') return -1;
      return a.name.compareTo(b.name);
    });
    setState(() => _eventTypes = types);
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

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.light()
            .copyWith(colorScheme: ColorScheme.light(primary: AppColor.primary)),
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
        data: ThemeData.light()
            .copyWith(colorScheme: ColorScheme.light(primary: AppColor.primary)),
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
      final event = EventData(
        name: _titleController.text.trim(),
        eventTypeId: _selectedEventType!.id,
        eventDate: _combineDateTime(),
        location: _locationController.text.trim(),
        address: _addressController.text.trim(),
        description: _descriptionController.text.trim(),
        estimatedBudget: double.parse(_budgetController.text.trim()),
        guestCount: int.parse(_guestsController.text.trim()),
        status: 'planning',
      );

      try {
        await CreateEventService().createEvent(event);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create event: $e')),
        );
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
          icon: Icon(Icons.arrow_back_ios_new, color: AppColor.blueFont, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Event',
          style: TextStyle(color: AppColor.blueFont, fontSize: 18, fontWeight: FontWeight.w600),
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
                onCategoryChanged: (val) => setState(() => _selectedEventType = val),
                showOtherField: _selectedEventType?.slug == 'other',
                otherTypeController: _otherTypeController,
              ),
              const Divider(),
              const SectionHeader(title: 'When and Where'),
              DateTimeLocationWidget(
                eventDate: _eventDate,
                onDateChanged: (d) => _pickDate(context),
                eventTime: _eventTime,
                onTimeChanged: (t) => _pickTime(context),
                dateController: _dateController,
                timeController: _timeController,
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
                    onPressed: _submitForm,
                    child: const Text(
                      'Start Event Planning',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
