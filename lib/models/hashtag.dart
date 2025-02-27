class Hashtag {
  final int id;
  final String hashTagName;
  final int videosCount;

  Hashtag({
    required this.id,
    required this.hashTagName,
    required this.videosCount,
  });

  factory Hashtag.fromJson(Map<String, dynamic> json) => Hashtag(
        id: json['id'],
        hashTagName: json['hash_tag_name'],
        videosCount: json['videos_count'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'hash_tag_name': hashTagName,
        'videos_count': videosCount,
      };

  static List<Hashtag> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => Hashtag.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
