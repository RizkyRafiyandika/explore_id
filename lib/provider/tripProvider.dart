import 'package:explore_id/models/listTrip.dart';
import 'package:explore_id/services/likes_Service.dart';
import 'package:flutter/widgets.dart';

class MytripProvider with ChangeNotifier {
  List<ListTrip> _allTrips = [];
  List<ListTrip> _filteredTrips = [];
  List<ListTrip> _selectedTrips = [];
  List<ListTrip> _categoryTrips = [];

  final Map<String, bool> _likeStatus = {}; // key: trip.id
  final Map<String, int> _likeCount = {}; // key: trip.id

  String _filterType = 'Nama'; // Default filter

  List<ListTrip> get allTrip => _allTrips;
  List<ListTrip> get filteredTrip => _filteredTrips;
  List<ListTrip> get selectedTrips => _selectedTrips;
  List<ListTrip> get categoryTrips => _categoryTrips;

  Future<void> loadTripsFromFirestore() async {
    try {
      final trips = await ListTrip.getDestinations(); // Ambil dari Firestore
      setTrips(trips); // Set ke state
      await fetchLikeStatus(); // Ambil status like untuk setiap trip
    } catch (e) {
      print("❌ Gagal mengambil data trip: $e");
    }
  }

  void setTrips(List<ListTrip> trip) {
    _allTrips = trip;
    _filteredTrips = trip;
    _selectedTrips = List.from(_allTrips)..shuffle();
    _selectedTrips = _selectedTrips.take(4).toList(); // ambil 4 random
    notifyListeners();
  }

  void filterByCategory(String category) {
    _categoryTrips =
        _allTrips
            .where((trip) => trip.label.toLowerCase() == category.toLowerCase())
            .toList();
    notifyListeners();
  }

  void setFilterType(String type) {
    _filterType = type;
    notifyListeners();
  }

  void runFilter(String query) {
    if (query.isNotEmpty) {
      _filteredTrips =
          _allTrips.where((trip) {
            switch (_filterType) {
              case 'Nama':
                return trip.name.toLowerCase().contains(query.toLowerCase());
              case 'Daerah':
                return trip.daerah.toLowerCase().contains(query.toLowerCase());
              case 'Category':
                return trip.label.toLowerCase().contains(query.toLowerCase());
              default:
                return true;
            }
          }).toList();
    } else {
      _filteredTrips = _allTrips;
    }
    notifyListeners();
  }

  Future<void> fetchLikeStatus() async {
    for (var trip in _allTrips) {
      final status = await isTripLiked(trip.id);
      _likeStatus[trip.id] = status;
    }
    notifyListeners();
  }

  bool isTripLikedLocal(String tripId) => _likeStatus[tripId] ?? false;

  Future<void> toggleLike(String tripId) async {
    final currentStatus = _likeStatus[tripId] ?? false;

    try {
      if (currentStatus) {
        await unlikeTrip(tripId);
      } else {
        await likeTrip(tripId);
      }

      _likeStatus[tripId] = !currentStatus;
      await loadLikeCounts(tripId); // Update like count after toggling
      notifyListeners();
    } catch (e) {
      throw Exception("Gagal mengubah status like");
    }
  }

  int getTotalLikesLocal(String tripId) {
    return _likeCount[tripId] ?? 0;
  }

  Future<void> loadLikeCounts(String tripId) async {
    int total = await getTotalLikesForTrip(tripId);
    _likeCount[tripId] = total;
    notifyListeners();
  }
}
