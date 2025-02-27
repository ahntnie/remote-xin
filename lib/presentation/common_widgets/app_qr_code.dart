import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AppQrCodeView extends StatelessWidget {
  final String data;
  final double size;

  const AppQrCodeView(
    this.data, {
    super.key,
    this.size = 160, // here
  });

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: data,
      size: size,
      backgroundColor: Colors.white,
      errorCorrectionLevel: QrErrorCorrectLevel.H, // here
      // embeddedImage: Assets.images.logoSquareShort.provider(),
      embeddedImageStyle: const QrEmbeddedImageStyle(
        size: Size(40, 40), //here
      ),
    );
  }
}

// https://github.com/theyakka/qr.flutter/issues/142#issuecomment-1004243671
