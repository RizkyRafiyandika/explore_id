class Event {
  final String id; // <-- id untuk trip
  final String title;
  final String desk;
  final DateTime date; // <-- Start date
  final DateTime endDate; // <-- End date for multi-day support
  final String start;
  final String end;
  final String place;
  final String label;
  late bool isCheck;
  final String? docId;

  Event({
    required this.id,
    required this.title,
    required this.desk,
    required this.date,
    required this.endDate,
    required this.start,
    required this.end,
    required this.place,
    required this.label,
    this.isCheck = true,
    this.docId,
  });

  // Helper to check if this event covers a specific day
  bool occursOn(DateTime day) {
    final startDay = DateTime(date.year, date.month, date.day);
    final endDay = DateTime(endDate.year, endDate.month, endDate.day);
    final targetDay = DateTime(day.year, day.month, day.day);
    
    return (targetDay.isAtSameMomentAs(startDay) || targetDay.isAfter(startDay)) &&
           (targetDay.isAtSameMomentAs(endDay) || targetDay.isBefore(endDay));
  }
}
