import 'package:flutter/material.dart';

class EventFormProvider with ChangeNotifier {
  // Field values
  String _title = "";
  String _description = "";
  DateTime? _selectedDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Error states
  String? _titleError;
  String? _descriptionError;
  String? _dateError;
  String? _endDateError;
  String? _startTimeError;
  String? _endTimeError;

  // Getters
  String get title => _title;
  String get description => _description;
  DateTime? get selectedDate => _selectedDate;
  DateTime? get endDate => _endDate;
  TimeOfDay? get startTime => _startTime;
  TimeOfDay? get endTime => _endTime;

  String? get titleError => _titleError;
  String? get descriptionError => _descriptionError;
  String? get dateError => _dateError;
  String? get endDateError => _endDateError;
  String? get startTimeError => _startTimeError;
  String? get endTimeError => _endTimeError;

  // Setters with error clearing
  void setDateRange(List<DateTime?> dates) {
    if (dates.isNotEmpty) {
      _selectedDate = dates[0];
      if (dates.length > 1 && dates[1] != null) {
        _endDate = dates[1];
      } else {
        _endDate = _selectedDate;
      }

      _dateError = null;
      _endDateError = null;
      notifyListeners();
    }
  }

  void setTitle(String value) {
    _title = value;
    if (_titleError != null && value.trim().isNotEmpty) {
      _titleError = null;
    }
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    if (_descriptionError != null && value.trim().isNotEmpty) {
      _descriptionError = null;
    }
    notifyListeners();
  }

  void setSelectedDate(DateTime? value) {
    _selectedDate = value;
    if (_dateError != null && value != null) {
      _dateError = null;
    }

    if (_endDate != null && value != null && _endDate!.isBefore(value)) {
      // If end date is already set and is before new start date, update it
      _endDate = value;
    }
    notifyListeners();
  }

  void setEndDate(DateTime? value) {
    _endDate = value;
    if (_endDateError != null && value != null) {
      _endDateError = null;
    }
    _validateDates();
    notifyListeners();
  }

  void setStartTime(TimeOfDay? value) {
    _startTime = value;
    if (_startTimeError != null && value != null) {
      _startTimeError = null;
    }
    // Re-validate times if start time changes
    if (_endTime != null) {
      _validateTimes();
    }
    notifyListeners();
  }

  void setEndTime(TimeOfDay? value) {
    _endTime = value;
    if (_endTimeError != null && value != null) {
      _endTimeError = null;
    }
    _validateTimes();
    notifyListeners();
  }

  bool _validateDates() {
    if (_selectedDate != null && _endDate != null) {
      if (_endDate!.isBefore(_selectedDate!)) {
        _endDateError = "End date cannot be before start date";
        return false;
      } else {
        _endDateError = null;
        return true;
      }
    }
    return true;
  }

  bool _validateTimes() {
    // Only strictly validate start before end if they are on the same day
    if (_selectedDate != null &&
        _endDate != null &&
        _selectedDate!.year == _endDate!.year &&
        _selectedDate!.month == _endDate!.month &&
        _selectedDate!.day == _endDate!.day) {
      if (_startTime != null && _endTime != null) {
        final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
        final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

        if (endMinutes <= startMinutes) {
          _endTimeError = "End time must be after start time";
          return false;
        } else {
          _endTimeError = null;
          return true;
        }
      }
    } else {
      _endTimeError = null;
    }
    return true;
  }

  bool validate() {
    bool isValid = true;

    if (_title.trim().isEmpty) {
      _titleError = "Title is required";
      isValid = false;
    } else {
      _titleError = null;
    }

    if (_description.trim().isEmpty) {
      _descriptionError = "Description is required";
      isValid = false;
    } else {
      _descriptionError = null;
    }

    if (_selectedDate == null) {
      _dateError = "Start date is required";
      isValid = false;
    } else {
      _dateError = null;
    }

    if (_endDate == null) {
      _endDateError = "End date is required";
      isValid = false;
    } else {
      _endDateError = null;
    }

    if (_startTime == null) {
      _startTimeError = "Start time is required";
      isValid = false;
    } else {
      _startTimeError = null;
    }

    if (_endTime == null) {
      _endTimeError = "End time is required";
      isValid = false;
    } else {
      _endTimeError = null;
    }

    if (isValid) {
      isValid = _validateDates() && _validateTimes();
    }

    notifyListeners();
    return isValid;
  }

  void reset() {
    _title = "";
    _description = "";
    _selectedDate = null;
    _endDate = null;
    _startTime = null;
    _endTime = null;
    _titleError = null;
    _descriptionError = null;
    _dateError = null;
    _endDateError = null;
    _startTimeError = null;
    _endTimeError = null;
    notifyListeners();
  }
}
