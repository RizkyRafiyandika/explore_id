import 'package:explore_id/models/listTrip.dart';
import 'package:explore_id/services/likes_Service.dart';
import 'package:flutter/widgets.dart';

class MytripProvider with ChangeNotifier {
  List<ListTrip> _allTrips = [];
  List<ListTrip> _filteredTrips = [];

  final Map<String, bool> _likeStatus = {}; // key: trip.id

  String _filterType = 'Nama'; // Default filter

  List<ListTrip> get allTrip => _allTrips;
  List<ListTrip> get filteredTrip => _filteredTrips;

  void setTrips(List<ListTrip> trip) {
    _allTrips = trip;
    _filteredTrips = trip;
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
      notifyListeners();
    } catch (e) {
      throw Exception("Gagal mengubah status like");
    }
  }
}
