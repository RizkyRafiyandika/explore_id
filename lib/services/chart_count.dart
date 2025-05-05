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
