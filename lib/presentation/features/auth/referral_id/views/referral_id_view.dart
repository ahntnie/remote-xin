import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../base/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/styles/styles.dart';
import '../all.dart';

class ReferralIdView extends BaseView<ReferralIdController> {
  const ReferralIdView({Key? key}) : super(key: key);

  Widget _buildContinueBtn() {
    return AppButton.primary(
      label: l10n.button__continue,
      width: double.infinity,
      onPressed: controller.signInWithSignInThirdParty,
    );
  }

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      hideKeyboardWhenTouchOutside: true,
      appBar: CommonAppBar(
        leadingIconColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Column(
            children: [
              SizedBox(
                height: 206.h,
              ),
              AppTextField(
                // inputFormatters: [LowerCaseTextFormatter()],
                controller: controller.referralIdController,
                label: l10n.field__referralId,
                textInputAction: TextInputAction.done,
                contentPadding: EdgeInsets.all(17.w),
                keyboardType: TextInputType.text,
              ),
              AppSpacing.gapH24,
              _buildContinueBtn(),
            ],
          ),
        ),
      ),
    );
  }
}
