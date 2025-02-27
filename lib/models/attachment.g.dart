// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attachment _$AttachmentFromJson(Map<String, dynamic> json) => Attachment(
      id: json['id'] as int,
      path: json['path'] as String,
      contentType: json['content_type'] as String,
      thumb: json['thumb'] as String?,
      isImage: json['is_image'] as bool? ?? false,
      isVideo: json['is_video'] as bool? ?? false,
      isProcessing: json['is_processing'] as bool?,
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AttachmentToJson(Attachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'thumb': instance.thumb,
      'path': instance.path,
      'content_type': instance.contentType,
      'is_image': instance.isImage,
      'is_video': instance.isVideo,
      'is_processing': instance.isProcessing,
      'width': instance.width,
      'height': instance.height,
    };
