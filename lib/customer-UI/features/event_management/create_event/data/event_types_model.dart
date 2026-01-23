class EventType {
  final int id;
  final String name;

  EventType({
    required this.id,
    required this.name,
  });

  factory EventType.fromJson(Map<String, dynamic> json) {
    return EventType(
      id: json['id'],
      name: json['name'],
    );
  }
}
