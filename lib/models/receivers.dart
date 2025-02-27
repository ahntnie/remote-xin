import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'receivers.g.dart';

@JsonSerializable()
class Receivers {
  User user;

  Receivers({
    required this.user,
  });

  factory Receivers.fromJson(Map<String, dynamic> json) {
    return _$ReceiversFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ReceiversToJson(this);

  static List<Receivers> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => Receivers.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
