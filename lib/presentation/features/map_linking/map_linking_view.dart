import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/all.dart';
import '../../../models/map_linking/position_map.dart';
import '../../base/all.dart';
import '../../common_widgets/all.dart';
import '../../resource/resource.dart';
import 'map_linking_controller.dart';

class MapLinkingView extends BaseView<MapLinkingController> {
  const MapLinkingView({super.key});

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      body: Stack(
        children: [
          Obx(
            () => controller.currentP.value == null
                ? const Center(
                    child: Text('Loading...'),
                  )
                : GoogleMap(
                    onMapCreated: (GoogleMapController mapController) async {
                      controller.mapController.complete(mapController);
                    },
                    mapToolbarEnabled: false,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    initialCameraPosition: CameraPosition(
                      target: controller.pGooglePlex,
                      zoom: 13,
                    ),
                    markers: controller.markers,
                    polylines: Set<Polyline>.of(controller.polylines.values),
                    onTap: (argument) {
                      controller.showNavigator.value = false;
                    },
                  ),
          ),
          Positioned(
            bottom: controller.collapsedHeight + 40,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => controller.showNavigator.value
                      ? Container(
                          width: 35,
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white),
                          child: Column(
                            children: [
                              MaterialButton(
                                onPressed: () {
                                  if (controller.positionNavigator != null) {
                                    controller.openGoogleMapsNavigation();
                                  }
                                },
                                padding: const EdgeInsets.all(0),
                                child: const Icon(
                                  Icons.directions,
                                  size: 22,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                ),
                AppSpacing.gapH12,
                Container(
                  width: 35,
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  child: Column(
                    children: [
                      MaterialButton(
                        onPressed: () {
                          controller.cameraToPosition(
                              controller.currentP.value!, 13);
                        },
                        padding: const EdgeInsets.all(0),
                        child: const Icon(
                          Icons.gps_fixed,
                          size: 22,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapH12,
                Container(
                  width: 35,
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  child: Column(
                    children: [
                      MaterialButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              padding: const EdgeInsets.all(20),
                              color: Colors.white,
                              height: MediaQuery.of(context).size.height * 0.3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.map_linking_theme,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 100,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: controller.mapThemes.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            controller.setMapStyle(
                                              controller.mapThemes[index]
                                                  ['style'],
                                            );
                                            controller.indexTheme.value = index;
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            width: 100,
                                            margin: const EdgeInsets.only(
                                              right: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                  controller.mapThemes[index]
                                                      ['image'],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        padding: const EdgeInsets.all(0),
                        child: const Icon(
                          Icons.layers_rounded,
                          size: 22,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapH12,
                Container(
                  width: 35,
                  height: 105,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  child: Column(
                    children: [
                      MaterialButton(
                        onPressed: () {
                          controller.zoomInMap();
                        },
                        padding: const EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 25,
                          color: Colors.black,
                        ),
                      ),
                      const Divider(
                        height: 5,
                        color: Colors.black,
                      ),
                      MaterialButton(
                        onPressed: () {
                          controller.zoomOutMap();
                        },
                        padding: const EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.remove,
                          size: 25,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Obx(() => AppIcon(
                  icon: AppIcons.arrowLeft,
                  color: controller.indexTheme.value == 0 ||
                          controller.indexTheme.value == 1 ||
                          controller.indexTheme.value == 2
                      ? Colors.black
                      : Colors.white,
                  onTap: () => Get.back(),
                ).paddingOnly(left: 20, top: 12)),
          ),
          Obx(
            () => controller.showNavigator.value
                ? const SizedBox()
                : Positioned(
                    bottom: 0,
                    child: Obx(
                      () => GestureDetector(
                        onTap: () {
                          if (!controller.isExpanded.value) {
                            controller.toggleContainer();
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: controller.isExpanded.value
                              ? controller.expandedHeight
                              : controller.collapsedHeight,
                          width: 1.sw - 40,
                          padding: AppSpacing.edgeInsetsAll12,
                          margin: AppSpacing.edgeInsetsAll20,
                          decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16)),
                          child: controller.isExpanded.value
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppIcon(
                                      icon: AppIcons.arrowLeft,
                                      color: Colors.black,
                                      onTap: () =>
                                          controller.isExpanded.value = false,
                                    ),
                                    AppSpacing.gapH12,
                                    _buildTabBar(),
                                    Expanded(
                                      child: TabBarView(
                                        controller: controller.tabController,
                                        children: controller.categories
                                            .map((category) =>
                                                _buildPositionsList(
                                                    category.positions ?? []))
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Obx(
                                      () => Row(
                                        children: [
                                          Expanded(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                '${controller.numberPosition.value == 0 ? l10n.map_linking_no : controller.numberPosition.value} ${l10n.map_linking_active}',
                                                style: AppTextStyles
                                                    .s22w500.text2Color,
                                              ),
                                            ),
                                          ),
                                          AppSpacing.gapW20,
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: AppColors.blue10,
                                                borderRadius:
                                                    BorderRadius.circular(100)),
                                            child: Text(
                                              controller.category.value,
                                              style: AppTextStyles.s12w600
                                                  .copyWith(fontSize: 11),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AppSpacing.gapH8,
                                    const Divider(
                                      color: AppColors.subText2,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          l10n.map_linking_view_all,
                                          style: AppTextStyles.s14w500
                                              .toColor(AppColors.blue10),
                                        ),
                                        AppSpacing.gapW4,
                                        const AppIcon(
                                          icon: Icons.arrow_forward,
                                          color: AppColors.blue10,
                                          size: 14,
                                        ),
                                      ],
                                    ).clickable(
                                      () => controller.isExpanded.value = true,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      height: 36,
      child: TabBar(
        tabAlignment: TabAlignment.start,
        indicatorWeight: 1,
        isScrollable: true,
        labelStyle: AppTextStyles.s14w600.text1Color,
        dividerColor: AppColors.subText1,
        dividerHeight: 0,
        controller: controller.tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(80),
          color: AppColors.blue10,
        ),
        onTap: (value) {},
        tabs: controller.categories
            .map((category) => Tab(text: category.language[controller.key]))
            .toList(),
      ),
    );
  }

  Widget _buildPositionsList(List<PositionMap> positions) {
    return ListView.builder(
      itemCount: positions.length,
      itemBuilder: (context, index) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcon(
                icon: Assets.icons.locationProfile,
                color: const Color(0xff369C09),
                size: 20,
              ),
              AppSpacing.gapW12,
              Text(
                positions[index].name,
                style: AppTextStyles.s16w700.text2Color,
              ),
            ],
          ),
          Text(
            positions[index].physicalAddress,
            style: AppTextStyles.s14w500.subText2Color,
          ).paddingOnly(left: 32),
          AppSpacing.gapH20,
        ],
      ).clickable(() {
        controller.isExpanded.value = false;
        controller.cameraToPosition(
            LatLng(
              positions[index].latitude,
              positions[index].longitude,
            ),
            14);
      }),
    );
  }
}
