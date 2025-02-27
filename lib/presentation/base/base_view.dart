import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';

import '../../models/user.dart';
import '../common_widgets/all.dart';
import '../resource/resource.dart';
import 'base_controller.dart';

abstract class BaseView<Controller extends BaseController>
    extends GetView<Controller> {
  const BaseView({super.key});

  AppLocalizations get l10n => AppLocalizations.of(Get.context!)!;

  bool get allowLoadingIndicator => true;

  User get currentUser => controller.currentUser;

  @override
  Widget build(BuildContext context) {
    if (!allowLoadingIndicator) {
      return buildPage(context);
    }

    return Stack(
      children: [
        buildPage(context),
        if (allowLoadingIndicator) _loadingLayer(),
      ],
    );
  }

  Widget buildPage(BuildContext context);

  Widget _loadingLayer() {
    return Obx(
      () => controller.isLoading ? _buildLoading() : AppSpacing.emptyBox,
    );
  }

  Widget _buildLoading() {
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Center(
        child: IntrinsicWidth(
          child: IntrinsicHeight(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(Sizes.s16),
                ),
                child: loadingContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget loadingContent() {
    return const AppDefaultLoading();
  }
}
