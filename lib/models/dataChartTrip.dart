import 'package:flutter/material.dart';
import 'package:explore_id/services/chart_count.dart'; // pastikan ini ada dan benar

// Data model untuk chart (persen)
class ChartData {
  final String name;
  final int percent;
  final int count;
  final Color color;

  ChartData({
    required this.name,
    required this.percent,
    required this.count,
    required this.color,
  });
}

// Data model untuk count mentah
class ChartCountData {
  final String name;
  final int count;
  final Color color;

  ChartCountData({
    required this.name,
    required this.count,
    required this.color,
  });
}

// Final data yang akan dipakai untuk chart (misal: pie chart)
List<ChartData> chartData = [];

// Fungsi untuk generate chart data (bisa pakai dummy atau dari Firebase)
Future<void> generateChartData(String userId) async {
  chartData.clear();

  final rawData = await getVisitedPlacesCount(userId);
  final totalVisits = rawData.values.fold(0, (sum, count) => sum + count);

  // Buat mapping warna berdasarkan nama kategori
  final colorMap = {
    'Mountain': Colors.blue.withOpacity(0.8),
    'Culinary': Colors.orange.withOpacity(0.8),
    'Culture': Color.fromARGB(255, 76, 104, 175).withOpacity(0.8),
    'Beach': Color.fromARGB(255, 175, 135, 76).withOpacity(0.8),
    'Nature': Color.fromARGB(255, 190, 53, 217).withOpacity(0.8),
  };

  rawData.forEach((place, count) {
    final int percent = ((count / totalVisits) * 100).round();

    chartData.add(
      ChartData(
        name: place,
        percent: percent,
        count: count,
        color:
            colorMap[place] ??
            Colors.grey, // fallback kalau warnanya gak ketemu
      ),
    );
  });
}

// Fungsi untuk mengubah count mentah ke persen
List<ChartData> convertToPercent(List<ChartCountData> rawData) {
  int totalCount = rawData.fold(0, (sum, item) => sum + item.count);

  return rawData.map((item) {
    int percent = ((item.count / totalCount) * 100).round();
    return ChartData(
      name: item.name,
      percent: percent,
      color: item.color,
      count: item.count,
    );
  }).toList();
}
