import 'package:flutter/material.dart';

import '../../../utils/colors.dart';

class SecondsTab extends StatelessWidget {
  final VoidCallback onTap;
  final bool isSelected;
  final String title;

  const SecondsTab(
      {required this.onTap,
      required this.isSelected,
      required this.title,
      super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 28,
        width: 60,
        decoration: BoxDecoration(
          color: isSelected ? ColorRes.white : Colors.black54,
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.black : ColorRes.white,
            ),
          ),
        ),
      ),
    );
  }
}
