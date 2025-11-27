import 'package:explore_id/colors/color.dart';
import 'package:explore_id/pages/detailPlace.dart';
import 'package:explore_id/provider/tripProvider.dart';
import 'package:explore_id/widget/listTripCard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyBrowser extends StatefulWidget {
  final String? initialQuery;
  const MyBrowser({super.key, this.initialQuery});

  @override
  State<MyBrowser> createState() => _MyBrowserState();
}

class _MyBrowserState extends State<MyBrowser> {
  final TextEditingController browserController = TextEditingController();
  String selectedFilter = "All";
  final List<String> filterOptions = [
    "All",
    "Mountain",
    "Culture",
    "Nature",
    "Culinary",
    "Beach",
    "Monument",
  ];

  @override
  void initState() {
    super.initState();
    // initialize with provided initial query if available
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      browserController.text = widget.initialQuery!;
      // run the filter initially
      // run the filter after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<MytripProvider>(
          context,
          listen: false,
        ).runFilter(widget.initialQuery!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = Provider.of<MytripProvider>(context);
    final trips = tripProvider.filteredTrip;
    final filteredTrips =
        selectedFilter == "All"
            ? trips
            : trips
                .where(
                  (trip) =>
                      trip.label.toLowerCase() == selectedFilter.toLowerCase(),
                )
                .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          height: 50,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: browserController,
                    onChanged: (val) => tripProvider.runFilter(val),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: tdwhitepure,
                      hintText: "Search...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children:
                  filterOptions.map((filter) {
                    final isSelected = selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: GestureDetector(
                        onTap: () => setState(() => selectedFilter = filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? tdcyan : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? tdcyan : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          Expanded(
            child:
                filteredTrips.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "No destinations found",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Try different search terms",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                    : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: GridView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: filteredTrips.length,
                        itemBuilder: (context, index) {
                          final trip = filteredTrips[index];
                          return GestureDetector(
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => MyDetailPlace(trip: trip),
                                  ),
                                ),
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

  // old _browserField removed — replaced by inline AppBar search and body
}
