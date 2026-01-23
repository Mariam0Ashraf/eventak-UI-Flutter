import 'package:eventak/core/constants/app-colors.dart';
import 'package:flutter/material.dart';

class CreateEventView extends StatefulWidget {
  const CreateEventView({super.key});

  @override
  State<CreateEventView> createState() => _CreateEventViewState();
}

final Color lightFillColor = Colors.grey.shade100;

class _CreateEventViewState extends State<CreateEventView> {
  // --- State Variables ---
  String?
  _selectedCategory; // Will hold the selected category name (e.g., 'Wedding')
  DateTime? _eventDate;
  TimeOfDay? _eventTime;
  String _visibility = 'Public';

  // Categories data, simulating data fetched from DB (using the HomeView's labels)
  final List<String> categoryLabels = [
    'Wedding',
    'Birthday',
    'Seminar',
    'Graduation',
    'Concert',
    'Workshop',
    'Festival',
  ];

  // --- Utility Widgets ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColor.blueFont,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String hint = '',
    int maxLines = 1,
    IconData? suffixIcon,
    Widget? customWidget,
    VoidCallback? onTap, //test
    bool readOnly = false, //test
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColor.blueFont,
            ),
          ),
          const SizedBox(height: 6),
          customWidget ??
              TextFormField(
                readOnly: readOnly,
                onTap: onTap,
                maxLines: maxLines,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                    color: Colors.grey, // Set hint color to light gray
                  ),
                  suffixIcon: suffixIcon != null
                      ? Icon(
                          suffixIcon,
                          color: AppColor.blueFont.withOpacity(0.6),
                        )
                      : null,
                  filled: true,
                  fillColor: lightFillColor,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  // --- Form Sections ---

  Widget _buildBasicDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Basic Event Details'),
        _buildTextField(
          label: 'Event Title',
          hint: 'e.g., Sarah & Adam Wedding',
        ),
        _buildTextField(label: 'Estimated Budget', hint: 'e.g.10000 EGP'),
        _buildCategoryDropdown(),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return _buildTextField(
      label: 'Event Category',
      customWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: lightFillColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          hint: Text('Select a category'),
          decoration: const InputDecoration(
            border: InputBorder.none, // Remove the default dropdown border
            contentPadding: EdgeInsets.zero,
          ),
          isExpanded: true,
          items: categoryLabels.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
          },
          // Dropdown styling
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColor.blueFont.withOpacity(0.6),
          ),
          dropdownColor: Colors.white,
          style: TextStyle(color: AppColor.blueFont, fontSize: 16),
        ),
      ),
    );
  }

  // NOTE: Keeping the original methods for context, but they are not executed here.
  // The original buildCategorySelector is removed.

  Widget _buildDateTimeLocation() {
    final dateFormatter = _eventDate == null
        ? 'Select Date'
        : '${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year}';
    final timeFormatter = _eventTime == null
        ? 'Select Time'
        : _eventTime!.format(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('When and Where'),
        _buildTextField(
          label: 'Date',
          hint: dateFormatter,
          suffixIcon: Icons.calendar_month_outlined,
          readOnly: true, 
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(primary: AppColor.primary),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) setState(() => _eventDate = date);
          },
        ),
        
        
        _buildTextField(
          label: 'Time',
          hint: timeFormatter,
          suffixIcon: Icons.access_time_outlined,
          readOnly: true, 
          
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(primary: AppColor.primary),
                  ),
                  child: child!,
                );
              },
            );
            if (time != null) setState(() => _eventTime = time);
          },
        ),

        // Location Input
        _buildTextField(label: 'Location', hint: 'e.g., The Grand Hall'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton.icon(
            onPressed: () => debugPrint('Open Map Selector'),
            icon: const Icon(Icons.location_on_outlined),
            label: const Text('Select Location on Map'),
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColor.blueFont,
              backgroundColor: AppColor.beige,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilitySettings() {
    final visibilityOptions = ['Public', 'Private', 'Invitation Only'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Visibility & Capacity'),
        _buildTextField(
          label: 'Guests Number',
          hint: 'e.g., 150',
          suffixIcon: Icons.people_alt_outlined,
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event Visibility',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColor.blueFont,
                ),
              ),
              const SizedBox(height: 8),
              // Reusing the Tab/Segmented Button Style
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: visibilityOptions.map((option) {
                  final isSelected = _visibility == option;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _visibility = option),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColor.primary : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColor.primary
                                  : AppColor.primary.withOpacity(0.2),
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColor.primary.withOpacity(0.12),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              option,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColor.blueFont,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.blueFont),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Create New Event',
              style: TextStyle(
                color: AppColor.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Eventak',
              style: TextStyle(color: AppColor.secondaryBlue, fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBasicDetails(),
            const Divider(),
            _buildDateTimeLocation(),
            const Divider(),
            _buildVisibilitySettings(),
            const Divider(),

            // Final Action Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement event submission logic
                  debugPrint('Start Event Planning Tapped');
                  debugPrint('Selected Category: $_selectedCategory');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColor.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start Event Planning',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
