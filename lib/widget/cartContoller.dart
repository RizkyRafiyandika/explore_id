import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnimatedPieChart extends StatefulWidget {
  final List<PieChartSectionData> Function(int) getSections;
  final Duration rotationDuration;
  final double aspectRatio;
  final int totalTrips;

  const AnimatedPieChart({
    super.key,
    required this.getSections,
    required this.totalTrips,
    this.rotationDuration = const Duration(milliseconds: 1000),
    this.aspectRatio = 1.2,
  });

  @override
  State<AnimatedPieChart> createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<AnimatedPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  int touchIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.rotationDuration,
    );
    _rotationAnimation = Tween<double>(
      begin: -3.14,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 70,
                    sectionsSpace: 4,
                    startDegreeOffset: -90,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, pieTouchResponse) {
                        setState(() {
                          if (event is FlTapUpEvent ||
                              event is FlLongPressEnd) {
                            touchIndex = -1;
                          } else {
                            touchIndex =
                                pieTouchResponse
                                    ?.touchedSection
                                    ?.touchedSectionIndex ??
                                -1;
                          }
                        });
                      },
                    ),
                    sections: widget.getSections(touchIndex),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 400),
                  swapAnimationCurve: Curves.easeInOut,
                ),
              );
            },
          ),
          // Center Text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.totalTrips}',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  height: 1,
                ),
              ),
              Text(
                'Total Trips',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B).withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
