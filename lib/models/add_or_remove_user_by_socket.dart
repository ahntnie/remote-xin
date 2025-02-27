import 'package:json_annotation/json_annotation.dart';

part 'add_or_remove_user_by_socket.g.dart';

@JsonSerializable()
class AddOrRemoveUserBySocket {
  @JsonKey(name: 'roomId')
  String roomId;
  @JsonKey(name: 'addedMembers')
  List<String> addedMembers;
  @JsonKey(name: 'removedMembers')
  List<String> removedMembers;

  AddOrRemoveUserBySocket({
    required this.roomId,
    this.addedMembers = const [],
    this.removedMembers = const [],
  });

  factory AddOrRemoveUserBySocket.fromJson(Map<String, dynamic> json) {
    return _$AddOrRemoveUserBySocketFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AddOrRemoveUserBySocketToJson(this);
}
