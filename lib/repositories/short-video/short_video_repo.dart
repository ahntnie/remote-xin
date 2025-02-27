import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/all.dart';
import '../../data/api/api.dart';
import '../../data/preferences/app_preferences.dart';
import '../../models/all.dart';
import '../../models/hashtag.dart';
import '../../models/user_like_video.dart';
import '../../presentation/features/short_video/modal/comment/comment.dart';
import '../../presentation/features/short_video/modal/explore/explore_hash_tag.dart';
import '../../presentation/features/short_video/modal/sound/sound.dart';
import '../../presentation/features/short_video/modal/user_video/user_video.dart';
import '../../presentation/features/short_video/utils/url_res.dart';
import '../base/base_repo.dart';
import 'documents/_search_hashtag.dart';
import 'documents/_search_video.dart';

class ShortVideoRepository extends BaseRepository {
  final _graphQLApiClient = Get.find<AuthenticatedGraphQLApiClient>();
  final _authenticatedRestApiClient = Get.find<AuthenticatedRestApiClient>();
  static const String keyReels = 'init_reels_xin';
  static const String keyVideo = 'cached_video_data';
  static const String videoName = 'cached_video.mp4';
  final Dio _dio = Dio();

  Future<List<Data>> getPostList(
      String limit, String userId, String type, int page) async {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient.post(
          '/short-video/getPostList?page=$page',
          body: {
            UrlRes.limit: limit,
            UrlRes.userId: userId,
            UrlRes.type: type,
          },
          decoder: (data) =>
              Data.fromJsonList((data as Map<String, dynamic>)['data']),
        );
      },
    );
  }

  Future<List<Data>> getPostFollowingList(
    String limit,
    String userId,
    String type,
    int page,
  ) async {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient.post(
          '/short-video-follows/getTopFollowedVideos?page=$page',
          body: {
            UrlRes.limit: limit,
            UrlRes.userId: userId,
            UrlRes.type: type,
          },
          decoder: (data) =>
              Data.fromJsonList((data as Map<String, dynamic>)['data']),
        );
      },
    );
  }

  Future<Object> getUserVideos(
      String limit, int type, int userId, int page) async {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient.post(
          type == 0
              ? '/short-video/getUserVideos?page=$page'
              : '/short-video/getUserLikesVideos?page=$page',
          body: {
            'user_id': userId,
            'limit': 10,
          },
          decoder: (data) => data as Map<String, dynamic>,
        );
      },
    );
  }

  Future<Object> getSingleHashTagPostList(
      String limit, String hashtag, int page) async {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient.post(
          '/short-video/getSingleHashTagPostList?page=$page',
          body: {'hashtag': hashtag, 'limit': 10},
          decoder: (data) => data as Map<String, dynamic>,
        );
      },
    );
  }

  Future<List<Data>> searchVideos(String query) {
    logDebug(query);
    return executeApiRequest(
      () async {
        return _graphQLApiClient.query(
          document: searchVideoByQuery(query),
          decoder: (data) => Data.fromJsonList(
            (data as Map<String, dynamic>)['short_videos'] as List<dynamic>,
          ),
        );
      },
    );
  }

  Future<List<Data>> likeOrUnlikeVideo(int id) async {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient.post(
          '/short-video/likeUnlikePost',
          // body: map,
          body: {'video_id': id},
          // decoder: (data) =>
          //     Data.fromJsonList((data as Map<String, dynamic>)['data']),
        );
      },
    );
  }

  Future<List<CommentData>> getCommentByPostId(
      String start, String limit, String postId) async {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient.post(
          '/short-video/getCommentByPostId',
          // body: map,
          body: {'video_id': postId},
          decoder: (data) =>
              CommentData.fromJsonList((data as Map<String, dynamic>)['data']),
        );
      },
    );
  }

  Future<void> likeAndUnlikeComment({required int commentId}) {
    return executeApiRequest(() async {
      return _authenticatedRestApiClient.post('/short-video/likeUnlikeComment',
          body: {'comment_id': commentId});
    });
  }

  Future<CommentData> addComment(String comment, int postId) async {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient.post(
          '/short-video/addComment',
          // body: map,
          body: {'video_id': postId, 'comment': comment},
          decoder: (data) =>
              CommentData.fromAddJson((data as Map<String, dynamic>)['data']),
        );
      },
    );
  }

  Future<void> addPost(
      int soundId, String description, String video, String image) async {
    final Map<String, dynamic> map = {
      'sound_id': soundId,
      'description': description,
      'video': video,
      'image': image,
    };

    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient.post(
          '/short-video/addPost',
          // body: map,
          body: map,
          // decoder: (data) =>
          //     CommentData.fromJsonList((data as Map<String, dynamic>)['data']),
        );
      },
    );
  }

  Future<List<SoundList>> getListSound() async {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient.post(
          '/short-video/getSoundList',
          // body: map,
          // body: {'video_id': postId},
          decoder: (data) => SoundList.fromJsonList(
              (data as Map<String, dynamic>)['data'][0]['sound_list']),
        );
      },
    );
  }

  Future<List<Data>> getPostListBySoundId(int soundId, int page) async {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient.post(
          '/short-video/getPostBySoundId?page=$page',
          // body: map,
          body: {'sound_id': soundId},
          decoder: (data) =>
              Data.fromJsonList((data as Map<String, dynamic>)['data']),
        );
      },
    );
  }

  Future<void> deleteComment(int id) async {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient.post(
          '/short-video/deleteComment',
          // body: map,
          body: {
            'comment_id': id,
          },
          // decoder: (data) =>
          //     CommentData.fromJsonList((data as Map<String, dynamic>)['data']),
        );
      },
    );
  }

  Future<UserStatistics> getUserStatistics(int id) async {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient.post(
          '/short-video/getUserStatistics',
          // body: map,
          body: {'user_id': id},
          decoder: (data) =>
              UserStatistics.fromJson((data as Map<String, dynamic>)['data']),
        );
      },
    );
  }

  Future<String> getShareLink(String data) async {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient.post(
          '/sharelinkGeneral',
          // body: map,
          body: {'data': data},
          decoder: (data) =>
              (data as Map<String, dynamic>)['data']['share_link'] as String,
        );
      },
    );
  }

  Future<List<ExploreData>> getExplore() async {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient.post(
          '/short-video/getExploreHashTagPostList',
          decoder: (data) =>
              ExploreData.fromJsonList((data as Map<String, dynamic>)['data']),
        );
      },
    );
  }

  Future writeInitReels() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyReels, false);
  }

  Future<bool> readInitReels() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(keyReels) ?? true;
  }

  Future<bool> writeVideo(Data video) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final File cachedFile = await getCachedVideoFile();
      final newData = video.copyWith(postVideo: cachedFile.path);
      // Convert model to JSON then to String
      final String videoJson = jsonEncode(newData.toJson());

      // Save string to SharedPreferences
      return await prefs.setString(keyVideo, videoJson);
    } catch (e) {
      print('Error saving video: $e');
      return false;
    }
  }

  // Hàm đọc model từ SharedPreferences
  Future<Data?> readVideo() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Read string from SharedPreferences
      final String? videoJson = prefs.getString(keyVideo);

      if (videoJson != null) {
        // Convert string back to JSON then to model
        final Map<String, dynamic> json = jsonDecode(videoJson);
        return Data.fromJsonDecode(json);
      }

      return null;
    } catch (e) {
      print('Error reading video: $e');
      return null;
    }
  }

  Future<Data> getDetailVideo(int id) async {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient.post(
          '/short-video/getVideoInfo',
          // body: map,
          body: {'video_id': id},
          decoder: (data) =>
              Data.fromJson((data as Map<String, dynamic>)['data']),
        );
      },
    );
  }

  Future<File> getCachedVideoFile() async {
    final Directory tempDir = await getTemporaryDirectory();
    return File('${tempDir.path}/$videoName');
  }

  Future<String> downloadVideo(
    String videoUrl, {
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final File cachedFile = await getCachedVideoFile();

      // Xóa video cũ nếu tồn tại
      if (await cachedFile.exists()) {
        await cachedFile.delete();
      }

      // Download với Dio
      await _dio.download(
        videoUrl,
        cachedFile.path,
        onReceiveProgress: onProgress,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      return cachedFile.path;
    } catch (e) {
      return '';
    }
  }

  Future cacheVideo(
    String videoUrl, {
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final File cachedFile = await getCachedVideoFile();

      // Xóa video cũ nếu tồn tại
      if (await cachedFile.exists()) {
        await cachedFile.delete();
      }

      // Download với Dio
      await _dio.download(
        videoUrl,
        cachedFile.path,
        onReceiveProgress: onProgress,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.cancel) {
          throw Exception('Download cancelled');
        }
      }
      throw Exception('Error caching video: $e');
    }
  }

  Future<File?> getVideo() async {
    try {
      final File cachedFile = await getCachedVideoFile();
      if (await cachedFile.exists()) {
        return cachedFile;
      }
      return null;
    } catch (e) {
      throw Exception('Error getting cached video: $e');
    }
  }

  Future<void> deleteShortVideo(int videoId) async {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient
            .delete('/short-video/deletePost', body: {
          'video_id': videoId,
        });
      },
    );
  }

  Future<PinVideoErrorResponse> pinOrUnpinVideo(int idVideo) {
    try {
      return executeApiRequest(
        () async {
          return _authenticatedRestApiClient.post(
            '/short-video/pinUnpinPost',
            body: {'video_id': idVideo},
            decoder: (data) =>
                PinVideoErrorResponse.fromJson(data as Map<String, dynamic>),
          );
        },
      );
    } catch (e) {
      ViewUtil.showToast(
          title: Get.context!.l10n.global__error_title, message: e.toString());
      return Future.value(
          PinVideoErrorResponse(status: 500, message: e.toString()));
    }
  }

  Future<List<Data>> searchShortVideo(
      {required String query, int size = 10}) async {
    return await executeApiRequest(
      () async {
        return await _authenticatedRestApiClient.get(
          '/short-video/searchVideo',
          queryParameters: {'q': query, 'size': size},
          decoder: (data) =>
              Data.fromJsonList((data as Map<String, dynamic>)['data']),
          headers: {'Content-Type': 'application/json'},
        );
      },
    );
  }

  Future<List<CategoryReport>> getListReasonReportShortVideo() async {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient.get(
          '/short-video-reports/listReportReason',
          decoder: (data) => CategoryReport.fromJsonVideoList(
            (data as Map<String, dynamic>)['data'],
          ),
        );
      },
    );
  }

  Future<List<Hashtag>> searchHashtag(String query) {
    return executeApiRequest(
      () async {
        return _graphQLApiClient.query(
          document: searchHashtagByName(query),
          decoder: (data) => Hashtag.fromJsonList(
            (data as Map<String, dynamic>)['short_video_hashtag']
                as List<dynamic>,
          ),
        );
      },
    );
  }

  Future<PinVideoErrorResponse> bookmarkOrUnBookmark(int videoId) async {
    final baseUrl = Get.find<EnvConfig>().apiUrl;
    final token = await Get.find<AppPreferences>().getAccessToken();
    final data = await Dio().post(
      '$baseUrl/short-video/bookmarks/markOrUnmark',
      data: {'video_id': videoId},
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (data.statusCode == 200) {
      return PinVideoErrorResponse(status: 200, message: data.data['message']);
    } else {
      return PinVideoErrorResponse(
          status: data.statusCode ?? 500, message: data.data['message']);
    }
  }

  Future<PinVideoErrorResponse> followUser(int userId) async {
    final baseUrl = Get.find<EnvConfig>().apiUrl;
    final token = await Get.find<AppPreferences>().getAccessToken();
    final data = await Dio().post(
      '$baseUrl/short-video-follows/follow/$userId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (data.statusCode == 200) {
      return PinVideoErrorResponse(status: 200, message: data.data['message']);
    } else {
      return PinVideoErrorResponse(
          status: data.statusCode ?? 500, message: data.data['message']);
    }
  }

  Future<void> reportShortVideo(
      int videoId, List<int> reasonIds, String otherReason) async {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient.post(
          '/short-video-reports/reportVideo',
          body: {
            'video_id': videoId,
            'reason_id': reasonIds,
            'other_reason': otherReason,
          },
        );
      },
    );
  }

  Future<List<Data>> getBookmark(int? page) async {
    return await executeApiRequest(
      () async {
        return await _authenticatedRestApiClient.get('/short-video/bookmarks',
            queryParameters: {'pageSize': 10, 'page': page},
            decoder: (data) => Data.fromJsonBookmarkList(
                (data as Map<String, dynamic>)['data']));
      },
    );
  }

  Future<UserLikeVideo> getUserLikeVideo(int videoId) async {
    return await executeApiRequest(
      () async {
        return await _authenticatedRestApiClient.post(
          '/short-video/listUserLikeVideo',
          body: {'video_id': videoId},
          decoder: (data) =>
              UserLikeVideo.fromJson((data as Map<String, dynamic>)['data']),
        );
      },
    );
  }
}

class UserStatistics {
  final int totalLikes;
  final int totalComments;
  final int totalShares;

  const UserStatistics({
    required this.totalLikes,
    required this.totalComments,
    required this.totalShares,
  });

  // Factory constructor từ JSON
  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalLikes: json['total_likes'] ?? 0,
      totalComments: json['total_comments'] ?? 0,
      totalShares: json['total_shares'] ?? 0,
    );
  }

  // Hàm copyWith để tạo bản sao với các giá trị được thay đổi
  UserStatistics copyWith({
    int? totalLikes,
    int? totalComments,
    int? totalShares,
  }) {
    return UserStatistics(
      totalLikes: totalLikes ?? this.totalLikes,
      totalComments: totalComments ?? this.totalComments,
      totalShares: totalShares ?? this.totalShares,
    );
  }

  // Optional: Hàm toJson để chuyển đổi ngược lại
  Map<String, dynamic> toJson() {
    return {
      'total_likes': totalLikes,
      'total_comments': totalComments,
      'total_shares': totalShares,
    };
  }

  // Optional: Hàm toString để dễ debug
  @override
  String toString() {
    return 'UserStatistics(totalLikes: $totalLikes, totalComments: $totalComments, totalShares: $totalShares)';
  }

  // Optional: So sánh bằng
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserStatistics &&
        other.totalLikes == totalLikes &&
        other.totalComments == totalComments &&
        other.totalShares == totalShares;
  }

  // Optional: Hashcode
  @override
  int get hashCode {
    return totalLikes.hashCode ^ totalComments.hashCode ^ totalShares.hashCode;
  }
}

class PinVideoErrorResponse {
  final int status;
  final String message;

  PinVideoErrorResponse({required this.status, required this.message});

  factory PinVideoErrorResponse.fromJson(Map<String, dynamic> json) {
    return PinVideoErrorResponse(
        status: json['status'], message: json['message']);
  }

  Map<String, dynamic> toJson() => {'status': status, 'message': message};
}
