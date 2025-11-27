import 'package:explore_id/models/listTrip.dart';
import 'package:explore_id/services/likes_Service.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MytripProvider with ChangeNotifier {
  List<ListTrip> _allTrips = [];
  List<ListTrip> _filteredTrips = [];
  List<ListTrip> _selectedTrips = [];
  List<ListTrip> _categoryTrips = [];

  final Map<String, bool> _likeStatus = {}; // key: trip.id
  final Map<String, int> _likeCount = {}; // key: trip.id
  bool _hasNewLikes = false;
  int _currentLikedCount = 0;
  int _lastSeenLikedCount = 0;
  StreamSubscription<QuerySnapshot>? _likeStreamSub;

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

  String get filterType => _filterType;

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
    // Also update the current user's liked count and check for new likes
    await _updateCurrentUserLikedCount();
    // Start real-time listener if not already started
    _startLikesListener();
    notifyListeners();
  }

  void _startLikesListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (_likeStreamSub != null) return;

    _likeStreamSub = FirebaseFirestore.instance
        .collection('likes')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) async {
          _currentLikedCount = snapshot.size;
          final prefs = await SharedPreferences.getInstance();
          final key = 'last_seen_likes_count_${user.uid}';
          if (!prefs.containsKey(key)) {
            await prefs.setInt(key, _currentLikedCount);
            _lastSeenLikedCount = _currentLikedCount;
            _hasNewLikes = false;
          } else {
            _lastSeenLikedCount = prefs.getInt(key) ?? 0;
            _hasNewLikes = _currentLikedCount > _lastSeenLikedCount;
          }
          notifyListeners();
        });
  }

  bool get hasNewLikes => _hasNewLikes;

  Future<void> _updateCurrentUserLikedCount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _currentLikedCount = 0;
        _hasNewLikes = false;
        return;
      }

      final snapshot =
          await FirebaseFirestore.instance
              .collection('likes')
              .where('userId', isEqualTo: user.uid)
              .get();
      _currentLikedCount = snapshot.size;

      // Load last seen count
      final prefs = await SharedPreferences.getInstance();
      final key = 'last_seen_likes_count_${user.uid}';
      if (!prefs.containsKey(key)) {
        // first run: mark currently existing liked items as seen so indicator won't
        // show a false positive
        await prefs.setInt(key, _currentLikedCount);
        _lastSeenLikedCount = _currentLikedCount;
        _hasNewLikes = false;
      } else {
        _lastSeenLikedCount = prefs.getInt(key) ?? 0;
        // if current is greater than last seen, user has new likes to check
        _hasNewLikes = _currentLikedCount > _lastSeenLikedCount;
      }
      notifyListeners();
    } catch (e) {
      print('Error updating liked count: $e');
    }
  }

  Future<void> markLikesSeen() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final key = 'last_seen_likes_count_${user.uid}';
    await prefs.setInt(key, _currentLikedCount);
    _lastSeenLikedCount = _currentLikedCount;
    _hasNewLikes = false;
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
      // Update user's liked count (and hasNewLikes logic)
      await _updateCurrentUserLikedCount();
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

  @override
  void dispose() {
    _likeStreamSub?.cancel();
    super.dispose();
  }
}
