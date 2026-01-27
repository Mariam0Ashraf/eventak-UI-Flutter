class EventData {
  final String name;
  final int eventTypeId;
  final DateTime eventDate;
  final int? areaId;
  final String location;
  final String address;
  final String description;
  final double estimatedBudget;
  final int guestCount;
  final String status;

  EventData({
    required this.name,
    required this.eventTypeId,
    required this.eventDate,
    required this.areaId,
    required this.location,
    required this.address,
    required this.description,
    required this.estimatedBudget,
    required this.guestCount,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "event_type_id": eventTypeId,
      "event_date":
          "${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')} "
          "${eventDate.hour.toString().padLeft(2, '0')}:${eventDate.minute.toString().padLeft(2, '0')}:00",
      'area_id': areaId,
      "location": location,
      "address": address,
      "description": description,
      "estimated_budget": estimatedBudget,
      "guest_count": guestCount,
      "status": status,
    };
  }
}
