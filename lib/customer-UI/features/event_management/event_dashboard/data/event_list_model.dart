import 'package:eventak/customer-UI/features/event_management/create_event/data/event_types_model.dart';

class EventListItem {
  final int id;
  final String name;
  final DateTime eventDate;
  String statusLabel;
  final bool isUpcoming;
  final int daysUntilEvent;
  final double completionPercentage;
  final int todosCount;
  final int timelinesCount;
  final int budgetItemsCount;
  final double estimatedBudget;
  final String location;
  final String address;
  final String description;
  final EventType eventType;
  final int guestCount;
  final Area? area;
  String status;



  EventListItem({
    required this.id,
    required this.name,
    required this.eventDate,
    required this.statusLabel,
    required this.isUpcoming,
    required this.daysUntilEvent,
    required this.completionPercentage,
    required this.todosCount,
    required this.timelinesCount,
    required this.budgetItemsCount,
    required this.estimatedBudget,
    required this.location,
    required this.address,
    required this.description,
    required this.eventType,
    required this.guestCount,
    required this.area,
    required this.status,
  });

  factory EventListItem.fromJson(Map<String, dynamic> json) {
    return EventListItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      eventDate: _parseDate(json['event_date']),
      status: json['status'] ?? 'planning', 
      statusLabel: json['status_label'] ?? 'Planning',
      // ... map the rest
      isUpcoming: json['is_upcoming'] ?? true,
      daysUntilEvent: json['days_until_event'] ?? 0,
      completionPercentage:
          (json['completion_percentage'] ?? 0).toDouble(),
      todosCount: json['todos_count'] ?? 0,
      timelinesCount: json['timelines_count'] ?? 0,
      budgetItemsCount: json['budget_items_count'] ?? 0,
      estimatedBudget: (json['estimated_budget'] ?? 0).toDouble(),
      guestCount: json['guest_count'] ?? 0,
      location: json['location'] ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      eventType: json['event_type'] != null
          ? EventType.fromJson(json['event_type'])
          : EventType(id: 0, name: 'Unknown', slug: '', icon: ''),
      area: json['area'] != null ? Area.fromJson(json['area']) : null,

    );
  }

  static DateTime _parseDate(dynamic value) {
  if (value is DateTime) return value;

  if (value is String) {
    try {
      // backend format: yyyy-MM-dd HH:mm:ss
      return DateTime.parse(value.replaceFirst(' ', 'T'));
    } catch (_) {
      return DateTime.now();
    }
  }

  return DateTime.now();
}

}
class Area {
  final int id;
  final String name;

  Area({required this.id, required this.name});

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

