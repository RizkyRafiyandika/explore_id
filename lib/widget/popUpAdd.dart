import 'package:explore_id/models/event.dart';
import 'package:explore_id/models/listTrip.dart';
import 'package:explore_id/services/event_Service.dart';
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

            print("📝 Title: $title");
            print("🗒️ Description: $desc");
            print("📍 Place: $place");
            print("📅 Date: ${selectedDate?.toIso8601String()}");
            print("⏰ Start Time: ${startTime?.format(context)}");
            print("⏰ End Time: ${endTime?.format(context)}");
            print("Label: $label");

            print("UID: $userId");

            if (title.isEmpty ||
                desc.isEmpty ||
                startTime == null ||
                endTime == null ||
                selectedDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Please fill all fields, select date and time.",
                  ),
                  backgroundColor: Colors.redAccent,
                ),
              );
              return;
            }

            addEvents(
                  userId: userId,
                  events: [
                    Event(
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
            title: const Text("Add Destination Details"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: deskController,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: selectDate,
                    child: Text(
                      selectedDate != null
                          ? "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}"
                          : "Pick Date",
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => selectTime(true),
                          child: Text(
                            startTime != null
                                ? "Start: ${startTime!.format(context)}"
                                : "Pick Start Time",
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => selectTime(false),
                          child: Text(
                            endTime != null
                                ? "End: ${endTime!.format(context)}"
                                : "Pick End Time",
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: validateAndSave,
                child: const Text("Save"),
              ),
            ],
          );
        },
      );
    },
  );
}
