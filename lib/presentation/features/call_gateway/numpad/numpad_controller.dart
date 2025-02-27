import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../../models/user.dart';
import '../../../../repositories/all.dart';
import '../../../base/all.dart';
import '../../call/call.dart';

class NumpadController extends BaseController {
  final TextEditingController textEditingController = TextEditingController();

  final UserRepository _userRepository = Get.find<UserRepository>();
  final ChatRepository _chatRepository = Get.find<ChatRepository>();

  void checkPhoneNumberIsExists() {
    if (textEditingController.text.isNotEmpty) {
      runAction(
        action: () async {
          final List<User> users =
              await _userRepository.getUserByPhone(textEditingController.text);
          if (users.isEmpty) {
            ViewUtil.showToast(
              title: l10n.call__numpad_warning,
              message: l10n.call__numpad_phone_not_exits,
            );

            return;
          } else {
            /// implement call người có số điện thoại trong hệ thống
            if (users.first.id == currentUser.id) {
              ViewUtil.showToast(
                title: l10n.call__numpad_warning,
                message: l10n.call__numpad_not_call_myself,
              );

              return;
            }
            await createCall(users.first);
          }
        },
        onError: (e) {
          ViewUtil.showToast(
            title: l10n.call__numpad_warning,
            message: l10n.global__error_has_occurred,
          );
        },
      );
    }
  }

  Future createCall(User receiver) async {
    final conversation =
        await _chatRepository.createConversation([receiver.id]);
    await CallKitManager.instance.createCall(
      chatChannelId: conversation.id,
      receiverIds: [receiver.id],
      isGroup: false,
      isVideo: false,
      isTranslate: false,
    );
  }
}
