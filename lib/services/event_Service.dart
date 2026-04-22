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
        "endDate": Timestamp.fromDate(e.endDate),
        "start": e.start,
        "end": e.end,
        "place": e.place,
        "label": e.label,
        "isCheck": e.isCheck,
      });

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

    // Query events that start on or before the target day
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection("events")
            .where("userId", isEqualTo: userId)
            .where(
              "date",
              isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
            )
            .get();

    // Filter client-side to ensure they also end on or after the target day
    return querySnapshot.docs.where((doc) {
      final data = doc.data();
      final eventEndDate = (data['endDate'] as Timestamp).toDate();
      final normalizedEndDate = DateTime(eventEndDate.year, eventEndDate.month, eventEndDate.day);
      return normalizedEndDate.isAtSameMomentAs(startOfDay) || normalizedEndDate.isAfter(startOfDay);
    }).map((doc) {
      final data = doc.data();
      return Event(
        id: data['id'],
        title: data['title'],
        desk: data['desk'],
        date: (data['date'] as Timestamp).toDate(),
        endDate: (data['endDate'] as Timestamp).toDate(),
        start: data['start'],
        end: data['end'],
        place: data['place'],
        label: data['label'],
        isCheck: data['isCheck'] ?? false, 
        docId: doc.id,
      );
    }).toList();
  } catch (e) {
    print("❌ Error fetching events: $e");
    return [];
  }
}

Future<void> updateEvent(Event event) async {
  if (event.docId == null) return;
  try {
    await FirebaseFirestore.instance.collection("events").doc(event.docId).update({
      "title": event.title,
      "desk": event.desk,
      "date": Timestamp.fromDate(event.date),
      "endDate": Timestamp.fromDate(event.endDate),
      "start": event.start,
      "end": event.end,
      "isCheck": event.isCheck,
    });
    print("✅ Event updated: ${event.docId}");
  } catch (e) {
    print("❌ Error updating event: $e");
    rethrow;
  }
}

Future<void> deleteEvent(String docId) async {
  try {
    await FirebaseFirestore.instance.collection("events").doc(docId).delete();
    print("✅ Event deleted: $docId");
  } catch (e) {
    print("❌ Error deleting event: $e");
    rethrow;
  }
}
