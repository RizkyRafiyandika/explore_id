import 'package:explore_id/features/profile/models/data_chart_trip.dart';
import 'package:explore_id/features/profile/providers/user_provider.dart';
import 'package:explore_id/features/profile/services/chart_count_service.dart';
import 'package:explore_id/features/profile/widgets/profile_header.dart';
import 'package:explore_id/features/profile/widgets/profile_stats_card.dart';
import 'package:explore_id/features/profile/widgets/profile_chart_section.dart';
import 'package:explore_id/features/profile/widgets/profile_monthly_summary.dart';
import 'package:explore_id/features/profile/widgets/profile_action_buttons.dart';
import 'package:explore_id/features/profile/widgets/profile_danger_zone.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile>
    with SingleTickerProviderStateMixin {
  late int touchIndex = -1;
  bool isLoading = true;
  late Future<List<double>> futureData;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      futureData = getMonthlyVisitCounts(currentUser.uid);
      generateChartData(currentUser.uid).then((_) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          _animationController.forward();
        }
      }).catchError((e) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          _animationController.forward();
        }
        debugPrint("Error generating chart data: $e");
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<MyUserProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          ProfileHeader(userProvider: userProvider, user: user),
          // Content sections
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileStatsCard(isLoading: isLoading),
                      const SizedBox(height: 24),

                      ProfileChartSection(isLoading: isLoading),
                      const SizedBox(height: 24),

                      ProfileMonthlySummary(futureData: futureData),
                      const SizedBox(height: 32),

                      const ProfileActionButtons(),
                      const SizedBox(height: 32),

                      const ProfileDangerZone(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
