import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../../all.dart';

class SearchPostIcon extends StatefulWidget {
  final bool isExpand;
  const SearchPostIcon({required this.isExpand, super.key});

  @override
  State<SearchPostIcon> createState() => _SearchPostIconState();
}

class _SearchPostIconState extends State<SearchPostIcon> {
  final postController = Get.find<PostsController>();
  bool hideSearch = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (widget.isExpand)
          SizedBox(
            width: 0.2.sw - 12,
            child: AppIcon(
              icon: AppIcons.arrowLeft,
              color: AppColors.text2,
              onTap: () {
                setState(() {
                  hideSearch = false;
                });
                Get.find<PostsController>().setIsSearch(false);
              },
            ),
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: widget.isExpand ? 0.8.sw : 40,
          margin: const EdgeInsets.only(
            left: Sizes.s2,
            right: Sizes.s2,
            top: Sizes.s8,
          ),
          padding: widget.isExpand
              ? EdgeInsets.zero
              : const EdgeInsets.all(Sizes.s8),
          decoration: widget.isExpand
              ? BoxDecoration(
                  color: AppColors.grey6,
                  borderRadius: BorderRadius.circular(100),
                )
              : const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.grey6,
                ),
          child: widget.isExpand
              ? TextFormField(
                  onChanged: (value) {
                    postController.search(value);
                  },
                  style: AppTextStyles.s16Base.text2Color,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    fillColor: AppColors.grey6,
                    filled: true,
                    // isDense: true,
                    hintText: context.l10n.search__search,
                    hintStyle: AppTextStyles.s16w400.copyWith(
                      color: AppColors.subText2,
                      fontStyle: FontStyle.italic,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide.none,
                    ),
                  ))
              : AppIcon(
                  icon: AppIcons.search,
                  color: Colors.black,
                  size: hideSearch ? 0 : 24,
                ),
        ).clickable(() {
          setState(() {
            hideSearch = true;
          });
          // Get.toNamed(Routes.search, arguments: {'type': 'post'});
          Get.find<PostsController>().setIsSearch(true);
          Get.find<PostsController>().clearSearchText();
        }),
      ],
    );
  }
}
