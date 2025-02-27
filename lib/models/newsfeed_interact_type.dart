import 'enums/newsfeed_interact_type_enum.dart';

class NewsfeedInteractType {
  final NewsfeedInteractTypeEnum type;
  final int postId;
  final int? commentId;
  final DateTime createdAt = DateTime.now();

  NewsfeedInteractType({
    required this.type,
    required this.postId,
    this.commentId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsfeedInteractType &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          postId == other.postId &&
          commentId == other.commentId;

  @override
  int get hashCode => type.hashCode ^ postId.hashCode ^ commentId.hashCode;

}
