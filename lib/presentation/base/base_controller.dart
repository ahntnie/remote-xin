// ignore_for_file: member-ordering, depend_on_referenced_packages

import 'dart:async';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get/get.dart';

import '../../core/all.dart';
import '../../data/preferences/app_preferences.dart';
import '../../data/preferences/base_storage.dart';
import '../../models/all.dart';
import '../../repositories/all.dart';
import '../../services/chat_socket_service.dart';
import '../common_controller.dart/app_controller.dart';
import '../routing/routers/app_pages.dart';
import 'exception_handler.dart';

abstract class BaseController extends GetxController
    with LogMixin, BaseStorage
    implements ExpiredTokenHandler {
  AppLocalizations get l10n => AppLocalizations.of(Get.context!)!;

  // Only use this when you are sure that the user is logged in
  User get currentUser => Get.find<AppController>().lastLoggedUser!;
  Rx<User?> get currentUserRx => Get.find<AppController>().lastLoggedUserRx;

  late ExceptionHandler exceptionHandler =
      ExceptionHandler(onTokenExpired: onRefreshTokenFailed);

  // error message
  final _errorMessageController = ''.obs;
  String get errorMessage => _errorMessageController.value;

  void showErrorMessage(String message) {
    ViewUtil.showAppSnackBar(Get.context!, message);
    _errorMessageController.value = message;
  }

  void hideErrorMessage() {
    ViewUtil.showAppSnackBar(Get.context!, '');
    _errorMessageController.value = '';
  }

  // loading
  final _loadingController = false.obs;
  bool get isLoading => _loadingController.value;
  void showLoading() => _loadingController.value = true;
  void hideLoading() => _loadingController.value = false;

  @protected
  Future<void> runAction<T>({
    required Future<T> Function() action,
    Function(AppException exception)? onError,
    Future<T> Function()? onSuccess,
    Function? onStart,
    Function? onComplete,
    bool handleLoading = true,
    bool handleError = false,
    String? overrideMessage,
  }) async {
    try {
      if (handleLoading) {
        showLoading();
      }

      if (onStart != null) {
        onStart();
      }

      await action();

      if (onSuccess != null) {
        await onSuccess();
      }
    } on AppException catch (e) {
      logError(e);

      onError?.call(e);

      if (!handleError && _isRefreshTokenFailed(e)) {
        unawaited(onRefreshTokenFailed());
      }

      if (handleError) {
        exceptionHandler.handleException(e, overrideMessage: overrideMessage);
      }
    } finally {
      hideLoading();

      if (onComplete != null) {
        await onComplete();
      }
    }
  }

  @override
  Future<void> onRefreshTokenFailed() async {
    await logout();
    ViewUtil.showAppSnackBar(Get.context!, l10n.global__token_expired_message);

    unawaited(Get.offAllNamed(Routes.authOption));
  }

  bool _isRefreshTokenFailed(AppException exception) {
    if (exception is! ApiException) {
      return false;
    }

    return exception.kind == ApiExceptionKind.refreshTokenFailed;
  }

  Future<void> logout() async {
    try {
      final deviceId = await DeviceUtil.getDeviceId();
      await Get.find<AuthRepository>().logout(deviceId ?? '');
    } finally {
      Get.find<ChatSocketService>().disconnectSocket();
      await Get.find<AppPreferences>().deleteAllTokens();
      Get.find<AppController>().setLogged(false);
      unawaited(DefaultCacheManager().emptyCache());

      await Get.offAllNamed(Routes.authOption);
    }
  }

  @override
  String get boxName => '';

  final List<Worker> _workers = [];

  @protected
  Future<T?> hydrate<T, E>(
    RxInterface<T?> listener, {
    required String key,
    E? Function(T? value)? encoder,
    T? Function(E? value)? decoder,
  }) async {
    assert(key.isNotEmpty);
    assert(encoder == null && decoder == null ||
        encoder != null && decoder != null);

    final worker = ever<T?>(
      listener,
      (value) => encoder != null
          ? write<E?>(key, encoder(value))
          : write<T?>(key, value),
    );

    _workers.add(worker);

    return decoder != null ? decoder(await read<E>(key)) : await read<T>(key);
  }

  @override
  void onClose() {
    for (var worker in _workers) {
      worker.dispose();
    }

    super.onClose();
  }
}
