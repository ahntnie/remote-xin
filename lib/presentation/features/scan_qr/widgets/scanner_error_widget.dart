import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/all.dart';

class ScannerErrorWidget extends StatelessWidget {
  const ScannerErrorWidget({required this.error, super.key});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    String errorMessage;

    switch (error.errorCode) {
      case MobileScannerErrorCode.controllerUninitialized:
        errorMessage = context.l10n.scan__error_not_ready;
      case MobileScannerErrorCode.permissionDenied:
        errorMessage = context.l10n.scan__error_unsupported;
      case MobileScannerErrorCode.unsupported:
        errorMessage = context.l10n.scan__error_permission_denied;
      default:
        errorMessage = context.l10n.scan__error_generic_error;
        break;
    }

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Icon(Icons.error, color: Colors.white),
            ),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
            // Text(
            //   error.errorDetails?.message ?? '',
            //   style: const TextStyle(color: Colors.white),
            // ),
          ],
        ),
      ),
    );
  }
}
