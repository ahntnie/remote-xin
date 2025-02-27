import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/all.dart';
import '../../common_controller.dart/all.dart';

class ContactDisplayNameText extends StatelessWidget {
  final User user;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const ContactDisplayNameText({
    required this.user,
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserPool>(
      builder: (controller) {
        final userContact = controller.myContacts
            .firstWhereOrNull((contact) => contact.contactId == user.id);

        final name = userContact?.fullName.isNotEmpty == true
            ? userContact?.fullName ?? user.fullName
            : user.fullName;

        return Text(
          name.trim(),
          style: style,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}
