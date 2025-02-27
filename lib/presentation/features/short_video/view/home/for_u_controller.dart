// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:video_player/video_player.dart';

// import '../../../../../repositories/short-video/short_video_repo.dart';
// import '../../modal/user_video/user_video.dart';
// import '../../utils/const_res.dart';
// import '../../utils/url_res.dart';

// class ForUController extends ChangeNotifier {
//   List<Data> mList = [];
//   PageController pageController = PageController();
//   int focusedIndex = 0;
//   Map<int, VideoPlayerController> controllers = {};
//   bool isLoading = false;
//   bool isApiCall = true;
//   int pageIndex = 1;
//   int currentIndex = 0;
//   final shortVideoRepo = Get.find<ShortVideoRepository>();

//   void init() {
//     callApiForYou(
//       (p0) {
//         initVideoPlayer();
//       },
//       true,
//     );
//   }

//   Future callApiForYou(Function(List<Data>) onCompletion, bool init) async {
//     if (init) {
//       mList = [];
//       pageIndex = 1;
//       isLoading = true;
//     }
//     if (isApiCall) {
//       isApiCall = true;
//     }
//     await shortVideoRepo
//         .getPostList(
//             paginationLimit.toString(), '1505', UrlRes.related, pageIndex)
//         .then(
//       (value) {
//         isLoading = false;
//         isApiCall = false;
//         pageIndex++;
//         if (value.isNotEmpty) {
//           final newData = value.toList();
//           if (newData.isNotEmpty) {
//             mList.addAll(newData);
//             onCompletion(mList);
//             log(mList.length.toString());
//             notifyListeners();
//           }
//         }
//       },
//     );
//   }

//   Future<void> pausePlayer() async {
//     await controllers[focusedIndex]?.pause();
//   }

//   void _playNext(int index) {
//     controllers.forEach((key, value) {
//       if (value.value.isPlaying) {
//         value.pause();
//       }
//     });

//     /// Stop [index - 1] controller
//     _stopControllerAtIndex(index - 1);

//     /// Dispose [index - 2] controller
//     _disposeControllerAtIndex(index - 2);

//     /// Play current video (already initialized)
//     _playControllerAtIndex(index);

//     /// Initialize [index + 1] controller

//     _initializeControllerAtIndex(index + 1);
//   }

//   void _playPrevious(int index) {
//     controllers.forEach((key, value) {
//       value.pause();
//     });

//     /// Stop [index + 1] controller
//     _stopControllerAtIndex(index + 1);

//     /// Dispose [index + 2] controller
//     _disposeControllerAtIndex(index + 2);

//     /// Play current video (already initialized)
//     _playControllerAtIndex(index);

//     /// Initialize [index - 1] controller
//     _initializeControllerAtIndex(index - 1);
//   }

//   Future _initializeControllerAtIndex(
//     int index,
//   ) async {
//     if (mList.length > index && index >= 0) {
//       log('🚀🚀🚀 INITIALIZED $index');
//       if (index == mList.length - 3) {
//         callApiForYou(
//           (p0) {},
//           false,
//         );
//       }

//       /// Create new controller
//       final VideoPlayerController controller = VideoPlayerController.networkUrl(
//           Uri.parse(mList[index].postVideo ?? ''));

//       /// Add to [controllers] list
//       controllers[index] = controller;

//       await controller.initialize();

//       notifyListeners();
//     }
//   }

//   void _playControllerAtIndex(int index) {
//     focusedIndex = index;
//     if (mList.length > index && index >= 0) {
//       /// Get controller at [index]
//       final VideoPlayerController? controller = controllers[index];

//       if (controller != null) {
//         /// Play controller
//         controller.play();
//         controller.setLooping(true);
//         log('🚀🚀🚀 PLAYING $index');
//         currentIndex = index;
//         // ApiService().increasePostViewCount(mList[index].postId.toString());
//         notifyListeners();
//       }
//     }
//   }

//   void _stopControllerAtIndex(int index) {
//     if (mList.length > index && index >= 0) {
//       /// Get controller at [index]
//       final VideoPlayerController? controller = controllers[index];

//       if (controller != null) {
//         /// Pause
//         controller.pause();

//         /// Reset postiton to beginning
//         controller.seekTo(const Duration());
//         log('==================================');
//         log('🚀🚀🚀 STOPPED $index');
//       }
//     }
//   }

//   void _disposeControllerAtIndex(int index) {
//     if (mList.length > index && index >= 0) {
//       /// Get controller at [index]
//       final VideoPlayerController? controller = controllers[index];

//       /// Dispose controller
//       controller?.dispose();

//       if (controller != null) {
//         controllers.remove(controller);
//       }

//       log('🚀🚀🚀 DISPOSED $index');
//     }
//   }

//   Future<void> initVideoPlayer() async {
//     /// Initialize 1st video
//     await _initializeControllerAtIndex(0);

//     /// Play 1st video
//     _playControllerAtIndex(0);

//     /// Initialize 2nd vide
//     await _initializeControllerAtIndex(1);
//   }

//   void onPageChanged(int value) {
//     // if (value == mList.length - 3) {
//     //   // if (!isLoading) {
//     //   //   callApiForYou(
//     //   //     (p0) {},

//     //   //   );
//     //   // }
//     // }
//     if (value > focusedIndex) {
//       _playNext(value);
//     } else {
//       _playPrevious(value);
//     }
//   }

//   // @override
//   // void dispose() {
//   //   pageController.dispose();
//   //   super.dispose();
//   //   controllers.forEach((key, value) async {
//   //     await value.dispose();
//   //   });
//   // }
// }
