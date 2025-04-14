import 'package:explore_id/colors/color.dart';
import 'package:flutter/material.dart';

class MyfilterButton extends StatefulWidget {
  final Function(String) onfilterSelection;
  const MyfilterButton({super.key, required this.onfilterSelection});

  @override
  State<MyfilterButton> createState() => _MyfilterButtonState();
}

class _MyfilterButtonState extends State<MyfilterButton> {
  String selectionFilter = "All";
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _BuildFilterButton("All"),
        _BuildFilterButton("Top Rated"),
        _BuildFilterButton("Open Now"),
      ],
    );
  }

  Widget _BuildFilterButton(String label) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectionFilter = label;
          });
          widget.onfilterSelection(label);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selectionFilter == label ? tdwhitecyan : tdwhite,
          foregroundColor: selectionFilter == label ? tdwhite : tdcyan,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: Text(label),
      ),
    );
  }
}
