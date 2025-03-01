import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

// Global notifier để quản lý video đang được phát (chỉ cho phép 1 video phát tại 1 thời điểm)
ValueNotifier<int?> currentPlayingIndex = ValueNotifier<int?>(null);

class VideoGridItem extends StatefulWidget {
  final String videoUrl;
  final int index; // index của video trong danh sách

  const VideoGridItem({
    required this.videoUrl,
    required this.index,
    Key? key,
  }) : super(key: key);

  @override
  _VideoGridItemState createState() => _VideoGridItemState();
}

class _VideoGridItemState extends State<VideoGridItem> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
    _initializeVideo();
    currentPlayingIndex.addListener(_globalPlayListener);
  }

  void _globalPlayListener() {
    if (currentPlayingIndex.value != widget.index) {
      if (_controller.value.isPlaying) {
        _controller.pause();
      }
    } else {
      if (_isInitialized && !_controller.value.isPlaying) {
        _controller.play();
      }
    }
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();
      await _controller.seekTo(Duration.zero);
      _controller.setLooping(true);
      setState(() {
        _isInitialized = true;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Unable to load video';
      });
      print('Error initializing video: $error');
    }
  }

  @override
  void dispose() {
    currentPlayingIndex.removeListener(_globalPlayListener);
    _controller.dispose();
    super.dispose();
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!_isInitialized) return;
    final RenderBox box = context.findRenderObject() as RenderBox;
    final widgetPosition = box.localToGlobal(Offset.zero);
    final widgetTop = widgetPosition.dy;

    final screenHeight = MediaQuery.of(context).size.height;

    final isLeft = widget.index % 2 == 0;

    if (info.visibleFraction > 0.4) {
      if (!isLeft && widgetTop < screenHeight * 0.4) {
        if (currentPlayingIndex.value != widget.index) {
          currentPlayingIndex.value = widget.index;
        }
      } else if (isLeft &&
          widgetTop >= screenHeight * 0.4 &&
          widgetTop <= screenHeight * 0.6) {
        if (currentPlayingIndex.value != widget.index) {
          currentPlayingIndex.value = widget.index;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    return VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: _handleVisibilityChanged,
      child: Container(
        color: Colors.transparent,
        child: _isInitialized
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phần video có bo góc tròn
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.33,
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    ),
                  ),
                  // Tiêu đề video
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Cùng Xuân Ca uống CocaCola, nước uống có ga ngon nhất hiện tại',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  // Thông tin bên dưới (tên kênh & lượt thích)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Xuân ca',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        Text(
                          '44k',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
