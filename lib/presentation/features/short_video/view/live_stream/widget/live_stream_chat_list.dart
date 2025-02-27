import 'package:flutter/material.dart';

import '../../../custom_view/image_place_holder.dart';
import '../../../modal/live_stream/live_stream.dart';
import '../../../utils/colors.dart';
import '../../../utils/font_res.dart';

class LiveStreamChatList extends StatelessWidget {
  final List<LiveStreamComment> commentList;
  final BuildContext pageContext;

  const LiveStreamChatList({
    required this.commentList,
    required this.pageContext,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double tempSize = MediaQuery.of(pageContext).viewInsets.bottom == 0
        ? 0
        : MediaQuery.of(pageContext).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.only(left: 10),
      height: (tempSize == 0)
          ? (MediaQuery.of(context).size.height - 270) / 2
          : (MediaQuery.of(context).size.height - 270) - tempSize - 50,
      width: MediaQuery.of(context).size.width,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red, Colors.transparent, Colors.transparent],
            stops: [0.0, 0.3, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstOut,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: commentList.length,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          reverse: true,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        border: Border.all(color: ColorRes.white),
                        borderRadius: BorderRadius.circular(30)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        commentList[index].userImage ?? '',
                        fit: BoxFit.cover,
                        height: 35,
                        width: 35,
                        errorBuilder: (context, error, stackTrace) {
                          return ImagePlaceHolder(
                              heightWeight: 35,
                              name: commentList[index].fullName,
                              fontSize: 15);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(commentList[index].fullName ?? '',
                            style: const TextStyle(
                                color: ColorRes.white,
                                fontSize: 13,
                                fontFamily: FontRes.fNSfUiMedium)),
                        const SizedBox(height: 2),
                        commentList[index].commentType == 'msg'
                            ? Text(commentList[index].comment ?? '',
                                style: const TextStyle(
                                    color: ColorRes.greyShade100, fontSize: 12))
                            : Container(
                                height: 55,
                                width: 55,
                                padding: const EdgeInsets.all(5),
                                child: Image.network(
                                  commentList[index].comment ?? '',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container();
                                  },
                                ),
                              ),
                      ],
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
