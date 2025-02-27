import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../models/user.dart';

part 'login_response_data.freezed.dart';
part 'login_response_data.g.dart';

@freezed
class LoginResponseData with _$LoginResponseData {
  const LoginResponseData._();

  const factory LoginResponseData({
    required String token,
    required User user,
  }) = _LoginResponseData;

  factory LoginResponseData.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDataFromJson(json);
}
