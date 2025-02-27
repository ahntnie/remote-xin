import 'dart:developer';

class UserVideo {
  int? _status;
  String? _message;
  List<Data>? _data;
  int? _totalVideos;

  int? get status => _status;

  String? get message => _message;

  List<Data>? get data => _data;

  int? get totalVideos => _totalVideos;

  UserVideo(
      {int? status, String? message, List<Data>? data, int? totalVideos}) {
    _status = status;
    _message = message;
    _data = data;
    _totalVideos = totalVideos;
  }

  UserVideo.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _totalVideos = json['total_videos'];

    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Data {
  int? _postId;
  int? _userId;
  String? _fullName;
  String? _userName;
  String? _userProfile;
  int? _isVerify;
  bool? _isTrending;
  String? _postDescription;
  String? _postHashTag;
  String? _postVideo;
  String? _postImage;
  String? _profileCategoryName;
  int? _soundId;
  String? _soundTitle;
  String? _duration;
  String? _singer;
  String? _soundImage;
  String? _sound;
  int? _postLikesCount;
  int? _postCommentsCount;
  int? _postViewCount;
  String? _createdDate;
  int? _videoLikesOrNot;
  int? _followOrNot;
  bool? _isBookmark;
  bool? _canComment;
  bool? _canDuet;
  bool? _canSave;
  int? _postShareCount;
  bool? _isPinned;
  bool? _isFollowed;

  int? get postId => _postId;

  int? get userId => _userId;

  String? get fullName => _fullName;

  String? get userName => _userName;

  String? get userProfile => _userProfile;

  int? get isVerify => _isVerify;

  bool? get isTrending => _isTrending;

  String? get postDescription => _postDescription;

  String? get postHashTag => _postHashTag;

  String? get postVideo => _postVideo;

  String? get postImage => _postImage;

  String? get profileCategoryName => _profileCategoryName;

  int? get soundId => _soundId;

  String? get soundTitle => _soundTitle;

  String? get duration => _duration;

  String? get singer => _singer;

  String? get soundImage => _soundImage;

  int? get postShareCount => _postShareCount;

  bool? get isPinned => _isPinned;

  bool? get isFollowed => _isFollowed;

  void setVideoLikesOrNot(int value) {
    _videoLikesOrNot = value;
    log(value.toString());
    if (value == 0) {
      _postLikesCount = _postLikesCount! - 1;
    } else {
      _postLikesCount = _postLikesCount! + 1;
    }
  }

  void setPostCommentCount(bool isAdd) {
    if (isAdd) {
      _postCommentsCount = _postCommentsCount! + 1;
    } else {
      _postCommentsCount = _postCommentsCount! - 1;
    }
  }

  String? get sound => _sound;

  int? get postLikesCount => _postLikesCount;

  int? get postCommentsCount => _postCommentsCount;

  int? get postViewCount => _postViewCount;

  String? get createdDate => _createdDate;

  int? get videoLikesOrNot => _videoLikesOrNot;

  int? get followOrNot => _followOrNot;

  bool? get isBookmark => _isBookmark;

  bool? get canComment => _canComment;

  bool? get canDuet => _canDuet;

  bool? get canSave => _canSave;

  Data({
    int? postId,
    int? userId,
    String? fullName,
    String? userName,
    String? userProfile,
    int? isVerify,
    bool? isTrending,
    String? postDescription,
    String? postHashTag,
    String? postVideo,
    String? postImage,
    String? profileCategoryId,
    String? profileCategoryName,
    int? soundId,
    String? soundTitle,
    String? duration,
    String? singer,
    String? soundImage,
    String? sound,
    int? postLikesCount,
    int? postCommentsCount,
    int? postViewCount,
    String? createdDate,
    int? videoLikesOrNot,
    int? followOrNot,
    bool? isBookmark,
    bool? canComment,
    bool? canDuet,
    bool? canSave,
    int? postShareCount,
    bool? isPinned,
    bool? isFollowed,
  }) {
    _postId = postId;
    _userId = userId;
    _fullName = fullName;
    _userName = userName;
    _userProfile = userProfile;
    _isVerify = isVerify;
    _isTrending = isTrending;
    _postDescription = postDescription;
    _postHashTag = postHashTag;
    _postVideo = postVideo;
    _postImage = postImage;
    _profileCategoryName = profileCategoryName;
    _soundId = soundId;
    _soundTitle = soundTitle;
    _duration = duration;
    _singer = singer;
    _soundImage = soundImage;
    _sound = sound;
    _postLikesCount = postLikesCount;
    _postCommentsCount = postCommentsCount;
    _postViewCount = postViewCount;
    _createdDate = createdDate;
    _videoLikesOrNot = videoLikesOrNot;
    _followOrNot = followOrNot;
    _isBookmark = isBookmark;
    _canComment = canComment;
    _canDuet = canDuet;
    _canSave = canSave;
    _postShareCount = postShareCount;
    _isPinned = isPinned;
    _isFollowed = isFollowed;
  }

  Data.fromJson(dynamic json) {
    _postId = json['id'];
    _userId = json['user_id'];
    _fullName = json['user']['first_name'] + ' ' + json['user']['last_name'];
    _userName = json['user']['nickname'];
    _userProfile = json['user']['avatar_path'];
    _isVerify = json['is_verify'];
    _isTrending = json['is_trending'];
    _postDescription = json['description'];
    _postHashTag = json['hash_tag'];
    _postVideo = json['video'];
    _postImage = json['image'];
    _profileCategoryName = json['profile_category_name'];
    _soundId = json['sound_id'];
    _soundTitle = json['sound'] == null ? null : json['sound']['title'];
    _duration = json['duration'];
    _singer = json['singer'];
    _soundImage = json['sound'] == null ? null : json['sound']['image'];
    _sound = json['sound'] == null ? null : json['sound']['sound'];
    _postLikesCount = json['post_likes_count'];
    _postCommentsCount = json['post_comments_count'];
    _postViewCount = json['video_view_count'];
    _createdDate = json['created_date'];
    _videoLikesOrNot = json['video_likes_or_not'];
    _followOrNot = json['follow_or_not'];
    _isBookmark = json['is_bookmarked'];
    _canComment = json['can_comment'];
    _canDuet = json['can_duet'];
    _canSave = json['can_save'];
    _postShareCount = json['video_share_count'];
    _isPinned = json['is_pinned'];
    _isFollowed = json['user']['is_followed'];
  }

  Data.fromGrapQLJson(dynamic json) {
    _postId = json['id'];
    _userId = json['user_id'];
    // _fullName = json['user']['first_name'] + ' ' + json['user']['last_name'];
    // _userName = json['user']['nickname'];
    // _userProfile = json['user']['avatar_path'];
    _isVerify = json['is_verify'];
    _isTrending = json['is_trending'];
    _postDescription = json['description'];
    _postHashTag = json['hash_tag'];
    _postVideo = json['video'];
    _postImage = json['image'];
    // _profileCategoryName = json['profile_category_name'];
    _soundId = json['sound_id'];
    // _soundTitle = json['sound'] == null ? null : json['sound']['title'];
    _duration = json['duration'];
    _singer = json['singer'];
    // _soundImage = json['sound'] == null ? null : json['sound']['image'];
    // _sound = json['sound'] == null ? null : json['sound']['sound'];
    _postLikesCount = json['post_likes_count'];
    _postCommentsCount = json['post_comments_count'];
    _postViewCount = json['video_view_count'];
    _createdDate = json['created_date'];
    _videoLikesOrNot = json['video_likes_or_not'];
    _followOrNot = json['follow_or_not'];
    _isBookmark = json['is_bookmark'];
    _canComment = json['can_comment'];
    _canDuet = json['can_duet'];
    _canSave = json['can_save'];
    _postShareCount = json['video_share_count'];
  }

  factory Data.fromJsonDecode(Map<String, dynamic> json) {
    return Data(
      postId: json['post_id'],
      userId: json['user_id'],
      fullName: json['full_name'],
      userName: json['user_name'],
      userProfile: json['user_profile'],
      isVerify: json['is_verify'],
      isTrending: json['is_trending'],
      postDescription: json['post_description'],
      postHashTag: json['post_hash_tag'],
      postVideo: json['post_video'],
      postImage: json['post_image'],
      profileCategoryName: json['profile_category_name'],
      soundId: json['sound_id'],
      soundTitle: json['sound_title'],
      duration: json['duration'],
      singer: json['singer'],
      soundImage: json['sound_image'],
      sound: json['sound'],
      postLikesCount: json['post_likes_count'],
      postCommentsCount: json['post_comments_count'],
      postViewCount: json['post_view_count'],
      createdDate: json['created_date'],
      videoLikesOrNot: json['video_likes_or_not'],
      followOrNot: json['follow_or_not'],
      isBookmark: json['is_bookmark'],
      canComment: json['can_comment'],
      canDuet: json['can_duet'],
      canSave: json['can_save'],
      postShareCount: json['post_share_count'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['post_id'] = _postId;
    map['user_id'] = _userId;
    map['full_name'] = _fullName;
    map['user_name'] = _userName;
    map['user_profile'] = _userProfile;
    map['is_verify'] = _isVerify;
    map['is_trending'] = _isTrending;
    map['post_description'] = _postDescription;
    map['post_hash_tag'] = _postHashTag;
    map['post_video'] = _postVideo;
    map['post_image'] = _postImage;
    map['profile_category_name'] = _profileCategoryName;
    map['sound_id'] = _soundId;
    map['sound_title'] = _soundTitle;
    map['duration'] = _duration;
    map['singer'] = _singer;
    map['sound_image'] = _soundImage;
    map['sound'] = _sound;
    map['post_likes_count'] = _postLikesCount;
    map['post_comments_count'] = _postCommentsCount;
    map['post_view_count'] = _postViewCount;
    map['created_date'] = _createdDate;
    map['video_likes_or_not'] = _videoLikesOrNot;
    map['follow_or_not'] = _followOrNot;
    map['is_bookmark'] = _isBookmark;
    map['can_comment'] = _canComment;
    map['can_duet'] = _canDuet;
    map['can_save'] = _canSave;
    map['post_share_count'] = _postShareCount;
    return map;
  }

  static List<Data> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => Data.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Data> fromJsonBookmarkList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => Data.fromJson(e['short_video'] as Map<String, dynamic>))
        .toList();
  }

  Data copyWith({
    int? postId,
    int? userId,
    String? fullName,
    String? userName,
    String? userProfile,
    int? isVerify,
    bool? isTrending,
    String? postDescription,
    String? postHashTag,
    String? postVideo,
    String? postImage,
    String? profileCategoryName,
    int? soundId,
    String? soundTitle,
    String? duration,
    String? singer,
    String? soundImage,
    String? sound,
    int? postLikesCount,
    int? postCommentsCount,
    int? postViewCount,
    String? createdDate,
    int? videoLikesOrNot,
    int? followOrNot,
    bool? isBookmark,
    bool? canComment,
    bool? canDuet,
    bool? canSave,
    int? postShareCount,
    bool? isPinned,
    bool? isFollowed,
  }) {
    return Data(
      postId: postId ?? _postId,
      userId: userId ?? _userId,
      fullName: fullName ?? _fullName,
      userName: userName ?? _userName,
      userProfile: userProfile ?? _userProfile,
      isVerify: isVerify ?? _isVerify,
      isTrending: isTrending ?? _isTrending,
      postDescription: postDescription ?? _postDescription,
      postHashTag: postHashTag ?? _postHashTag,
      postVideo: postVideo ?? _postVideo,
      postImage: postImage ?? _postImage,
      profileCategoryName: profileCategoryName ?? _profileCategoryName,
      soundId: soundId ?? _soundId,
      soundTitle: soundTitle ?? _soundTitle,
      duration: duration ?? _duration,
      singer: singer ?? _singer,
      soundImage: soundImage ?? _soundImage,
      sound: sound ?? _sound,
      postLikesCount: postLikesCount ?? _postLikesCount,
      postCommentsCount: postCommentsCount ?? _postCommentsCount,
      postViewCount: postViewCount ?? _postViewCount,
      createdDate: createdDate ?? _createdDate,
      videoLikesOrNot: videoLikesOrNot ?? _videoLikesOrNot,
      followOrNot: followOrNot ?? _followOrNot,
      isBookmark: isBookmark ?? _isBookmark,
      canComment: canComment ?? _canComment,
      canDuet: canDuet ?? _canDuet,
      canSave: canSave ?? _canSave,
      postShareCount: postShareCount ?? _postShareCount,
      isPinned: isPinned ?? _isPinned,
      isFollowed: isFollowed ?? _isFollowed,
    );
  }
}
