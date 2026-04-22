import 'package:explore_id/colors/color.dart';
import 'package:explore_id/features/profile/models/data_chart_trip.dart';
import 'package:explore_id/pages/nearby_List_Page.dart';
import 'package:flutter/material.dart';

class MyIndicatorWidget extends StatelessWidget {
  const MyIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...chartData.map(
          (data) => BuildIndicator(data: data),
        ),
        const BuildAddIndicator(),
      ],
    );
  }
}

class BuildIndicator extends StatelessWidget {
  final ChartData data;

  const BuildIndicator({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: data.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        data.name,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: data.color.withOpacity(0.9),
        ),
      ),
    );
  }
}

class BuildAddIndicator extends StatelessWidget {
  const BuildAddIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyNearbyPage()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.grey[600], size: 16),
            const SizedBox(width: 4),
            Text(
              "Tambah",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
