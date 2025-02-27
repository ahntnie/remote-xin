class UserLikeVideo {
  UserLikeVideo({
    required this.data,
  });

  final List<Datum> data;

  UserLikeVideo copyWith({
    List<Datum>? data,
  }) {
    return UserLikeVideo(
      data: data ?? this.data,
    );
  }

  factory UserLikeVideo.fromJson(Map<String, dynamic> json) {
    return UserLikeVideo(
      data: json['data'] == null
          ? []
          : List<Datum>.from(json['data']!.map((x) => Datum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.map((x) => x?.toJson()).toList(),
      };
}

class Datum {
  Datum({
    required this.id,
    required this.videoId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.user,
  });

  final int? id;
  final int? videoId;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;
  final UserLike? user;

  Datum copyWith({
    int? id,
    int? videoId,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic deletedAt,
    UserLike? user,
  }) {
    return Datum(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      user: user ?? this.user,
    );
  }

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json['id'],
      videoId: json['video_id'],
      userId: json['user_id'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? ''),
      deletedAt: json['deleted_at'],
      user: json['user'] == null ? null : UserLike.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'video_id': videoId,
        'user_id': userId,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt,
        'user': user?.toJson(),
      };
}

class UserLike {
  UserLike({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.login,
    required this.email,
    required this.permissions,
    required this.isActivated,
    required this.isSuperuser,
    required this.activatedAt,
    required this.lastLogin,
    required this.deletedAt,
    required this.roleId,
    required this.createdAt,
    required this.updatedAt,
    required this.isPasswordExpired,
    required this.passwordChangedAt,
    required this.phone,
    required this.avatarPath,
    required this.nickname,
    required this.otpCount,
    required this.isLocked,
    required this.shareLink,
    required this.webUserId,
    required this.webRefId,
    required this.googleUserId,
    required this.appleUserId,
    required this.zoomId,
    required this.zoomShareLink,
    required this.balance,
    required this.balanceVnd,
    required this.balanceXin,
    required this.wallet,
    required this.searchFullname,
    required this.gender,
    required this.birthday,
    required this.location,
    required this.isSearchGlobal,
    required this.isShowEmail,
    required this.isShowPhone,
    required this.isShowGender,
    required this.isShowBirthday,
    required this.isShowLocation,
    required this.cccd,
    required this.dateCccd,
    required this.addressCccd,
    required this.talkLanguage,
    required this.subscriptionPaymentOtp,
    required this.nftNumber,
    required this.allowConnect,
    required this.bookingOtp,
    required this.countryId,
    required this.cityId,
    required this.categoryId,
    required this.description,
    required this.yearsOfExperience,
    required this.countNotification,
    required this.otp,
    required this.otpExpired,
    required this.twitter,
    required this.skype,
    required this.website,
    required this.avatarBackground,
    required this.isPhoneVerified,
    required this.otpPhoneVerify,
    required this.isShowNft,
    required this.department,
    required this.isSeeding,
    required this.isBot,
    required this.botOwnerId,
    required this.botToken,
  });

  final int? id;
  final String? firstName;
  final String? lastName;
  final String? login;
  final String? email;
  final dynamic permissions;
  final bool? isActivated;
  final bool? isSuperuser;
  final DateTime? activatedAt;
  final DateTime? lastLogin;
  final dynamic deletedAt;
  final int? roleId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isPasswordExpired;
  final dynamic passwordChangedAt;
  final String? phone;
  final String? avatarPath;
  final String? nickname;
  final int? otpCount;
  final bool? isLocked;
  final String? shareLink;
  final dynamic webUserId;
  final dynamic webRefId;
  final dynamic googleUserId;
  final dynamic appleUserId;
  final dynamic zoomId;
  final dynamic zoomShareLink;
  final String? balance;
  final String? balanceVnd;
  final dynamic balanceXin;
  final String? wallet;
  final dynamic searchFullname;
  final String? gender;
  final String? birthday;
  final String? location;
  final bool? isSearchGlobal;
  final bool? isShowEmail;
  final bool? isShowPhone;
  final bool? isShowGender;
  final bool? isShowBirthday;
  final bool? isShowLocation;
  final dynamic cccd;
  final dynamic dateCccd;
  final dynamic addressCccd;
  final String? talkLanguage;
  final dynamic subscriptionPaymentOtp;
  final String? nftNumber;
  final int? allowConnect;
  final dynamic bookingOtp;
  final int? countryId;
  final int? cityId;
  final int? categoryId;
  final String? description;
  final int? yearsOfExperience;
  final int? countNotification;
  final String? otp;
  final DateTime? otpExpired;
  final String? twitter;
  final String? skype;
  final String? website;
  final String? avatarBackground;
  final bool? isPhoneVerified;
  final dynamic otpPhoneVerify;
  final bool? isShowNft;
  final String? department;
  final bool? isSeeding;
  final bool? isBot;
  final dynamic botOwnerId;
  final dynamic botToken;

  UserLike copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? login,
    String? email,
    dynamic permissions,
    bool? isActivated,
    bool? isSuperuser,
    DateTime? activatedAt,
    DateTime? lastLogin,
    dynamic deletedAt,
    int? roleId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPasswordExpired,
    dynamic passwordChangedAt,
    String? phone,
    String? avatarPath,
    String? nickname,
    int? otpCount,
    bool? isLocked,
    String? shareLink,
    dynamic webUserId,
    dynamic webRefId,
    dynamic googleUserId,
    dynamic appleUserId,
    dynamic zoomId,
    dynamic zoomShareLink,
    String? balance,
    String? balanceVnd,
    dynamic balanceXin,
    String? wallet,
    dynamic searchFullname,
    String? gender,
    String? birthday,
    String? location,
    bool? isSearchGlobal,
    bool? isShowEmail,
    bool? isShowPhone,
    bool? isShowGender,
    bool? isShowBirthday,
    bool? isShowLocation,
    dynamic cccd,
    dynamic dateCccd,
    dynamic addressCccd,
    String? talkLanguage,
    dynamic subscriptionPaymentOtp,
    String? nftNumber,
    int? allowConnect,
    dynamic bookingOtp,
    int? countryId,
    int? cityId,
    int? categoryId,
    String? description,
    int? yearsOfExperience,
    int? countNotification,
    String? otp,
    DateTime? otpExpired,
    String? twitter,
    String? skype,
    String? website,
    String? avatarBackground,
    bool? isPhoneVerified,
    dynamic otpPhoneVerify,
    bool? isShowNft,
    String? department,
    bool? isSeeding,
    bool? isBot,
    dynamic botOwnerId,
    dynamic botToken,
  }) {
    return UserLike(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      login: login ?? this.login,
      email: email ?? this.email,
      permissions: permissions ?? this.permissions,
      isActivated: isActivated ?? this.isActivated,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      activatedAt: activatedAt ?? this.activatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      deletedAt: deletedAt ?? this.deletedAt,
      roleId: roleId ?? this.roleId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPasswordExpired: isPasswordExpired ?? this.isPasswordExpired,
      passwordChangedAt: passwordChangedAt ?? this.passwordChangedAt,
      phone: phone ?? this.phone,
      avatarPath: avatarPath ?? this.avatarPath,
      nickname: nickname ?? this.nickname,
      otpCount: otpCount ?? this.otpCount,
      isLocked: isLocked ?? this.isLocked,
      shareLink: shareLink ?? this.shareLink,
      webUserId: webUserId ?? this.webUserId,
      webRefId: webRefId ?? this.webRefId,
      googleUserId: googleUserId ?? this.googleUserId,
      appleUserId: appleUserId ?? this.appleUserId,
      zoomId: zoomId ?? this.zoomId,
      zoomShareLink: zoomShareLink ?? this.zoomShareLink,
      balance: balance ?? this.balance,
      balanceVnd: balanceVnd ?? this.balanceVnd,
      balanceXin: balanceXin ?? this.balanceXin,
      wallet: wallet ?? this.wallet,
      searchFullname: searchFullname ?? this.searchFullname,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      location: location ?? this.location,
      isSearchGlobal: isSearchGlobal ?? this.isSearchGlobal,
      isShowEmail: isShowEmail ?? this.isShowEmail,
      isShowPhone: isShowPhone ?? this.isShowPhone,
      isShowGender: isShowGender ?? this.isShowGender,
      isShowBirthday: isShowBirthday ?? this.isShowBirthday,
      isShowLocation: isShowLocation ?? this.isShowLocation,
      cccd: cccd ?? this.cccd,
      dateCccd: dateCccd ?? this.dateCccd,
      addressCccd: addressCccd ?? this.addressCccd,
      talkLanguage: talkLanguage ?? this.talkLanguage,
      subscriptionPaymentOtp:
          subscriptionPaymentOtp ?? this.subscriptionPaymentOtp,
      nftNumber: nftNumber ?? this.nftNumber,
      allowConnect: allowConnect ?? this.allowConnect,
      bookingOtp: bookingOtp ?? this.bookingOtp,
      countryId: countryId ?? this.countryId,
      cityId: cityId ?? this.cityId,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      countNotification: countNotification ?? this.countNotification,
      otp: otp ?? this.otp,
      otpExpired: otpExpired ?? this.otpExpired,
      twitter: twitter ?? this.twitter,
      skype: skype ?? this.skype,
      website: website ?? this.website,
      avatarBackground: avatarBackground ?? this.avatarBackground,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      otpPhoneVerify: otpPhoneVerify ?? this.otpPhoneVerify,
      isShowNft: isShowNft ?? this.isShowNft,
      department: department ?? this.department,
      isSeeding: isSeeding ?? this.isSeeding,
      isBot: isBot ?? this.isBot,
      botOwnerId: botOwnerId ?? this.botOwnerId,
      botToken: botToken ?? this.botToken,
    );
  }

  factory UserLike.fromJson(Map<String, dynamic> json) {
    return UserLike(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      login: json['login'],
      email: json['email'],
      permissions: json['permissions'],
      isActivated: json['is_activated'],
      isSuperuser: json['is_superuser'],
      activatedAt: DateTime.tryParse(json['activated_at'] ?? ''),
      lastLogin: DateTime.tryParse(json['last_login'] ?? ''),
      deletedAt: json['deleted_at'],
      roleId: json['role_id'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? ''),
      isPasswordExpired: json['is_password_expired'],
      passwordChangedAt: json['password_changed_at'],
      phone: json['phone'],
      avatarPath: json['avatar_path'],
      nickname: json['nickname'],
      otpCount: json['otp_count'],
      isLocked: json['is_locked'],
      shareLink: json['share_link'],
      webUserId: json['web_user_id'],
      webRefId: json['web_ref_id'],
      googleUserId: json['google_user_id'],
      appleUserId: json['apple_user_id'],
      zoomId: json['zoom_id'],
      zoomShareLink: json['zoom_share_link'],
      balance: json['balance'],
      balanceVnd: json['balance_vnd'],
      balanceXin: json['balance_xin'],
      wallet: json['wallet'],
      searchFullname: json['search_fullname'],
      gender: json['gender'],
      birthday: json['birthday'],
      location: json['location'],
      isSearchGlobal: json['is_search_global'],
      isShowEmail: json['is_show_email'],
      isShowPhone: json['is_show_phone'],
      isShowGender: json['is_show_gender'],
      isShowBirthday: json['is_show_birthday'],
      isShowLocation: json['is_show_location'],
      cccd: json['cccd'],
      dateCccd: json['date_cccd'],
      addressCccd: json['address_cccd'],
      talkLanguage: json['talk_language'],
      subscriptionPaymentOtp: json['subscription_payment_otp'],
      nftNumber: json['nft_number'],
      allowConnect: json['allow_connect'],
      bookingOtp: json['booking_otp'],
      countryId: json['country_id'],
      cityId: json['city_id'],
      categoryId: json['category_id'],
      description: json['description'],
      yearsOfExperience: json['years_of_experience'],
      countNotification: json['count_notification'],
      otp: json['otp'],
      otpExpired: DateTime.tryParse(json['otp_expired'] ?? ''),
      twitter: json['twitter'],
      skype: json['skype'],
      website: json['website'],
      avatarBackground: json['avatar_background'],
      isPhoneVerified: json['is_phone_verified'],
      otpPhoneVerify: json['otp_phone_verify'],
      isShowNft: json['is_show_nft'],
      department: json['department'],
      isSeeding: json['is_seeding'],
      isBot: json['is_bot'],
      botOwnerId: json['bot_owner_id'],
      botToken: json['bot_token'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'login': login,
        'email': email,
        'permissions': permissions,
        'is_activated': isActivated,
        'is_superuser': isSuperuser,
        'activated_at': activatedAt?.toIso8601String(),
        'last_login': lastLogin?.toIso8601String(),
        'deleted_at': deletedAt,
        'role_id': roleId,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'is_password_expired': isPasswordExpired,
        'password_changed_at': passwordChangedAt,
        'phone': phone,
        'avatar_path': avatarPath,
        'nickname': nickname,
        'otp_count': otpCount,
        'is_locked': isLocked,
        'share_link': shareLink,
        'web_user_id': webUserId,
        'web_ref_id': webRefId,
        'google_user_id': googleUserId,
        'apple_user_id': appleUserId,
        'zoom_id': zoomId,
        'zoom_share_link': zoomShareLink,
        'balance': balance,
        'balance_vnd': balanceVnd,
        'balance_xin': balanceXin,
        'wallet': wallet,
        'search_fullname': searchFullname,
        'gender': gender,
        'birthday': birthday,
        'location': location,
        'is_search_global': isSearchGlobal,
        'is_show_email': isShowEmail,
        'is_show_phone': isShowPhone,
        'is_show_gender': isShowGender,
        'is_show_birthday': isShowBirthday,
        'is_show_location': isShowLocation,
        'cccd': cccd,
        'date_cccd': dateCccd,
        'address_cccd': addressCccd,
        'talk_language': talkLanguage,
        'subscription_payment_otp': subscriptionPaymentOtp,
        'nft_number': nftNumber,
        'allow_connect': allowConnect,
        'booking_otp': bookingOtp,
        'country_id': countryId,
        'city_id': cityId,
        'category_id': categoryId,
        'description': description,
        'years_of_experience': yearsOfExperience,
        'count_notification': countNotification,
        'otp': otp,
        'otp_expired': otpExpired?.toIso8601String(),
        'twitter': twitter,
        'skype': skype,
        'website': website,
        'avatar_background': avatarBackground,
        'is_phone_verified': isPhoneVerified,
        'otp_phone_verify': otpPhoneVerify,
        'is_show_nft': isShowNft,
        'department': department,
        'is_seeding': isSeeding,
        'is_bot': isBot,
        'bot_owner_id': botOwnerId,
        'bot_token': botToken,
      };
}
