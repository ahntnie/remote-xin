import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../all.dart';
import '../utc_time_converter.dart';

part 'notification.g.dart';

@JsonSerializable(explicitToJson: true)
@UTCDateTimeConverter()
// @BaseNotificationPayloadConverter()
class NotificationModel extends Equatable {
  final int id;
  final String title;
  final String contentText;
  final String notifiableType;
  final DateTime? createdAt;
  final DateTime? readAt;
  final String type;
  final BaseNotificationPayload? data;
  final User? author;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.contentText,
    required this.notifiableType,
    required this.type,
    this.createdAt,
    this.readAt,
    this.data,
    this.author,
  });

  bool get isRead => readAt != null;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final notification = _$NotificationModelFromJson(json);

    return notification;
  }

  static List<NotificationModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  NotificationModel copyWith({
    int? id,
    String? title,
    String? contentText,
    String? notifiableType,
    DateTime? createdAt,
    DateTime? readAt,
    String? type,
    BaseNotificationPayload? data,
    User? author,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      contentText: contentText ?? this.contentText,
      notifiableType: notifiableType ?? this.notifiableType,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      type: type ?? this.type,
      data: data ?? this.data,
      author: author ?? this.author,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        contentText,
        notifiableType,
        createdAt,
        readAt,
        type,
        data,
        author,
      ];
}

// class BaseNotificationPayloadConverter
//     implements JsonConverter<BaseNotificationPayload, String> {
//   const BaseNotificationPayloadConverter();

//   @override
//   BaseNotificationPayload fromJson(Map<String, dynamic> jsonString) {
//     final json = jsonDecode(jsonString);

//     return BaseNotificationPayload.fromJson(json);
//   }

//   @override
//   String toJson(BaseNotificationPayload object) {
//     return jsonEncode(object.toJson());
//   }
// }
