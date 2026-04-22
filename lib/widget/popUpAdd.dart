import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:explore_id/provider/event_form_provider.dart';
import 'package:provider/provider.dart';
import 'package:explore_id/widget/custom_text_field.dart';
import 'package:explore_id/colors/color.dart';
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

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return ChangeNotifierProvider(
        create: (_) => EventFormProvider(),
        child: Consumer<EventFormProvider>(
          builder: (context, formProvider, _) {
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
                if (isStart) {
                  formProvider.setStartTime(picked);
                } else {
                  formProvider.setEndTime(picked);
                }
              }
            }

            Future<void> showRangeDatePicker() async {
              final values = await showCalendarDatePicker2Dialog(
                context: context,
                config: CalendarDatePicker2WithActionButtonsConfig(
                  calendarType: CalendarDatePicker2Type.range,
                  selectedDayHighlightColor: tdcyan,
                  weekdayLabelTextStyle: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  controlsTextStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  dayTextStyle: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  disabledDayTextStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  selectableDayPredicate: (day) => !day.isBefore(
                    DateTime.now().subtract(const Duration(days: 1)),
                  ),
                ),
                value: [formProvider.selectedDate, formProvider.endDate],
                dialogSize: const Size(325, 400),
                borderRadius: BorderRadius.circular(15),
              );
              if (values != null && values.isNotEmpty) {
                formProvider.setDateRange(values);
              }
            }

            void validateAndSave() {
              if (!formProvider.validate()) {
                return;
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
                        date: formProvider.selectedDate!,
                        endDate: formProvider.endDate!,
                        start: formProvider.startTime!.format(context),
                        end: formProvider.endTime!.format(context),
                        place: place,
                        label: label,
                      ),
                    ],
                  )
                  .then((_) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
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
                    }
                  })
                  .catchError((e) {
                    if (context.mounted) {
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
                    }
                  });
            }

            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: BoxDecoration(
                  color: tdwhitepure,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header with gradient background
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [tdcyan, tdwhiteblue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(12),
                                child: const Icon(
                                  Icons.add_location_alt_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Add New Destination",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
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
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Destination info card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
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
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: tdcyan,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Destination",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: tdwhite.withOpacity(0.7),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          trip.name,
                                          style: const TextStyle(
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

                            const SizedBox(height: 24),

                            // Form fields
                            CustomTextField(
                              controller: titleController,
                              label: "Event Title",
                              hint: "What will you do?",
                              icon: Icons.event_rounded,
                              errorText: formProvider.titleError,
                              onChanged: (value) {
                                formProvider.setTitle(value);
                              },
                            ),

                            const SizedBox(height: 16),

                            CustomTextField(
                              controller: deskController,
                              label: "Description",
                              hint: "Tell us more about this event...",
                              icon: Icons.description_rounded,
                              maxLines: 3,
                              errorText: formProvider.descriptionError,
                              onChanged: (value) {
                                formProvider.setDescription(value);
                              },
                            ),

                            const SizedBox(height: 20),

                            const Text(
                              "Schedule",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: tdwhiteblue,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Modern Range Date Selector
                            _ModernButton(
                              onPressed: showRangeDatePicker,
                              icon: Icons.calendar_today_rounded,
                              label: formProvider.selectedDate == null
                                  ? "Select Date / Range"
                                  : (formProvider.selectedDate ==
                                          formProvider.endDate
                                      ? DateFormat('MMM dd, yyyy').format(
                                          formProvider.selectedDate!)
                                      : "${DateFormat('MMM dd').format(formProvider.selectedDate!)} - ${DateFormat('MMM dd, yyyy').format(formProvider.endDate!)}"),
                              isSelected: formProvider.selectedDate != null,
                            ),
                            if (formProvider.dateError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0, left: 16),
                                child: Text(
                                  formProvider.dateError!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                              ),

                            const SizedBox(height: 12),

                            // Time pickers
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _ModernButton(
                                        onPressed: () => selectTime(true),
                                        icon: Icons.access_time_rounded,
                                        label:
                                            formProvider.startTime != null
                                                ? formProvider.startTime!.format(context)
                                                : "Start Time",
                                        isSelected: formProvider.startTime != null,
                                      ),
                                      if (formProvider.startTimeError != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4.0, left: 16),
                                          child: Text(
                                            formProvider.startTimeError!,
                                            style: const TextStyle(color: Colors.red, fontSize: 12),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _ModernButton(
                                        onPressed: () => selectTime(false),
                                        icon: Icons.access_time_filled_rounded,
                                        label:
                                            formProvider.endTime != null
                                                ? formProvider.endTime!.format(context)
                                                : "End Time",
                                        isSelected: formProvider.endTime != null,
                                      ),
                                      if (formProvider.endTimeError != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4.0, left: 16),
                                          child: Text(
                                            formProvider.endTimeError!,
                                            style: const TextStyle(color: Colors.red, fontSize: 12),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Add padding for keyboard
                            SizedBox(
                              height: MediaQuery.of(context).viewInsets.bottom,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Action buttons
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
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
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Row(
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: ElevatedButton(
                                onPressed: validateAndSave,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: tdwhiteblue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 4,
                                ),
                                child: const Row(
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
        ),
      );
    },
  );
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
      duration: const Duration(milliseconds: 200),
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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? tdcyan : tdwhite, size: 18),
            const SizedBox(width: 8),
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
