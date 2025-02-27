import 'hashtag_scheme.dart';

String searchHashtagByName(String query) => '''
  query SearchHashtags(\$query: String = "%$query%") {
    short_video_hashtag(
      where: {
        hash_tag_name: {_ilike: \$query},
        videos_count: {_gt: 0}
      }
    ) {
      $hashtagSchema
    }
  }
''';
