import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../../../../../models/conversation.dart';
import '../../../../../../../models/message.dart';
import '../../../../../../common_widgets/app_icon.dart';
import '../../../../../../common_widgets/reaction_chat_widget/model/menu_item.dart';
import '../../../../../../resource/styles/app_colors.dart';
import '../../../../../../resource/styles/gaps.dart';
import 'preview_messages.dart';

class PreviewChatDialogWidget extends StatefulWidget {
  const PreviewChatDialogWidget({
    required this.id,
    required this.messageWidget,
    required this.onReactionTap,
    required this.onContextMenuTap,
    required this.menuItems,
    required this.position,
    required this.messages,
    required this.conversation,
    required this.currentUserId,
    required this.indexLastSeen,
    super.key,
    this.widgetAlignment = Alignment.centerRight,
    this.menuItemsWidth = 0.47,
  });

  final int indexLastSeen;

  // Id for the hero widget
  final String id;

  // The message widget to be displayed in the dialog
  final Widget messageWidget;

  // The callback function to be called when a reaction is tapped
  final Function(String) onReactionTap;

  // The callback function to be called when a context menu item is tapped
  final Function(MenuItem) onContextMenuTap;

  // The list of menu items to be displayed in the context menu
  final List<MenuItem> menuItems;

  // The alignment of the widget
  final Alignment widgetAlignment;

  // The width of the menu items
  final double menuItemsWidth;

  final String position;

  final List<Message> messages;
  final Conversation conversation;
  final int currentUserId;

  @override
  State<PreviewChatDialogWidget> createState() =>
      _PreviewChatDialogWidgetState();
}

class _PreviewChatDialogWidgetState extends State<PreviewChatDialogWidget> {
  // state variables for activating the animation
  bool reactionClicked = false;
  int? clickedReactionIndex;
  int? clickedContextMenuIndex;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
      child: Align(
        alignment: widget.position == 'top'
            ? Alignment.topRight
            : widget.position == 'center'
                ? Alignment.centerRight
                : Alignment.bottomRight,
        child: Padding(
          padding: EdgeInsets.only(
              right: 20.0,
              left: 20.0,
              top: widget.position == 'top' ? 40 : 0,
              bottom: widget.position == 'bottom' ? 20 : 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              buildMessageList(),
              // message
              buildMessage(),
              const SizedBox(height: 10),
              // context menu
              buildMenuItems(context),
            ],
          ),
        ),
      ),
    );
  }

  Align buildMenuItems(BuildContext context) {
    return Align(
      alignment: widget.widgetAlignment,
      child: // contextMenu for reply, copy, delete
          Material(
        color: Colors.transparent,
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            // color: Colors.white,
            color: AppColors.grey7,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade500,
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSpacing.gapH4,
              for (var item in widget.menuItems)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                      child: InkWell(
                        onTap: () {
                          // set the clicked index for animation
                          setState(() {
                            clickedContextMenuIndex =
                                widget.menuItems.indexOf(item);
                          });

                          // delay for 200 milliseconds to allow the animation to complete
                          Future.delayed(const Duration(milliseconds: 300))
                              .whenComplete(() {
                            // pop the dialog
                            Navigator.of(context).pop();
                            widget.onContextMenuTap(item);
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.label,
                              style: TextStyle(
                                color: item.isDestuctive
                                    ? Colors.red
                                    : AppColors.text2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Pulse(
                              duration: const Duration(milliseconds: 300),
                              animate: clickedContextMenuIndex ==
                                  widget.menuItems.indexOf(item),
                              child: AppIcon(
                                icon: item.icon,
                                color: item.isDestuctive
                                    ? Colors.red
                                    : AppColors.grey8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.menuItems.last != item)
                      Divider(
                        color: const Color(0xffa6a6a6).withOpacity(0.4),
                        thickness: 1,
                      ),
                  ],
                ),
              AppSpacing.gapH4,
            ],
          ),
        ),
      ),
    );
  }

  Align buildMessageList() {
    return Align(
      alignment: widget.widgetAlignment,
      child: PreviewMessages(
        messages: widget.messages,
        conversation: widget.conversation,
        currentUserId: widget.currentUserId,
        indexLastSeen: widget.indexLastSeen,
      ),
    );
  }

  Align buildMessage() {
    return Align(
      alignment: widget.widgetAlignment,
      child: Hero(
        tag: widget.id,
        child: widget.messageWidget,
      ),
    );
  }
}
