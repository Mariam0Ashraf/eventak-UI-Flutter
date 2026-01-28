class TimelineItem {
  final int id;
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final int duration;
  final int order;

  TimelineItem({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.order,
  });

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    return TimelineItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      duration: json['duration_minutes'] ?? 0,
      order: json['order'] ?? 0,
    );
  }
}