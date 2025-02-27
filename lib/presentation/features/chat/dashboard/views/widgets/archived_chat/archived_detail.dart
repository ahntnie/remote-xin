import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common_widgets/common_app_bar.dart';
import '../../../controllers/dashboard_controller.dart';
import '../_conversation_item.dart';

class ArchivedChatsScreen extends StatefulWidget {
  final ChatDashboardController controller;

  const ArchivedChatsScreen({required this.controller, super.key});

  @override
  State<ArchivedChatsScreen> createState() => _ArchivedChatsScreenState();
}

class _ArchivedChatsScreenState extends State<ArchivedChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(),
      body: Obx(() {
        final archivedConversations = widget.controller.archivedConversations;
        if (archivedConversations.isEmpty) {
          return const Center(
            child: Text(
              'No archived chats',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        if (archivedConversations.isNotEmpty &&
            archivedConversations[0].messages.isNotEmpty) {
          print('Hahahaha');
          print(archivedConversations[0].messages[0].content);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: archivedConversations.length,
          itemBuilder: (context, index) {
            final conversation = archivedConversations[index];
            return ConversationItem(
              key: ValueKey(conversation.id),
              conversation: conversation,
              controller: widget.controller,
              isArchived: true,
            );
          },
        );
      }),
    );
  }
}
