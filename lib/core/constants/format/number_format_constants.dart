part of 'format_constants.dart';

class NumberFormatConstants {
  NumberFormatConstants._();

  static const String defaultFormat = '#,###';

  static String formatNumber(int number) {
    if (number >= 1000000) {
      final double result = number / 1000000.0;

      return '${result.toStringAsFixed(0)}M';
    } else if (number >= 1000) {
      final double result = number / 1000.0;

      return '${result.toStringAsFixed(0)}k';
    } else {
      return '$number';
    }
  }

  String formatPhoneNumber(String phone) {
    // Remove any existing spaces or special characters
    final String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Split into groups as per requirement
    final List<String> parts = [];

    // First group (039)
    if (cleaned.length >= 3) {
      parts.add(cleaned.substring(0, 3));
    }

    // Second group (558)
    if (cleaned.length >= 6) {
      parts.add(cleaned.substring(3, 6));
    }

    // Third group (17)
    if (cleaned.length >= 8) {
      parts.add(cleaned.substring(6, 8));
    }

    // Fourth group (11)
    if (cleaned.length >= 10) {
      parts.add(cleaned.substring(8, 10));
    }

    // Join with spaces
    return parts.join(' ');
  }
}
