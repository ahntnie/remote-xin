import 'package:freezed_annotation/freezed_annotation.dart';

import 'all.dart';

part 'call_history.g.dart';

@JsonSerializable()
class CallHistory {
  final Call? call;
  final int userId;
  final String status;
  final int duration;
  final DateTime? joinedAt;
  final DateTime? leftAt;
  final String? role;
  CallHistory({
    required this.userId,
    required this.status,
    required this.duration,
    this.call,
    this.joinedAt,
    this.leftAt,
    this.role,
  });

  factory CallHistory.fromJson(Map<String, dynamic> json) {
    return _$CallHistoryFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CallHistoryToJson(this);

  static List<CallHistory> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => CallHistory.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
