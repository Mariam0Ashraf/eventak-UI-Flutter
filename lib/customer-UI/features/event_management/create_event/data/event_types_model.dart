class EventType {
  final int id;
  final String name;
  final String slug;
  final String icon;

  EventType({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
  });

  factory EventType.fromJson(Map<String, dynamic> json) {
    return EventType(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      icon: json['icon'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventType && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
