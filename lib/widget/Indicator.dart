import 'package:explore_id/models/dataChartTrip.dart';
import 'package:flutter/material.dart';

class MyIndicatorWidget extends StatelessWidget {
  const MyIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children:
          chartData
              .map(
                (data) => Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
                  child: BuildIndicator(
                    color: data.color,
                    text: data.name, // gunakan 'name' karena ini String
                  ),
                ),
              )
              .toList(),
    );
  }
}

class BuildIndicator extends StatelessWidget {
  final Color color;
  final String text;

  const BuildIndicator({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
