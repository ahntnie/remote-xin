// ignore_for_file: prefer-single-widget-per-file

import 'package:any_link_preview/any_link_preview.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:voice_message_package/voice_message_package.dart';

import '../../../../../core/all.dart';
import '../../../../base/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../../all.dart';

part 'widgets/_images_tab_view.dart';
part 'widgets/_link_tab_view.dart';
part 'widgets/_video_tab_view.dart';
part 'widgets/_voice_tab_view.dart';

class ConversationResourcesView
    extends BaseView<ConversationResourcesController> {
  const ConversationResourcesView({Key? key}) : super(key: key);

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      backgroundGradientColor: AppColors.background6,
      appBar: CommonAppBar(
        titleType: AppBarTitle.none,
        titleWidget: Text(
          context.l10n.text_back,
          style: AppTextStyles.s16w700.text2Color,
        ).clickable(() {
          Get.back();
        }),
        leadingIconColor: AppColors.text2,
        centerTitle: false,
      ),
      body: Column(
        children: [
          AppSpacing.gapH20,
          _buildTabBar(),
          AppSpacing.gapH8,
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                _ImageTabView(controller: controller),
                _VideoTabView(controller: controller),
                _VoiceTabView(controller: controller),
                _LinkTabView(controller: controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 36,
      child: TabBar(
        indicatorWeight: 1,
        labelStyle: AppTextStyles.s14w600.text1Color,
        dividerColor: AppColors.subText1,
        dividerHeight: 0,
        controller: controller.tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(80),
          color: AppColors.blue10,
        ),
        tabs: [
          Tab(text: l10n.conversation_resources__tab_image),
          Tab(text: l10n.conversation_resources__tab_video),
          Tab(text: l10n.conversation_resources__tab_voice),
          Tab(text: l10n.conversation_resources__tab_links),
        ],
      ),
    );
  }
}
