import 'package:freezed_annotation/freezed_annotation.dart';

import 'all.dart';

part 'user_contact.g.dart';

@JsonSerializable()
class UserContact {
  int? id;
  String contactFirstName;
  String contactLastName;
  String contactPhoneNumber;
  String? contactAvatarPath;
  bool isExpanded;
  int? userId;
  int? contactId;
  User? user;
  String? data;

  UserContact({
    required this.contactFirstName,
    required this.contactLastName,
    required this.contactPhoneNumber,
    this.user,
    this.id,
    this.contactAvatarPath,
    this.isExpanded = false,
    this.userId,
    this.contactId,
    this.data,
  });

  factory UserContact.fromJson(Map<String, dynamic> json) {
    final user = _$UserContactFromJson(json);

    // Get.find<UserPool>().storeUser(user);

    return user;
  }

  static List<UserContact> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => UserContact.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  String get fullName => contactFirstName.isEmpty && contactLastName.isEmpty
      ? ''
      : '$contactFirstName $contactLastName';

  Map<String, dynamic> toJson() => _$UserContactToJson(this);

  Map<String, dynamic> toDtoJson() {
    return <String, dynamic>{
      'first_name': contactFirstName,
      'last_name': contactLastName,
      'phone_number': contactPhoneNumber,
      if (contactAvatarPath != null && contactAvatarPath!.isNotEmpty)
        'avatar_path': contactAvatarPath,
      if (data != null) 'data': data,
    };
  }
}

@JsonSerializable()
class ContactsResult {
  final List<UserContact> created;
  final NotCreatedContacts notCreated;

  ContactsResult({
    required this.notCreated,
    this.created = const [],
  });

  factory ContactsResult.fromJson(Map<String, dynamic> json) {
    final contactResults = _$ContactsResultFromJson(json);

    return contactResults;
  }

  Map<String, dynamic> toJson() => _$ContactsResultToJson(this);
}

@JsonSerializable()
class NotCreatedContacts {
  final List<UserContact> existed;
  final List<String> notFounds;

  NotCreatedContacts({
    this.existed = const [],
    this.notFounds = const [],
  });

  factory NotCreatedContacts.fromJson(Map<String, dynamic> json) {
    final notCreated = _$NotCreatedContactsFromJson(json);

    return notCreated;
  }

  Map<String, dynamic> toJson() => _$NotCreatedContactsToJson(this);
}
