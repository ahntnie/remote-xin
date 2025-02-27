import 'package:flutter/material.dart';

import '../../../../../resource/resource.dart';
import '../../../utils/assert_image.dart';
import '../../../utils/colors.dart';
import '../../../view/live_stream/model/broad_cast_screen_view_model.dart';

class LiveStreamBottomField extends StatelessWidget {
  final BroadCastScreenViewModel model;

  const LiveStreamBottomField({
    required this.model,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(30)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(
                            fontSize: 15, color: ColorRes.white),
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        controller: model.commentController,
                        focusNode: model.commentFocus,
                        cursorColor: ColorRes.white,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Comment...',
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            hintStyle: TextStyle(
                                color: ColorRes.white.withOpacity(0.70),
                                fontSize: 15)),
                      ),
                    ),
                    InkWell(
                      onTap: model.onComment,
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.blue10,
                        ),
                        child: Image.asset(send),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: !model.isHost,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => model.onGiftTap(context),
                child: Container(
                  height: 45,
                  width: 45,
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.blue10,
                  ),
                  child: Image.asset(gift),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
