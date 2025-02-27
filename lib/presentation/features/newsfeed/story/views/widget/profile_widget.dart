import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/all.dart';
import '../../../../../../models/user_story.dart';
import '../../../../../common_controller.dart/all.dart';
import '../../../../../common_widgets/all.dart';
import '../../../../../resource/resource.dart';

class ProfileWidget extends StatelessWidget {
  final UserStory user;
  final String date;
  final VoidCallback onTapMenu;
  final VoidCallback onTapItem;

  ProfileWidget({
    required this.user,
    required this.date,
    required this.onTapMenu,
    required this.onTapItem,
    super.key,
  });

  final appController = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 56),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppCircleAvatar(size: 50, url: user.avatar ?? ''),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                user.name ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                DateTimeUtil.timeAgoStory(context, date),
                style: const TextStyle(color: Colors.white38),
              ),
            ],
          ),
          const Spacer(),
          user.userId == appController.currentUser.id
              ? PopupMenuButton(
                  onOpened: onTapMenu,
                  onSelected: (value) {
                    if (value == 'delete') {
                      onTapItem.call();
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          context.l10n.button__delete,
                          style: AppTextStyles.s14w400.text2Color,
                        ),
                      ),
                    ];
                  },
                  icon: const Icon(Icons.more_horiz),
                  color: Colors.white,
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
