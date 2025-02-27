import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../data/api/clients/all.dart';
import '../../data/mappers/response_mapper/base/all.dart';
import '../../models/call_history.dart';
import '../../models/create_call.dart';
import '../../models/join_call.dart';
import '../../presentation/features/call/enums/call_action_enum.dart';
import '../base/base_repo.dart';
import 'documents/all.dart';

const _prefix = '/call';

class CallRepository extends BaseRepository {
  final _authenticatedRestApiClient = Get.find<AuthenticatedRestApiClient>();
  final _authenticatedGraphQLApiClient =
      Get.find<AuthenticatedGraphQLApiClient>();

  Future<CreateCall> createCall({
    required List<int> receiverIds,
    required String chatChannelId,
    required bool isGroup,
    required bool isVideo,
    required bool isTranslate,
  }) {
    return executeApiRequest(
      () async {
        return _authenticatedRestApiClient.post(
          '$_prefix/create-call',
          body: {
            'receiver_ids': receiverIds,
            'chat_channel_id': chatChannelId,
            'is_group': isGroup,
            'is_video': isVideo,
            'is_translate': isTranslate,
          },
          decoder: (data) => CreateCall.fromJson(
            data as Map<String, dynamic>,
          ),
          errorResponseMapperType: ErrorResponseMapperType.jsonObject,
        );
      },
    );
  }

  Future updateCallAction({
    required String callId,
    required CallActionEnum action,
  }) {
    return executeApiRequest(() async {
      return _authenticatedRestApiClient.post(
        '$_prefix/execute-call-action',
        body: {
          'call_id': callId,
          'action': action.name,
        },
        decoder: (data) {},
        errorResponseMapperType: ErrorResponseMapperType.jsonObject,
      );
    });
  }

  Future<JoinCall> generateToken({required String callId}) {
    return executeApiRequest(() async {
      return _authenticatedRestApiClient.post(
        '$_prefix/generate-call-token',
        body: {
          'call_id': callId,
        },
        decoder: (data) => JoinCall.fromJson(
          data as Map<String, dynamic>,
        ),
        errorResponseMapperType: ErrorResponseMapperType.jsonObject,
      );
    });
  }

  Future<List<CallHistory>> getAllCallHistory({
    required int userId,
    required int pageSize,
    required int offset,
  }) {
    return executeApiRequest(() async {
      return _authenticatedGraphQLApiClient.query(
        document: getAllHistoryCallByUserIdQuery(
          userId: userId,
          pageSize: pageSize,
          offset: offset,
        ),
        decoder: (data) => CallHistory.fromJsonList(
          (data as Map<String, dynamic>)['call_histories'] as List<dynamic>,
        ),
      );
    });
  }

  Future<List<CallHistory>> getMissedCallHistory({
    required int userId,
    required int pageSize,
    required int offset,
  }) {
    return executeApiRequest(() async {
      return _authenticatedGraphQLApiClient.query(
        document: getMissedCallByUserIdQuery(
          userId: userId,
          pageSize: pageSize,
          offset: offset,
        ),
        decoder: (data) => CallHistory.fromJsonList(
          (data as Map<String, dynamic>)['call_histories'] as List<dynamic>,
        ),
      );
    });
  }

  Future readyCall({required String callId}) async {
    return executeApiRequest(() async {
      return _authenticatedRestApiClient.post(
        '$_prefix/mark-call-ready',
        body: {'call_id': callId},
        decoder: (data) {},
      );
    });
  }

  Future<String> translateAudio(
      String path, String fromLang, String toLang) async {
    String code = '';
    try {
      final request = http.MultipartRequest('POST',
          Uri.parse('https://api.hifriend.site/translate-audio/translate'));

      request.headers.addAll({
        'lang': 'vn',
        'gmt': '1',
        'os-name': '.',
        'os-version': '.',
        'app-version': '.',
        'Content-Type': 'application/json',
        'uuid': '.',
      });

      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        path,
        contentType: MediaType('audio', 'mpeg'),
      ));

      request.fields['from-lang'] = fromLang;
      request.fields['to-lang'] = toLang;
      request.fields['gender'] = 'male';

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        log(responseBody);
        final responseJson = json.decode(responseBody);
        code = responseJson['data'];
      } else {
        print('Upload failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      log(e.toString());
    }
    return code;
  }
}
