import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:explore_id/provider/event_form_provider.dart';
import 'package:provider/provider.dart';
import 'package:explore_id/widget/custom_text_field.dart';
import 'package:explore_id/colors/color.dart';
import 'package:explore_id/models/event.dart';
import 'package:explore_id/services/event_Service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarEventBottomSheet extends StatefulWidget {
  final Event event;

  const CalendarEventBottomSheet({super.key, required this.event});

  @override
  State<CalendarEventBottomSheet> createState() =>
      _CalendarEventBottomSheetState();
}

class _CalendarEventBottomSheetState extends State<CalendarEventBottomSheet> {
  late TextEditingController _titleController;
  late TextEditingController _deskController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _deskController = TextEditingController(text: widget.event.desk);

    // Initialize provider data after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<EventFormProvider>();
      provider.setTitle(widget.event.title);
      provider.setDescription(widget.event.desk);
      provider.setDateRange([widget.event.date, widget.event.endDate]);

      // Parse time strings back to TimeOfDay
      final startTime = _parseTimeString(widget.event.start);
      final endTime = _parseTimeString(widget.event.end);
      provider.setStartTime(startTime);
      provider.setEndTime(endTime);
    });
  }

  TimeOfDay _parseTimeString(String timeStr) {
    try {
      // Expects "HH:mm AM/PM" format from TimeOfDay.format(context)
      final parts = timeStr.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      if (parts.length > 1) {
        if (parts[1].toUpperCase() == 'PM' && hour < 12) hour += 12;
        if (parts[1].toUpperCase() == 'AM' && hour == 12) hour = 0;
      }
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _deskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = context.watch<EventFormProvider>();

    Future<void> selectTime(bool isStart) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime:
            isStart
                ? (formProvider.startTime ?? TimeOfDay.now())
                : (formProvider.endTime ?? TimeOfDay.now()),
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
          disabledDayTextStyle: const TextStyle(color: Colors.grey),
        ),
        value: [formProvider.selectedDate, formProvider.endDate],
        dialogSize: const Size(325, 400),
        borderRadius: BorderRadius.circular(15),
      );
      if (values != null && values.isNotEmpty) {
        formProvider.setDateRange(values);
      }
    }

    Future<void> handleUpdate() async {
      if (!formProvider.validate()) return;

      final updatedEvent = Event(
        id: widget.event.id,
        title: _titleController.text.trim(),
        desk: _deskController.text.trim(),
        date: formProvider.selectedDate!,
        endDate: formProvider.endDate!,
        start: formProvider.startTime!.format(context),
        end: formProvider.endTime!.format(context),
        place: widget.event.place,
        label: widget.event.label,
        isCheck: widget.event.isCheck,
        docId: widget.event.docId,
      );

      try {
        await updateEvent(updatedEvent);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Event updated successfully"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to update event: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    Future<void> handleDelete() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Delete Event"),
              content: const Text(
                "Are you sure you want to delete this event from your calendar?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
      );

      if (confirm == true && widget.event.docId != null) {
        try {
          await deleteEvent(widget.event.docId!);
          if (mounted) {
            Navigator.pop(context); // Close bottom sheet
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Event deleted successfully"),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Failed to delete event: $e"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
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

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Edit Travel Plan",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: tdwhiteblue,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: handleDelete,
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: _titleController,
                      label: "Event Title",
                      hint: "What will you do?",
                      icon: Icons.event_rounded,
                      errorText: formProvider.titleError,
                      onChanged: (value) => formProvider.setTitle(value),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _deskController,
                      label: "Description",
                      hint: "Tell us more...",
                      icon: Icons.description_rounded,
                      maxLines: 3,
                      errorText: formProvider.descriptionError,
                      onChanged: (value) => formProvider.setDescription(value),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Schedule",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: tdwhiteblue,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Range Date Selector
                    _ModernButton(
                      onPressed: showRangeDatePicker,
                      icon: Icons.calendar_today_rounded,
                      label:
                          formProvider.selectedDate == null
                              ? "Select Date / Range"
                              : (formProvider.selectedDate ==
                                      formProvider.endDate
                                  ? DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(formProvider.selectedDate!)
                                  : "${DateFormat('MMM dd').format(formProvider.selectedDate!)} - ${DateFormat('MMM dd, yyyy').format(formProvider.endDate!)}"),
                      isSelected: formProvider.selectedDate != null,
                    ),

                    const SizedBox(height: 12),

                    // Time pickers
                    Row(
                      children: [
                        Expanded(
                          child: _ModernButton(
                            onPressed: () => selectTime(true),
                            icon: Icons.access_time_rounded,
                            label:
                                formProvider.startTime?.format(context) ??
                                "Start Time",
                            isSelected: formProvider.startTime != null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ModernButton(
                            onPressed: () => selectTime(false),
                            icon: Icons.access_time_filled_rounded,
                            label:
                                formProvider.endTime?.format(context) ??
                                "End Time",
                            isSelected: formProvider.endTime != null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Save Button
            Container(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: handleUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tdcyan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Update Plan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: isSelected ? tdcyan : tdcyan.withOpacity(0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    );
  }
}

// Global function to show the bottom sheet
void showCalendarEventBottomSheet(BuildContext context, Event event) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => ChangeNotifierProvider(
          create: (_) => EventFormProvider(),
          child: CalendarEventBottomSheet(event: event),
        ),
  );
}
