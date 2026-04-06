import 'package:explore_id/models/listTrip.dart';

enum PlanPreferenceType { category, price }

class PlanPreferenceCardData {
  final PlanPreferenceType type;
  final String key;

  const PlanPreferenceCardData({required this.type, required this.key});
}

const List<String> planHelperCategoryOptions = [
  'Mountain',
  'Culture',
  'Nature',
  'Culinary',
  'Beach',
  'Monument',
];

List<PlanPreferenceCardData> buildPlanHelperSwipeCards() {
  return [
    ...planHelperCategoryOptions.map(
      (label) =>
          PlanPreferenceCardData(type: PlanPreferenceType.category, key: label),
    ),
    const PlanPreferenceCardData(type: PlanPreferenceType.price, key: 'budget'),
    const PlanPreferenceCardData(
      type: PlanPreferenceType.price,
      key: 'standard',
    ),
    const PlanPreferenceCardData(
      type: PlanPreferenceType.price,
      key: 'premium',
    ),
  ];
}

List<ListTrip> applyPlanHelperPreferenceFilter({
  required List<ListTrip> allTrips,
  required Set<String> selectedCategories,
  required Set<String> excludedCategories,
  required Set<String> selectedPrices,
  required Set<String> excludedPrices,
}) {
  var result = allTrips;

  if (excludedCategories.isNotEmpty) {
    result =
        result
            .where(
              (trip) => !excludedCategories.contains(trip.label.toLowerCase()),
            )
            .toList();
  }

  if (excludedPrices.isNotEmpty) {
    result =
        result
            .where(
              (trip) =>
                  !excludedPrices.any(
                    (range) => matchesPriceRange(range, trip.harga),
                  ),
            )
            .toList();
  }

  if (selectedCategories.isNotEmpty) {
    result =
        result
            .where(
              (trip) => selectedCategories.contains(trip.label.toLowerCase()),
            )
            .toList();
  }

  if (selectedPrices.isNotEmpty) {
    result =
        result
            .where(
              (trip) => selectedPrices.any(
                (range) => matchesPriceRange(range, trip.harga),
              ),
            )
            .toList();
  }

  return result;
}

bool matchesPriceRange(String rangeKey, double price) {
  switch (rangeKey) {
    case 'budget':
      return price <= 100000;
    case 'standard':
      return price > 100000 && price <= 300000;
    case 'premium':
      return price > 300000;
    default:
      return false;
  }
}

String priceLabelFromKey(String key) {
  switch (key) {
    case 'budget':
      return 'Murah (<= 100K)';
    case 'standard':
      return 'Sedang (100K - 300K)';
    case 'premium':
      return 'Mahal (> 300K)';
    default:
      return key;
  }
}

String toTitleCase(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
