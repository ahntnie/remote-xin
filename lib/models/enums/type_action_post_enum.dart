enum TypeActionPostEnum {
  commentPost('comment_post'),
  reactPost('react_post'),
  lockedPost('locked_post');

  final String value;
  const TypeActionPostEnum(this.value);
}
