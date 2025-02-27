import 'package:flutter/material.dart';

import '../resource/styles/app_colors.dart';

class CheckBoxButton extends StatelessWidget {
  final bool value;
  final Function(bool?)? onChanged;
  const CheckBoxButton({required this.value, super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      onChanged: (value) {
        onChanged!(value);
      },
      side: const BorderSide(),
      checkColor: AppColors.text1,
      fillColor: MaterialStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.blue10;
          }

          return Colors.transparent;
        },
      ),
    );
  }
}
