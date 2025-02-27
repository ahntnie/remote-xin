import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';

import '../../../../../../models/message.dart';
import '../../../../../../models/story.dart';
import '../../../../../../models/user_story.dart';
import '../../../../../../repositories/chat_repo.dart';
import '../../../../../resource/styles/app_colors.dart';
import 'custom_textfield.dart';

class CommentWidget extends StatefulWidget {
  final VoidCallback onTap;
  final Function()? onKeyboardHidden;
  final bool isExpanded;
  final UserStory userStory;
  final Story story;
  const CommentWidget({
    required this.onTap,
    required this.onKeyboardHidden,
    required this.isExpanded,
    required this.userStory,
    required this.story,
    super.key,
  });

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget>
    with SingleTickerProviderStateMixin {
  final commentController = TextEditingController();
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  final FocusNode _focusNode = FocusNode();
  late KeyboardVisibilityController _keyboardDetectionController;
  final _chatRepository = Get.find<ChatRepository>();
  Message? message;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _widthAnimation = Tween<double>(begin: 200.0, end: 350.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _focusNode.addListener(_onFocusChange);
    _keyboardDetectionController = KeyboardVisibilityController();
    _keyboardDetectionController.onChange.listen((bool visible) {
      // _toggleExpansion(visible);
    });
    if (widget.isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(CommentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      setState(() {
        _isExpanded = widget.isExpanded;
      });

      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  // void _toggleExpansion(bool visible) {
  //   setState(() {
  //     _isExpanded = visible;
  //     if (_isExpanded) {
  //       _animationController.forward();
  //     } else {
  //       _animationController.reverse();
  //     }
  //   });
  // }

  // void _onFocusChange() {
  //   if (!_focusNode.hasFocus && _isExpanded) {
  //     widget.onKeyboardHidden?.call();
  //     setState(() {
  //       _isExpanded = false;
  //       _animationController.reverse();
  //     });
  //   }
  // }
  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isExpanded) {
      if (widget.onKeyboardHidden != null) {
        widget.onKeyboardHidden!.call();
      }
      setState(() {
        _isExpanded = false;
      });
      _animationController.reverse();
    }
  }

  Future<void> repStory() async {
    try {
      final message = await _chatRepository.repStory(
        content: commentController.text,
        repliedStoryId: widget.story.storyId.toString(),
        userId: widget.userStory.userId.toString(),
      );

      await showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: const Text('Thành công'),
            content: const Text('Bạn đã gửi phản hồi thành công!'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      commentController.clear();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: AnimatedBuilder(
          animation: _widthAnimation,
          builder: (context, child) {
            return SizedBox(
              width: _widthAnimation.value,
              height: 55,
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      focusNode: _focusNode,
                      controller: commentController,
                      name: 'Say something...',
                      inputType: TextInputType.text,
                      backgroundColor: AppColors.disable,
                      onTap: () {
                        widget.onTap.call();
                      },
                    ),
                  ),
                  if (_isExpanded)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: AppColors.primary,
                          size: 30,
                        ),
                        onPressed: repStory,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
