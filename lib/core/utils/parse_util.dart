import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';

import '../exceptions/parse_exception.dart';

class ParseUtil {
  const ParseUtil._();

  static int parseStringToInt(String value) {
    try {
      return int.parse(value);
    } on FormatException catch (e) {
      throw ParseException(ParseExceptionKind.invalidSourceFormat, e);
    }
  }

  static double parseStringToDouble(String value) {
    try {
      return double.parse(value);
    } on FormatException catch (e) {
      throw ParseException(ParseExceptionKind.invalidSourceFormat, e);
    }
  }

  static CallEvent parseCallEvent(Map<String, dynamic> map) {
    return CallEvent(
      sessionId: map['session_id'] as String,
      callType: int.tryParse(map['call_type'] as String? ?? '') ?? 0,
      callerId:  int.tryParse(map['caller_id'] as String? ?? '') ?? 0,
      callerName: map['caller_name'] as String,
      opponentsIds: (map['call_opponents'] as String)
          .split(',')
          .map((e) => int.parse(e))
          .toSet(),
      callPhoto: map['photo_url'] as String?,
    );
  }
}
