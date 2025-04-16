import 'dart:ui';

import 'package:explore_id/models/dataChartTrip.dart' as PieData;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

List<PieChartSectionData> getSections(int touchIndex) =>
    PieData.chartData
        .asMap()
        .map<int, PieChartSectionData>((index, data) {
          final isTouched = index == touchIndex;
          final double fontSize = isTouched ? 22 : 16;
          final double radius = isTouched ? 80 : 65;

          final section = PieChartSectionData(
            color: data.color,

            value:
                data.percent
                    .toDouble(), // tetap pakai percent untuk proporsi grafik
            title: '${data.count}', // ini count-nya yang ditampilkan
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );

          return MapEntry(index, section);
        })
        .values
        .toList();
