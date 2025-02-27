import '../base/app_exception.dart';

class AuthException extends AppException {
  const AuthException(this.kind, [this.exception])
      : super(AppExceptionType.custom);

  final AuthExceptionKind kind;
  final Object? exception;

  @override
  String toString() {
    return 'AuthException{kind: $kind, exception: $exception}';
  }
}

enum AuthExceptionKind {
  invalidCredentials,
  emailAlreadyInUse,
  phoneAlreadyInUse,
  inActiveAccount,
  unknown,
  custom,
  otpIncorrect,
  userNotFound,
  resetPasswordFail,
  limitOtp,
  userIsLocked,
  userIsAdmin,
  otpNotExpired,
}
