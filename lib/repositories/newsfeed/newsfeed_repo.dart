import 'dart:io';

import 'package:get/get.dart';

import '../../core/exceptions/custom/all.dart';
import '../../core/exceptions/validation_exception.dart';
import '../../data/api/clients/all.dart';
import '../../data/mappers/response_mapper/base/base_success_response_mapper.dart';
import '../../models/all.dart';
import '../../models/base/pagination.dart';
import '../../models/command.dart';
import '../../models/comment.dart';
import '../../models/user_story.dart';
import '../base/base_repo.dart';
import 'documents/all.dart';

class NewsfeedRepository extends BaseRepository {
  final _graphQLApiClient = Get.find<AuthenticatedGraphQLApiClient>();

  final _authenticatedRestApiClient = Get.find<AuthenticatedRestApiClient>();

  Future<Attachment> createFile(File file) async {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient.postMultiForm(
          '/files',
          body: {
            'file_data': file,
          },
          decoder: (data) =>
              Attachment.fromJson((data as Map<String, dynamic>)['data']),
        );
      },
    );
  }

  Future<Post> createPostOrShortVideo({
    required String type,
    String? content,
    List<int> attachment = const [],
  }) async {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient.post(
          '/posts',
          body: {
            'type': type,
            'content': content,
            'attachments': attachment,
          },
          decoder: (data) => Post.fromJson(data as Map<String, dynamic>),
          successResponseMapperType: SuccessResponseMapperType.dataJsonObject,
        );
      },
    );
  }

  Future<PaginationResponse> getNewsfeed({
    required List<String> type,
    required int page,
    required int pageSize,
  }) {
    return executeApiRequest(() async {
      final Map<String, dynamic> queryParameters = {
        'type[]': type,
        'page': page,
        'page_size': pageSize,
      };

      return _authenticatedRestApiClient.get(
        '/newsfeeds',
        queryParameters: queryParameters,
        decoder: (data) => PaginationResponse.fromJson(
          data as Map<String, dynamic>,
          (p0) => Post.fromJson(
            p0 as Map<String, dynamic>,
          ),
        ),
        // decoder: (data) => Post.fromJsonList(
        //   (data as Map<String, dynamic>)['data'] as List<dynamic>,
        // ),
      );
    });
  }

  Future<Post> getPostById(int postId) {
    return executeApiRequest(() {
      return _authenticatedRestApiClient.get(
        '/posts/$postId',
        successResponseMapperType: SuccessResponseMapperType.jsonObject,
        decoder: (data) => Post.fromJson(data as Map<String, dynamic>),
      );
    });
  }

  Future<PaginationResponse> getPostPersonalPage({
    required int boardId,
    required String boardType,
    required List<String> type,
    required int page,
    required int pageSize,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) {
    return executeApiRequest(() async {
      final Map<String, dynamic> queryParameters = {
        'board_id': boardId,
        'board_type': boardType,
        'type[]': type,
        'page': page,
        'page_size': pageSize,
        'sort_by': sortBy,
        'sort_order': sortOrder,
      };

      return _authenticatedRestApiClient.get(
        '/posts',
        queryParameters: queryParameters,
        decoder: (data) => PaginationResponse.fromJson(
          data as Map<String, dynamic>,
          (p0) => Post.fromJson(
            p0 as Map<String, dynamic>,
          ),
        ),
        // decoder: (data) => Post.fromJsonList(
        //   (data as Map<String, dynamic>)['data'] as List<dynamic>,
        // ),
      );
    });
  }

  Future<String> likePost({required int postId, String type = 'like'}) {
    return executeApiRequest(() {
      return _authenticatedRestApiClient.post(
        '/posts/$postId/reactions',
        body: {
          'type': type,
        },
        decoder: (data) => (data as Map<String, dynamic>)['code'] as String,
      );
    });
  }

  Future<String> unLikePost({required int postId}) {
    return executeApiRequest(() {
      return _authenticatedRestApiClient.delete(
        '/posts/$postId/reactions',
        decoder: (data) => (data as Map<String, dynamic>)['code'] as String,
      );
    });
  }

  Future<String> deletePost({required int postId}) {
    return executeApiRequest(() {
      return _authenticatedRestApiClient.delete(
        '/posts/$postId',
        decoder: (data) => (data as Map<String, dynamic>)['code'] as String,
      );
    });
  }

  Future<Post> updatePost({
    required int postId,
    required String content,
    List<int> attachments = const [],
  }) {
    return executeApiRequest(() {
      return _authenticatedRestApiClient.put(
        '/posts/$postId',
        body: {
          if (content.isNotEmpty) 'content': content,
          'attachments': attachments,
        },
        decoder: (data) => Post.fromJson(data as Map<String, dynamic>),
        successResponseMapperType: SuccessResponseMapperType.dataJsonObject,
      );
    });
  }

  Future<List<CategoryReport>> getCategoriesReport() {
    return executeApiRequest(
      () => _authenticatedRestApiClient.get(
        '/reports/categories',
        decoder: (data) => CategoryReport.fromJsonList(
          (data as Map<String, dynamic>)['data'] as List<dynamic>,
        ),
      ),
    );
  }

  Future<String> report(
    String idReport,
    List<int> categoryIds,
    String reason, {
    required String type,
  }) {
    return executeApiRequest(
      () => _authenticatedRestApiClient.post(
        '/reports',
        body: {
          'reportable_id': idReport,
          'reportable_type': type,
          'categories': categoryIds,
          if (reason.isNotEmpty) 'reason': reason,
        },
        decoder: (data) => (data as Map<String, dynamic>)['code'] as String,
        serverKnownExceptionParser: (statusCode, serverError) {
          return NewsfeedException(
            NewsfeedExceptionKind.custom,
            serverError.message,
          );
        },
      ),
    );
  }

  Future<Post> getPostDetail(int postId) {
    return executeApiRequest(() {
      return _authenticatedRestApiClient.get(
        '/posts/$postId',
        decoder: (data) => Post.fromJson(data as Map<String, dynamic>),
        successResponseMapperType: SuccessResponseMapperType.dataJsonObject,
      );
    });
  }

  // Comments
  Future<PaginatedList<Comment>> getComments({
    required int postId,
    required int page,
    required int pageSize,
    int? parentId,
    SortOrderEnum sortOrder = SortOrderEnum.asc,
  }) {
    return executeApiRequest(
      () async {
        final queryParameters = {
          'page': page,
          'per_page': pageSize,
          'sort_by': 'created_at',
          'sort_order': sortOrder.name,
          'parent_id': parentId,
        };

        final PaginatedList<Comment> paginatedList =
            await _authenticatedRestApiClient.get(
          '/posts/$postId/comments',
          queryParameters: queryParameters,
          successResponseMapperType: SuccessResponseMapperType.paginatedList,
          decoder: (data) => Comment.fromJson(data as Map<String, dynamic>),
        );

        return paginatedList.replaceAll(
          paginatedList.items
              .map((comment) => comment.copyWith(postId: postId))
              .toList(),
        );
      },
    );
  }

  Future<List<UserContact>> getUserShare({
    required int userId,
    required String search,
  }) async {
    return executeApiRequest(() {
      return _graphQLApiClient.query(
        document: getContactsQuery(userId, search),
        decoder: (data) => UserContact.fromJsonList(
          (data as Map<String, dynamic>)['pi_xfactor_contacts']
              as List<dynamic>,
        ),
      );
    });
  }

  Future<Comment> postComment({
    required int postId,
    String? content,
    int? attachmentId,
    int? parentId,
  }) {
    // if ((content != null && content.isEmpty) || attachmentId == null) {
    //   throw const ValidationException(ValidationExceptionKind.commentIsEmpty);
    // }

    // must have content or attachment
    if ((content == null || content.isEmpty) && attachmentId == null) {
      throw const ValidationException(ValidationExceptionKind.commentIsEmpty);
    }

    return executeApiRequest(() {
      final data = {
        'content': content,
        'attachments': [attachmentId],
        'parent_id': parentId,
      };

      return _authenticatedRestApiClient.post(
        '/posts/$postId/comments',
        body: data,
        successResponseMapperType: SuccessResponseMapperType.dataJsonObject,
        decoder: (data) => Comment.fromJson(data as Map<String, dynamic>),
      );
    });
  }

  Future<void> likeComment({required int commentId}) async {
    await executeApiRequest(() {
      return _authenticatedRestApiClient.post(
        '/comments/$commentId/reactions',
        body: {
          'type': ReactionType.like.name,
        },
        successResponseMapperType: SuccessResponseMapperType.plain,
      );
    });
  }

  Future<void> unLikeComment({required int commentId}) async {
    await executeApiRequest(() {
      return _authenticatedRestApiClient.delete(
        '/comments/$commentId/reactions',
        successResponseMapperType: SuccessResponseMapperType.plain,
      );
    });
  }

  Future<void> deleteComment(int commentId) {
    return executeApiRequest(() {
      return _authenticatedRestApiClient.delete(
        '/comments/$commentId',
        successResponseMapperType: SuccessResponseMapperType.plain,
      );
    });
  }

  Future<Comment> editComment(int id, String text) {
    if (text.isEmpty) {
      throw const ValidationException(ValidationExceptionKind.commentIsEmpty);
    }

    return executeApiRequest(() {
      return _authenticatedRestApiClient.put(
        '/comments/$id',
        body: {'content': text},
        successResponseMapperType: SuccessResponseMapperType.dataJsonObject,
        decoder: (data) => Comment.fromJson(data as Map<String, dynamic>),
      );
    });
  }

  Future<Post> sharePostToPersonal({
    required int postId,
    required String type,
  }) async {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient.post(
          '/posts',
          body: {
            'original_post_id': postId,
            'type': type,
          },
          decoder: (data) => Post.fromJson(data as Map<String, dynamic>),
          successResponseMapperType: SuccessResponseMapperType.dataJsonObject,
        );
      },
    );
  }

  Future<void> newsfeedInteractCounter(int postId, Map<String, dynamic> body) {
    return executeApiRequest(() {
      return _authenticatedRestApiClient.put(
        '/posts/$postId/counter',
        body: body,
        successResponseMapperType: SuccessResponseMapperType.plain,
      );
    });
  }

  Future<List<UserStory>> getListUserStory() async {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient.get(
          '/story/list',
          decoder: (data) => List<UserStory>.from(
              (data as Map<String, dynamic>)['data']
                  .map((x) => UserStory.fromJson(x))),
        );
      },
    );
  }

  Future<String> postStory({
    String? storyType,
    String? status,
    String? colorCode,
    String? content,
    String? mediaType,
    String? urlMedia,
  }) async {
    return executeApiRequest(
      () async {
        final code = await _authenticatedRestApiClient.post(
          '/story/create',
          body: {
            'story_type': storyType,
            'status': 'public',
            if (colorCode != null) 'color_code': colorCode,
            'content': content,
            if (mediaType != null) 'media_type': mediaType,
            if (urlMedia != null) 'url_media': urlMedia,
          },
          decoder: (data) => (data as Map<String, dynamic>)['code'] as String,
        );
        return code;
      },
    );
  }

  Future<String> reactionStory({
    required String type,
    required int id,
  }) async {
    return executeApiRequest(
      () async {
        final code = await _authenticatedRestApiClient.post(
          '/story/reaction/$id',
          body: {
            'type': type,
          },
          decoder: (data) => (data as Map<String, dynamic>)['code'] as String,
        );
        return code;
      },
    );
  }

  Future<CommandModel> getListCommandBot({required int botId}) async {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient
            .post('/chatbot/slash-commands', body: {
          'bot_id': botId,
        }, decoder: (data) {
          print('Lấy xong command bot');
          print(data);
          return CommandModel.fromJson(data as Map<String, dynamic>);
        });
      },
    );
  }

  Future<void> deleteStory({required int storyId}) async {
    return executeApiRequest(
      () async {
        await _authenticatedRestApiClient.delete(
          '/story/delete/$storyId',
        );
      },
    );
  }
}
