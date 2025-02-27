import 'package:get/get.dart';

import '../../core/all.dart';
import '../../core/constants/server/server_error_constants.dart';
import '../../data/api/clients/all.dart';
import '../../data/mappers/response_mapper/base/base_success_response_mapper.dart';
import '../../data/preferences/app_preferences.dart';
import '../../models/all.dart';
import '../../models/nft_number.dart';
import '../base/base_repo.dart';
import 'data/login_response_data.dart';

const _prefix = '/auth';

class AuthRepository extends BaseRepository {
  final _unAuthenticatedRestApiClient =
      Get.find<UnAuthenticatedRestApiClient>();
  final _appPreferences = Get.find<AppPreferences>();
  final _authenticatedRestApiClient = Get.find<AuthenticatedRestApiClient>();

  // Return user id
  Future<int> login({
    required String password,
    String? email,
    String? phone,
  }) async {
    return executeApiRequest(
      () async {
        final deviceId = await DeviceUtil.getDeviceId();

        final Map<String, dynamic> queryParameters = {
          'login_tour': 1,
        };

        final data = await _unAuthenticatedRestApiClient.post(
          '$_prefix/login',
          queryParameters: queryParameters,
          body: {
            if (email != null) 'email': email,
            if (phone != null) 'phone': phone,
            'password': password,
            'device': deviceId,
          },
          decoder: (data) => LoginResponseData.fromJson(
            data as Map<String, dynamic>,
          ),
          serverKnownExceptionParser: (statusCode, serverError) {
            if (serverError.code == ServerErrorConstants.authUserIsLocked) {
              return const AuthException(AuthExceptionKind.userIsLocked);
            }

            return null;
          },
        );

        assert(data is LoginResponseData);

        await _appPreferences.saveAccessToken(data.token);

        return data.user.id;
      },
    );
  }

  Future sendOTPVerifyPhone() async {
    return await executeApiRequest(
      () async {
        return await _authenticatedRestApiClient.get(
          '/auth/verify-phone',
          headers: {'Content-Type': 'application/json'},
          serverKnownExceptionParser: (statusCode, serverError) {
            switch (statusCode) {
              case 400:
                if (serverError.code == 'limit_otp') {
                  return AuthException(
                    AuthExceptionKind.limitOtp,
                    serverError,
                  );
                }

                if (serverError.code == 'otp_not_expired') {
                  return AuthException(
                    AuthExceptionKind.otpNotExpired,
                    serverError,
                  );
                }

                return AuthException(
                  AuthExceptionKind.custom,
                  serverError,
                );
              case 404:
                return AuthException(
                  AuthExceptionKind.userNotFound,
                  serverError,
                );
              case 500:
                return ApiException(
                  kind: ApiExceptionKind.serverDefined,
                  serverError: serverError,
                );
              default:
                return ApiException(
                  kind: ApiExceptionKind.serverDefined,
                  serverError: serverError,
                );
            }
          },
        );
      },
    );
  }

  Future<bool> validateOtpVerify(int otp) async {
    return await executeApiRequest(
      () async {
        return await _authenticatedRestApiClient.post(
            '/auth/validate-phone-verify-otp',
            body: {'otp': otp},
            decoder: (data) =>
                (data as Map<String, dynamic>)['success'] as bool,
            headers: {'Content-Type': 'application/json'});
      },
    );
  }

  Future<User> register({
    String? email,
    String? phone,
    String? referralId,
  }) async {
    return executeApiRequest<User>(
      () async {
        return _unAuthenticatedRestApiClient.post(
          '$_prefix/register',
          body: {
            if (email != null) 'email': email,
            if (phone != null) 'phone': phone,
            if (referralId != null && referralId.isNotEmpty)
              'ref_id': referralId,
          },
          decoder: (data) =>
              User.fromJson((data as Map<String, dynamic>)['user']),
          serverKnownExceptionParser: (statusCode, serverError) {
            switch (statusCode) {
              case 400:
                if (serverError.fieldErrors.isNotEmpty) {
                  for (var error in serverError.fieldErrors) {
                    if (error.field == 'phone' &&
                        error.messages.first ==
                            'The phone has already been taken.') {
                      return const AuthException(
                        AuthExceptionKind.phoneAlreadyInUse,
                      );
                    } else if (error.field == 'email' &&
                        error.messages.first ==
                            'The email has already been taken.') {
                      return const AuthException(
                        AuthExceptionKind.emailAlreadyInUse,
                      );
                    } else {
                      return AuthException(
                        AuthExceptionKind.custom,
                        serverError,
                      );
                    }
                  }
                }
              case 500:
                return ApiException(
                  kind: ApiExceptionKind.serverDefined,
                  serverError: serverError,
                );
              default:
                return null;
            }

            return null;
          },
        );
      },
    );
  }

  Future<bool> getIsVerify() async {
    return executeApiRequest(
      () async {
        return _unAuthenticatedRestApiClient.get(
          '/auth/check-require-phone-verification',
          decoder: (data) => (data
              as Map<String, dynamic>)['isRequirePhoneVerification'] as bool,
        );
      },
    );
  }

  Future<dynamic> requestResendOTP({
    required String type,
    String? email,
    String? phone,
  }) async {
    final body = {
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      'type': type,
    };

    return executeApiRequest(
      () async {
        return _unAuthenticatedRestApiClient.post(
          '$_prefix/resend-otp',
          body: body,
          decoder: (data) {
            final respData = data as Map<String, dynamic>;

            // on success, code is 'otp_generated'
            final code = respData['code'] as String?;

            if (code == 'otp_generated') {
              return code;
            } else {
              throw const AuthException(AuthExceptionKind.unknown);
            }
          },
          serverKnownExceptionParser: (statusCode, serverError) {
            switch (statusCode) {
              case 400:
                if (serverError.code == 'limit_otp') {
                  return AuthException(
                    AuthExceptionKind.limitOtp,
                    serverError,
                  );
                }

                if (serverError.code == 'otp_not_expired') {
                  return AuthException(
                    AuthExceptionKind.otpNotExpired,
                    serverError,
                  );
                }

                return AuthException(
                  AuthExceptionKind.custom,
                  serverError,
                );
              case 404:
                return AuthException(
                  AuthExceptionKind.userNotFound,
                  serverError,
                );
              case 500:
                return ApiException(
                  kind: ApiExceptionKind.serverDefined,
                  serverError: serverError,
                );
              default:
                return ApiException(
                  kind: ApiExceptionKind.serverDefined,
                  serverError: serverError,
                );
            }
          },
        );
      },
    );
  }

  Future<dynamic> requestResetPassword({
    String? email,
    String? phone,
  }) async {
    final body = {
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
    };

    return executeApiRequest(
      () async {
        return _unAuthenticatedRestApiClient.post(
          '$_prefix/request-reset-password',
          body: body,
          decoder: (data) {
            final respData = data as Map<String, dynamic>;

            // on success, code is 'otp_generated'
            final code = respData['code'] as String?;

            if (code == 'otp_generated') {
              return respData;
            } else {
              throw const AuthException(AuthExceptionKind.unknown);
            }
          },
          serverKnownExceptionParser: (statusCode, serverError) {
            switch (statusCode) {
              case 400:
                if (serverError.code == 'limit_otp') {
                  return AuthException(
                    AuthExceptionKind.limitOtp,
                    serverError,
                  );
                }

                return AuthException(
                  AuthExceptionKind.custom,
                  serverError,
                );
              case 404:
                return AuthException(
                  AuthExceptionKind.userNotFound,
                  serverError,
                );
              case 500:
              default:
                return ApiException(
                  kind: ApiExceptionKind.serverDefined,
                  serverError: serverError,
                );
            }
          },
        );
      },
    );
  }

  Future<String?> validateOtp({
    required String otp,
    String? email,
    String? phone,
  }) async {
    final body = {
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      'otp': otp,
    };

    return executeApiRequest<String?>(
      () async {
        return _unAuthenticatedRestApiClient.post(
          '$_prefix/validate-otp',
          body: body,
          decoder: (data) {
            final code = (data as Map<String, dynamic>)['code'] as String?;

            // on success, code is 'otp_correct'
            // on failure, code is 'otp_incorrect'
            final inCorrectOtp = code == 'otp_incorrect';
            if (inCorrectOtp) {
              throw const AuthException(AuthExceptionKind.otpIncorrect);
            } else {
              return code;
            }
          },
          serverKnownExceptionParser: (statusCode, serverError) {
            switch (statusCode) {
              case 400:
                return AuthException(
                  AuthExceptionKind.custom,
                  serverError,
                );
              case 404:
                return const AuthException(AuthExceptionKind.userNotFound);
              case 500:
                return ApiException(
                  kind: ApiExceptionKind.serverDefined,
                  serverError: serverError,
                );
              default:
                return ApiException(
                  kind: ApiExceptionKind.serverDefined,
                  serverError: serverError,
                );
            }
          },
        );
      },
    );
  }

  Future<dynamic> resetPassword({
    required String otp,
    required String password,
    required String passwordConfirmation,
    String? email,
    String? phone,
  }) async {
    final body = {
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      'otp': otp,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };

    return executeApiRequest(
      () async {
        return _unAuthenticatedRestApiClient.post(
          '$_prefix/reset-password',
          body: body,
          decoder: (data) {
            // on success, code is 'reset_password_success'
            // on failure, code is 'reset_password_fail'
            final code = (data as Map<String, dynamic>)['code'] as String?;

            if (code == 'reset_password_success') {
              return data;
            } else {
              throw const AuthException(AuthExceptionKind.resetPasswordFail);
            }
          },
          serverKnownExceptionParser: (statusCode, serverError) {
            switch (statusCode) {
              case 400:
                return AuthException(
                  AuthExceptionKind.custom,
                  serverError,
                );
              case 404:
                return const AuthException(AuthExceptionKind.userNotFound);
              case 500:
                return ApiException(
                  kind: ApiExceptionKind.serverDefined,
                  serverError: serverError,
                );
              default:
                return ApiException(
                  kind: ApiExceptionKind.serverDefined,
                  serverError: serverError,
                );
            }
          },
        );
      },
    );
  }

  Future<String> logout(String deviceId) async {
    return executeApiRequest(
      () {
        return _authenticatedRestApiClient.post(
          '$_prefix/logout',
          body: {'device': deviceId},
          decoder: (data) => (data as Map<String, dynamic>)['code'] as String,
        );
      },
    );
  }

  Future<String> deleteAccount() async {
    return executeApiRequest(
      () {
        return _authenticatedRestApiClient.post(
          '$_prefix/delete',
          decoder: (data) => (data as Map<String, dynamic>)['code'] as String,
        );
      },
    );
  }

  Future<void> updateFCMToken(String fcmToken, String? voipToken) async {
    return executeApiRequest(
      () async {
        final deviceId = await DeviceUtil.getDeviceId();

        return _authenticatedRestApiClient.post(
          '/noti/update-fcm-token',
          body: {
            'fcm_token': fcmToken,
            'apn_token': voipToken,
            'device': deviceId,
          },
          successResponseMapperType: SuccessResponseMapperType.plain,
        );
      },
    );
  }

  Future<CheckAccountExist> checkAccountExistWithSignInThirdParty({
    String? idToken,
    String? accessToken,
    String? platform,
  }) async {
    return executeApiRequest(
      () async {
        return _unAuthenticatedRestApiClient.post(
          '$_prefix/is-3rd-party-account-exist',
          body: {
            'id_token': idToken,
            'access_token': accessToken,
            'platform': platform,
          },
          decoder: (data) => CheckAccountExist.fromJson(
            data as Map<String, dynamic>,
          ),
          serverKnownExceptionParser: (statusCode, serverError) {
            switch (statusCode) {
              case 400:
                if (serverError.code == 'user_is_admin') {
                  return const AuthException(AuthExceptionKind.userIsAdmin);
                } else if (serverError.code == 'user_is_locked') {
                  return const AuthException(AuthExceptionKind.userIsLocked);
                } else if (serverError.fieldErrors.isNotEmpty) {
                  return AuthException(
                    AuthExceptionKind.custom,
                    serverError,
                  );
                }
            }

            return null;
          },
        );
      },
    );
  }

  Future<int> signInWithSignInThirdParty({
    String? idToken,
    String? accessToken,
    String? refId,
    String? platform,
  }) async {
    final deviceId = await DeviceUtil.getDeviceId();
    final Map<String, dynamic> queryParameters = {
      'login_tour': 1,
    };

    return executeApiRequest(
      () async {
        final data = await _unAuthenticatedRestApiClient.post(
          '$_prefix/login-by-3rd',
          queryParameters: queryParameters,
          body: {
            'id_token': idToken,
            'access_token': accessToken,
            'platform': platform,
            if (refId != null && refId.isNotEmpty) 'ref_id': refId,
            'device': deviceId,
          },
          decoder: (data) => LoginResponseData.fromJson(
            data as Map<String, dynamic>,
          ),
          serverKnownExceptionParser: (statusCode, serverError) {
            switch (statusCode) {
              case 400:
                if (serverError.code == 'user_is_admin') {
                  return const AuthException(AuthExceptionKind.userIsAdmin);
                } else if (serverError.code == 'user_is_locked') {
                  return const AuthException(AuthExceptionKind.userIsLocked);
                } else if (serverError.fieldErrors.isNotEmpty) {
                  return AuthException(
                    AuthExceptionKind.custom,
                    serverError,
                  );
                }
            }

            return null;
          },
        );

        assert(data is LoginResponseData);

        await _appPreferences.saveAccessToken(data.token);

        return data.user.id;
      },
    );
  }

  Future<List<NftNumber>> getListNumber(String email) async {
    List<NftNumber> listNumber = [];

    final data = await _unAuthenticatedRestApiClient.get(
      '/temp-nft',
      queryParameters: {'email': email},
      decoder: (data) =>
          (data as Map<String, dynamic>)['data'] as List<dynamic>,
    );
    // final baseUrl = Get.find<EnvConfig>().apiUrl;
    //  final uri = Uri.parse('$baseUrl/api/temp-nft');
    // final data =
    //     await http.get(uri, body: {'email': email});
    listNumber = NftNumber.fromJsonList(data);

    return listNumber;
  }

  Future<bool> updateNFTNumber(
      String email, String nftId, String number) async {
    try {
      final data = await _unAuthenticatedRestApiClient.post(
        '/update-nft',
        body: {
          'email': email,
          'nft_id': nftId,
          'nft_number': number,
        },
        decoder: (data) => (data as Map<String, dynamic>)['status'] as bool,
      );
      if (data == true) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> getMyListNFT() async {
    List<String> listNumber = [];

    final data = await _authenticatedRestApiClient.get(
      '/my-nft',
      decoder: (data) =>
          (data as Map<String, dynamic>)['data'] as List<dynamic>,
    );
    listNumber = List<String>.from(data);

    return listNumber;
  }
}
