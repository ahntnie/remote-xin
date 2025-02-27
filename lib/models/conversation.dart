import 'package:equatable/equatable.dart';
import 'package:get/get.dart';

import '../presentation/common_controller.dart/app_controller.dart';
import 'all.dart';

class Conversation extends Equatable {
  final String id;
  final String name;
  final int creatorId;
  final List<int> memberIds;

  final bool isGroup;
  final List<Message> messages;
  final String? avatar;
  final bool isLocked;

  final List<User> members;

  final List<int> adminIds;
  final List<User> admins;
  final int? lastSeen;
  final int? unreadCount;

  final bool isBlocked;
  final bool blockedByMe;
  final bool? isMuted;
  final int? mutedUntil;
  final List<String>? pins;

  final List<User> memberActionSystem;

  final Map<String, int>? lastSeenUsers;

  const Conversation({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.memberIds,
    required this.isGroup,
    required this.members,
    required this.messages,
    required this.adminIds,
    this.isLocked = false,
    this.avatar,
    this.admins = const [],
    this.lastSeen,
    this.unreadCount,
    this.isBlocked = false,
    this.blockedByMe = false,
    this.isMuted,
    this.mutedUntil,
    this.pins,
    this.memberActionSystem = const [],
    this.lastSeenUsers,
  });

  Message? get lastMessage {
    if (messages.isEmpty) {
      return null;
    }

    return messages.first;
  }

  String? get avatarUrl {
    if (avatar != null) {
      return avatar;
    }

    final currentUserId = Get.find<AppController>().lastLoggedUser!.id;

    if (!isGroup && members.isNotEmpty) {
      final otherMember = members.firstWhereOrNull(
        (member) => member.id != currentUserId,
      );

      return otherMember?.avatarPath ?? '';
    }

    return '';
  }

  String title() {
    final partner = chatPartner();

    return partner?.contactName ?? name;
  }

  User? chatPartner() {
    if (!isGroup && members.isNotEmpty) {
      final currentUserId = Get.find<AppController>().lastLoggedUser!.id;

      return members.firstWhereOrNull(
        (member) => member.id != currentUserId,
      );
    }

    return null;
  }

  User? get creator =>
      members.firstWhereOrNull((member) => member.id == creatorId);

  bool isAdmin(int userId) => adminIds.contains(userId);

  bool isCreator(int userId) => creatorId == userId;

  bool isCreatorOrAdmin(int userId) => isCreator(userId) || isAdmin(userId);

  Conversation copyWith({
    String? id,
    String? name,
    int? creatorId,
    List<int>? memberIds,
    bool? isGroup,
    List<User>? members,
    List<Message>? messages,
    String? avatar,
    List<int>? adminIds,
    List<User>? admins,
    int? lastSeen,
    int? unreadCount,
    bool? isBlocked,
    bool? blockedByMe,
    bool? isMuted,
    int? mutedUntil,
    List<String>? pins,
    List<User>? memberActionSystem,
    Map<String, int>? lastSeenUsers,
  }) {
    return Conversation(
      id: id ?? this.id,
      name: name ?? this.name,
      creatorId: creatorId ?? this.creatorId,
      memberIds: memberIds ?? this.memberIds,
      isGroup: isGroup ?? this.isGroup,
      members: members ?? this.members,
      messages: messages ?? this.messages,
      avatar: avatar ?? this.avatar,
      isLocked: isLocked,
      adminIds: adminIds ?? this.adminIds,
      admins: admins ?? this.admins,
      lastSeen: lastSeen ?? this.lastSeen,
      unreadCount: unreadCount ?? this.unreadCount,
      isBlocked: isBlocked ?? this.isBlocked,
      blockedByMe: blockedByMe ?? this.blockedByMe,
      isMuted: isMuted ?? this.isMuted,
      mutedUntil: mutedUntil ?? this.mutedUntil,
      pins: pins ?? this.pins,
      memberActionSystem: memberActionSystem ?? this.memberActionSystem,
      lastSeenUsers: lastSeenUsers ?? this.lastSeenUsers,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      name: _parseName(
        json['name'] as String,
        isGroup: json['isGroup'] as bool?,
      ),
      creatorId: int.parse(json['creator']),
      memberIds:
          (json['members'] as List).map((e) => int.parse(e as String)).toList(),
      isGroup: json['isGroup'],
      messages: json['messages'] != null
          ? (json['messages'] as List)
              .map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      members: json['membersUserModel'] != null
          ? (json['membersUserModel'] as List)
              .map((e) => User.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      avatar: json['avatar'],
      isLocked: json['isLocked'] ?? false,
      adminIds:
          (json['admins'] as List).map((e) => int.parse(e as String)).toList(),
      admins:
          json['adminsUserModel'] != null && json['adminsUserModel'].isNotEmpty
              ? (json['adminsUserModel'] as List)
                  .map((e) => User.fromJson(e as Map<String, dynamic>))
                  .toList()
              : [],
      unreadCount: json['unreadCount'],
      lastSeen: _parseLastSeen(json['lastSeen']),
      isBlocked: json['isBlocked'] ?? false,
      blockedByMe: json['blockedByYou'] ?? false,
      isMuted: json['isMuted'],
      mutedUntil: json['mutedUntil'],
      pins: json['pins'] != null
          ? (json['pins'] as List).map((e) => e.toString()).toList()
          : null,
      lastSeenUsers: (json['lastSeenUsers'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value as int),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'creator': creatorId.toString(),
      'members': memberIds.map((e) => e.toString()).toList(),
      'membersUserModel': members.map((e) => e.toJson()).toList(),
      'isGroup': isGroup,
      'messages': messages.map((e) => e.toJson()).toList(),
      'avatar': avatar,
      'isLocked': isLocked,
      'admins': adminIds.map((e) => e.toString()).toList(),
      'adminsUserModel': admins.map((e) => e.toJson()).toList(),
      'unreadCount': unreadCount,
      'lastSeen': lastSeen,
      'isBlocked': isBlocked,
      'blockedByYou': blockedByMe,
      'isMuted': isMuted,
      'mutedUntil': mutedUntil,
      'pins': pins,
      'lastSeenUsers': lastSeenUsers, // Thêm vào đây
    };
  }

  static int? _parseLastSeen(dynamic lastSeen) {
    if (lastSeen == null) {
      return null;
    }
    if (lastSeen is String) {
      return int.parse(lastSeen);
    }

    return lastSeen;
  }

  static List<Conversation> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String _parseName(String name, {bool? isGroup}) {
    if (isGroup ?? false) {
      return name;
    }

    final loggedInUserId = Get.find<AppController>().lastLoggedUser?.id;

    return name
        .replaceFirst(loggedInUserId!.toString(), '')
        .replaceFirst('_', '');
  }

  @override
  List<Object?> get props => [
        id,
        name,
        creatorId,
        memberIds,
        isGroup,
        members,
        messages,
        avatar,
        isLocked,
        adminIds,
        admins,
        lastSeen,
        unreadCount,
        isBlocked,
        blockedByMe,
        isMuted,
        mutedUntil,
        pins,
        memberActionSystem,
      ];
}
