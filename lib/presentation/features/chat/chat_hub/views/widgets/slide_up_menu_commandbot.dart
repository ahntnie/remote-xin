import 'package:flutter/material.dart';

class SlideUpMenuCommandBot extends StatefulWidget {
  final Widget child;
  final bool isVisible;
  const SlideUpMenuCommandBot({
    required this.child,
    required this.isVisible,
    Key? key,
  }) : super(key: key);

  @override
  State<SlideUpMenuCommandBot> createState() => _SlideUpMenuCommandBotState();
}

class _SlideUpMenuCommandBotState extends State<SlideUpMenuCommandBot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  void _runShowAnimation() {
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.value = 0.0;
    _controller.forward();
  }

  void _runHideAnimation() {
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -1.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.value = 0.0;
    _controller.forward();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    if (widget.isVisible) {
      _runShowAnimation();
    } else {
      _offsetAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(0.0, -1.0),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant SlideUpMenuCommandBot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isVisible != widget.isVisible) {
      if (widget.isVisible) {
        _runShowAnimation();
      } else {
        _runHideAnimation();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: widget.child,
    );
  }
}
