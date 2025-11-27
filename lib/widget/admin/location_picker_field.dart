import 'package:flutter/material.dart';
import 'package:explore_id/colors/color.dart';

class LocationPickerField extends StatelessWidget {
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final VoidCallback onMapButtonPressed;

  const LocationPickerField({
    super.key,
    required this.latitudeController,
    required this.longitudeController,
    required this.onMapButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lokasi (Koordinat)',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _CoordinateField(
                controller: latitudeController,
                label: 'Latitude',
                hint: '-7.942493',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CoordinateField(
                controller: longitudeController,
                label: 'Longitude',
                hint: '112.953012',
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: onMapButtonPressed,
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: tdcyan,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.map, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CoordinateField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const _CoordinateField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          validator: (value) => value!.isEmpty ? 'Required' : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: tdcyan),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
