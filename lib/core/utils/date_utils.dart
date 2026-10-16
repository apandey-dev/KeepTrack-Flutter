import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _keyFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _weekdayFormat = DateFormat('EEE');
  static final DateFormat _dayFormat = DateFormat('d');
  static final DateFormat _fullDateFormat = DateFormat('EEEE, MMM d');
  static final DateFormat _shortDateFormat = DateFormat('MMM d, yyyy');

  /// Normalizes a DateTime to start of day in local timezone (00:00:00.000)
  static DateTime normalizeDate(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  /// Converts a DateTime into a standardized `yyyy-MM-dd` key
  static String toDateKey(DateTime dt) {
    return _keyFormat.format(dt);
  }

  /// Parses a `yyyy-MM-dd` key back to local start-of-day DateTime
  static DateTime fromDateKey(String key) {
    return _keyFormat.parseStrict(key);
  }

  /// Returns true if two DateTimes belong to the same calendar day in local time
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Returns true if the date is today in local time
  static bool isToday(DateTime dt) {
    return isSameDay(dt, DateTime.now());
  }

  /// Returns a list of 7 consecutive normalized dates starting from today
  static List<DateTime> getNext7Days([DateTime? startDate]) {
    final start = normalizeDate(startDate ?? DateTime.now());
    return List.generate(7, (index) => start.add(Duration(days: index)));
  }

  /// Format as abbreviated weekday: "Mon", "Tue"
  static String formatWeekday(DateTime dt) {
    return _weekdayFormat.format(dt).toUpperCase();
  }

  /// Format as day of month: "1", "25"
  static String formatDayNumber(DateTime dt) {
    return _dayFormat.format(dt);
  }

  /// Format as full header date: "Thursday, Oct 15"
  static String formatHeaderDate(DateTime dt) {
    return _fullDateFormat.format(dt);
  }

  /// Format as short date: "Oct 15, 2026"
  static String formatShortDate(DateTime dt) {
    return _shortDateFormat.format(dt);
  }

  /// Format TimeOfDay to 12-hour string e.g. "09:30 AM"
  static String formatTimeOfDay(TimeOfDay time, BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(time, alwaysUse24HourFormat: false);
  }

  /// Convert TimeOfDay to standard 24h string "HH:mm" for persistent storage
  static String timeOfDayToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Parse 24h "HH:mm" string back to TimeOfDay
  static TimeOfDay? stringToTimeOfDay(String? timeStr) {
    if (timeStr == null || !timeStr.contains(':')) return null;
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  /// Friendly display for a 24h time string: "2:30 PM"
  static String formatStoredTime(String? timeStr) {
    if (timeStr == null) return '';
    final tod = stringToTimeOfDay(timeStr);
    if (tod == null) return timeStr;
    final hour = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = tod.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  /// Greeting based on current time of day: "Good morning", "Good afternoon", "Good evening"
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
}
