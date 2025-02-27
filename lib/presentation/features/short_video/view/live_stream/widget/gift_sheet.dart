import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/all.dart';
import '../../../../../common_controller.dart/all.dart';
import '../../../../../common_widgets/app_icon.dart';
import '../../../../../common_widgets/circle_avatar.dart';
import '../../../../../resource/resource.dart';
import '../../../modal/setting/setting.dart';
import '../../../modal/user/user.dart';
import '../../../utils/colors.dart';
import '../../../utils/font_res.dart';

class GiftSheet extends StatefulWidget {
  final VoidCallback onAddShortzzTap;
  final User? user;
  final Function(Gifts? gifts) onGiftSend;
  final SettingData? settingData;
  final List<Gifts> gifts;
  final int balance;

  const GiftSheet(
      {required this.onAddShortzzTap,
      required this.onGiftSend,
      required this.settingData,
      required this.gifts,
      required this.balance,
      Key? key,
      this.user})
      : super(key: key);

  @override
  State<GiftSheet> createState() => _GiftSheetState();
}

class _GiftSheetState extends State<GiftSheet> {
  int balance = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    balance = widget.balance;
  }

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          color: Color(0xff2e2e2e),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppCircleAvatar(
                  url: appController.lastLoggedUser?.avatarPath ?? '',
                  size: 40,
                ),
                AppSpacing.gapW4,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appController.lastLoggedUser?.fullName ?? '',
                      style: AppTextStyles.s12w600.text2Color
                          .copyWith(fontSize: 13),
                    ).paddingOnly(right: 4),
                    Row(
                      children: [
                        // AppIcon(
                        //   icon: Assets.images.diamond,
                        //   size: 12,
                        // ),
                        AppSpacing.gapW4,
                        Text(
                          balance.toString(),
                          style: AppTextStyles.s12w400
                              .copyWith(fontSize: 11, color: Colors.white),
                        )
                      ],
                    )
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: const Color(0xff1e1e1e),
                      borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    children: [
                      // AppIcon(
                      //   icon: Assets.images.diamond,
                      //   size: 12,
                      // ),
                      AppSpacing.gapW4,
                      Text(
                        'Recharge',
                        style: AppTextStyles.s12w500.text2Color,
                      ),
                      AppIcon(
                        icon: Assets.icons.arrowRight,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                )
              ],
            ),
            AppSpacing.gapH20,
            Expanded(
              child: GridView.builder(
                itemCount: widget.gifts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  // final Gifts? gift = settingData?.gifts?[index];
                  // log(gift?.image ?? '');
                  return InkWell(
                    onTap: () {
                      // if (gift!.coinPrice! < user!.data!.myWallet!) {
                      //   onGiftSend(Gifts(
                      //     coinPrice: 100,
                      //     id: 1,
                      //     image:
                      //         'https://storage.streamdps.com/iblock/50f/50f8e7cf26128a6e10d0b792019c1303/94aa2d574cfe6e3893c087cfb5a5efcd.png',
                      //   ));
                      // } else {
                      //   Navigator.pop(context);
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     const SnackBar(
                      //       content: Text(
                      //           'Insufficient Shortzz..! Please purchase shortzz'),
                      //       behavior: SnackBarBehavior.floating,
                      //     ),
                      //   );
                      // }
                      setState(() {
                        balance = balance - widget.gifts[index].coinPrice!;
                      });
                      widget.onGiftSend(widget.gifts[index]);
                    },
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.gifts[index].image ?? '',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // AppIcon(
                              //   icon: Assets.images.diamond,
                              //   size: 12,
                              // ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  '${widget.gifts[index].coinPrice ?? 0}',
                                  style: const TextStyle(
                                    fontFamily: FontRes.fNSfUiLight,
                                    color: ColorRes.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
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
  }
}
