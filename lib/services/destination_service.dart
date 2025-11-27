import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_id/models/listTrip.dart';

Future<List<ListTrip>> getDestinations(String userId) async {
  try {
    final querySnapshot =
        await FirebaseFirestore.instance.collection("destinations").get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return ListTrip(
        id: data['id'],
        imagePath: data['imagePath'],
        name: data['name'],
        daerah: data['daerah'],
        label: data['label'],
        desk: data['desk'],
        latitude: data['latitude'],
        longitude: data['longitude'],
        harga: data['harga'],
        userId: data['userId'],
      );
    }).toList();
  } catch (e) {
    print("❌ Error fetching destinations: $e");
    return [];
  }
}

Future<void> uploadListTripToFirestore(List<ListTrip> list) async {
  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('destinations');

  for (final trip in list) {
    try {
      await collection.doc(trip.id).set({
        'id': trip.id,
        'imagePath': trip.imagePath,
        'name': trip.name,
        'daerah': trip.daerah,
        'label': trip.label,
        'desk': trip.desk,
        'latitude': trip.latitude,
        'longitude': trip.longitude,
        'harga': trip.harga,
        'userId': trip.userId,
      });
      print("✅ Uploaded: ${trip.name}");
    } catch (e) {
      print("❌ Failed to upload ${trip.name}: $e");
    }
  }
}

Future<void> addDestination(ListTrip trip) async {
  try {
    await FirebaseFirestore.instance
        .collection('destinations')
        .doc(trip.id)
        .set({
          'id': trip.id,
          'imagePath': trip.imagePath,
          'name': trip.name,
          'daerah': trip.daerah,
          'label': trip.label,
          'desk': trip.desk,
          'latitude': trip.latitude,
          'longitude': trip.longitude,
          'harga': trip.harga,
          'userId': trip.userId,
        });
    print("✅ Destination added: ${trip.name}");
  } catch (e) {
    print("❌ Failed to add destination: $e");
    throw e;
  }
}
