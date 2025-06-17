import 'package:explore_id/colors/color.dart';
import 'package:explore_id/provider/tripProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class showSheetBottom extends StatelessWidget {
  const showSheetBottom({super.key});

  @override
  Widget build(BuildContext context) {
    return _showFilterOptions(context);
  }
}

Widget _showFilterOptions(BuildContext context) {
  final provider = Provider.of<MytripProvider>(context);
  final selected = provider.filterType;
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,

      children: [
        const Text(
          'Filter By',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _builderListTile(context, provider, selected, "nama", Icons.person),
        _builderListTile(
          context,
          provider,
          selected,
          "Daerah",
          Icons.location_on,
        ),
        _builderListTile(
          context,
          provider,
          selected,
          "Category",
          Icons.category,
        ),
      ],
    ),
  );
}

Widget _builderListTile(
  BuildContext context,
  MytripProvider provider,
  String selected,
  String label,
  IconData icon,
) {
  final isSelected = selected == label;
  return ListTile(
    leading: Icon(icon, color: isSelected ? tdcyan : Colors.grey),
    title: Text(
      label,
      style: TextStyle(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    ),
    trailing:
        isSelected
            ? Icon(Icons.radio_button_checked_rounded)
            : Icon(Icons.radio_button_off_outlined),
    onTap: () {
      provider.setFilterType(label);
    },
  );
}
