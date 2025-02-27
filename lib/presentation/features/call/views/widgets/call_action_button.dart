import 'package:flutter/material.dart';

class CallActionButton extends StatelessWidget {
  const CallActionButton(
      {required this.onPressed,
      required this.child,
      super.key,
      this.fillColor,
      this.turnOn = false});

  final Function() onPressed;
  final Color? fillColor;
  final bool turnOn;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fillColor ?? (turnOn ? Colors.white : const Color(0xfff3f3f3)),
        border: fillColor == null
            ? Border.all(color: const Color(0xffe6edee), width: 2)
            : null,
        boxShadow: fillColor == null
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 4),
                  blurRadius: 1,
                  spreadRadius: 0.2,
                ),
              ]
            : [],
      ),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: child,
        ),
      ),
    );
  }
}
