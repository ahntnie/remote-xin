class EnvConfig {
  EnvConfig(this.environment);

  final Map<String, String> environment;

  String get apiUrl => environment['BASE_URL']!;
  String get hasuraUrl => environment['HASURA_URL']!;
  String get chatApiUrl => environment['CHAT_URL']!;
  String get chatSocketUrl => environment['CHAT_SOCKET_URL']!;
  String get minIoUrl => environment['MINIO_URL']!;
  String get minIoAccessKey => environment['MINIO_ACCESS_KEY']!;
  String get minIoSecretKey => environment['MINIO_SECRET_KEY']!;
  String get cmsSecret => environment['CMS_SECRET']!;
  String get missionUrl => environment['MISSION_URL']!;
  String get jitsiUrl => environment['JITSI_URL']!;
  String get mapUrl => environment['MAP_URL']!;
  String get translateServiceUrl => environment['TRANSLATE_SERVICE_URL']!;
}
