import 'package:explore_id/colors/color.dart';
import 'package:explore_id/models/listTrip.dart';
import 'package:explore_id/widget/listTripCard.dart';
import 'package:flutter/material.dart';

class MySelectCategory extends StatefulWidget {
  final String categoryName;

  const MySelectCategory({super.key, required this.categoryName});

  @override
  State<MySelectCategory> createState() => _MySelectCategoryState();
}

class _MySelectCategoryState extends State<MySelectCategory> {
  late List<ListTrip> filteredTrips;

  @override
  void initState() {
    super.initState();
    filteredTrips =
        ListTrips.where(
          (trip) =>
              trip.label.toLowerCase() == widget.categoryName.toLowerCase(),
        ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kategori: ${widget.categoryName}"),
        backgroundColor: tdwhitecyan,
      ),
      body:
          filteredTrips.isEmpty
              ? Center(child: Text("Tidak ada trip di kategori ini."))
              : SingleChildScrollView(
                child: ListTripWidget(trips: filteredTrips),
              ),
    );
  }
}
