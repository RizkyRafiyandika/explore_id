import 'package:flutter/material.dart';
import 'package:explore_id/colors/color.dart';

/// Widget for selecting travel mode (driving, cycling, walking)
class ModeSelector extends StatelessWidget {
  final String selectedMode;
  final Function(String) onModeChanged;
  final bool disabled;

  const ModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildModeButton('driving', Icons.directions_car_filled_rounded),
          const SizedBox(width: 12),
          _buildModeButton('cycling', Icons.directions_bike_rounded),
          const SizedBox(width: 12),
          _buildModeButton('walking', Icons.directions_walk_rounded),
        ],
      ),
    );
  }

  Widget _buildModeButton(String mode, IconData icon) {
    final isSelected = selectedMode == mode;

    return GestureDetector(
      onTap: disabled ? null : () => onModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? tdcyan : Colors.grey.shade200.withOpacity(0.8),
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: tdcyan.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black87,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              mode[0].toUpperCase() + mode.substring(1),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
