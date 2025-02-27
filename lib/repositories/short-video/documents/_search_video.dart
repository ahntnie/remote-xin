import 'video_scheme.dart';

String searchVideoByQuery(String query) => '''
      query MyQuery(\$query: String = "%$query%") {
        short_videos(
            where: {
             
                  _or: [
                    {description: {_ilike: \$query}},
                    {hash_tag: {_ilike: \$query}},
                 
                  ]
            },
            limit: 8
      ) {
          $videoSchema
        }
      }
      ''';
