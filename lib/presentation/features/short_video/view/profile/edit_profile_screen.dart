import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../api/api_service.dart';
import '../../custom_view/app_bar_custom.dart';
import '../../custom_view/common_ui.dart';
import '../../custom_view/image_place_holder.dart';
import '../../languages/languages_keys.dart';
import '../../modal/profileCategory/profile_category.dart';
import '../../modal/status.dart';
import '../../modal/user/user.dart';
import '../../utils/assert_image.dart';
import '../../utils/colors.dart';
import '../../utils/const_res.dart';
import '../../utils/font_res.dart';
import '../../utils/my_loading/my_loading.dart';
import 'dialog_profile_category.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String profileImage = '';
  String createNewUserName = '';
  String userEmail = '';
  TextEditingController fullNameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController faceBookController = TextEditingController();
  TextEditingController youtubeController = TextEditingController();
  TextEditingController instagramController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String profileCategoryID = '';
  String? profileCategoryName = '';
  UserData? user;

  @override
  void initState() {
    user = Provider.of<MyLoading>(context, listen: false).getUser?.data;
    print(user?.profileCategory);
    fullNameController = TextEditingController(text: user?.fullName ?? '');
    userNameController = TextEditingController(text: user?.userName ?? '');
    bioController = TextEditingController(text: user?.bio ?? '');
    faceBookController = TextEditingController(text: user?.fbUrl ?? '');
    youtubeController = TextEditingController(text: user?.youtubeUrl ?? '');
    instagramController = TextEditingController(text: user?.instaUrl ?? '');
    profileCategoryName = user?.profileCategoryName ?? '';
    profileCategoryID = '${user?.profileCategory ?? -1}';
    userEmail = user?.userEmail ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, MyLoading myLoading, child) {
      return Scaffold(
        body: Column(
          children: [
            AppBarCustom(title: LKey.editProfile.tr),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: myLoading.isDark
                                  ? ColorRes.greyShade100
                                  : ColorRes.colorPrimary,
                              width: 0.5),
                          shape: BoxShape.circle),
                      child: ClipOval(
                        child: profileImage.isEmpty
                            ? Image.network(
                                ConstRes.itemBaseUrl +
                                    (myLoading.getUser?.data?.userProfile !=
                                                null &&
                                            myLoading.getUser!.data!
                                                .userProfile!.isNotEmpty
                                        ? myLoading.getUser!.data!.userProfile!
                                        : ''),
                                errorBuilder: (context, error, stackTrace) {
                                  return ImagePlaceHolder(
                                    name: user?.fullName,
                                    heightWeight: 100,
                                    fontSize: 70,
                                  );
                                },
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(profileImage),
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              myLoading.isDark
                                  ? ColorRes.colorPrimary
                                  : ColorRes.greyShade100),
                          alignment: Alignment.center,
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(horizontal: 50),
                          ),
                        ),
                        onPressed: () {
                          _imagePicker
                              .pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: imageQuality,
                                  maxHeight: maxHeight,
                                  maxWidth: maxWidth)
                              .then((value) {
                            if (value != null) {
                              profileImage = value.path;
                              setState(() {});
                            } else {
                              CommonUI.showToast(
                                  msg: LKey.somethingWentWrong.tr);
                            }
                          });
                        },
                        child: Text(
                          LKey.change.tr,
                          style: const TextStyle(
                            color: ColorRes.colorIcon,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      LKey.profileCategory.tr,
                    ),
                    Container(
                      height: 50,
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: myLoading.isDark
                            ? ColorRes.colorPrimary
                            : ColorRes.greyShade100,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              profileCategoryName ?? '',
                              style: const TextStyle(
                                color: ColorRes.colorTextLight,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  return DialogProfileCategory(
                                    function: (data) {
                                      if (data == null) {
                                        profileCategoryName = '';
                                        profileCategoryID = '-1';
                                      } else {
                                        final ProfileCategoryData p = data;
                                        profileCategoryID =
                                            p.profileCategoryId.toString();
                                        profileCategoryName =
                                            p.profileCategoryName;
                                      }
                                      Navigator.pop(context);

                                      setState(() {});
                                    },
                                    categoryId: profileCategoryID,
                                  );
                                },
                              );
                            },
                            child: Container(
                              height: 20,
                              width: 20,
                              decoration: const BoxDecoration(
                                color: ColorRes.colorIcon,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: ColorRes.greyShade100,
                                size: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      LKey.fullName.tr,
                    ),
                    TextFiledCustom(
                      controller: fullNameController,
                      hintText: LKey.fullName.tr,
                      isDarkMode: myLoading.isDark,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      LKey.username.tr,
                    ),
                    TextFiledCustom(
                      controller: userNameController,
                      hintText: LKey.username.tr,
                      isDarkMode: myLoading.isDark,
                      onChanged: (p0) {
                        createNewUserName = p0;
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      LKey.bio.tr,
                    ),
                    TextFiledCustom(
                      isDarkMode: myLoading.isDark,
                      controller: bioController,
                      hintText: LKey.presentYourself.tr,
                      textFieldHeight: 115,
                      isExpand: true,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      LKey.social.tr,
                    ),
                    SocialMediaTextField(
                        controller: faceBookController,
                        hintText: LKey.facebook.tr,
                        image: icFaceBook,
                        isDarkMode: myLoading.isDark),
                    SocialMediaTextField(
                        controller: instagramController,
                        hintText: LKey.instagram.tr,
                        image: icInstagram,
                        isDarkMode: myLoading.isDark),
                    SocialMediaTextField(
                        controller: youtubeController,
                        hintText: LKey.youtube.tr,
                        image: icYouTube,
                        isDarkMode: myLoading.isDark),
                    const SizedBox(
                      height: 30,
                    ),
                    InkWell(
                      onTap: () => onUpdateClick(myLoading),
                      child: Center(
                        child: FittedBox(
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              gradient: LinearGradient(
                                colors: [
                                  ColorRes.colorTheme,
                                  ColorRes.colorPink,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                LKey.update.tr,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: FontRes.fNSfUiSemiBold,
                                    color: ColorRes.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> onUpdateClick(MyLoading myLoading) async {
    FocusScope.of(context).unfocus();
    if (fullNameController.text.isEmpty) {
      CommonUI.showToast(msg: LKey.fullNameRequired.tr);
      return;
    }
    if (userNameController.text.isEmpty) {
      CommonUI.showToast(msg: LKey.userNameRequired.tr);
      return;
    }

    CommonUI.showLoader(context);

    if (createNewUserName.isNotEmpty &&
        createNewUserName != userNameController.text) {
      final Status s =
          await ApiService().checkUsername(userName: createNewUserName);
      if (s.status == 200) {
        userNameController =
            TextEditingController(text: createNewUserName.toUpperCase());
      } else {
        CommonUI.showToast(msg: s.message ?? '');
        return;
      }
    }

    ApiService()
        .updateProfile(
            fullName: fullNameController.text,
            userName:
                createNewUserName.isNotEmpty ? userNameController.text : '',
            bio: bioController.text,
            fbUrl: faceBookController.text.trim(),
            instagramUrl: instagramController.text.trim(),
            youtubeUrl: youtubeController.text.trim(),
            profileCategory: profileCategoryID,
            profileImage: profileImage.isNotEmpty ? File(profileImage) : null)
        .then(
      (value) {
        Navigator.pop(context);
        if (value.status == 200) {
          myLoading.setUser(value);
          Navigator.pop(context);
          CommonUI.showToast(msg: LKey.updateProfileSuccessfully.tr);
        } else {
          CommonUI.showToast(msg: value.message ?? '');
        }
      },
    );
  }
}

class TextFiledCustom extends StatelessWidget {
  final bool isDarkMode;
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final double textFieldHeight;
  final bool isExpand;
  final TextCapitalization textCapitalization;

  const TextFiledCustom(
      {required this.isDarkMode,
      required this.controller,
      required this.hintText,
      super.key,
      this.onChanged,
      this.textFieldHeight = 50,
      this.isExpand = false,
      this.textCapitalization = TextCapitalization.none});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: textFieldHeight,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: isDarkMode ? ColorRes.colorPrimary : ColorRes.greyShade100,
      ),
      child: TextField(
        controller: controller,
        expands: isExpand,
        maxLines: isExpand ? null : 1,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: const TextStyle(color: ColorRes.colorTextLight),
            contentPadding: EdgeInsets.symmetric(
                horizontal: 10, vertical: isExpand ? 10 : 0)),
        style: const TextStyle(
          color: ColorRes.colorTextLight,
        ),
        cursorColor: ColorRes.colorTextLight,
        onChanged: onChanged,
      ),
    );
  }
}

class SocialMediaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String image;
  final bool isDarkMode;

  const SocialMediaTextField(
      {required this.controller,
      required this.hintText,
      required this.image,
      required this.isDarkMode,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: isDarkMode ? ColorRes.colorPrimary : ColorRes.greyShade100,
      ),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              color: ColorRes.colorIcon,
              height: 22,
              width: 22,
              padding: const EdgeInsets.all(5),
              child: Image.asset(image, color: ColorRes.white),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText.capitalize ?? '',
                hintStyle: const TextStyle(color: ColorRes.colorTextLight),
              ),
              style: const TextStyle(color: ColorRes.colorTextLight),
              cursorColor: ColorRes.colorTextLight,
            ),
          ),
        ],
      ),
    );
  }
}
