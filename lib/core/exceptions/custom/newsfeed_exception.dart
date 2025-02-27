import '../base/app_exception.dart';

class NewsfeedException extends AppException {
  const NewsfeedException(this.kind, [this.exception])
      : super(AppExceptionType.custom);

  final NewsfeedExceptionKind kind;
  final Object? exception;

  @override
  String toString() {
    return 'AuthException{kind: $kind, exception: $exception}';
  }
}

enum NewsfeedExceptionKind { custom }
