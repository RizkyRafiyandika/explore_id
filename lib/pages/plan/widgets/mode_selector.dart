import 'package:flutter/material.dart';
import 'package:explore_id/colors/color.dart';

/// Widget for selecting travel mode (driving, cycling, walking)
class ModeSelector extends StatelessWidget {
  final String selectedMode;
  final Function(String) onModeChanged;
  final bool disabled;

  const ModeSelector({
    Key? key,
    required this.selectedMode,
    required this.onModeChanged,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _buildModeChip('driving', Icons.directions_car),
        _buildModeChip('cycling', Icons.directions_bike),
        _buildModeChip('walking', Icons.directions_walk),
      ],
    );
  }

  Widget _buildModeChip(String mode, IconData icon) {
    final selected = selectedMode == mode;

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(mode[0].toUpperCase() + mode.substring(1)),
        ],
      ),
      selected: selected,
      onSelected:
          disabled
              ? null
              : (v) {
                if (v) onModeChanged(mode);
              },
      selectedColor: tdcyan.withOpacity(0.2),
      labelStyle: TextStyle(
        color: selected ? tdcyan : Colors.black87,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: selected ? tdcyan : Colors.grey.shade300),
      ),
    );
  }
}
