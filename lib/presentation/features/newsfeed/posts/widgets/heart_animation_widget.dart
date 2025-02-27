import 'package:flutter/material.dart';

class HeartAnimationWiget extends StatefulWidget {
  final Widget child;
  final bool isAnimating;
  final Duration duration;
  final VoidCallback onEnd;
  const HeartAnimationWiget(
      {required this.child,
      required this.onEnd,
      super.key,
      this.isAnimating = true,
      this.duration = const Duration(milliseconds: 200)});

  @override
  State<HeartAnimationWiget> createState() => _HeartAnimationWigetState();
}

class _HeartAnimationWigetState extends State<HeartAnimationWiget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final haftDuration = widget.duration;
    controller = AnimationController(vsync: this, duration: haftDuration);
    scale = Tween<double>(begin: 1, end: 1.2).animate(controller);
  }

  @override
  void didUpdateWidget(covariant HeartAnimationWiget oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    if (widget.isAnimating != oldWidget.isAnimating) {
      doAnimation();
    }
  }

  Future doAnimation() async {
    if (widget.isAnimating) {
      await controller.forward();
      await controller.reverse();
      await Future.delayed(const Duration(milliseconds: 300));
      widget.onEnd();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: widget.child,
    );
  }
}
