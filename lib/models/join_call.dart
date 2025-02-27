import 'package:freezed_annotation/freezed_annotation.dart';

import 'all.dart';

part 'join_call.g.dart';

@JsonSerializable()
class JoinCall extends ActionCall {
  final Call call;

  JoinCall({
    required String token,
    required this.call,
    required String appId,
  }) : super(appId, token);

  factory JoinCall.fromJson(Map<String, dynamic> json) {
    return _$JoinCallFromJson(json);
  }

  Map<String, dynamic> toJson() => _$JoinCallToJson(this);

  static List<JoinCall> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => JoinCall.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
