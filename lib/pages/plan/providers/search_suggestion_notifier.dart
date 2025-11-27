import 'dart:async';
import 'package:flutter/material.dart';
import '../services/graphhopper_service.dart';

/// Model untuk suggestion lokasi
class LocationSuggestion {
  final String id;
  final String name;
  final String fullAddress;
  final double latitude;
  final double longitude;

  LocationSuggestion({
    required this.id,
    required this.name,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
  });
}

/// Notifier untuk mengelola search suggestions
/// Memisahkan logic pencarian dari destination management
/// Ini membuat search feature mudah di-maintain dan di-extend
class SearchSuggestionNotifier extends ChangeNotifier {
  // ===== STATE =====
  List<LocationSuggestion> _suggestions = [];
  bool _isLoading = false;
  String _lastQuery = '';
  String? _error;

  // Debounce timer untuk search
  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 600);

  // ===== GETTERS =====
  List<LocationSuggestion> get suggestions => List.unmodifiable(_suggestions);
  bool get isLoading => _isLoading;
  String get lastQuery => _lastQuery;
  String? get error => _error;
  bool get hasSuggestions => _suggestions.isNotEmpty;

  // ===== PUBLIC METHODS =====

  /// Cari lokasi berdasarkan query dengan debounce
  /// Tidak akan auto-submit, hanya menampilkan suggestions
  Future<void> searchLocations(String query) async {
    _debounceTimer?.cancel();

    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      clearSuggestions();
      return;
    }

    _lastQuery = trimmedQuery;

    _debounceTimer = Timer(_debounceDuration, () async {
      await _fetchSuggestions(trimmedQuery);
    });
  }

  /// Clear suggestions dan error
  void clearSuggestions() {
    _suggestions.clear();
    _error = null;
    _lastQuery = '';
    notifyListeners();
  }

  /// Clear error messages
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ===== PRIVATE METHODS =====

  /// Fetch suggestions dari GraphHopper/Nominatim
  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await GraphHopperService.searchLocationSuggestions(
        query,
        limit: 5, // Tampilkan max 5 suggestions
      );

      if (results != null && results.isNotEmpty) {
        // Convert Map to LocationSuggestion objects
        _suggestions =
            results
                .map(
                  (item) => LocationSuggestion(
                    id: item['id'] as String,
                    name: item['name'] as String,
                    fullAddress: item['fullAddress'] as String,
                    latitude: item['latitude'] as double,
                    longitude: item['longitude'] as double,
                  ),
                )
                .toList();
        _error = null;
      } else {
        _suggestions = [];
        _error = 'Lokasi tidak ditemukan untuk "$query"';
      }
    } catch (e) {
      _suggestions = [];
      _error = 'Gagal mencari lokasi: $e';
      print('❌ Search error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
