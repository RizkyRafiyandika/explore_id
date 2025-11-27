## Search Feature Architecture

Dokumentasi lengkap tentang fitur search untuk plan page dengan suggestions dropdown.

### Overview

Search feature telah direfactor untuk **menghindari auto-submit** yang memberikan UX buruk. Sekarang user harus **secara manual memilih** destination dari suggestions atau menekan tombol add/enter.

### Architecture

Search feature terdiri dari 4 komponen utama:

#### 1. **SearchSuggestionNotifier** (`providers/search_suggestion_notifier.dart`)
   - Mengelola state suggestions dan loading
   - Menangani debouncing pencarian (600ms)
   - Memisahkan logic pencarian dari destination management
   - **Benefit**: Mudah di-maintain dan di-extend untuk fitur search lainnya

```dart
// Usage dalam widget
final notifier = SearchSuggestionNotifier();

// User mengetik
notifier.searchLocations('Monas');

// Akses suggestions
List<LocationSuggestion> suggestions = notifier.suggestions;
bool isLoading = notifier.isLoading;
```

#### 2. **SearchBarWidget** (`widgets/search_bar_widget.dart`)
   - TextField dengan placeholder "Cari lokasi (manual submit saja)"
   - Tombol add circle untuk submit manual
   - Terintegrasi dengan `SearchSuggestionNotifier`
   - **NO AUTO-SUBMIT** pada `onChanged` - hanya untuk menampilkan suggestions
   - Manual submit via:
     - Tekan tombol add (IconButton)
     - Tekan Enter/Search di keyboard

```dart
SearchBarWidget(
  controller: controller,
  isSearching: isSearching,
  suggestionNotifier: notifier,
  onChanged: (value) {
    // Hanya trigger suggestions
    notifier.searchLocations(value);
  },
  onSuggestionSelected: (suggestion) {
    // User memilih dari dropdown
    handleAddDestination(suggestion);
  },
  onAddPressed: () {
    // User tekan tombol add
    handleManualSearch();
  },
)
```

#### 3. **SearchSuggestionsDropdown** (`widgets/search_bar_widget.dart`)
   - Menampilkan list suggestions dari notifier
   - Setiap item menampilkan:
     - Name (lokasi utama)
     - Full Address (jalan + kota, dll)
   - Tap untuk auto-select dan clear controller
   - Styling modern dengan border cyan dan shadow

```dart
SearchSuggestionsDropdown(
  notifier: notifier,
  onSuggestionSelected: (suggestion) {
    // Handle selection
  },
  controller: controller,
)
```

#### 4. **GraphHopperService** (`services/graphhopper_service.dart`)
   - Method lama: `searchLocation()` - return single result
   - **NEW Method**: `searchLocationSuggestions()` - return up to 5 results
   - Menggunakan Nominatim OpenStreetMap API
   - Fokus ke Indonesia (countrycodes=id)
   - Menambahkan address details untuk display yang lebih baik

```dart
// Get multiple suggestions
final suggestions = await GraphHopperService.searchLocationSuggestions(
  'Monas',
  limit: 5, // Max results
);

// Each suggestion has:
// - id: place_id dari Nominatim
// - name: Location name (e.g., 'Monas')
// - fullAddress: Full address for display
// - latitude, longitude: Coordinates
```

### Data Flow

```
User mengetik
    ↓
SearchBarWidget.onChanged()
    ↓
SearchSuggestionNotifier.searchLocations()
    ↓
Debounce 600ms
    ↓
GraphHopperService.searchLocationSuggestions()
    ↓
Query Nominatim API
    ↓
Parse results → List<LocationSuggestion>
    ↓
notifyListeners()
    ↓
SearchSuggestionsDropdown rebuild
    ↓
User melihat suggestions
```

### User Workflows

#### Workflow 1: Memilih dari Suggestions
```
1. User mengetik "Monas"
2. Suggestions muncul (3-5 lokasi relevan)
3. User tap salah satu suggestion
4. Destination langsung ditambahkan ke route
5. Controller di-clear, suggestions di-clear
```

#### Workflow 2: Manual Submit dengan Enter
```
1. User mengetik "Monas"
2. Suggestions muncul
3. User tekan Enter di keyboard
4. Lokasi pertama dari Nominatim di-add
5. Controller di-clear, suggestions di-clear
```

#### Workflow 3: Manual Submit dengan Tombol
```
1. User mengetik "Monas"
2. Suggestions muncul
3. User tap tombol add (circular button)
4. Lokasi pertama dari Nominatim di-add
5. Controller di-clear, suggestions di-clear
```

### Implementation in PlanScreen

```dart
class _PlanScreenState extends State<PlanScreen> {
  late SearchSuggestionNotifier _searchSuggestionNotifier;

  @override
  void initState() {
    _searchSuggestionNotifier = SearchSuggestionNotifier();
    // ...
  }

  @override
  void dispose() {
    _searchSuggestionNotifier.dispose();
    // ...
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ... map, toolbar, etc
        
        // Search bar (tanpa auto-submit)
        SearchBarWidget(
          controller: _destinationController,
          isSearching: provider.isSearching,
          suggestionNotifier: _searchSuggestionNotifier,
          onChanged: (value) {
            // Only update suggestions, no auto-submit
          },
          onSuggestionSelected: (suggestion) async {
            // User selected from dropdown
            await provider.addDestinationFromSuggestion(
              suggestion.name,
              suggestion.latitude,
              suggestion.longitude,
            );
            _destinationController.clear();
            customToast("Destinasi ditambahkan: ${suggestion.name}");
          },
          onAddPressed: () async {
            // User pressed add button or Enter
            await _handleManualSearch(provider, _destinationController.text);
          },
        ),

        // Suggestions dropdown
        SearchSuggestionsDropdown(
          notifier: _searchSuggestionNotifier,
          onSuggestionSelected: (suggestion) async {
            // Same as SearchBarWidget.onSuggestionSelected
            // ...
          },
          controller: _destinationController,
        ),
      ],
    );
  }
}
```

### Provider Changes

#### PlanProvider Updates:
- ❌ **REMOVED**: `searchWithDebounce()` - moved to SearchSuggestionNotifier
- ✅ **NEW**: `addDestinationFromSuggestion(name, lat, lng)` - add destination dari suggestion
- ✅ **KEPT**: `searchAndAddDestination(query)` - untuk fallback manual search

```dart
// Contoh usage:
await provider.addDestinationFromSuggestion(
  'Monas',
  -6.1751,
  106.8249,
);
```

### Maintenance & Extension

#### Untuk menambah fitur baru di search:

1. **Tambah state ke SearchSuggestionNotifier**:
```dart
class SearchSuggestionNotifier extends ChangeNotifier {
  // Tambah state baru
  List<String> _recentSearches = [];
  
  List<String> get recentSearches => List.unmodifiable(_recentSearches);
  
  void addRecentSearch(String query) {
    _recentSearches.insert(0, query);
    notifyListeners();
  }
}
```

2. **Update SearchBarWidget untuk tampilkan recent searches**:
```dart
// Di SearchBarWidget atau buat RecentSearchesDropdown baru
if (_destinationController.text.isEmpty) {
  return RecentSearchesDropdown(
    notifier: widget.suggestionNotifier,
    // ...
  );
}
```

3. **Add method di GraphHopperService**:
```dart
static Future<List<String>> getSearchHistory() {
  // ...
}
```

### Benefits of This Architecture

✅ **Separation of Concerns**: Search logic terpisah dari destination management
✅ **Easy Maintenance**: SearchSuggestionNotifier bisa di-reuse di screen lain
✅ **Better UX**: Tidak ada auto-submit yang mengganggu
✅ **Extensible**: Mudah tambah fitur seperti recent searches, favorites, dll
✅ **Performance**: Debouncing mencegah terlalu banyak API calls
✅ **Testable**: Setiap komponen bisa di-test terpisah

### API Reference

#### SearchSuggestionNotifier

```dart
// Search dengan debounce
Future<void> searchLocations(String query)

// Clear suggestions dan error
void clearSuggestions()

// Clear error messages
void clearError()

// Getters
List<LocationSuggestion> get suggestions
bool get isLoading
String get lastQuery
String? get error
bool get hasSuggestions
```

#### LocationSuggestion Model

```dart
class LocationSuggestion {
  final String id;              // place_id dari Nominatim
  final String name;            // Nama lokasi
  final String fullAddress;     // Full address untuk display
  final double latitude;
  final double longitude;
}
```

#### GraphHopperService.searchLocationSuggestions()

```dart
/// Cari lokasi dengan multiple results
/// @param query - Search query (e.g., 'Monas, Jakarta')
/// @param limit - Max results (default 5)
/// @return List<Map> dengan keys: id, name, fullAddress, latitude, longitude
static Future<List<Map<String, dynamic>>?> searchLocationSuggestions(
  String query,
  {int limit = 5}
)
```

### Troubleshooting

#### Suggestions tidak muncul
- Cek network connectivity
- Cek query yang dikirim (harus tidak kosong setelah trim)
- Lihat console untuk error message dari Nominatim

#### Performance issue / Terlalu banyak API calls
- Debounce duration sudah 600ms
- Jika perlu lebih lambat, ubah di SearchSuggestionNotifier:
```dart
static const _debounceDuration = Duration(milliseconds: 800); // Lebih lambat
```

#### Suggestions dropdown tidak hilang
- Panggil `notifier.clearSuggestions()` setelah selection
- Atau panggil ketika controller di-clear

---

**Terakhir diupdate**: 2025-11-27  
**Status**: Production Ready ✅
