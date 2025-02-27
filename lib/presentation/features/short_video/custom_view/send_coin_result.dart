import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../languages/languages_keys.dart';
import '../utils/assert_image.dart';
import '../utils/colors.dart';
import '../utils/font_res.dart';

class SendCoinsResult extends StatefulWidget {
  final bool isSuccess;

  const SendCoinsResult(this.isSuccess, {super.key});

  @override
  _SendCoinsResultState createState() => _SendCoinsResultState();
}

class _SendCoinsResultState extends State<SendCoinsResult>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 2), () {
      _controller.dispose();
      Navigator.pop(context);
    });
    return Center(
      child: ScaleTransition(
        scale: _animation,
        child: Container(
          height: 160,
          width: 160,
          decoration: BoxDecoration(
            color: widget.isSuccess ? Colors.green : Colors.red,
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.isSuccess
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: ColorRes.white,
                      size: 35,
                    )
                  : const Image(
                      image: AssetImage(icSad),
                      color: ColorRes.white,
                      height: 50,
                    ),
              const SizedBox(height: 10),
              Text(
                widget.isSuccess
                    ? LKey.sentSuccessfully.tr
                    : LKey.insufficientBalance.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: FontRes.fNSfUiSemiBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
