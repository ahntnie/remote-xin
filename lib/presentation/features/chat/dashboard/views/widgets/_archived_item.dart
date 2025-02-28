import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../resource/resource.dart';
import '../../../../all.dart';
import 'archived_chat/archived_detail.dart';

class ArchivedItem extends StatefulWidget {
  final bool showChildOnly;
  final EdgeInsets? contentPadding;
  final ChatDashboardController controller;
  final VoidCallback? beforeGoToChat;

  const ArchivedItem({
    required this.controller,
    this.contentPadding,
    this.showChildOnly = false,
    this.beforeGoToChat,
    super.key,
  });

  @override
  State<ArchivedItem> createState() => _ConversationItemState();
}

class _ConversationItemState extends State<ArchivedItem> {
  @override
  Widget build(BuildContext context) {
    final child = GestureDetector(
      child: Container(
        color: AppColors.subText2.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8, top: 10),
          child: ListTile(
            contentPadding: widget.contentPadding,
            splashColor: Colors.transparent,
            leading: _buildSto(),
            title: const Text(
              'Archived chats',
              style: TextStyle(color: AppColors.text2),
            ),
          ),
        ),
      ),
      onTap: () {
        Get.to(() => ArchivedChatsScreen(
              controller: widget.controller,
            ));
      },
    );

    if (widget.showChildOnly) {
      return child;
    }

    return Container(
      child: child,
    );
  }

  Widget _buildSto() {
    return const CircleAvatar(
      radius: 25,
      backgroundColor: AppColors.blue10,
      child: Icon(
        size: 30,
        Icons.storage,
      ),
    );
  }
}
