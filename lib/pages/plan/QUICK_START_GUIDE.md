# Quick Start Guide - Search Feature

Panduan cepat untuk menggunakan dan maintain fitur search baru.

## 🎯 Apa yang Berubah?

**Sebelumnya (Auto-Submit)**:
```
User mengetik "Monas"
    ↓ (debounce 600ms)
    ↓ (AUTOMATIC SUBMIT)
Destination langsung ditambahkan
    ↓
User: "Eh wait, I'm still typing!" ❌ BAD UX
```

**Sekarang (Manual Submit + Suggestions)**:
```
User mengetik "Monas"
    ↓ (debounce 600ms)
Dropdown muncul dengan 5 suggestions
    ↓
User memilih salah satu / press Enter / click button
Destination ditambahkan
    ↓
User: "Perfect, I had control!" ✅ GOOD UX
```

---

## 📦 File Structure

```
lib/pages/plan/
├── providers/
│   ├── plan_provider.dart              ← Main state
│   └── search_suggestion_notifier.dart ← NEW: Search suggestions
├── screens/
│   └── plan_screen.dart                ← Updated integration
├── widgets/
│   ├── search_bar_widget.dart          ← Updated + new dropdown
│   ├── destination_list_item.dart
│   └── ...
├── services/
│   ├── graphhopper_service.dart        ← NEW: searchLocationSuggestions()
│   └── location_service.dart
├── models/
│   └── destination.dart
├── SEARCH_FEATURE_GUIDE.md             ← Full documentation
└── README.md
```

---

## 🚀 How It Works

### 1. User Mengetik
```dart
TextField(
  onChanged: (value) {
    notifier.searchLocations(value);  // Trigger search dengan debounce
  },
)
```

### 2. Notifier Debounce 600ms
```dart
Future<void> searchLocations(String query) {
  _debounceTimer?.cancel();
  _lastQuery = query;
  
  _debounceTimer = Timer(Duration(milliseconds: 600), () {
    _fetchSuggestions(query);  // Call API setelah 600ms
  });
}
```

### 3. GraphHopper Query Nominatim
```dart
// Query dengan limit=5
https://nominatim.openstreetmap.org/search
  ?q=Monas
  &format=json
  &limit=5
  &countrycodes=id
```

### 4. Parse & Convert
```dart
final results = await graphHopperService.searchLocationSuggestions(query);

// Convert ke LocationSuggestion objects
final suggestions = results.map((item) => LocationSuggestion(
  id: item['id'],
  name: item['name'],
  fullAddress: item['fullAddress'],
  latitude: item['latitude'],
  longitude: item['longitude'],
)).toList();
```

### 5. Display Dropdown
```dart
SearchSuggestionsDropdown(
  notifier: notifier,
  onSuggestionSelected: (suggestion) { ... },
)
```

### 6. User Tap Suggestion
```dart
InkWell(
  onTap: () {
    // Call parent callback
    onSuggestionSelected(suggestion);
    
    // Clear notifier
    notifier.clearSuggestions();
  },
)
```

### 7. Add Destination
```dart
await provider.addDestinationFromSuggestion(
  suggestion.name,
  suggestion.latitude,
  suggestion.longitude,
);
```

---

## 💻 Code Example

### Menggunakan di Screen Baru

```dart
class MySearchScreen extends StatefulWidget {
  @override
  State<MySearchScreen> createState() => _MySearchScreenState();
}

class _MySearchScreenState extends State<MySearchScreen> {
  final TextEditingController _controller = TextEditingController();
  late SearchSuggestionNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = SearchSuggestionNotifier();
  }

  @override
  void dispose() {
    _controller.dispose();
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        SearchBarWidget(
          controller: _controller,
          isSearching: false,
          suggestionNotifier: _notifier,
          onChanged: (value) {
            // Hanya untuk trigger suggestions
          },
          onSuggestionSelected: (suggestion) {
            print('Selected: ${suggestion.name}');
            _controller.text = suggestion.name;
            _notifier.clearSuggestions();
          },
          onAddPressed: () {
            print('Add pressed: ${_controller.text}');
          },
        ),

        // Suggestions dropdown
        SearchSuggestionsDropdown(
          notifier: _notifier,
          onSuggestionSelected: (suggestion) {
            print('Selected: ${suggestion.name}');
          },
          controller: _controller,
        ),
      ],
    );
  }
}
```

---

## 🔌 API Reference

### SearchSuggestionNotifier

```dart
// Methods
searchLocations(String query)      // Search dengan debounce
clearSuggestions()                 // Clear semua data
clearError()                       // Clear error message

// Getters
suggestions                        // List<LocationSuggestion>
isLoading                         // bool
lastQuery                         // String
error                             // String?
hasSuggestions                    // bool
```

### LocationSuggestion

```dart
class LocationSuggestion {
  final String id;              // Unique ID dari Nominatim
  final String name;            // Nama lokasi (e.g., 'Monas')
  final String fullAddress;     // Full address (e.g., 'Monas, Jakarta, Indonesia')
  final double latitude;        // Latitude
  final double longitude;       // Longitude
}
```

### PlanProvider - New Methods

```dart
// Add destination dari suggestion
Future<void> addDestinationFromSuggestion(
  String name,
  double latitude,
  double longitude,
)

// Old method (kept for backward compatibility)
Future<String?> searchAndAddDestination(String query)
```

### GraphHopperService - New Method

```dart
// Get multiple suggestions
static Future<List<Map<String, dynamic>>?> searchLocationSuggestions(
  String query,
  {int limit = 5}
)

// Returns null jika error atau empty
// Otherwise returns List<Map> dengan keys:
// - id: String
// - name: String
// - fullAddress: String
// - latitude: double
// - longitude: double
```

---

## ⚙️ Configuration

### Debounce Duration

Default: 600ms (di `SearchSuggestionNotifier`)

```dart
// Ubah ke file
static const _debounceDuration = Duration(milliseconds: 800); // Lebih lambat

// atau

static const _debounceDuration = Duration(milliseconds: 400); // Lebih cepat
```

### Suggestions Limit

Default: 5 suggestions (di `plan_screen.dart`)

```dart
// SearchSuggestionsDropdown muncul untuk max 5 lokasi
// Ubah di GraphHopperService call

final results = await GraphHopperService.searchLocationSuggestions(
  query,
  limit: 10,  // Tampilkan lebih banyak
);
```

### API Configuration

Nominatim settings (di `graphhopper_service.dart`):

```dart
final url = Uri.parse(
  'https://nominatim.openstreetmap.org/search'
  '?q=${Uri.encodeComponent(query)}'
  '&format=json'
  '&limit=$limit'
  '&countrycodes=id'        // Hanya Indonesia
  '&addressdetails=1',      // Include address details
);
```

---

## 🐛 Troubleshooting

### Issue: Suggestions tidak muncul

**Penyebab**: Network error atau query kosong

**Solusi**:
```dart
// Check di console untuk error message
I/flutter: 🔍 Searching suggestions for: "..."
I/flutter: ✅ Found 3 suggestions

// Atau error
E/flutter: ❌ Search error: Connection timeout
```

### Issue: Terlalu banyak API calls

**Penyebab**: Debounce tidak berfungsi

**Solusi**:
- Cek jika `searchLocations()` dipanggil berkali-kali di listener
- Tambah debounce duration

```dart
static const _debounceDuration = Duration(milliseconds: 800); // Lebih lambat
```

### Issue: Dropdown tidak hilang setelah selection

**Penyebab**: `clearSuggestions()` tidak dipanggil

**Solusi**:
```dart
onSuggestionSelected: (suggestion) async {
  // ... add destination ...
  _searchSuggestionNotifier.clearSuggestions(); // Add this!
  _destinationController.clear();
}
```

### Issue: TextField still auto-submits

**Penyebab**: `onSubmitted` callback masih auto-submit

**Solusi**: Pastikan `onSubmitted` hanya dipanggil dari keyboard Enter, tidak dari `onChanged`:

```dart
// ✅ CORRECT
TextField(
  onChanged: (value) {
    // Hanya untuk UI update, tidak submit
    notifier.searchLocations(value);
  },
  onSubmitted: (value) {
    // Manual submit via Enter key
    handleManualSearch(value);
  },
)

// ❌ WRONG - jangan lakukan ini
TextField(
  onChanged: (value) async {
    await handleSearch(value);  // AUTO-SUBMIT! Bad UX
  },
)
```

---

## 📊 Performance Tips

1. **Debouncing**: Prevent excessive API calls
   ```dart
   // Default 600ms - good balance
   // Increase untuk slower network
   // Decrease untuk faster response
   ```

2. **Limit Results**: Max 5 suggestions untuk better UX
   ```dart
   limit: 5  // Not too many untuk scroll
   ```

3. **Cache Recent Searches**: (optional)
   ```dart
   // Add to notifier
   List<String> _recentSearches = [];
   
   // Show when text is empty
   if (controller.text.isEmpty) {
     showRecentSearches();
   }
   ```

---

## 🧪 Testing

### Unit Tests untuk Notifier

```dart
test('searchLocations debounce works', () async {
  final notifier = SearchSuggestionNotifier();
  
  notifier.searchLocations('Monas');
  expect(notifier.suggestions, isEmpty); // Immediately empty
  
  await Future.delayed(Duration(milliseconds: 700)); // Wait for debounce
  expect(notifier.suggestions, isNotEmpty); // Now has data
});

test('clearSuggestions clears everything', () {
  notifier.searchLocations('Monas');
  notifier.clearSuggestions();
  
  expect(notifier.suggestions, isEmpty);
  expect(notifier.error, isNull);
});
```

### Widget Tests untuk SearchBar

```dart
testWidgets('SearchBar shows add button', (tester) async {
  await tester.pumpWidget(
    SearchBarWidget(
      controller: TextEditingController(),
      isSearching: false,
      suggestionNotifier: SearchSuggestionNotifier(),
      onChanged: (_) {},
      onSuggestionSelected: (_) {},
      onAddPressed: () {},
    ),
  );
  
  expect(find.byIcon(Icons.add_circle), findsOneWidget);
});

testWidgets('Dropdown appears with suggestions', (tester) async {
  final notifier = SearchSuggestionNotifier();
  // ... seed notifier dengan suggestions ...
  
  await tester.pumpWidget(
    SearchSuggestionsDropdown(
      notifier: notifier,
      onSuggestionSelected: (_) {},
      controller: TextEditingController(),
    ),
  );
  
  expect(find.byType(InkWell), findsWidgets); // Suggestion items
});
```

---

## 📚 Related Documentation

- [`SEARCH_FEATURE_GUIDE.md`](./lib/pages/plan/SEARCH_FEATURE_GUIDE.md) - Full technical documentation
- [`search_suggestion_notifier.dart`](./lib/pages/plan/providers/search_suggestion_notifier.dart) - Source code dengan comments
- [`search_bar_widget.dart`](./lib/pages/plan/widgets/search_bar_widget.dart) - Widget implementation

---

## 🎓 Learning Resources

### Concepts Used

1. **Debouncing Pattern**
   - Prevent excessive API calls
   - Good for search, autocomplete, form validation

2. **Provider Pattern**
   - ChangeNotifier untuk state management
   - Reusable across screens

3. **Composition**
   - SearchBar + Dropdown = Complete search UX
   - Can be reused independently

4. **Clean Architecture**
   - Services (GraphHopperService) untuk API
   - Notifier untuk business logic
   - Widgets untuk UI

---

## ✅ Checklist - Sebelum Deploy

- [ ] App builds without errors
- [ ] Search suggestions muncul saat mengetik
- [ ] No auto-submit pada `onChanged`
- [ ] 3 ways to submit: dropdown, Enter key, button
- [ ] Dropdown hilang setelah selection
- [ ] Toast message tampil
- [ ] Input di-clear setelah submission
- [ ] Route kalkulasi ulang dengan destination baru
- [ ] Error handling untuk not found
- [ ] No excessive API calls (check network tab)
- [ ] Mobile responsive (test di phone/tablet)

---

## 📞 Support

Jika ada pertanyaan atau issue:

1. Check `SEARCH_FEATURE_GUIDE.md` untuk detail lengkap
2. Check console logs untuk error message
3. Check notifier state: `_suggestions`, `_isLoading`, `_error`
4. Check API response dari Nominatim

---

**Version**: 1.0  
**Status**: ✅ Production Ready  
**Last Updated**: 2025-11-27
