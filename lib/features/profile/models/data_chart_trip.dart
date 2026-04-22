import 'package:flutter/material.dart';
import 'package:explore_id/features/profile/services/chart_count_service.dart'; // pastikan ini ada dan benar

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
    'Mountain': Colors.blue.shade600,
    'Culinary': Colors.orange.shade600,
    'Culture': Colors.indigo.shade600,
    'Beach': Colors.teal.shade600,
    'Nature': Colors.green.shade600,
    'Historical': Colors.brown.shade600,
    'City': Colors.blueGrey.shade600,
    'Adventure': Colors.red.shade600,
    'Religious': Colors.amber.shade700,
    'Water': Colors.cyan.shade600,
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
