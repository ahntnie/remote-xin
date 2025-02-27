import 'const_res.dart';

class UrlRes {
  ///RegisterUser
  static const String registerUser = '${ConstRes.baseUrl}User/Registration';
  static const String checkUsername = '${ConstRes.baseUrl}User/checkUsername';
  static const String deviceToken = 'device_token';
  static const String userEmail = 'user_email';
  static const String fullName = 'full_name';
  static const String loginType = 'login_type';
  static const String userName = 'user_name';
  static const String identity = 'identity';
  static const String platform = 'platform';

  ///getUserVideos getUserLikesVideos
  static const String getUserVideos = '${ConstRes.baseUrl}Post/getUserVideos';
  static const String getUserLikesVideos =
      '${ConstRes.baseUrl}Post/getUserLikesVideos';
  static const String start = 'start';
  static const String limit = 'limit';
  static const String userId = 'user_id';
  static const String myUserId = 'my_user_id';

  /// getPostList
  ///type following and related
  static const String getPostList =
      '${ConstRes.baseUrl}/short-video/getPostList';
  static const String type = 'type';
  static const String following = 'following';
  static const String trending = 'trending';
  static const String related = 'related';

  ///LikeUnlikeVideo
  static const String likeUnlikePost = '${ConstRes.baseUrl}Post/LikeUnlikePost';
  static const String postId = 'post_id';

  ///CommentListByPostId
  static const String getCommentByPostId =
      '${ConstRes.baseUrl}Post/getCommentByPostId';

  ///addComment
  static const String addComment = '${ConstRes.baseUrl}Post/addComment';
  static const String comment = 'comment';

  ///deleteComment
  static const String deleteComment = '${ConstRes.baseUrl}Post/deleteComment';
  static const String commentId = 'comments_id';

  ///getVideoByHashTag
  static const String videosByHashTag =
      '${ConstRes.baseUrl}Post/getSingleHashTagPostList';
  static const String hashTag = 'hash_tag';

  ///getVideoBySoundId
  static const String getPostBySoundId =
      '${ConstRes.baseUrl}Post/getPostBySoundId';
  static const String soundId = 'sound_id';
  static const String soundIds = 'sound_ids';

  ///sendCoin
  static const String sendCoin = '${ConstRes.baseUrl}Wallet/sendCoin';
  static const String coin = 'coin';
  static const String toUserId = 'to_user_id';

  ///getExploreHashTag
  static const String getExploreHashTag =
      '${ConstRes.baseUrl}Post/getExploreHashTagPostList';

  ///getUserSearchPostList
  static const String getUserSearchPostList =
      '${ConstRes.baseUrl}Post/getUserSearchPostList';
  static const String keyWord = 'keyword';

  ///getSearchPostList
  static const String getSearchPostList =
      '${ConstRes.baseUrl}Post/getSearchPostList';

  ///getNotificationList
  static const String getNotificationList =
      '${ConstRes.baseUrl}User/getNotificationList';

  ///setNotificationSettings
  static const String setNotificationSettings =
      '${ConstRes.baseUrl}User/setNotificationSettings';

  ///getCoinRateList
  static const String getCoinRateList =
      '${ConstRes.baseUrl}Wallet/getCoinRateList';

  ///getRewardingActionList
  static const String getRewardingActionList =
      '${ConstRes.baseUrl}Wallet/getRewardingActionList';

  ///getMyWalletCoin
  static const String getMyWalletCoin =
      '${ConstRes.baseUrl}Wallet/getMyWalletCoin';

  ///redeemRequest
  static const String redeemRequest = '${ConstRes.baseUrl}Wallet/redeemRequest';
  static const String amount = 'amount';
  static const String redeemRequestType = 'redeem_request_type';
  static const String account = 'account';

  ///verifyRequest
  static const String verifyRequest = '${ConstRes.baseUrl}User/verifyRequest';
  static const String idNumber = 'id_number';
  static const String name = 'name';
  static const String address = 'address';
  static const String photoIdImage = 'photo_id_image';
  static const String photoWithIdImage = 'photo_with_id_image';

  ///getProfile
  static const String getProfile = '${ConstRes.baseUrl}User/getProfile';

  ///getProfileCategoryList
  static const String getProfileCategoryList =
      '${ConstRes.baseUrl}User/getProfileCategoryList';

  ///updateProfile
  static const String updateProfile = '${ConstRes.baseUrl}User/updateProfile';
  static const String bio = 'bio';
  static const String fbUrl = 'fb_url';
  static const String instaUrl = 'insta_url';
  static const String youtubeUrl = 'youtube_url';
  static const String userProfile = 'user_profile';
  static const String profileCategory = 'profile_category';
  static const String isNotification = 'is_notification';

  ///FollowUnFollowPost
  static const String followUnFollowPost =
      '${ConstRes.baseUrl}Post/FollowUnfollowPost';

  ///getFollowerList
  static const String getFollowerList =
      '${ConstRes.baseUrl}Post/getFollowerList';

  ///getFollowingList
  static const String getFollowingList =
      '${ConstRes.baseUrl}Post/getFollowingList';

  ///getSoundList
  static const String getSoundList = '${ConstRes.baseUrl}Post/getSoundList';

  ///getFavouriteSoundList
  static const String getFavouriteSoundList =
      '${ConstRes.baseUrl}Post/getFavouriteSoundList';

  ///getSearchSoundList
  static const String getSearchSoundList =
      '${ConstRes.baseUrl}Post/getSearchSoundList';

  ///generateAgoraToken
  static const String generateAgoraToken =
      '${ConstRes.baseUrl}User/generateAgoraToken';
  static const String channelName = 'channelName';

  ///addPost
  static const String addPost = '${ConstRes.baseUrl}Post/addPost';
  static const String postDescription = 'post_description';
  static const String postHashTag = 'post_hash_tag';
  static const String postVideo = 'post_video';
  static const String postImage = 'post_image';
  static const String isOriginalSound = 'is_orignal_sound';
  static const String postSound = 'post_sound';
  static const String soundTitle = 'sound_title';
  static const String duration = 'duration';
  static const String singer = 'singer';
  static const String soundImage = 'sound_image';

  ///Logout
  static const String logoutUser = '${ConstRes.baseUrl}User/Logout';

  ///DeleteAccount
  static const String deleteAccount = '${ConstRes.baseUrl}User/deleteMyAccount';

  ///DeletePost
  static const String deletePost = '${ConstRes.baseUrl}Post/deletePost';

  ///ReportPost
  static const String reportPostOrUser = '${ConstRes.baseUrl}Post/ReportPost';
  static const String reportType = 'report_type';
  static const String reason = 'reason';
  static const String description = 'description';
  static const String contactInfo = 'contact_info';

  ///BlockUser
  static const String blockUser = '${ConstRes.baseUrl}User/blockUser';

  ///getPostListById
  static const String getPostListById =
      '${ConstRes.baseUrl}Post/getPostListById';

  ///getCoinPlanList
  static const String getCoinPlanList =
      '${ConstRes.baseUrl}Wallet/getCoinPlanList';

  ///addCoin
  static const String addCoin = '${ConstRes.baseUrl}Wallet/addCoin';
  static const String rewardingActionId = 'rewarding_action_id';

  ///purchaseCoin
  static const String purchaseCoin = '${ConstRes.baseUrl}Wallet/purchaseCoin';

  ///IncreasePostViewCount
  static const String increasePostViewCount =
      '${ConstRes.baseUrl}Post/IncreasePostViewCount';

  ///fetchSettingsData
  static const String fetchSettingsData =
      '${ConstRes.baseUrl}fetchSettingsData';

  /// uploadFileGivenPath
  static const String fileGivenPath = '${ConstRes.baseUrl}uploadFileGivePath';

  /// Notification Api
  static const String notificationUrl =
      '${ConstRes.baseUrl}User/pushNotificationToSingleUser';

  /// privacy & term
  static const String termAndCondition = '${ConstRes.base}termsOfUse';
  static const String privacyPolicy = '${ConstRes.base}privacypolicy';

  static const String agoraLiveStreamingCheck =
      'https://api.agora.io/dev/v1/channel/user/';

  static const String checkVideoModeration =
      'https://api.sightengine.com/1.0/video/check-workflow-sync.json';

  static const String checkVideoModerationMoreThenOneMinutes =
      'https://api.sightengine.com/1.0/video/check.json';

  static const String uniqueKey = 'unique-key';
  static const String authorization = 'Authorization';
  static const String favourite = 'favourite';

  static const String isLogin = 'is_login';

  static const String camera = '';

  static const String isAccepted = 'is_accepted';
}
