import 'package:flutter/material.dart';

import '../resource/styles/app_colors.dart';

class SlidingSwitch extends StatefulWidget {
  final double height;
  final ValueChanged<bool> onChanged;
  final double width;
  final bool value;
  final String textOff;
  final String textOn;
  final IconData? iconOff;
  final IconData? iconOn;
  final double contentSize;
  final Duration animationDuration;
  final Color colorOn;
  final Color colorOff;
  final Color background;
  final Color inactiveColor;
  final Function onTap;
  final Function onSwipe;

  const SlidingSwitch({
    required this.value,
    required this.onChanged,
    required this.onTap,
    required this.onSwipe,
    super.key,
    this.height = 55,
    this.width = 250,
    this.animationDuration = const Duration(milliseconds: 400),
    this.textOff = 'Off',
    this.textOn = 'On',
    this.iconOff,
    this.iconOn,
    this.contentSize = 17,
    this.colorOn = const Color(0xffdc6c73),
    this.colorOff = const Color(0xff6682c0),
    this.background = AppColors.fieldBackground,
    this.inactiveColor = const Color(0xff636f7b),
  });
  @override
  State<SlidingSwitch> createState() => _SlidingSwitch();
}

class _SlidingSwitch extends State<SlidingSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  double value = 0.0;

  late bool turnState;

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: widget.animationDuration);
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut);
    animationController.addListener(() {
      setState(() {
        value = animation.value;
      });
    });
    turnState = widget.value;
    // ignore: avoid-unnecessary-setstate
    _determine(forwardFrom: 1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _action();
        widget.onTap();
      },
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: widget.background,
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.all(4),
        child: Stack(
          children: <Widget>[
            Transform.translate(
              offset: Offset((widget.width * 0.5) * value - (2 * value), 0),
              child: Container(
                height: widget.height,
                width: widget.width * 0.5 - 4,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                  color: AppColors.deepSkyBlue,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 10),
                      blurRadius: 20.0,
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: widget.iconOff == null
                        ? Text(
                            widget.textOff,
                            style: TextStyle(
                              color: turnState
                                  ? widget.inactiveColor
                                  : widget.colorOff,
                              fontSize: widget.contentSize,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : Icon(
                            widget.iconOff,
                            semanticLabel: widget.textOff,
                            size: widget.contentSize,
                            color: turnState
                                ? widget.inactiveColor
                                : widget.colorOff,
                          ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: widget.iconOn == null
                        ? Text(
                            widget.textOn,
                            style: TextStyle(
                              color: turnState
                                  ? widget.colorOn
                                  : widget.inactiveColor,
                              fontSize: widget.contentSize,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : Icon(
                            widget.iconOn,
                            semanticLabel: widget.textOn,
                            size: widget.contentSize,
                            color: turnState
                                ? widget.colorOn
                                : widget.inactiveColor,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _action() {
    _determine(changeState: true);
  }

  void _determine({
    bool changeState = false,
    double forwardFrom = 0.0,
  }) {
    setState(() {
      if (changeState) {
        turnState = !turnState;
      }

      turnState
          ? animationController.forward(
              from: forwardFrom,
            )
          : animationController.reverse();
      if (changeState) {
        widget.onChanged(turnState);
      }
    });
  }
}
