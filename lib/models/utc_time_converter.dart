import 'package:json_annotation/json_annotation.dart';

class UTCDateTimeConverter implements JsonConverter<DateTime, String> {
  const UTCDateTimeConverter();

  @override
  DateTime fromJson(String dateTime) {
    if (dateTime[dateTime.length - 1].toLowerCase() == 'z') {
      return DateTime.parse(dateTime).toLocal();
    }

    return DateTime.parse('${dateTime}z').toLocal();
  }

  @override
  String toJson(DateTime dateTime) {
    return dateTime.toUtc().toString();
  }
}
