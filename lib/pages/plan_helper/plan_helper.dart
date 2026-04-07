import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:explore_id/pages/detailPlace.dart';
import 'package:explore_id/pages/plan_helper/plan_helper_card.dart';
import 'package:explore_id/pages/plan_helper/plan_helper_logic.dart';
import 'package:explore_id/provider/plan_helper_provider.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MytripProvider>(context, listen: false);
      if (provider.allTrip.isEmpty) {
        provider.loadTripsFromFirestore();
      }

      // Fetch swipe cards from Firestore
      final planHelperProvider = Provider.of<PlanHelperProvider>(
        context,
        listen: false,
      );
      planHelperProvider.fetchPlanOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MytripProvider>(context);
    final planHelperProvider = Provider.of<PlanHelperProvider>(context);
    final filtered = planHelperProvider.filterTrips(provider.allTrip);
    final cards = planHelperProvider.swipeCards;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Perencanaan Perjalanan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    planHelperProvider.reset();
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
            SizedBox(
              height: 280,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child:
                    planHelperProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : planHelperProvider.swipeCards.isEmpty
                        ? const Center(child: Text('Tidak ada data kartu.'))
                        : AppinioSwiper(
                          cardCount: cards.length,
                          backgroundCardCount: 1,
                          swipeOptions: const SwipeOptions.only(
                            left: true,
                            right: true,
                          ),
                          onSwipeEnd: (
                            int previousIndex,
                            int targetIndex,
                            SwiperActivity activity,
                          ) {
                            if (activity is! Swipe) return;
                            final card = cards[previousIndex];
                            planHelperProvider.handleSwipe(
                              card,
                              activity.direction,
                            );
                          },
                          cardBuilder: (context, index) {
                            final card = cards[index];
                            return PlanHelperPreferenceCard(
                              card: card,
                              picked: planHelperProvider.isPicked(card),
                              skipped: planHelperProvider.isSkipped(card),
                            );
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
                  ...planHelperProvider.selectedCategories.map(
                    (cat) => Chip(label: Text(toTitleCase(cat))),
                  ),
                  ...planHelperProvider.excludedCategories.map(
                    (cat) => Chip(label: Text('Lewati: ${toTitleCase(cat)}')),
                  ),
                  ...planHelperProvider.selectedPrices.map(
                    (price) => Chip(label: Text(priceLabelFromKey(price))),
                  ),
                  ...planHelperProvider.excludedPrices.map(
                    (price) => Chip(
                      label: Text('Lewati: ${priceLabelFromKey(price)}'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Hasil Perencanaan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
      ),
    );
  }
}
