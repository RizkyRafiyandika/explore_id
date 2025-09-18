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
    barrierDismissible: false, // Prevent accidental dismissal
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> selectTime(bool isStart) async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    timePickerTheme: TimePickerThemeData(
                      backgroundColor: tdwhitepure,
                      hourMinuteTextColor: tdwhiteblue,
                      dialHandColor: tdcyan,
                      dialBackgroundColor: tdcyanwhite,
                    ),
                  ),
                  child: child!,
                );
              },
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
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    datePickerTheme: DatePickerThemeData(
                      backgroundColor: tdwhitepure,
                      surfaceTintColor: tdcyan,
                    ),
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: tdcyan,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                selectedDate = picked;
              });
            }
          }

          bool isFormValid() {
            return titleController.text.trim().isNotEmpty &&
                   deskController.text.trim().isNotEmpty &&
                   startTime != null &&
                   endTime != null &&
                   selectedDate != null;
          }

          void validateAndSave() {
            if (!isFormValid()) {
              cutomeSneakBar(context, "Please fill all fields.");
              return;
            }

            // Check if end time is after start time
            if (startTime != null && endTime != null) {
              final startMinutes = startTime!.hour * 60 + startTime!.minute;
              final endMinutes = endTime!.hour * 60 + endTime!.minute;
              
              if (endMinutes <= startMinutes) {
                cutomeSneakBar(context, "End time must be after start time.");
                return;
              }
            }

            String title = titleController.text.trim();
            String desc = deskController.text.trim();
            String place = trip.name;
            String label = trip.label;
            String id = trip.id;

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
            ).then((_) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text("Event successfully saved!"),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }).catchError((e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.error, color: Colors.white),
                      SizedBox(width: 8),
                      Expanded(child: Text("Failed to save event: $e")),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            });
          }

          bool formIsValid = isFormValid();

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: tdwhitepure,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with gradient background
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [tdcyan, tdwhiteblue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.add_location_alt_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Add New Destination",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Create your travel itinerary",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Destination info card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: tdcyanwhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: tdcyan.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: tdcyan,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Destination",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: tdwhite.withOpacity(0.7),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        trip.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: tdwhite,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24),

                          // Form fields
                          _ModernTextField(
                            controller: titleController,
                            label: "Event Title",
                            hint: "What will you do?",
                            icon: Icons.event_rounded,
                            onChanged: (value) {
                              setState(() {
                                formIsValid = isFormValid();
                              });
                            },
                          ),

                          SizedBox(height: 16),

                          _ModernTextField(
                            controller: deskController,
                            label: "Description",
                            hint: "Tell us more about this event...",
                            icon: Icons.description_rounded,
                            maxLines: 3,
                            onChanged: (value) {
                              setState(() {
                                formIsValid = isFormValid();
                              });
                            },
                          ),

                          SizedBox(height: 20),

                          Text(
                            "Schedule",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: tdwhiteblue,
                            ),
                          ),

                          SizedBox(height: 12),

                          // Date picker
                          _ModernButton(
                            onPressed: () async {
                              await selectDate();
                              setState(() {
                                formIsValid = isFormValid();
                              });
                            },
                            icon: Icons.calendar_today_rounded,
                            label: selectedDate != null
                                ? DateFormat('EEEE, MMM dd, yyyy').format(selectedDate!)
                                : "Select Date",
                            isSelected: selectedDate != null,
                          ),

                          SizedBox(height: 12),

                          // Time pickers
                          Row(
                            children: [
                              Expanded(
                                child: _ModernButton(
                                  onPressed: () async {
                                    await selectTime(true);
                                    setState(() {
                                      formIsValid = isFormValid();
                                    });
                                  },
                                  icon: Icons.access_time_rounded,
                                  label: startTime != null
                                      ? startTime!.format(context)
                                      : "Start Time",
                                  isSelected: startTime != null,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _ModernButton(
                                  onPressed: () async {
                                    await selectTime(false);
                                    setState(() {
                                      formIsValid = isFormValid();
                                    });
                                  },
                                  icon: Icons.access_time_filled_rounded,
                                  label: endTime != null
                                      ? endTime!.format(context)
                                      : "End Time",
                                  isSelected: endTime != null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Action buttons
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.close_rounded, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  "Cancel",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            child: ElevatedButton(
                              onPressed: formIsValid ? validateAndSave : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: formIsValid ? tdwhiteblue : Colors.grey.shade300,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                elevation: formIsValid ? 4 : 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    "Save Event",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _ModernTextField extends StatelessWidget {
  const _ModernTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: tdwhiteblue,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: tdcyan),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: tdcyan.withOpacity(0.3), width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: tdcyan, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            fillColor: tdcyanwhite,
            filled: true,
            hintStyle: TextStyle(color: tdwhite.withOpacity(0.6)),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: TextStyle(
            color: tdwhite,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ModernButton extends StatelessWidget {
  const _ModernButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isSelected ? tdcyan : tdcyan.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: isSelected ? tdcyan.withOpacity(0.1) : tdcyanwhite,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? tdcyan : tdwhite,
              size: 18,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? tdcyan : tdwhite,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}