import 'package:eventak/customer-UI/features/event_management/create_event/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'category_dropdown.dart';
import '../data/event_types_model.dart';
import 'package:flutter/services.dart';

class BasicDetailsWidget extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController budgetController;
  final TextEditingController guestsController;
  final EventType? selectedCategory;
  final ValueChanged<EventType?> onCategoryChanged;
  final List<EventType> categories;
  final bool showOtherField;
  final TextEditingController? otherTypeController;

  const BasicDetailsWidget({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.budgetController,
    required this.guestsController,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.categories,
    this.showOtherField = false,
    this.otherTypeController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          label: 'Event Title',
          hint: "e.g. John & Jane's Wedding",
          controller: titleController,
          isRequired: true, 
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Event title is required';
            }
            return null;
          },
        ),
        CustomTextField(
          label: 'Description',
          hint: 'Elegant summer wedding celebration',
          maxLines: 3,
          controller: descriptionController,
          isRequired: false, 
        ),
        CategoryDropdown(
          selected: selectedCategory,
          items: categories,
          onChanged: onCategoryChanged,
        ),
        ///not needed right now 
        /*if (showOtherField)
          CustomTextField(
            label: 'Specify Event Type',
            controller: otherTypeController,
            isRequired: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please specify the event type';
              }
              return null;
            },
          ),*/
        CustomTextField(
          label: 'Estimated Budget',
          hint: 'e.g. 25000',
          controller: budgetController,
          isRequired: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Budget is required';
            }
            return null;
          },
        ),
        CustomTextField(
          label: 'Number of Guests',
          hint: 'e.g. 150',
          controller: guestsController,
          isRequired: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Guest count is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}