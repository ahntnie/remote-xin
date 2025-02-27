import 'package:equatable/equatable.dart';

import 'message.dart';

class NewMessage extends Equatable {
  final String? creator;
  final Message? message;
  final bool? receiverMutedRoom;

  const NewMessage({
    this.creator,
    this.message,
    this.receiverMutedRoom = false,
  });

  @override
  List<Object?> get props => [
        creator,
        message,
        receiverMutedRoom,
      ];

  factory NewMessage.fromJson(Map<String, dynamic> json) {
    return NewMessage(
      creator: json['creator'],
      message: json['message'] != null
          ? Message.fromJson(json['message'] as Map<String, dynamic>)
          : null,
      receiverMutedRoom: json['receiverMutedRoom'] != null
          ? json['receiverMutedRoom'] as bool
          : false,
    );
  }
}
