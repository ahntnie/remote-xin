import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/colors.dart';
import '../utils/font_res.dart';
import '../utils/my_loading/my_loading.dart';

class DataNotFound extends StatelessWidget {
  const DataNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, MyLoading myLoading, child) => const SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Be the first to comment',
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: FontRes.fNSfUiBold,
                    color: ColorRes.colorTextLight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
