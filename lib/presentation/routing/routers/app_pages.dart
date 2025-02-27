import 'package:get/get.dart';

import '../../features/all.dart';
import '../../features/auth/otp_receive/all.dart';
import '../../features/auth/otp_receive/views/otp_receive_forgot_password_view.dart';
import '../../features/call/bindings/call_binding.dart';
import '../../features/call/views/call_video_view.dart';
import '../../features/call/views/in_coming_call_view.dart';
import '../../features/call_gateway/all.dart';
import '../../features/call_gateway/numpad/search_contact/search_contact_view.dart';
import '../../features/map_linking/map_linking_binding.dart';
import '../../features/map_linking/map_linking_view.dart';
import '../../features/mission/mission_binding.dart';
import '../../features/mission/mission_view.dart';
import '../../features/newsfeed/create_story/all.dart';
import '../../features/newsfeed/story/all.dart';
import '../../features/short_video/view/camera/camera_screen.dart';
import '../../features/travel/location/filter/travel_location_filter_binding.dart';
import '../../features/travel/location/filter/travel_location_filter_view.dart';
import '../../features/travel/location/travel_location_binding.dart';
import '../../features/travel/location/travel_location_view.dart';
import '../../features/travel/travel_web_view.dart';
import '../../features/user/my_profile/bindings/my_profile_binding.dart';
import '../../features/user/my_profile/views/my_profile_view.dart';
import '../../features/zoom/zoom_home_view.dart';
import '../middlewares/auth_guard.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initialRoute = Routes.splash;
  static const afterAuthRoute = Routes.home;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.authOption,
      page: () => const AuthOptionView(),
      binding: AuthOptionBinding(),
    ),
    GetPage(
      name: _Paths.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.referralId,
      page: () => const ReferralIdView(),
      binding: ReferralIdBinding(),
    ),
    GetPage(
      name: _Paths.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.noTransition,
      middlewares: [AuthGuard()],
    ),

    GetPage(
      name: _Paths.XINMeeting,
      page: () => const ZoomHomeView(),
    ),

    GetPage(
      name: _Paths.cameraScreen,
      page: () => const CameraScreen(),
    ),

    GetPage(
      name: _Paths.travelMiniApp,
      page: () => const TravelWebView(),
    ),
    // GetPage(
    //   name: _Paths.otpReceive,
    //   binding: OtpReceiveBinding(),
    //   page: () => const OtpReceiveView(),
    //   transition: Transition.noTransition,
    // ),
    GetPage(
      name: _Paths.otpReceiveForgotPassword,
      binding: OtpReceiveBinding(),
      page: () => const OtpReceiveForgotPasswordView(),
      transition: Transition.noTransition,
    ),
    // GetPage(
    //   name: _Paths.resetPassword,
    //   binding: ResetPasswordBinding(),
    //   page: () => const ResetPasswordView(),
    //   transition: Transition.noTransition,
    // ),
    GetPage(
      name: _Paths.intro,
      page: () => const IntroView(),
      binding: IntroBinding(),
    ),
    GetPage(
      name: _Paths.call,
      page: () => const CallView(),
      transition: Transition.noTransition,
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.setting,
      page: () => const SettingView(),
      binding: SettingBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.chatHub,
      page: () => const ChatHubView(),
      binding: ChatHubBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.conversationDetails,
      page: () => const ConversationDetailsView(),
      binding: ConversationDetailsBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.conversationMembers,
      page: () => const ConversationMembersView(),
      binding: ConversationMembersBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.conversationResources,
      page: () => const ConversationResourcesView(),
      binding: ConversationResourcesBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.callGateway,
      page: () => const CallGatewayView(),
      binding: CallGatewayBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.searchContact,
      page: () => const SearchContactView(),
      binding: CallGatewayBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.inComingCall,
      page: () => const InComingCallView(),
      binding: CallBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.search,
      page: () => const SearchView(),
      binding: SearchBinding(),
      middlewares: [AuthGuard()],
      fullscreenDialog: true,
    ),
    GetPage(
      name: _Paths.createPost,
      page: () => const CreatePostView(),
      binding: CreatePostBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.editPost,
      page: () => const EditPostView(),
      binding: EditPostBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.report,
      page: () => const ReportView(),
      binding: ReportBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.postDetail,
      page: () => const PostDetailView(),
      binding: PostDetailBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.personalPage,
      page: () => const PersonalPageView(),
      binding: PersonalPageBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.post,
      page: () => const PostsView(),
      binding: PostsBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.notification,
      page: () => const NotificationView(),
      // binding: NotificationBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.posterPersonal,
      page: () => const PosterPersonalPageView(),
      binding: PosterPersonalPageBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.myProfile,
      page: () => const MyProfileView(),
      binding: MyProfileBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.mission,
      page: () => const MissionView(),
      binding: MissionBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: _Paths.storyPage,
      binding: StoryBinding(),
      page: () => const StoryViewNewFeed(),
    ),
    GetPage(
      name: _Paths.createStory,
      page: () => const CreateStoryView(),
      binding: CreateStoryBinding(),
    ),
    GetPage(
      name: _Paths.travelLocation,
      page: () => const TravelLocationView(),
      binding: TravelLocationBinding(),
    ),
    GetPage(
      name: _Paths.travelLocationFilter,
      page: () => const TravelLocationFilterView(),
      binding: TravelLocationFilterBinding(),
    ),
    GetPage(
      name: _Paths.mapLinking,
      page: () => const MapLinkingView(),
      binding: MapLinkingBinding(),
    ),
  ];
}
