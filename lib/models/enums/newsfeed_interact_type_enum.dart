enum NewsfeedInteractTypeEnum {
  view(core: 1),
  like(core: 1),
  unLike(core: 1),
  comment(core: 1),
  share(core: 1),
  follow(core: 1);

  final int core;

  const NewsfeedInteractTypeEnum({required this.core});
}
extension NewsfeedInteractTypeEnumExtension on NewsfeedInteractTypeEnum {
  String get apiCode {
    switch (this) {
      case NewsfeedInteractTypeEnum.view:
        return 'view_count';
      case NewsfeedInteractTypeEnum.like:
        return 'like_count';
      case NewsfeedInteractTypeEnum.unLike:
        return 'unlike_count';
      case NewsfeedInteractTypeEnum.comment:
        return 'comment_count';
      case NewsfeedInteractTypeEnum.share:
        return 'share_count';
      case NewsfeedInteractTypeEnum.follow:
        return 'follow_count';
    }
  }
}