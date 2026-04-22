import 'package:explore_id/widget/cartContoller.dart';
import 'package:flutter/material.dart';
import 'package:explore_id/colors/color.dart';
import 'package:explore_id/features/profile/models/data_chart_trip.dart';
import 'package:explore_id/features/profile/widgets/animated_pie_chart.dart';

class ProfileChartSection extends StatelessWidget {
  final bool isLoading;

  const ProfileChartSection({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: tdorange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.pie_chart_rounded, color: tdorange, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                "Trip Distribution",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isLoading)
            const SizedBox(
              height: 250,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (chartData.isEmpty)
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.travel_explore_rounded,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No travel data yet",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            AnimatedPieChart(
              getSections: getSections,
              totalTrips: chartData.fold(0, (sum, item) => sum + item.count),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 20),
            // Legend
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    chartData.map((data) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: data.color,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              data.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
