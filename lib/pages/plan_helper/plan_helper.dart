import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:explore_id/pages/detailPlace.dart';
import 'package:explore_id/pages/plan_helper/plan_helper_card.dart';
import 'package:explore_id/pages/plan_helper/plan_helper_logic.dart';
import 'package:explore_id/provider/plan_helper_provider.dart';
import 'package:explore_id/provider/tripProvider.dart';
import 'package:explore_id/widget/listTripCard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:explore_id/colors/color.dart';
import 'package:explore_id/models/listTrip.dart';

enum PlanViewState { swiping, loading, results }

class PlanHelper extends StatefulWidget {
  const PlanHelper({super.key});

  @override
  State<PlanHelper> createState() => _PlanHelperState();
}

class _PlanHelperState extends State<PlanHelper> {
  PlanViewState _viewState = PlanViewState.swiping;

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: _buildBody(planHelperProvider, cards, filtered),
        ),
      ),
    );
  }

  Widget _buildBody(
    PlanHelperProvider planHelperProvider,
    List<PlanPreferenceCardData> cards,
    List<ListTrip> filtered,
  ) {
    if (_viewState == PlanViewState.swiping) {
      return _buildSwipingView(planHelperProvider, cards);
    } else if (_viewState == PlanViewState.loading) {
      return _buildLoadingView();
    } else {
      return _buildResultsView(planHelperProvider, filtered);
    }
  }

  void _onCardsFinished() {
    setState(() {
      _viewState = PlanViewState.loading;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _viewState = PlanViewState.results;
        });
      }
    });
  }

  Widget _buildSwipingView(
    PlanHelperProvider planHelperProvider,
    List<PlanPreferenceCardData> cards,
  ) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Swipe kartu untuk memilih preferensi perjalanan kamu.',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        SizedBox(
          height: 280,
          width: MediaQuery.of(context).size.width * 0.85,
          child:
              planHelperProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : cards.isEmpty
                  ? const Center(child: Text('Tidak ada data kartu.'))
                  : AppinioSwiper(
                    cardCount: cards.length,
                    backgroundCardCount: 1,
                    onEnd: _onCardsFinished,
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
                      planHelperProvider.handleSwipe(card, activity.direction);
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
        const Spacer(),
        TextButton(
          onPressed: () {
            if (cards.isNotEmpty) {
              _onCardsFinished();
            }
          },
          child: const Text('Selesai Memilih', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: tdcyan),
          const SizedBox(height: 32),
          const Text(
            'Kami akan rencanakan\nberdasarkan pilihanmu...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 64), // Offset to visually center better
        ],
      ),
    );
  }

  Widget _buildResultsView(
    PlanHelperProvider planHelperProvider,
    List<ListTrip> filtered,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hasil Perencanaan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {
                planHelperProvider.reset();
                setState(() {
                  _viewState = PlanViewState.swiping;
                });
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (planHelperProvider.selectedCategories.isNotEmpty ||
            planHelperProvider.selectedPrices.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...planHelperProvider.selectedCategories.map(
                  (cat) => Chip(
                    label: Text(
                      toTitleCase(cat),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: tdcyan.withValues(alpha: 0.1),
                    side: BorderSide(color: tdcyan.withValues(alpha: 0.3)),
                  ),
                ),
                ...planHelperProvider.selectedPrices.map(
                  (price) => Chip(
                    label: Text(
                      priceLabelFromKey(price),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: tdcyan.withValues(alpha: 0.1),
                    side: BorderSide(color: tdcyan.withValues(alpha: 0.3)),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child:
              filtered.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Wah, belum ada destinasi\nyang pas dengan pilihanmu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            planHelperProvider.reset();
                            setState(() {
                              _viewState = PlanViewState.swiping;
                            });
                          },
                          child: const Text('Coba Pilihan Lain'),
                        ),
                        const SizedBox(height: 64),
                      ],
                    ),
                  )
                  : GridView.builder(
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
                              builder: (context) => MyDetailPlace(trip: trip),
                            ),
                          );
                        },
                        child: TripCardGridItem(trip: trip),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
