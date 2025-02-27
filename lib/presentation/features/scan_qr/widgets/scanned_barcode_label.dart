import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/all.dart';

class ScannedBarcodeLabel extends StatefulWidget {
  const ScannedBarcodeLabel({
    required this.barcodes,
    required this.handleDeepLink,
    required this.scanViewContext,
    super.key,
  });
  final Function handleDeepLink;
  final Stream<BarcodeCapture> barcodes;
  final BuildContext scanViewContext;

  @override
  State<ScannedBarcodeLabel> createState() => _ScannedBarcodeLabelState();
}

class _ScannedBarcodeLabelState extends State<ScannedBarcodeLabel> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.barcodes,
      builder: (context, snapshot) {
        final scannedBarcodes = snapshot.data?.barcodes ?? [];

        if (scannedBarcodes.isEmpty) {
          return Text(
            context.l10n.scan__let_start,
            overflow: TextOverflow.fade,
            style: const TextStyle(color: Colors.white),
          );
        }

        if (scannedBarcodes.first.displayValue != null) {
          if (scannedBarcodes.first.displayValue != '') {
            widget.handleDeepLink(
              scannedBarcodes.first.displayValue,
              widget.scanViewContext,
            );
          }
        }
        return Text(
          scannedBarcodes.first.displayValue ?? context.l10n.scan__no_value,
          overflow: TextOverflow.fade,
          style: const TextStyle(color: Colors.white),
        );
      },
    );
  }
}
