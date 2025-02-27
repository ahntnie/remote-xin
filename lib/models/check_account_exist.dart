import 'package:json_annotation/json_annotation.dart';

part 'check_account_exist.g.dart';

@JsonSerializable()
class CheckAccountExist {
  final String code;
  final bool accountExist;

  CheckAccountExist({
    required this.code,
    required this.accountExist,
  });

  factory CheckAccountExist.fromJson(Map<String, dynamic> json) {
    return _$CheckAccountExistFromJson(json);
  }
}
