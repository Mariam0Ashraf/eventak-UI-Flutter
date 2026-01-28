String friendlyDate(DateTime date) {
  final now = DateTime.now();
  final eventDate = DateTime(date.year, date.month, date.day);
  final today = DateTime(now.year, now.month, now.day);

  final difference = eventDate.difference(today).inDays;

  if (difference == 0) return "Today";
  if (difference == 1) return "Tomorrow";
  if (difference > 1) return "$difference days left";
  if (difference == -1) return "Yesterday";
  return "${-difference} days ago";
}
