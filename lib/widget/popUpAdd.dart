import 'package:explore_id/colors/color.dart';
import 'package:explore_id/models/event.dart';
import 'package:explore_id/models/listTrip.dart';
import 'package:explore_id/services/event_Service.dart';
import 'package:explore_id/widget/customeToast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showAddDestinationDialog(
  BuildContext context,
  String userId,
  ListTrip trip,
) {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController deskController = TextEditingController();
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  DateTime? selectedDate;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> selectTime(bool isStart) async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (picked != null) {
              setState(() {
                if (isStart) {
                  startTime = picked;
                } else {
                  endTime = picked;
                }
              });
            }
          }

          Future<void> selectDate() async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() {
                selectedDate = picked;
              });
            }
          }

          void validateAndSave() {
            String title = titleController.text.trim();
            String desc = deskController.text.trim();
            String place = trip.name; // ✅ Diambil langsung dari trip
            String label = trip.label; // ✅ Diambil langsung dari trip

            String id = trip.id; // ✅ Diambil langsung dari trip

            print("🗺️ ID: $id");

            // print("📝 Title: $title");
            // print("🗒️ Description: $desc");
            // print("📍 Place: $place");
            // print("📅 Date: ${selectedDate?.toIso8601String()}");
            // print("⏰ Start Time: ${startTime?.format(context)}");
            // print("⏰ End Time: ${endTime?.format(context)}");
            // print("Label: $label");

            // print("UID: $userId");

            if (title.isEmpty ||
                desc.isEmpty ||
                startTime == null ||
                endTime == null ||
                selectedDate == null) {
              cutomeSneakBar(context, "Please fill all fields.");
              return;
            }

            addEvents(
                  userId: userId,
                  events: [
                    Event(
                      id: id,
                      title: title,
                      desk: desc,
                      date: selectedDate!,
                      start: startTime!.format(context),
                      end: endTime!.format(context),
                      place: place,
                      label: label,
                    ),
                  ],
                )
                .then((_) {
                  Navigator.of(context).pop(); // Tutup dialog kalau sukses
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Event berhasil disimpan!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                })
                .catchError((e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Gagal simpan event: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: tdwhitepure, // Added background color
            title: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: tdcyan,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.add_location_alt_outlined,
                      color: tdwhite,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Add Destination",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: tdwhiteblue,
                    ),
                  ),
                ],
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MyTextFieldAdd(
                    titleController: titleController,
                    label: "Title",
                  ),

                  const SizedBox(height: 12),

                  _MyTextFieldAdd(
                    titleController: deskController,
                    label: "Description",
                  ),

                  const SizedBox(height: 10),

                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: tdwhiteblue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: tdcyanwhite,
                      foregroundColor: tdwhite,
                      padding: const EdgeInsets.all(12),
                    ),
                    onPressed: selectDate,
                    child: Text(
                      selectedDate != null
                          ? "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}"
                          : "Date",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: tdwhiteblue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: tdcyanwhite,
                            foregroundColor: tdwhite,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => selectTime(true),
                          child: Text(
                            startTime != null
                                ? "Start: ${startTime!.format(context)}"
                                : "Start Time",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: tdwhiteblue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: tdcyanwhite,
                            foregroundColor: tdwhite,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => selectTime(false),
                          child: Text(
                            endTime != null
                                ? "End: ${endTime!.format(context)}"
                                : "End Time",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Place: ${trip.name}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: tdwhite,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: validateAndSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tdwhiteblue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}

class _MyTextFieldAdd extends StatelessWidget {
  const _MyTextFieldAdd({required this.titleController, required this.label});

  final String label;

  final TextEditingController titleController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: titleController,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.place, color: tdwhite),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: tdwhiteblue, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: tdwhiteblue, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        fillColor: tdcyanwhite,
        filled: true,
        labelStyle: const TextStyle(color: tdwhite),
      ),
    );
  }
}
