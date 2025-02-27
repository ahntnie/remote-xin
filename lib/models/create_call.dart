import 'package:freezed_annotation/freezed_annotation.dart';

import 'base/action_call.dart';

part 'create_call.g.dart';

@JsonSerializable()
class CreateCall extends ActionCall {
  String callId;

  CreateCall({
    required String token,
    required String appId,
    required this.callId,
  }) : super(appId, token);

  factory CreateCall.fromJson(Map<String, dynamic> json) {
    return _$CreateCallFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CreateCallToJson(this);

  static List<CreateCall> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((e) => CreateCall.fromJson(e as Map<String, dynamic>)).toList();
  }
}
