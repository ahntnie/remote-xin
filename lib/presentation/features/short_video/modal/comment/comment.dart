class Comment {
  int? _status;
  String? _message;
  List<CommentData>? _data;

  int? get status => _status;

  String? get message => _message;

  List<CommentData>? get data => _data;

  Comment({int? status, String? message, List<CommentData>? data}) {
    _status = status;
    _message = message;
    _data = data;
  }

  Comment.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data!.add(CommentData.fromJson(v));
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

class CommentData {
  int? _commentsId;
  String? _comment;
  String? _createdDate;
  int? _userId;
  String? _fullName;
  String? _userName;
  String? _userProfile;
  int? _isVerify;
  bool? _isLiked;
  int? _likedUsersCount;

  int? get commentsId => _commentsId;

  String? get comment => _comment;

  String? get createdDate => _createdDate;

  int? get userId => _userId;

  String? get fullName => _fullName;

  String? get userName => _userName;

  String? get userProfile => _userProfile;

  int? get isVerify => _isVerify;

  bool? get isLiked => _isLiked;

  int? get likedUsersCount => _likedUsersCount;

  CommentData(
      {int? commentsId,
      String? comment,
      String? createdDate,
      int? userId,
      String? fullName,
      String? userName,
      String? userProfile,
      int? isVerify,
      bool? isLiked,
      int? likedUsersCount}) {
    _commentsId = commentsId;
    _comment = comment;
    _createdDate = createdDate;
    _userId = userId;
    _fullName = fullName;
    _userName = userName;
    _userProfile = userProfile;
    _isVerify = isVerify;
    _isLiked = isLiked;
    _likedUsersCount = likedUsersCount;
  }

  CommentData.fromJson(dynamic json) {
    _commentsId = json['id'];
    _comment = json['comment'];
    _createdDate = json['created_date'];
    _userId = json['user_id'];
    _fullName = json['user']['first_name'] + ' ' + json['user']['last_name'];
    _userName = json['nickname'];
    _userProfile = json['user']['avatar_path'];
    _isVerify = json['is_verify'];
    _isLiked = json['is_liked'];
    _likedUsersCount = json['liked_users_count'];
  }

  CommentData.fromAddJson(dynamic json) {
    _commentsId = json['id'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['comments_id'] = _commentsId;
    map['comment'] = _comment;
    map['created_date'] = _createdDate;
    map['user_id'] = _userId;
    map['full_name'] = _fullName;
    map['user_name'] = _userName;
    map['user_profile'] = _userProfile;
    map['is_verify'] = _isVerify;
    map['is_liked'] = _isVerify;
    map['liked_users_count'] = _likedUsersCount;
    return map;
  }

  static List<CommentData> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => CommentData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  CommentData copyWith({
    int? commentsId,
    String? comment,
    String? createdDate,
    int? userId,
    String? fullName,
    String? userName,
    String? userProfile,
    int? isVerify,
    bool? isLiked,
    int? likedUsersCount,
  }) {
    return CommentData(
        commentsId: commentsId ?? _commentsId,
        comment: comment ?? _comment,
        createdDate: createdDate ?? _createdDate,
        userId: userId ?? _userId,
        fullName: fullName ?? _fullName,
        userName: userName ?? _userName,
        userProfile: userProfile ?? _userProfile,
        isVerify: isVerify ?? _isVerify,
        isLiked: isLiked ?? _isLiked,
        likedUsersCount: likedUsersCount ?? _likedUsersCount);
  }
}
