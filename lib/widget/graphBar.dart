import 'package:explore_id/models/dataGraph.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyGraphBar extends StatefulWidget {
  final List<double> monthlySummary;

  const MyGraphBar({super.key, required this.monthlySummary});

  @override
  State<MyGraphBar> createState() => _MyGraphBarState();
}

class _MyGraphBarState extends State<MyGraphBar> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BarData barData = BarData(monthlyValues: widget.monthlySummary);
    barData.initializeBarData();

    // Cari nilai maksimum untuk scaling yang lebih baik
    final maxValue =
        widget.monthlySummary.isNotEmpty
            ? widget.monthlySummary.reduce((a, b) => a > b ? a : b)
            : 10.0;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 280,
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              maxY: (maxValue + 2) * 1.1,
              minY: 0,

              // Grid styling
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxValue > 0 ? maxValue / 4 : 2.5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),

              // Border styling
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                  left: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),

              // Titles styling
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    getTitlesWidget: getBottomTitles,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: maxValue > 0 ? maxValue / 4 : 2.5,
                    getTitlesWidget: getLeftTitles,
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),

              // Bar groups dengan animasi
              barGroups:
                  barData.barData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final bar = entry.value;
                    final isSelected = touchedIndex == index;

                    return BarChartGroupData(
                      x: bar.x,
                      barRods: [
                        BarChartRodData(
                          toY: bar.y * _animation.value,
                          gradient: LinearGradient(
                            colors:
                                isSelected
                                    ? [
                                      const Color(0xFF6C63FF),
                                      const Color(0xFF4ECDC4),
                                    ]
                                    : [
                                      const Color(0xFF6C63FF).withOpacity(0.8),
                                      const Color(0xFF4ECDC4).withOpacity(0.6),
                                    ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          width: isSelected ? 24 : 20,
                          borderRadius: BorderRadius.circular(8),

                          // Background bar
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxValue * 1.1,
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ],
                    );
                  }).toList(),

              // Touch interaction - disesuaikan untuk versi lama
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  // Menggunakan parameter yang kompatibel dengan versi lama
                  getTooltipColor: (group) => Colors.blueGrey.shade800,
                  tooltipRoundedRadius: 12,
                  tooltipMargin: 8,
                  tooltipPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final months = [
                      'January',
                      'February',
                      'March',
                      'April',
                      'May',
                      'June',
                      'July',
                      'August',
                      'September',
                      'October',
                      'November',
                      'December',
                    ];
                    final monthName = months[group.x.toInt()];
                    return BarTooltipItem(
                      '$monthName\n',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: '${rod.toY.toStringAsFixed(0)} trips',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                touchCallback: (FlTouchEvent event, barTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        barTouchResponse == null ||
                        barTouchResponse.spot == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    if (value.toInt() >= 0 && value.toInt() < months.length) {
      final isSelected = touchedIndex == value.toInt();
      return SideTitleWidget(
        child: Text(
          months[value.toInt()],
          style: TextStyle(
            fontSize: isSelected ? 12 : 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.shade600,
          ),
        ),
        space: 8,
        meta: meta,
      );
    }
    return const SizedBox.shrink();
  }

  Widget getLeftTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      child: Text(
        value.toInt().toString(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade600,
        ),
      ),
      space: 8,
      meta: meta,
    );
  }
}

// Summary statistics widget
class ChartSummary extends StatelessWidget {
  final List<double> data;

  const ChartSummary({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final total = data.reduce((a, b) => a + b);
    final average = total / data.length;
    final max = data.reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(
            'Total',
            total.toInt().toString(),
            const Color(0xFF6C63FF),
          ),
          _buildStat(
            'Average',
            average.toStringAsFixed(1),
            const Color(0xFF4ECDC4),
          ),
          _buildStat('Peak', max.toInt().toString(), const Color(0xFFFF6B6B)),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
