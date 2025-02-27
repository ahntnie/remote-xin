import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';

import '../../../../../../core/all.dart';
import '../../../../../common_widgets/all.dart';
import '../../../../../resource/styles/styles.dart';
import '../../../custom_view/banner_ads_widget.dart';
import '../../../custom_view/image_place_holder.dart';
import '../../../languages/languages_keys.dart';
import '../../../modal/live_stream/live_stream.dart';
import '../../../utils/assert_image.dart';
import '../../../utils/colors.dart';
import '../../../utils/font_res.dart';
import '../../../utils/my_loading/my_loading.dart';
import '../../../view/live_stream/model/live_stream_view_model.dart';

class LiveStreamScreen extends StatelessWidget {
  const LiveStreamScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LiveStreamScreenViewModel>.reactive(
      onViewModelReady: (model) {
        return model.init();
      },
      viewModelBuilder: () => LiveStreamScreenViewModel(),
      builder: (context, model, child) {
        return Consumer(builder: (context, MyLoading myLoading, child) {
          return CommonScaffold(
            appBar: CommonAppBar(
              titleType: AppBarTitle.text,
              titleWidget:
                  Text('EDC Live', style: AppTextStyles.s20w500).clickable(() {
                Get.back();
              }),
              centerTitle: false,
              actions: [
                InkWell(
                  onTap: () {
                    model.goLiveTap(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF124984),
                            Color(0xFF369C09),
                          ],
                          stops: [0.0505, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(30)),
                    child: Row(
                      children: [
                        Image.asset(
                          goLive,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          LKey.goLive.tr,
                          style: const TextStyle(
                              fontFamily: FontRes.fNSfUiSemiBold,
                              color: ColorRes.white),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  CustomGridView(model: model),
                  const SizedBox(height: 10),
                  const BannerAdsWidget()
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

class CustomGridView extends StatelessWidget {
  final LiveStreamScreenViewModel model;

  const CustomGridView({
    required this.model,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: model.liveUsers.isEmpty
          ? Center(
              child: Text(
                LKey.noUserLive.tr,
                style: const TextStyle(
                    fontSize: 18, fontFamily: FontRes.fNSfUiSemiBold),
              ),
            )
          : Container(
              margin: const EdgeInsets.all(6),
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5),
                  itemCount: model.liveUsers.length,
                  itemBuilder: (BuildContext context, int index) {
                    return gridTile(
                        context: context, data: model.liveUsers[index]);
                  }),
            ),
    );
  }

  Widget gridTile(
      {required LiveStreamUser data, required BuildContext context}) {
    return GestureDetector(
      onTap: () => model.onImageTap(context, data),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                data.userImage ?? '',
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return ImagePlaceHolder(
                    fontSize: 100,
                    heightWeight: double.infinity,
                    name: data.fullName ?? '',
                  );
                },
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                width: double.infinity,
                color: ColorRes.colorPrimary.withOpacity(0.6),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${data.fullName ?? ''} ",
                          style: const TextStyle(
                            color: ColorRes.white,
                            fontSize: 15,
                          ),
                        ),
                        // Image.asset(
                        //   icVerify,
                        //   height: 16,
                        //   width: 16,
                        // ),
                      ],
                    ),
                    // Text(
                    //   '${NumberFormat.compact(locale: 'en').format(data.followers ?? 0)} ${LKey.followers.tr}',
                    //   style: const TextStyle(
                    //     color: ColorRes.white,
                    //     fontSize: 12,
                    //   ),
                    // ),
                    const SizedBox(height: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Image.asset(
                          feEye,
                          width: 20,
                          height: 15,
                          color: ColorRes.white,
                        ),
                        const SizedBox(width: 3.5),
                        Text(
                          NumberFormat.compact(locale: 'en')
                              .format(data.watchingCount ?? 0),
                          style: const TextStyle(
                            color: ColorRes.white,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
