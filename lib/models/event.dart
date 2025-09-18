class Event {
  final String id; // <-- id untuk trip
  final String title;
  final String desk;
  final DateTime date; // <-- tambahkan ini
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
    required this.start,
    required this.end,
    required this.place,
    required this.label,
    this.isCheck = true,
    this.docId,
  });
}
