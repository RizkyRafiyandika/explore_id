import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:explore_id/colors/color.dart';
import 'package:explore_id/models/listTrip.dart';
import 'package:explore_id/pages/detailPlace.dart';
import 'package:explore_id/provider/tripProvider.dart';
import 'package:explore_id/widget/listTripCard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlanHelper extends StatefulWidget {
  const PlanHelper({super.key});

  @override
  State<PlanHelper> createState() => _PlanHelperState();
}

class _PlanHelperState extends State<PlanHelper> {
  final Set<String> _selectedCategories = {};
  final Set<String> _selectedPrices = {};
  final List<String> _categoryOptions = const [
    'Mountain',
    'Culture',
    'Nature',
    'Culinary',
    'Beach',
    'Monument',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MytripProvider>(context, listen: false);
      if (provider.allTrip.isEmpty) {
        provider.loadTripsFromFirestore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MytripProvider>(context);
    final filtered = _applyPreferenceFilter(provider.allTrip);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Plan Helper'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Swipe kartu untuk pilih preferensi perjalanan kamu.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategories.clear();
                      _selectedPrices.clear();
                    });
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 280,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppinioSwiper(
                cardCount: _swipeCards.length,
                backgroundCardCount: 1,
                swipeOptions: const SwipeOptions.only(left: true, right: true),
                onSwipeEnd: (
                  int previousIndex,
                  int targetIndex,
                  SwiperActivity activity,
                ) {
                  if (activity is! Swipe) return;
                  final card = _swipeCards[previousIndex];
                  final value = card.key.toLowerCase();

                  setState(() {
                    if (activity.direction == AxisDirection.right) {
                      if (card.type == _PrefType.category) {
                        _selectedCategories.add(value);
                      } else {
                        _selectedPrices.add(value);
                      }
                    } else if (activity.direction == AxisDirection.left) {
                      if (card.type == _PrefType.category) {
                        _selectedCategories.remove(value);
                      } else {
                        _selectedPrices.remove(value);
                      }
                    }
                  });
                },
                cardBuilder: (context, index) {
                  final card = _swipeCards[index];
                  final picked =
                      card.type == _PrefType.category
                          ? _selectedCategories.contains(card.key.toLowerCase())
                          : _selectedPrices.contains(card.key.toLowerCase());
                  return _buildPreferenceCard(card, picked);
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._selectedCategories.map(
                  (cat) => Chip(label: Text(_toTitleCase(cat))),
                ),
                ..._selectedPrices.map(
                  (price) => Chip(label: Text(_priceLabelFromKey(price))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child:
                filtered.isEmpty
                    ? const Center(
                      child: Text(
                        'Belum ada hasil. Coba swipe kanan pada beberapa preferensi.',
                      ),
                    )
                    : Padding(
                      padding: const EdgeInsets.all(12),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final trip = filtered[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => MyDetailPlace(trip: trip),
                                ),
                              );
                            },
                            child: TripCardGridItem(trip: trip),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  List<ListTrip> _applyPreferenceFilter(List<ListTrip> allTrips) {
    var result = allTrips;

    if (_selectedCategories.isNotEmpty) {
      result =
          result
              .where(
                (trip) =>
                    _selectedCategories.contains(trip.label.toLowerCase()),
              )
              .toList();
    }

    if (_selectedPrices.isNotEmpty) {
      result =
          result
              .where(
                (trip) => _selectedPrices.any(
                  (range) => _matchesPriceRange(range, trip.harga),
                ),
              )
              .toList();
    }

    return result;
  }

  List<_PrefCardData> get _swipeCards {
    return [
      ..._categoryOptions.map(
        (label) => _PrefCardData(type: _PrefType.category, key: label),
      ),
      const _PrefCardData(type: _PrefType.price, key: 'budget'),
      const _PrefCardData(type: _PrefType.price, key: 'standard'),
      const _PrefCardData(type: _PrefType.price, key: 'premium'),
    ];
  }

  bool _matchesPriceRange(String rangeKey, double price) {
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

  String _priceLabelFromKey(String key) {
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

  String _toTitleCase(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  Widget _buildPreferenceCard(_PrefCardData card, bool picked) {
    final isPrice = card.type == _PrefType.price;
    final title = isPrice ? _priceLabelFromKey(card.key) : card.key;
    final subtitle = isPrice ? 'Rentang Harga' : 'Kategori Destinasi';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            tdcyan.withValues(alpha: 0.92),
            tdcyan.withValues(alpha: 0.64),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: tdcyan.withValues(alpha: 0.26),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                subtitle,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              picked ? 'Dipilih' : 'Swipe kanan untuk pilih',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Icon(Icons.swipe_left, color: Colors.white70, size: 16),
                SizedBox(width: 4),
                Text('Lewati', style: TextStyle(color: Colors.white70)),
                SizedBox(width: 12),
                Icon(Icons.swipe_right, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text('Pilih', style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _PrefType { category, price }

class _PrefCardData {
  final _PrefType type;
  final String key;

  const _PrefCardData({required this.type, required this.key});
}
