import 'package:explore_id/features/profile/models/data_chart_trip.dart' as PieData;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

List<PieChartSectionData> getSections(int touchIndex) =>
    PieData.chartData
        .asMap()
        .map<int, PieChartSectionData>((index, data) {
          final isTouched = index == touchIndex;
          final double fontSize = isTouched ? 22 : 16;
          final double radius = isTouched ? 60 : 40;

          final section = PieChartSectionData(
            color: data.color,
            value: data.percent.toDouble(),
            radius: radius,
            showTitle: false,
          );

          return MapEntry(index, section);
        })
        .values
        .toList();
