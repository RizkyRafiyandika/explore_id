import 'package:flutter/material.dart';
import 'package:explore_id/colors/color.dart';
import 'package:explore_id/features/profile/widgets/stats_indicator.dart';

class ProfileStatsCard extends StatelessWidget {
  final bool isLoading;
  const ProfileStatsCard({super.key, required this.isLoading});

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Travel Interests",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              Icon(
                Icons.local_offer_outlined,
                color: const Color(0xFF006699).withOpacity(0.8),
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: LinearProgressIndicator())
          else
            const MyIndicatorWidget(),
        ],
      ),
    );
  }
}
