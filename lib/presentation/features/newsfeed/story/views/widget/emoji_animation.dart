import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../resource/styles/styles.dart';

class EmojiAnimation extends StatefulWidget {
  final String emoji;
  final Function onTap;
  final bool isReaction;

  const EmojiAnimation(
      {required this.isReaction,
      required this.emoji,
      required this.onTap,
      Key? key})
      : super(key: key);

  @override
  _EmojiAnimationState createState() => _EmojiAnimationState();
}

class _EmojiAnimationState extends State<EmojiAnimation>
    with TickerProviderStateMixin {
  final List<AnimatedEmoji> _animatedEmojis = [];
  final double _emojiSize = 40;

  void _addNewEmoji() {
    final controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    final newEmoji = AnimatedEmoji(
      controller: controller,
      startOffset: const Offset(0, 240),
      emoji: widget.emoji,
    );
    setState(() {
      _animatedEmojis.add(newEmoji);
    });
    controller.forward().then((_) {
      setState(() {
        _animatedEmojis.remove(newEmoji);
      });
      controller.dispose();
    });
  }

  @override
  void dispose() {
    for (var emoji in _animatedEmojis) {
      emoji.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _addNewEmoji();
        widget.onTap();
      },
      child: Container(
        padding: const EdgeInsets.only(
          bottom: 8,
        ),
        // width: 50,
        // height: 50,
        color: Colors.transparent,
        child: Stack(
          children: [
            ..._animatedEmojis.map(
              (animatedEmoji) => AnimatedBuilder(
                animation: animatedEmoji.controller,
                builder: (context, child) {
                  final position = _calculatePosition(
                    animatedEmoji.controller.value,
                    animatedEmoji.startOffset,
                    animatedEmoji.randomSeed,
                    animatedEmoji.direction,
                  );

                  return Opacity(
                    opacity: 1 - animatedEmoji.controller.value,
                    child: Transform.translate(
                      offset: position,
                      child: Text(
                        animatedEmoji.emoji,
                        style: TextStyle(fontSize: _emojiSize),
                      ),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isReaction)
                    Container(
                      height: 5,
                      width: 5,
                      decoration: const BoxDecoration(
                          color: AppColors.blue10, shape: BoxShape.circle),
                    ),
                  Text(
                    widget.emoji,
                    style: TextStyle(fontSize: _emojiSize),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Offset _calculatePosition(
      double t, Offset startOffset, int seed, double direction) {
    final random = math.Random(seed);
    const endY = 20.0;
    final amplitude =
        20.0 + random.nextDouble() * 40.0; // Biên độ dao động ngẫu nhiên
    final frequency =
        1.0 + random.nextDouble() * 2.0; // Tần số dao động ngẫu nhiên

    // Di chuyển ziczac ngẫu nhiên theo hướng trái hoặc phải
    final x = startOffset.dx +
        amplitude * math.sin(frequency * math.pi * t) * direction;
    final y = startOffset.dy + (endY - startOffset.dy) * t;

    return Offset(x, y);
  }
}

class AnimatedEmoji {
  final AnimationController controller;
  final Offset startOffset;
  final String emoji;
  final int randomSeed;
  final double direction; // Hướng ngẫu nhiên: 1 hoặc -1

  AnimatedEmoji({
    required this.controller,
    required this.startOffset,
    required this.emoji,
  })  : randomSeed = math.Random().nextInt(1000),
        direction = math.Random().nextBool()
            ? 1
            : -1; // Ngẫu nhiên hướng trái hoặc phải
}
