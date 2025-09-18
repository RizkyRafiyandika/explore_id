import 'package:explore_id/colors/color.dart';
import 'package:explore_id/models/dataChartTrip.dart';
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
          (data) => BuildIndicator(color: data.color, text: data.name),
        ),
        const BuildAddIndicator(), // Tambahkan tombol +
      ],
    );
  }
}

class BuildIndicator extends StatelessWidget {
  final Color color;
  final String text;

  const BuildIndicator({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tdwhitepure,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: tdwhitepure,
            ),
          ),
        ],
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
        // Tindakan saat tombol "+" ditekan
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyNearbyPage()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.4)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text(
              "Tambah",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
