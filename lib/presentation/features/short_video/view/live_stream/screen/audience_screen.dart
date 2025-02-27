import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../modal/live_stream/live_stream.dart';
import '../../../view/live_stream/model/broad_cast_screen_view_model.dart';
import '../../../view/live_stream/widget/audience_top_bar.dart';
import '../../../view/live_stream/widget/live_stream_bottom_filed.dart';
import '../../../view/live_stream/widget/live_stream_chat_list.dart';

class AudienceScreen extends StatelessWidget {
  final String? agoraToken;
  final String? channelName;
  final LiveStreamUser user;

  const AudienceScreen({
    required this.user,
    Key? key,
    this.agoraToken,
    this.channelName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BroadCastScreenViewModel>.reactive(
      onViewModelReady: (model) {
        model.init(
          isBroadCast: false,
          agoraToken: agoraToken ?? '',
          channelName: channelName ?? '',
        );
      },
      viewModelBuilder: () => BroadCastScreenViewModel(),
      builder: (context, model, child) {
        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                model.videoPanel(),
                Column(
                  children: [
                    // AppSpacing.gapH4,
                    // Image.asset(
                    //   ImageConstants.logo,
                    //   width: 0.2.sw,
                    // ),
                    AudienceTopBar(model: model, user: user),
                    const Spacer(),
                    LiveStreamChatList(
                        commentList: model.commentList, pageContext: context),
                    LiveStreamBottomField(model: model)
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
