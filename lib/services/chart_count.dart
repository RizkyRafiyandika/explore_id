import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, int>> getVisitedPlacesCount(String userId) async {
  final snapshot =
      await FirebaseFirestore.instance
          .collection('events') // ganti dengan nama koleksimu kalau beda
          .where('userId', isEqualTo: userId)
          .get();

  final placeCount = <String, int>{};

  for (var doc in snapshot.docs) {
    final place = doc['label'];
    if (place != null && place is String) {
      placeCount[place] = (placeCount[place] ?? 0) + 1;
    }
  }

  return placeCount;
}

Future<List<double>> getMonthlyVisitCounts(String userId) async {
  List<double> monthCounts = List.filled(12, 0); // index 0 = Jan, ..., 11 = Dec

  final snapshot =
      await FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: userId)
          .get();

  for (var doc in snapshot.docs) {
    final data = doc.data();
    if (data['date'] != null) {
      final timestamp = (data['date'] as Timestamp).toDate();
      int monthIndex = timestamp.month - 1;
      monthCounts[monthIndex]++;
    }
  }

  return monthCounts;
}
