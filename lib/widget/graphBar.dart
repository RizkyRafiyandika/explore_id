import 'package:explore_id/models/dataGraph.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyGraphBar extends StatelessWidget {
  final List<double> monthlySummary;

  const MyGraphBar({super.key, required this.monthlySummary});

  @override
  Widget build(BuildContext context) {
    final BarData barData = BarData(monthlyValues: monthlySummary);
    barData.initializeBarData();

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          maxY: (monthlySummary.reduce((a, b) => a > b ? a : b)) + 5,
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: getBottomTitles,
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups:
              barData.barData.map((bar) {
                return BarChartGroupData(
                  x: bar.x,
                  barRods: [
                    BarChartRodData(
                      toY: bar.y,
                      color: Colors.blueAccent,
                      width: 18,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
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
    final text =
        value.toInt() >= 0 && value.toInt() < months.length
            ? Text(months[value.toInt()], style: const TextStyle(fontSize: 10))
            : const Text('');

    return SideTitleWidget(child: text, meta: meta, space: 6);
  }
}
