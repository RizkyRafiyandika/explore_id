import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnimatedPieChart extends StatefulWidget {
  final List<PieChartSectionData> Function(int) getSections;
  final Duration rotationDuration;
  final double aspectRatio;

  const AnimatedPieChart({
    super.key,
    required this.getSections,
    this.rotationDuration = const Duration(milliseconds: 1000),
    this.aspectRatio = 2.5,
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
      begin: -2 * 3.14,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
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
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 20,
                sectionsSpace: 1,
                pieTouchData: PieTouchData(
                  touchCallback: (event, pieTouchResponse) {
                    setState(() {
                      if (event is FlTapUpEvent || event is FlLongPressEnd) {
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
              swapAnimationDuration: const Duration(milliseconds: 800),
              swapAnimationCurve: Curves.easeOutBack,
            ),
          );
        },
      ),
    );
  }
}
