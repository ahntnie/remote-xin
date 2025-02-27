import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/all.dart';
import 'exception_message_mapper.dart';

class ExceptionWrapper {
  ExceptionWrapper({
    required this.exception,
    required this.message,
  });

  final AppException exception;
  final String message;
}

abstract class ExpiredTokenHandler {
  void onRefreshTokenFailed();
}

class ExceptionHandler {
  ExceptionHandler({this.onTokenExpired});

  final VoidCallback? onTokenExpired;

  void handleException(AppException appException, {String? overrideMessage}) {
    final exception = ExceptionWrapper(
      exception: appException,
      message: overrideMessage ?? AppExceptionMessageMapper().map(appException),
    );

    switch (appException.type) {
      case AppExceptionType.api:
        return _handleApiException(exception);
      case AppExceptionType.parse:
      case AppExceptionType.validation:
      case AppExceptionType.uncaught:
      case AppExceptionType.custom:
        return _handleCustomException(exception);
      default:
        return;
    }
  }

  void _handleApiException(ExceptionWrapper exceptionWrapper) {
    final exception = exceptionWrapper.exception as ApiException;

    switch (exception.kind) {
      case ApiExceptionKind.refreshTokenFailed:
        return _showErrorDialog(
          message: exceptionWrapper.message,
          isRefreshTokenFailed: true,
        );
      case ApiExceptionKind.serverDefined:
        // TODO: Handle this case.
        break;
      case ApiExceptionKind.noInternet:
      case ApiExceptionKind.network:
      case ApiExceptionKind.badRequest:
      case ApiExceptionKind.timeout:
      case ApiExceptionKind.cancellation:
        return _showErrorDialog(
          message: exceptionWrapper.message,
        );

      default:
        break;
    }
  }

  void _showErrorDialog({
    required String message,
    VoidCallback? onPressed,
    bool isRefreshTokenFailed = false,
  }) {
    ViewUtil.showAppDialog(
      title: Get.context!.l10n.global__error_has_occurred,
      message: message,
      positiveText: Get.context!.l10n.button__ok,
      onPositivePressed: () {
        onPressed?.call();
      },
    ).then((value) {
      if (isRefreshTokenFailed) {
        _handleTokenExpired();
      }
    });
  }

  void _handleTokenExpired() {
    if (onTokenExpired != null) {
      onTokenExpired!();
    }
  }

  void _handleCustomException(ExceptionWrapper exception) {
    if (exception.message.isBlank) {
      return;
    }

    return _showErrorDialog(message: exception.message);
  }
}
