import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../core/all.dart';
import '../data/api/clients/base/rest_api_client.dart';
import '../data/preferences/app_preferences.dart';
import '../models/create_call.dart';
import '../presentation/features/call/enums/call_action_enum.dart';

const _prefix = '/call';

class AuthenticatedBackgroundRestApiClient extends RestApiClient {
  AuthenticatedBackgroundRestApiClient(EnvConfig envConfig)
      : super(
          baseUrl: envConfig.apiUrl,
          interceptors: [
            InterceptorsWrapper(
              onRequest: (options, handler) async {
                final accessToken = await AppPreferences().getAccessToken();
                if (accessToken != null && accessToken.isNotEmpty) {
                  options.headers['Authorization'] = 'Bearer $accessToken';
                }

                return handler.next(options);
              },
            ),
          ],
        );
}

class CallBackgroundRepository {
  AuthenticatedBackgroundRestApiClient? _authenticatedRestApiClient;

  Future<AuthenticatedBackgroundRestApiClient> init() async {
    await dotenv.load();

    return _authenticatedRestApiClient =
        AuthenticatedBackgroundRestApiClient(EnvConfig(dotenv.env));
  }

  Future<CreateCall> createCall({
    required List<int> receiverIds,
    required String chatChannelId,
    required bool isGroup,
    required bool isVideo,
  }) async {
    _authenticatedRestApiClient ??= await init();

    return _authenticatedRestApiClient!.post(
      '$_prefix/create-call',
      body: {
        'receiver_ids': receiverIds,
        'chat_channel_id': chatChannelId,
        'is_group': isGroup,
        'is_video': isVideo,
      },
      decoder: (data) => CreateCall.fromJson(
        data as Map<String, dynamic>,
      ),
    );
  }

  Future updateCallAction({
    required String callId,
    required CallActionEnum action,
  }) async {
    _authenticatedRestApiClient ??= await init();

    return _authenticatedRestApiClient!.post(
      '$_prefix/execute-call-action',
      body: {
        'call_id': callId,
        'action': action.name,
      },
      decoder: (data) {},
    );
  }

  Future<CreateCall> generateToken({required String callId}) async {
    _authenticatedRestApiClient ??= await init();

    return _authenticatedRestApiClient!.post(
      '$_prefix/generate-call-token',
      body: {
        'call_id': callId,
      },
      decoder: (data) => CreateCall.fromJson(
        data as Map<String, dynamic>,
      ),
    );
  }
}
