enum TypeNotificationEnum {
  postReaction(r'Pi\XFactor\Notifications\PostReaction'),
  commentNoti(r'Pi\XFactor\Notifications\CommentNoti'),
  postLocked(r'Pi\XFactor\Notifications\PostLocked');

  final String value;
  const TypeNotificationEnum(this.value);
}
