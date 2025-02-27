import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../models/conversation.dart';
import '../../../../../models/message.dart';
import '../../../../../repositories/all.dart';
import '../../../../base/base_controller.dart';

class ConversationResourcesArguments {
  final Conversation conversation;

  const ConversationResourcesArguments({
    required this.conversation,
  });
}

class ConversationResourcesController extends BaseController
    with GetSingleTickerProviderStateMixin {
  final _chatRepository = Get.find<ChatRepository>();
  final _storageRepository = Get.find<StorageRepository>();

  late final Conversation conversation;
  late final TabController tabController;

  final RxList<String> _images = <String>[].obs;
  List<String> get images => _images.reversed.toList();

  final RxList<String> _videos = <String>[].obs;
  List<String> get videos => _videos.reversed.toList();

  final RxList<String> _audios = <String>[].obs;
  List<String> get audios => _audios.reversed.toList();

  final RxList<String> _links = <String>[].obs;
  List<String> get links => _links.reversed.toList();

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as ConversationResourcesArguments;
    conversation = args.conversation;

    tabController = TabController(length: 4, vsync: this);

    _loadConversationResources();
    _loadConversationLinks();
  }

  Future<void> _loadConversationResources() async {
    final images = await _storageRepository.getAllConversationMediaByType(
      conversationId: conversation.id,
      messageType: MessageType.image,
    );
    _images.addAll(
      images
        ..removeWhere(
          (image) => image.endsWith('.mp4') || image.endsWith('.mov'),
        ),
    );

    final videos = await _storageRepository.getAllConversationMediaByType(
      conversationId: conversation.id,
      messageType: MessageType.video,
    );
    _videos.addAll(videos);

    final audios = await _storageRepository.getAllConversationMediaByType(
      conversationId: conversation.id,
      messageType: MessageType.audio,
    );
    _audios.addAll(audios);
  }

  Future<void> _loadConversationLinks() async {
    final messages = await _chatRepository.getAllMessagesByConversationId(
      conversationId: conversation.id,
      types: [MessageType.hyperText],
    );

    // link is include in content inside tag <hyper>

    _links
        .addAll(messages.expand((element) => element.linksInContent).toList());
  }
}
