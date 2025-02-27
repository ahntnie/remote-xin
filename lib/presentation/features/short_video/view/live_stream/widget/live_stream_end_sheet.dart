import 'package:flutter/material.dart';

import '../../../utils/colors.dart';
import '../../../utils/font_res.dart';

class LiveStreamEndSheet extends StatelessWidget {
  final String name;
  final VoidCallback onExitBtn;

  const LiveStreamEndSheet(
      {required this.name, required this.onExitBtn, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: const BoxDecoration(
        color: ColorRes.colorPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(15),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: onExitBtn,
                child: const Icon(Icons.close, color: ColorRes.white),
              ),
            ),
            const Spacer(),
            Text(
              name,
              style: const TextStyle(
                  color: ColorRes.white,
                  fontSize: 20,
                  fontFamily: FontRes.fNSfUiBold),
            ),
            const Text(
              'Live Stream Ended',
              style: TextStyle(
                  color: ColorRes.white,
                  fontSize: 19,
                  fontFamily: FontRes.fNSfUiRegular),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
