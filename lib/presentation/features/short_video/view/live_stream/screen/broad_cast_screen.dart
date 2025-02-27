import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../../../resource/resource.dart';
import '../../../modal/user/user.dart';
import '../../../view/live_stream/model/broad_cast_screen_view_model.dart';
import '../../../view/live_stream/widget/broad_cast_top_bar_area.dart';
import '../../../view/live_stream/widget/live_stream_bottom_filed.dart';
import '../../../view/live_stream/widget/live_stream_chat_list.dart';

class BroadCastScreen extends StatelessWidget {
  final String? agoraToken;
  final String? channelName;
  final User? registrationUser;

  const BroadCastScreen({
    required this.agoraToken,
    required this.channelName,
    Key? key,
    this.registrationUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BroadCastScreenViewModel>.reactive(
      onViewModelReady: (model) {
        return model.init(
            isBroadCast: true,
            agoraToken: agoraToken ?? '',
            channelName: channelName ?? '',
            registrationUser: registrationUser);
      },
      onDispose: (viewModel) {
        viewModel.leave();
      },
      viewModelBuilder: () => BroadCastScreenViewModel(),
      builder: (context, model, child) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            model.onEndButtonClick();
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: model.videoPanel(),
                ),
                Column(
                  children: [
                    AppSpacing.gapH4,
                    // Image.asset(
                    //   ImageConstants.logo,
                    //   width: 0.2.sw,
                    // ),
                    BroadCastTopBarArea(model: model),
                    const Spacer(),
                    LiveStreamChatList(
                        commentList: model.commentList, pageContext: context),
                    LiveStreamBottomField(
                      model: model,
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
