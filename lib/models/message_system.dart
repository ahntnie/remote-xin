import 'package:equatable/equatable.dart';

class MessageSystem extends Equatable {
  final MessageSystemType type;
  final List<String> memberIds;

  const MessageSystem({
    required this.type,
    this.memberIds = const [],
  });

  @override
  List<Object?> get props => [
        type,
        memberIds,
      ];

  factory MessageSystem.fromJson(Map<String, dynamic> json) {
    return MessageSystem(
      type: _parseType(json['type'] as String),
      memberIds:
          (json['members'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  static MessageSystemType _parseType(String json) {
    return MessageSystemType.values.firstWhere((e) => e.value == json);
  }
}

enum MessageSystemType {
  addMember('Ad'),
  removeMember('Rm');

  final String value;

  const MessageSystemType(this.value);
}
