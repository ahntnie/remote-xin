import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'all.dart';
import 'call_history.dart';
import 'callers.dart';
import 'receivers.dart';
import 'utc_time_converter.dart';

part 'call.g.dart';

@JsonSerializable()
@UTCDateTimeConverter()
class Call {
  String id;
  String chatChannelId;
  bool? isGroup;
  bool? isVideo;
  bool? isTranslate;
  DateTime? createdAt;
  DateTime? startedAt;
  DateTime? canceledAt;
  DateTime? endedAt;
  int? duration;
  List<Callers> callers;
  List<Receivers> receivers;
  @JsonKey(name: 'participants')
  List<CallHistory>? callHistories;
  Conversation? conversation;

  Call({
    required this.id,
    required this.chatChannelId,
    this.isGroup,
    this.isVideo,
    this.isTranslate,
    this.createdAt,
    this.startedAt,
    this.canceledAt,
    this.endedAt,
    this.duration,
    this.callers = const [],
    this.receivers = const [],
    this.callHistories,
    this.conversation,
  });

  factory Call.fromJson(Map<String, dynamic> json) {
    return _$CallFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CallToJson(this);

  static List<Call> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => Call.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Call? callFromStringJson(String? json) {
    if (json == null || json.isEmpty) {
      return null;
    }

    return Call.fromJson(jsonDecode(json));
  }

  Call copyWith({
    String? id,
    String? chatChannelId,
    bool? isGroup,
    bool? isVideo,
    bool? isTranslate,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? canceledAt,
    DateTime? endedAt,
    int? duration,
    List<Callers>? callers,
    List<Receivers>? receivers,
    List<CallHistory>? callHistories,
    Conversation? conversation,
  }) {
    return Call(
      id: id ?? this.id,
      chatChannelId: chatChannelId ?? this.chatChannelId,
      isGroup: isGroup ?? this.isGroup,
      isVideo: isVideo ?? this.isVideo,
      isTranslate: isTranslate ?? this.isTranslate,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      canceledAt: canceledAt ?? this.canceledAt,
      endedAt: endedAt ?? this.endedAt,
      duration: duration ?? this.duration,
      callers: callers ?? this.callers,
      receivers: receivers ?? this.receivers,
      callHistories: callHistories ?? this.callHistories,
      conversation: conversation ?? this.conversation,
    );
  }
}
