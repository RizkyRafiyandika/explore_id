import 'package:explore_id/models/listTrip.dart';
import 'package:explore_id/models/plan_option_model.dart';

enum PlanPreferenceType { category, price }

class PlanPreferenceCardData {
  final PlanPreferenceType type;
  final String key;
  final String? title; // Optional override for the display title

  const PlanPreferenceCardData({
    required this.type,
    required this.key,
    this.title,
  });

  // Factory to create from PlanOption model
  factory PlanPreferenceCardData.fromModel(PlanOption model) {
    return PlanPreferenceCardData(
      type:
          model.type == 'price'
              ? PlanPreferenceType.price
              : PlanPreferenceType.category,
      key: model.key,
      title: model.title,
    );
  }
}

/// Helper to convert a list of Firestore PlanOptions to the UI card format.
List<PlanPreferenceCardData> buildPlanHelperSwipeCards(
  List<PlanOption> options,
) {
  if (options.isEmpty) return [];
  return options.map((opt) => PlanPreferenceCardData.fromModel(opt)).toList();
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
