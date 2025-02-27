import 'package:json_annotation/json_annotation.dart';

part 'attachment.g.dart';

@JsonSerializable()
class Attachment {
  int id;
  String? thumb;
  String path;
  String contentType;
  bool isImage;
  bool isVideo;
  bool? isProcessing;
  double? width;
  double? height;

  Attachment({
    required this.id,
    required this.path,
    required this.contentType,
    this.thumb,
    this.isImage = false,
    this.isVideo = false,
    this.isProcessing,
    this.width,
    this.height,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    final file = _$AttachmentFromJson(json);

    return file;
  }

  Map<String, dynamic> toJson() => _$AttachmentToJson(this);

  static List<Attachment> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => Attachment.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
