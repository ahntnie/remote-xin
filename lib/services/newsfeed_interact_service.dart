import 'dart:async';

import 'package:get/get.dart';

import '../core/all.dart';
import '../models/enums/newsfeed_interact_type_enum.dart';
import '../models/newsfeed_interact_type.dart';
import '../repositories/all.dart';

class NewsfeedInteractService extends GetxService {
  final NewsfeedRepository _newsfeedRepository = Get.find<NewsfeedRepository>();

  @override
  void onInit() {
    timer = Timer.periodic(const Duration(seconds: 15), _handleTask);

    super.onInit();
  }

  final Map<String, Map<NewsfeedInteractTypeEnum, Set<NewsfeedInteractType>>>
      _interactMap = {};
  late Timer timer;

  Future _handleTask(Timer timer) async {
    if (_interactMap.isEmpty) return;

    final interactMapCopy = Map<String,
        Map<NewsfeedInteractTypeEnum, Set<NewsfeedInteractType>>>.from(
      _interactMap,
    );
    _interactMap.clear();
    // for (final interact in interactMapCopy.values) {
    //   for (final set in interact.values) {
    //     for (final interact in set) {
    //       if (interact.createdAt.isBefore(DateTime.now().subtract(
    //         const Duration(seconds: 15),
    //       ))) {
    //         set.remove(interact);
    //       }
    //     }
    //   }
    // }
    final interactedPostIds = [];
    for (final postId in interactMapCopy.keys) {
      try {
        final body = interactMapCopy[postId]?.map<String, dynamic>((type, set) {
          final score = set.fold(
            0,
            (previousValue, element) => previousValue + element.type.core,
          );

          return MapEntry(type.apiCode, score);
        });
        if (body?.isEmpty ?? true) continue;

        await _requestUpdateInteractToServer(postId, body!);
        interactedPostIds.add(postId);
      } catch (e) {
        LogUtil.e(e, name: runtimeType.toString());
      }
    }
    // delete all post that interacted to server
    interactMapCopy
        .removeWhere((key, value) => interactedPostIds.contains(key));
    //add interactMapCopy to interactMap if request failed
    _interactMap.addAll(interactMapCopy);
  }

  Future _requestUpdateInteractToServer(
    String postId,
    Map<String, dynamic> body,
  ) async {
    LogUtil.i(body, name: runtimeType.toString());
    await _newsfeedRepository.newsfeedInteractCounter(
      int.parse(postId),
      body,
    );
  }

  String _createKeyMap(NewsfeedInteractType interact) {
    return interact.postId.toString();
  }

  void likePost(int postId) {
    _addInteract(NewsfeedInteractType(
      type: NewsfeedInteractTypeEnum.like,
      postId: postId,
    ));
  }

  void unlikePost(int postId) {
    _addInteract(NewsfeedInteractType(
      type: NewsfeedInteractTypeEnum.unLike,
      postId: postId,
    ));
  }

  void commentPost(int postId, int commentId) {
    _addInteract(NewsfeedInteractType(
      type: NewsfeedInteractTypeEnum.comment,
      postId: postId,
      commentId: commentId,
    ));
  }

  void sharePost(int postId) {
    _addInteract(NewsfeedInteractType(
      type: NewsfeedInteractTypeEnum.share,
      postId: postId,
    ));
  }

  void viewPost(int postId) {
    _addInteract(NewsfeedInteractType(
      type: NewsfeedInteractTypeEnum.view,
      postId: postId,
    ));
  }

  void _addInteract(NewsfeedInteractType interact) {
    final key = _createKeyMap(interact);

    if (_interactMap.containsKey(key)) {
      if (_interactMap[key]!.containsKey(interact.type)) {
        _interactMap[key]![interact.type]!.add(interact);
      } else {
        _interactMap[key]![interact.type] = {interact};
      }
    } else {
      _interactMap[key] = {
        interact.type: {interact},
      };
    }
  }
}
