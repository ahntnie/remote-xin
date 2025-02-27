import 'dart:io';

import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../../../core/all.dart';
import '../../../../../models/all.dart';
import '../../../../base/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../../all.dart';
import '_shared_link_widget.dart';
import 'widgets/actions_chat_details_widget.dart';
import 'widgets/contact_info.dart';
import 'widgets/edit_info_group_chat.dart';

part '_group_chat_details.dart';
part '_private_chat_details.dart';

class ConversationDetailsView extends BaseView<ConversationDetailsController> {
  const ConversationDetailsView({super.key});

  @override
  Widget buildPage(BuildContext context) {
    return Obx(
      () => controller.conversation.isGroup
          ? _GroupChatDetails(controller: controller)
          : _PrivateChatDetails(controller: controller),
    );
  }
}
