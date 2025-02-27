import 'package:flutter/material.dart';

import '../../core/all.dart';

abstract class BaseRepository with LogMixin {
  @protected
  Future<T> executeApiRequest<T>(
    Future<T> Function() datasourceCall,
  ) async {
    try {
      return await datasourceCall();
    } catch (e) {
      logError(e);

      if (e is AppException) {
        rethrow;
      }

      throw AppException.unexpectedError(rootError: e);
    }
  }
}
