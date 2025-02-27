import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../core/configs/env_config.dart';
import '../data/api/clients/all.dart';
import '../models/all.dart';
import 'base/base_repo.dart';

class AppConfigRepository extends BaseRepository {
  final _client = Get.find<AuthenticatedRestApiClient>();

  Future<ServerSettings> getServerSettings() async {
    return _client.get(
      '/configs/mobile-settings',
      headers: {'X-Pi-Secret': Get.find<EnvConfig>().cmsSecret},
      decoder: (json) => ServerSettings.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<XinEnvData?> fetchXinEnvData() async {
    const url = 'https://educhain-server.vercel.app/xin-env';
    try {
      final response = await Dio().post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: jsonEncode({
          'pass': '62b977ve7wfrntjj134ly0r6445ei5',
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data['data']; // Lấy trường 'data' từ API response
        return XinEnvData.fromJson(data); // Trả về đối tượng XinEnvData
      } else {
        print('Lỗi: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Lỗi khi lấy dữ liệu: $e');
      return null;
    }
  }
}

class XinEnvData {
  final String baseUrl;
  final String hasuraUrl;
  final String chatUrl;
  final String chatSocketUrl;
  final String minioUrl;
  final String minioAccessKey;
  final String minioSecretKey;
  final String cmsSecret;
  final String missionUrl;
  final String jitsiUrl;
  final bool status;

  XinEnvData({
    required this.baseUrl,
    required this.hasuraUrl,
    required this.chatUrl,
    required this.chatSocketUrl,
    required this.minioUrl,
    required this.minioAccessKey,
    required this.minioSecretKey,
    required this.cmsSecret,
    required this.missionUrl,
    required this.jitsiUrl,
    required this.status,
  });

  // Phương thức từ JSON
  factory XinEnvData.fromJson(Map<String, dynamic> json) {
    return XinEnvData(
      baseUrl: json['BASE_URL'] as String,
      hasuraUrl: json['HASURA_URL'] as String,
      chatUrl: json['CHAT_URL'] as String,
      chatSocketUrl: json['CHAT_SOCKET_URL'] as String,
      minioUrl: json['MINIO_URL'] as String,
      minioAccessKey: json['MINIO_ACCESS_KEY'] as String,
      minioSecretKey: json['MINIO_SECRET_KEY'] as String,
      cmsSecret: json['CMS_SECRET'] as String,
      missionUrl: json['MISSION_URL'] as String,
      jitsiUrl: json['JITSI_URL'] as String,
      status: json['status'] as bool,
    );
  }
}
