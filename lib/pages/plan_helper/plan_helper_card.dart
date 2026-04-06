import 'package:explore_id/colors/color.dart';
import 'package:explore_id/pages/plan_helper/plan_helper_logic.dart';
import 'package:flutter/material.dart';

class PlanHelperPreferenceCard extends StatelessWidget {
  final PlanPreferenceCardData card;
  final bool picked;
  final bool skipped;

  const PlanHelperPreferenceCard({
    super.key,
    required this.card,
    required this.picked,
    required this.skipped,
  });

  @override
  Widget build(BuildContext context) {
    final isPrice = card.type == PlanPreferenceType.price;
    final title = isPrice ? priceLabelFromKey(card.key) : card.key;
    final subtitle = isPrice ? 'Rentang Harga' : 'Kategori Destinasi';
    final hintText =
        picked
            ? 'Dipilih'
            : skipped
            ? 'Dilewati'
            : 'Swipe kanan untuk pilih';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            tdcyan.withValues(alpha: 0.92),
            tdcyan.withValues(alpha: 0.64),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: tdcyan.withValues(alpha: 0.26),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                subtitle,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(hintText, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            const Row(
              children: [
                Icon(Icons.swipe_left, color: Colors.white70, size: 16),
                SizedBox(width: 4),
                Text('Lewati', style: TextStyle(color: Colors.white70)),
                SizedBox(width: 12),
                Icon(Icons.swipe_right, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text('Pilih', style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
