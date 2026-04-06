import 'dart:collection';

import 'package:explore_id/models/listTrip.dart';
import 'package:explore_id/pages/plan_helper/plan_helper_logic.dart';
import 'package:flutter/material.dart';

class PlanHelperProvider extends ChangeNotifier {
  final Set<String> _selectedCategories = {};
  final Set<String> _excludedCategories = {};
  final Set<String> _selectedPrices = {};
  final Set<String> _excludedPrices = {};

  Set<String> get selectedCategories => UnmodifiableSetView(_selectedCategories);
  Set<String> get excludedCategories => UnmodifiableSetView(_excludedCategories);
  Set<String> get selectedPrices => UnmodifiableSetView(_selectedPrices);
  Set<String> get excludedPrices => UnmodifiableSetView(_excludedPrices);

  List<PlanPreferenceCardData> get swipeCards => buildPlanHelperSwipeCards();

  void reset() {
    _selectedCategories.clear();
    _excludedCategories.clear();
    _selectedPrices.clear();
    _excludedPrices.clear();
    notifyListeners();
  }

  void handleSwipe(PlanPreferenceCardData card, AxisDirection direction) {
    final value = card.key.toLowerCase();

    if (direction == AxisDirection.right) {
      if (card.type == PlanPreferenceType.category) {
        _selectedCategories.add(value);
        _excludedCategories.remove(value);
      } else {
        _selectedPrices.add(value);
        _excludedPrices.remove(value);
      }
    } else if (direction == AxisDirection.left) {
      if (card.type == PlanPreferenceType.category) {
        _selectedCategories.remove(value);
        _excludedCategories.add(value);
      } else {
        _selectedPrices.remove(value);
        _excludedPrices.add(value);
      }
    }

    notifyListeners();
  }

  bool isPicked(PlanPreferenceCardData card) {
    final value = card.key.toLowerCase();
    return card.type == PlanPreferenceType.category
        ? _selectedCategories.contains(value)
        : _selectedPrices.contains(value);
  }

  bool isSkipped(PlanPreferenceCardData card) {
    final value = card.key.toLowerCase();
    return card.type == PlanPreferenceType.category
        ? _excludedCategories.contains(value)
        : _excludedPrices.contains(value);
  }

  List<ListTrip> filterTrips(List<ListTrip> allTrips) {
    return applyPlanHelperPreferenceFilter(
      allTrips: allTrips,
      selectedCategories: _selectedCategories,
      excludedCategories: _excludedCategories,
      selectedPrices: _selectedPrices,
      excludedPrices: _excludedPrices,
    );
  }
}