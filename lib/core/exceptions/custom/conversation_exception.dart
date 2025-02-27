import '../base/app_exception.dart';

class ConversationException extends AppException {
  const ConversationException(this.kind, [this.exception])
      : super(AppExceptionType.custom);

  final ConversationExceptionKind kind;
  final Object? exception;

  @override
  String toString() {
    return 'AuthException{kind: $kind, exception: $exception}';
  }
}

enum ConversationExceptionKind {
  // delete
  onlyCreatorCanDelete,
}
