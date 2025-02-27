import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'callers.g.dart';

@JsonSerializable()
class Callers {
  User user;

  Callers({
    required this.user,
  });

  factory Callers.fromJson(Map<String, dynamic> json) {
    return _$CallersFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CallersToJson(this);

  static List<Callers> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => Callers.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
