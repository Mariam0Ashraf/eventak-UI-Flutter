import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/event_management/event_dashboard/widgets/date_countdown.dart';

/// ---------------- INFO CARD ----------------
class EventInfoCard extends StatelessWidget {
  final String type;
  final String status;
  final DateTime eventDate;
  final String date;
  final bool isEditing;
  final VoidCallback onPickDate;

  const EventInfoCard({
    super.key,
    required this.type,
    required this.status,
    required this.date,
    required this.eventDate,
    required this.isEditing,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LabelValue(label: "Event Type", value: type),
              _StatusChip(status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: InkWell(
                  onTap: isEditing ? onPickDate : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Date", style: TextStyle(fontSize: 12, color: AppColor.grey)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(date, style: const TextStyle(fontWeight: FontWeight.w600)),
                          if (isEditing) 
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(Icons.calendar_month, size: 16, color: AppColor.primary),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _LabelValue(label: "Days Left", value: friendlyDate(eventDate)),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------- DESCRIPTION ----------------
class EventDescriptionCard extends StatelessWidget {
  final String description;
  final bool isEditing;
  final TextEditingController nameController;
  final TextEditingController descController;

  const EventDescriptionCard({
    super.key,
    required this.description,
    required this.isEditing,
    required this.nameController,
    required this.descController,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEditing) ...[
            _SectionTitle("Event Name"),
            const SizedBox(height: 8),
            TextField(
              controller: nameController, 
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true)
            ),
            const SizedBox(height: 16),
          ],
          _SectionTitle("Description"),
          const SizedBox(height: 8),
          isEditing
              ? TextField(
                  controller: descController, 
                  maxLines: 3, 
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true)
                )
              : Text(description, style: TextStyle(color: AppColor.blueFont, height: 1.6)),
        ],
      ),
    );
  }
}

/// ---------------- LOCATION CARD ----------------
class EventLocationCard extends StatelessWidget {
  final String location;
  final String? area;
  final String address;
  final bool isEditing;
  final TextEditingController locationController;
  final TextEditingController areaController;
  final TextEditingController addressController;
  final VoidCallback onAreaTap;

  const EventLocationCard({
    super.key,
    required this.location,
    this.area,
    required this.address,
    required this.isEditing,
    required this.locationController,
    required this.areaController,
    required this.addressController,
    required this.onAreaTap,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Where", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.blueFont)),
          const SizedBox(height: 12),
          if (isEditing) ...[
            _buildEditField(locationController, "Location Name", Icons.place_outlined),
            const SizedBox(height: 10),
            InkWell(
              onTap: onAreaTap,
              child: IgnorePointer(
                child: _buildEditField(areaController, "Area", Icons.map_outlined),
              ),
            ),
            const SizedBox(height: 10),
            _buildEditField(addressController, "Detailed Address", Icons.home_outlined),
          ] else ...[
            _IconText(Icons.map_outlined, "Area: ${area ?? 'Not Set'}"),
            const SizedBox(height: 8),
            _IconText(Icons.place_outlined, "Location: $location"),
            const SizedBox(height: 8),
            _IconText(Icons.home_outlined, "Detailed Address: ${address.isEmpty ? 'Not Set' : address}"),
          ],
        ],
      ),
    );
  }

  Widget _buildEditField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      readOnly: label == "Area",
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 18, color: AppColor.primary),
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

/// ---------------- STATS ----------------
class EventStatsRow extends StatelessWidget {
  final int guests;
  final num budget;
  final double completion;
  final bool isEditing;
  final TextEditingController guestController;
  final TextEditingController budgetController;

  const EventStatsRow({
    super.key,
    required this.guests,
    required this.budget,
    required this.completion,
    required this.isEditing,
    required this.guestController,
    required this.budgetController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox("Guests", "$guests", isEditing: isEditing, controller: guestController, inputType: TextInputType.number),
        _StatBox("Budget", "$budget", isEditing: isEditing, controller: budgetController, inputType: TextInputType.number),
        _StatBox("Completed", "$completion%", isEditing: false),
      ],
    );
  }
}

/// ---------------- SHARED WIDGETS ----------------

class _IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  const _IconText(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColor.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: AppColor.blueFont, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final bool isEditing;
  final TextEditingController? controller;
  final TextInputType inputType;
  
  const _StatBox(this.label, this.value, {this.isEditing = false, this.controller, this.inputType = TextInputType.text});
  
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColor.beige.withOpacity(.5), 
          borderRadius: BorderRadius.circular(14)
        ),
        child: Column(children: [
          isEditing 
            ? TextField(
                controller: controller, 
                keyboardType: inputType, 
                textAlign: TextAlign.center, 
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.primary, fontSize: 14),
                decoration: const InputDecoration(isDense: true, border: InputBorder.none),
              )
            : Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.primary, fontSize: 14)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: AppColor.grey)),
        ]),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, 
      margin: const EdgeInsets.only(bottom: 16), 
      padding: const EdgeInsets.all(16), 
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), 
      child: child
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColor.blueFont));
  }
}

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;
  const _LabelValue({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 12, color: AppColor.grey)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]);
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip(this.status);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
      decoration: BoxDecoration(color: AppColor.secondaryBlue.withOpacity(.2), borderRadius: BorderRadius.circular(20)), 
      child: Text(status, style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.w600, fontSize: 12))
    );
  }
}

class EventTabsPlaceholder extends StatelessWidget {
  const EventTabsPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16), 
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), 
      child: const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Text("Timeline"), Text("Todos"), Text("Budget Tracker")])
    );
  }
}