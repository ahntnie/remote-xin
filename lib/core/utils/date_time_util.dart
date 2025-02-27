import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../all.dart';

class DateTimeUtil {
  DateTimeUtil._();

  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);

    return (to.difference(from).inHours / 24).round();
  }

  static int timezoneOffset() {
    return DateTime.now().timeZoneOffset.inHours;
  }

  static DateTime toLocalFromTimestamp({required int utcTimestampMillis}) {
    return DateTime.fromMillisecondsSinceEpoch(utcTimestampMillis, isUtc: true)
        .toLocal();
  }

  static DateTime toUtcFromTimestamp(int localTimestampMillis) {
    return DateTime.fromMillisecondsSinceEpoch(localTimestampMillis).toUtc();
  }

  static DateTime startTimeOfDate() {
    final now = DateTime.now();

    return DateTime(
      now.year,
      now.month,
      now.day,
    );
  }

  static DateTime? toDateTime(String dateTimeString, {bool isUtc = false}) {
    final dateTime = DateTime.tryParse(dateTimeString);
    if (dateTime != null) {
      if (isUtc) {
        return DateTime.utc(
          dateTime.year,
          dateTime.month,
          dateTime.day,
          dateTime.hour,
          dateTime.minute,
          dateTime.second,
          dateTime.millisecond,
          dateTime.microsecond,
        );
      }

      return dateTime;
    }

    return null;
  }

  static DateTime? toNormalizeDateTime(
    String dateTimeString, {
    bool isUtc = false,
  }) {
    final dateTime = DateTime.tryParse('-123450101 $dateTimeString');
    if (dateTime != null) {
      if (isUtc) {
        return DateTime.utc(
          dateTime.year,
          dateTime.month,
          dateTime.day,
          dateTime.hour,
          dateTime.minute,
          dateTime.second,
          dateTime.millisecond,
          dateTime.microsecond,
        );
      }

      return dateTime;
    }

    return null;
  }

  static DateTime? tryParse({
    String? date,
    String? format,
    String? locale,
  }) {
    if (date == null) {
      return null;
    }

    if (format == null) {
      return DateTime.tryParse(date);
    }

    final finalLocale = locale ?? Intl.defaultLocale;

    final DateFormat dateFormat = DateFormat(format, finalLocale);
    try {
      return dateFormat.parse(date);
    } catch (e) {
      return null;
    }
  }

  static String timeAgo(
    BuildContext context,
    DateTime dateTime,
  ) {
    // return hours ago if less than 24 hours else return date
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inHours < 24) {
      final days = diff.inDays;
      final hours = diff.inHours;
      final minutes = diff.inMinutes;

      if (minutes == 0) {
        return context.l10n.time_ago__just_now;
      } else if (hours == 0) {
        return context.l10n.time_ago__minutes(minutes);
      } else if (hours == 1) {
        return context.l10n.time_ago__1_hour;
      } else if (days == 0) {
        return context.l10n.time_ago__hours(hours);
      }

      return dateTime
          .toStringWithFormat(DateTimeFormatConstants.timeOnlyFormat);
    }

    return dateTime.toStringWithFormat(DateTimeFormatConstants.dateOnlyFormat);
  }

  static String timeAgoStory(
    BuildContext context,
    String dateTime, {
    String format = DateTimeFormatConstants.dateOnlyFormat,
  }) {
    final utcDate = '${dateTime}Z';
    final localDate = DateTime.parse(utcDate).toLocal();

    final createdAt = localDate.subtract(const Duration(hours: 24));

    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inHours < 24) {
      final days = diff.inDays;
      final hours = diff.inHours;
      final minutes = diff.inMinutes;

      if (minutes == 0) {
        return context.l10n.time_ago__just_now;
      } else if (hours == 0) {
        return context.l10n.time_ago__minutes(minutes);
      } else if (hours == 1) {
        return context.l10n.time_ago__1_hour;
      } else if (days == 0) {
        return context.l10n.time_ago__hours(hours);
      }

      return createdAt
          .toStringWithFormat(DateTimeFormatConstants.timeOnlyFormat);
    }

    return localDate.toStringWithFormat(format);
  }

  static String formatSecondsToTime(int seconds) {
    final int hours = (seconds / 3600).floor();
    final int remainingSecondsWithoutHours = seconds % 3600;
    final int minutes = (remainingSecondsWithoutHours / 60).floor();
    final int remainingSeconds = remainingSecondsWithoutHours % 60;

    final String hoursStr = (hours < 10) ? '0$hours' : '$hours';
    final String minutesStr = (minutes < 10) ? '0$minutes' : '$minutes';
    final String secondsStr =
        (remainingSeconds < 10) ? '0$remainingSeconds' : '$remainingSeconds';

    if (hours == 0 && minutes > 0) {
      return '($minutesStr:$secondsStr)';
    } else if (hours == 0 && minutes == 0 && remainingSeconds > 0) {
      return '($secondsStr)';
    } else if (hours == 0 && minutes == 0 && remainingSeconds == 0) {
      return '';
    }

    return '$hoursStr:$minutesStr:$secondsStr';
  }
}
