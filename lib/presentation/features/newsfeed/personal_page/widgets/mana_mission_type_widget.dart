import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../models/enums/mission_mana_type_enum.dart';
import '../../../../resource/resource.dart';

class ManaMissionTypeWidget extends StatelessWidget {
  final Rx<ManaMissionTypeEnum> missionManaType;

  const ManaMissionTypeWidget({
    required this.missionManaType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 236.w,
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColors.pacificBlue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(Sizes.s80),
      ),
      child: Obx(
        () => Row(
          children: ManaMissionTypeEnum.values
              .map((e) => Expanded(
                    child: InkWell(
                      onTap: () {
                        missionManaType.value = e;
                      },
                      child: Container(
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: e == missionManaType.value
                              ? AppColors.deepSkyBlue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(Sizes.s80),
                        ),
                        child: Center(
                          child: Text(
                            e.name,
                            style: AppTextStyles.s14w400.copyWith(
                              color: e == missionManaType.value
                                  ? AppColors.white
                                  : AppColors.zambezi,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
