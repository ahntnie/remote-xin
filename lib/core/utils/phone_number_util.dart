import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneNumberUtil {
  static Future<String> formatPhoneNumber(String phoneNumber) async {
    if (phoneNumber.isEmpty) return '';

    final PhoneNumber infoPhoneNumber =
        await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber);

    final String phoneNumberParsable =
        await PhoneNumber.getParsableNumber(infoPhoneNumber);

    return '(+${infoPhoneNumber.dialCode}) ${phoneNumberParsable.removeAllWhitespace}';
  }
}
