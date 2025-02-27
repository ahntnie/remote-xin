import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../presentation/common_widgets/raw_pip_view.dart';

class PipInAppService extends StatefulWidget {
  final Widget child;

  const PipInAppService({required this.child, super.key});

  @override
  PIPInAppState createState() {
    return PIPInAppState();
  }

  static PIPInAppState of(BuildContext context) {
    final PIPInAppState toastState =
        context.findRootAncestorStateOfType<PIPInAppState>()!;
    toastState._setCurrentContext(context);

    return toastState;
  }
}

class PIPInAppState extends State<PipInAppService>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late BuildContext _currentContext;
  late bool _pipInProgress;
  late bool _dismissInProgress;
  final EventBus _eventBus = Get.find<EventBus>();

  @override
  void initState() {
    super.initState();
    _pipInProgress = false;
    _dismissInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    return _MeoWoofToast(
      child: widget.child,
    );
  }

  Future showPIP({
    required Widget child,
    required VoidCallback onPIPClick,
  }) async {
    if (_pipInProgress) return;
    _pipInProgress = true;
    _overlayEntry = _createOverlayEntryFromTop(
      onPIPClick: onPIPClick,
      child: child,
    );
    final overlay = Overlay.of(_currentContext);
    if (_overlayEntry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        overlay.insert(_overlayEntry!);
      });
    }
  }

  Future dismissPIP() async {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _dismissInProgress = false;
    _pipInProgress = false;
  }

  OverlayEntry _createOverlayEntryFromTop({
    required Widget child,
    required VoidCallback onPIPClick,
  }) {
    return OverlayEntry(
      builder: (context) {
        return RawPIPView(
          topWidget: child,
          floatingHeight: 200.h,
          floatingWidth: 150.w,
          onTapTopWidget: () {
            if (_dismissInProgress) return;
            _dismissInProgress = true;
            dismissPIP();
            onPIPClick();
          },
        );
        // return Stack(
        //   children: [
        //     Positioned(
        //       right: 20.w,
        //       top: MediaQuery.of(context).padding.top + 40,
        //       child: GestureDetector(
        //         onTap: () {
        //           if (_dismissInProgress) return;
        //           _dismissInProgress = true;
        //           dismissPIP();
        //           onPIPClick();
        //         },
        //         child: ,
        //       ),
        //     ),
        //   ],
        // );
      },
    );
  }

  void _setCurrentContext(BuildContext context) {
    setState(() {
      _currentContext = context;
    });
  }
}

class _MeoWoofToast extends InheritedWidget {
  const _MeoWoofToast({required Widget child, Key? key})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(_MeoWoofToast old) {
    return true;
  }
}
