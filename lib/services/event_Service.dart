import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_id/models/event.dart';

Future<void> addEvents({
  required String userId,
  required List<Event> events,
}) async {
  try {
    for (Event e in events) {
      final docRef = await FirebaseFirestore.instance.collection("events").add({
        "userId": userId,
        "id": e.id,
        "title": e.title,
        "desk": e.desk,
        "date": Timestamp.fromDate(e.date),
        "start": e.start,
        "end": e.end,
        "place": e.place,
        "label": e.label,
        "ischeck": e.isCheck,
      });

      // Tambahkan ini:
      await docRef.update({"docId": docRef.id});

      print("✅ Event ditambahkan dengan docId: ${docRef.id}");
    }
  } catch (e) {
    print("❌ Error adding events: $e");
  }
}

Future<List<Event>> getEventsForDate({
  required String userId,
  required DateTime date,
}) async {
  try {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final querySnapshot =
        await FirebaseFirestore.instance
            .collection("events")
            .where("userId", isEqualTo: userId)
            .where(
              "date",
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .where("date", isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
            .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Event(
        id: data['id'],
        title: data['title'],
        desk: data['desk'],
        date: (data['date'] as Timestamp).toDate(),
        start: data['start'],
        end: data['end'],
        place: data['place'],
        label: data['label'],
        isCheck:
            data['isCheck'] ??
            false, // Ambil dari Firestore, default ke false jika null
        docId: doc.id,
      );
    }).toList();
  } catch (e) {
    print("❌ Error fetching events: $e");
    return [];
  }
}
