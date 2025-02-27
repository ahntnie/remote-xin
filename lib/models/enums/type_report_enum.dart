enum TypeReportEnum {
  message(r'Pi\Xfactor\Models\ChatMessage'),
  chat(r'Pi\Xfactor\Models\Chat'),
  user(r'Backend\Models\User'),
  post(r'Pi\XFactor\Models\Post');

  final String value;
  const TypeReportEnum(this.value);
}
