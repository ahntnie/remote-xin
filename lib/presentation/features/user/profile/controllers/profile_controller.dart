import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../../core/all.dart';
import '../../../../../models/all.dart';
import '../../../../../models/nft_number.dart';
import '../../../../../repositories/all.dart';
import '../../../../base/all.dart';
import '../../../../common_controller.dart/all.dart';
import '../../../../routing/routers/app_pages.dart';
import '../../../all.dart';
import '../views/widgets/otp_receive_bottom_sheet.dart';

class ProfileController extends BaseController {
  final UserRepository _userRepo = Get.find();
  final isAvatarLocal = false.obs;
  RxString initIsoCode = 'VN'.obs;

  RxString imagePath = ''.obs;
  RxString avatarUrl = ''.obs;
  RxString isoCode = ''.obs;
  RxString phoneEdit = ''.obs;
  RxString gender = ''.obs;
  RxString birthday = ''.obs;
  RxString location = ''.obs;
  RxString firstName = ''.obs;
  RxString lastName = ''.obs;
  RxString userName = ''.obs;
  RxString cccd = ''.obs;
  RxString dateCccd = ''.obs;
  RxString addressCccd = ''.obs;
  RxString email = ''.obs;
  RxBool isVerify = false.obs;
  Rx<NftNumber> nftNumber = NftNumber.empty().obs;

  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController birthdayController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController cccdController = TextEditingController();
  TextEditingController dateCccdController = TextEditingController();
  TextEditingController addressCccdController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  var isDisableLoginBtn = true.obs;

  RxString phoneLogin = ''.obs;
  final bool isUpdateProfileFirstLogin =
      Get.arguments['isUpdateProfileFirstLogin'] as bool;

  final homeController = Get.find<HomeController>();

  @override
  Future<void> onInit() async {
    avatarUrl.value = currentUser.avatarPath ?? '';

    firstName.value = currentUser.firstName;
    lastName.value = currentUser.lastName;
    userName.value = currentUser.nickname ?? '';
    gender.value = currentUser.gender ?? '';
    birthday.value = currentUser.birthday ?? '';
    location.value = currentUser.location ?? '';
    phoneEdit.value = currentUser.phone ?? '';
    isVerify.value = currentUser.isPhoneVerified ?? false;
    email.value = currentUser.email ?? '';

    reload();

    // if (isUpdateProfileFirstLogin) {
    //   await showDialogChooseNumber();
    // }
    await getRegionInfoFromPhoneNumber(currentUser.phone ?? '');

    isDisableLoginBtn.value = true;
    super.onInit();
  }

  // Future<void> showDialogChooseNumber() async {
  //   Future.delayed(Duration.zero, () async {
  //     await showModalBottomSheet(
  //       context: Get.context!,
  //       isScrollControlled: true,
  //       builder: (context) => BottomSheetChooseNumber(
  //         type: 'register',
  //         email: email.value,
  //         onChoose: (nftNumber) => this.nftNumber.value = nftNumber,
  //       ),
  //       useSafeArea: true,
  //     );
  //   });
  // }

  void reload() {
    emailController.text = email.value;

    usernameController.text = userName.value;

    if (firstName.value == 'User') {
      firstNameController.text = '';
    } else {
      firstNameController.text = firstName.value;
    }

    if (lastName.value == 'Person') {
      lastNameController.text = '';
    } else {
      lastNameController.text = lastName.value;
    }

    phoneController.text = phoneEdit.value;
    genderController.text = gender.value;
    birthdayController.text = birthday.value;
    locationController.text = location.value;
  }

  set setDisableLoginBtn(bool value) {
    isDisableLoginBtn.value = value;
  }

  Future<void> getImageFromGallery() async {
    final pickedImage = await MediaHelper.pickImageFromGallery();

    if (pickedImage == null) {
      return;
    }

    imagePath.value = pickedImage.file.path;
    isAvatarLocal.value = true;
    setDisableLoginBtn = false;

    // await runAction(
    //   action: () async {
    //     final avatar = await _storageRepository.uploadUserAvatar(
    //       file: pickedImage.file,
    //       currentUserId: currentUser.id,
    //     );

    //     avatarUrl.value = avatar;
    //     setDisableLoginBtn = false;
    //   },
    //   onError: (_) => isAvatarLocal.value = false,
    // );
  }

  RxBool isVerifyPhoneOrEmail = false.obs;

  void onChangeVerify() {
    isVerifyPhoneOrEmail.value = false;
    update();
  }

  final phonePattern = r'^[0-9]+$';
  final emailPattern = r'^.+@gmail\.com$';

  void updateProfile() {
    if (formKey.currentState!.validate()) {
      runAction(
        action: () async {
          if (firstName.value.isEmpty) {
            ViewUtil.showToast(
              title: l10n.profile__updated_error,
              message: l10n.field__first_name_error_empty,
            );
            return;
          }
          if (lastName.value.isEmpty) {
            ViewUtil.showToast(
              title: l10n.profile__updated_error,
              message: l10n.field__last_name_error_empty,
            );
            return;
          }
          if (userName.value.isEmpty) {
            ViewUtil.showToast(
              title: l10n.profile__updated_error,
              message: l10n.field__nickname_error_empty,
            );
            return;
          }

          // if (phoneEdit.value.isEmpty) {
          //   ViewUtil.showToast(
          //     title: l10n.profile__updated_error,
          //     message: l10n.field_phone__error_empty,
          //   );
          //   return;
          // }

          // if (isUpdateProfileFirstLogin &&
          //     isVerifyPhoneOrEmail.value == false) {
          //   ViewUtil.showToast(
          //     title: l10n.profile__updated_error,
          //     message: l10n.otp__verify_required,
          //   );

          //   return;
          // }

          if (email.value.trim().isNotEmpty) {
            final List<User> usersByEmail =
                await _userRepo.getUsersByEmail(email.value.trim());

            if (usersByEmail.isNotEmpty &&
                usersByEmail.first.id != currentUser.id &&
                usersByEmail.first.isActivated == true) {
              ViewUtil.showToast(
                title: l10n.profile__updated_error,
                message: l10n.profile__email_exits,
              );

              return;
            } else if (usersByEmail.isNotEmpty &&
                usersByEmail.first.id != currentUser.id &&
                usersByEmail.first.isActivated == false) {
              unawaited(_userRepo.deleteUserById(usersByEmail.first.id));
            }
          }

          final List<User> usersByUserName = await _userRepo.getUsersByUsername(
            userName.value,
          );

          if (usersByUserName.isNotEmpty &&
              usersByUserName.first.id != currentUser.id &&
              usersByUserName.first.isActivated == true) {
            ViewUtil.showToast(
              title: l10n.profile__updated_error,
              message: l10n.profile__username_exits,
            );

            return;
          }
          // LogUtil.e(phoneEdit.value.trim().removeAllWhitespace);
          // final List<User> usersByPhone = await _userRepo.getUserByPhone(
          //   phoneEdit.value,
          // );
          //
          // if (usersByPhone.isNotEmpty &&
          //     usersByPhone.first.id != currentUser.id &&
          //     usersByPhone.first.isActivated == true) {
          //   ViewUtil.showToast(
          //     title: l10n.profile__updated_error,
          //     message: l10n.profile__phone_exits,
          //   );
          //
          //   return;
          // } else if (usersByPhone.isNotEmpty &&
          //     usersByPhone.first.id != currentUser.id &&
          //     usersByPhone.first.isActivated == false) {
          //   unawaited(_userRepo.deleteUserById(usersByPhone.first.id));
          // }

          if (isAvatarLocal.value && imagePath.value.isNotEmpty) {
            final File fileAvatar = File(imagePath.value);

            final Attachment avatar = await _userRepo.uploadAvatarToServer(
              fileAvatar,
            );

            avatarUrl.value = avatar.path;

            final rowSuccess = await _userRepo.updateProfile(
              id: currentUser.id,
              firstName: firstName.value.trim(),
              lastName: lastName.value.trim(),
              phone: phoneEdit.value.trim().removeAllWhitespace,
              avatarPath: avatarUrl.value,
              nickname: userName.value.trim(),
              email: email.value.trim(),
              idAttachment: avatar.id,
              attachmentType: r'Backend\\\\Models\\\\User',
              gender: gender.value,
              birthday: birthday.value,
              location: location.value,
              isSearchGlobal: currentUser.isSearchGlobal ?? true,
              isShowEmail: currentUser.isShowEmail ?? true,
              isShowPhone: currentUser.isShowPhone ?? true,
              isShowGender: currentUser.isShowGender ?? true,
              isShowBirthday: currentUser.isShowBirthday ?? true,
              isShowLocation: currentUser.isShowLocation ?? true,
              isShowNft: currentUser.isShowNft ?? true,
              nftNumber: currentUser.nftNumber ?? '',
              talkLanguage: currentUser.talkLanguage ?? '',
            );

            if (rowSuccess == 1) {
              isAvatarLocal.value = false;

              ViewUtil.showToast(
                title: l10n.global__success_title,
                message: l10n.profile__updated_success,
              );

              setDisableLoginBtn = true;
              final userUpdated = await _userRepo.getUserById(currentUser.id);

              Get.find<AppController>().setLoggedUser(userUpdated);
              if (isUpdateProfileFirstLogin) {
                unawaited(Get.offNamed(AppPages.afterAuthRoute));
              }
            }
          } else {
            final rowSuccess = await _userRepo.updateProfile(
              id: currentUser.id,
              firstName: firstName.value.trim(),
              lastName: lastName.value.trim(),
              phone: phoneEdit.value.trim().removeAllWhitespace,
              avatarPath: avatarUrl.value,
              nickname: userName.value.trim(),
              email: email.value.trim(),
              gender: gender.value,
              birthday: birthday.value,
              location: location.value,
              isSearchGlobal: currentUser.isSearchGlobal ?? true,
              isShowEmail: currentUser.isShowEmail ?? true,
              isShowPhone: currentUser.isShowPhone ?? true,
              isShowGender: currentUser.isShowGender ?? true,
              isShowBirthday: currentUser.isShowBirthday ?? true,
              isShowLocation: currentUser.isShowLocation ?? true,
              isShowNft: currentUser.isShowNft ?? true,
              nftNumber: currentUser.nftNumber ?? '',
              talkLanguage: currentUser.talkLanguage ?? '',
            );

            if (rowSuccess == 1) {
              isAvatarLocal.value = false;

              ViewUtil.showToast(
                title: l10n.global__success_title,
                message: l10n.profile__updated_success,
              );

              setDisableLoginBtn = true;
              final userUpdated = await _userRepo.getUserById(currentUser.id);

              Get.find<AppController>().setLoggedUser(userUpdated);

              if (isUpdateProfileFirstLogin) {
                unawaited(Get.offNamed(AppPages.afterAuthRoute));
              }
            }
          }
        },
        onError: (exception) {
          ViewUtil.showToast(
            title: l10n.global__error_title,
            message: l10n.profile__updated_error,
          );
        },
      );
    }
  }

  // String validPhoneNumber(String phone) {
  //   if (phone.isEmpty) {
  //     return l10n.field_phone__error_empty;
  //   } else if (phone.length == 10) {
  //     ViewUtil.hideKeyboard(Get.context!);

  //     return '';
  //   } else if (!ValidationUtil.isValidPhoneNumber(phone)) {
  //     return l10n.field_phone__error_invalid;
  //   }

  //   return '';
  // }

  String validFirstName(String firstName) {
    if (firstName.isEmpty) {
      return l10n.field__first_name_error_empty;
    }

    return '';
  }

  String validLastName(String lastName) {
    if (lastName.isEmpty) {
      return l10n.field__last_name_error_empty;
    }

    return '';
  }

  String validNickname(String nickname) {
    if (nickname.isEmpty) {
      return l10n.field__nickname_error_empty;
    } else if (!ValidationUtil.isValidUsername(nickname)) {
      return l10n.profile__username_not_valid;
    }

    return '';
  }

  String validEmail(String email) {
    if (email.isEmpty) {
      return l10n.field__email_error_empty;
    } else if (!ValidationUtil.isValidEmail(email)) {
      return l10n.field__email_error_invalid;
    }

    return '';
  }

  Future<void> getRegionInfoFromPhoneNumber(String phone) async {
    if (phone.isEmpty) {
      isoCode.value = 'VN';

      return;
    }

    final PhoneNumber phoneNumberParse =
        await PhoneNumber.getRegionInfoFromPhoneNumber(phone);

    // final String phoneParsableNumber =
    //     await PhoneNumber.getParsableNumber(phoneNumberParse);

    isoCode.value = phoneNumberParse.isoCode ?? '';
    phoneEdit.value = phoneNumberParse.phoneNumber ?? '';
    phoneController.text = phone;
    update();
  }

  // verify otp logic
  final AuthRepository _authService = Get.find();

  // final String? email = Get.arguments['email'] as String?;
  // final flowFrom = Get.arguments['flowFrom'] as String;
  // final String? phone = Get.arguments['phone'] as String?;

  var isDisableSubmitBtn = true.obs;
  var otpTimeLeft = DurationConstants.maxTimeLiveOTP.inSeconds.obs;

  // late Timer timer;

  final otpController = TextEditingController();
  late CountdownTimer _countdownTimer;
  bool isTimerRunning = false;

  void reset() {
    isDisableSubmitBtn.value = true;
    otpController.text = '';
    otpTimeLeft.value = 0;
    isTimerRunning = false;
    try {
      _countdownTimer.stop(); // Dừng countdownTimer hiện tại
    } catch (e) {
      LogUtil.e(e);
    }
    update();
  }

  set setDisableSubmitBtn(bool value) {
    isDisableSubmitBtn.value = value;
    update();
  }

  String? validateOtp(String? otp) {
    if (otp!.isEmpty) {
      return l10n.field_otp__error_empty;
    }

    if (otp.length != 6) {
      return l10n.field_otp__error_invalid;
    }

    return null;
  }

  void startOtpTimer() {
    otpTimeLeft.value = DurationConstants.maxTimeLiveOTP.inSeconds;

    // timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    //   if (otpTimeLeft.value > 0) {
    //     otpTimeLeft.value--;
    //   } else {
    //     timer.cancel();
    //   }
    // });

    _countdownTimer = CountdownTimer(
      seconds: otpTimeLeft.value,
      onTick: (value) {
        isTimerRunning = true;
        otpTimeLeft.value = value;
      },
      onFinished: () {
        isTimerRunning = false;
        _countdownTimer.stop();
      },
    );

    SystemChannels.lifecycle.setMessageHandler((msg) {
// On AppLifecycleState: paused
      if (msg == AppLifecycleState.paused.toString()) {
        if (isTimerRunning) {
          _countdownTimer.pause(otpTimeLeft.value); //setting end time on pause
        }
      }

// On AppLifecycleState: resumed
      if (msg == AppLifecycleState.resumed.toString()) {
        if (isTimerRunning) {
          _countdownTimer.resume();
        }
      }

      return Future(() => null);
    });

    isTimerRunning = true;
    _countdownTimer.start();
  }

  void showBottomSheet() {
    otpController.clear();
    ViewUtil.showBottomSheet(
      isFullScreen: true,
      child: const OtpReceiveBottomSheet(),
    );
  }

  Future<void> sendOtp() async {
    // if (email.value.isEmpty) {
    //   ViewUtil.showToast(
    //     title: l10n.profile__updated_error,
    //     message: l10n.field__email_error_empty,
    //   );
    //   return;
    // }

    // if (!RegExp(emailPattern).hasMatch(email.value)) {
    //   ViewUtil.showToast(
    //     title: l10n.profile__updated_error,
    //     message: l10n.field_email__error_invalid,
    //   );
    //   return;
    // }

    if (phoneEdit.value.isEmpty) {
      ViewUtil.showToast(
        title: l10n.profile__updated_error,
        message: l10n.field_phone__error_empty,
      );
      return;
    }

    // if (!RegExp(phonePattern).hasMatch(phoneEdit.value)) {
    //   ViewUtil.showToast(
    //     title: l10n.profile__updated_error,
    //     message: l10n.field_phone__error_invalid,
    //   );
    //   return;
    // }
    showBottomSheet();
    ViewUtil.showToast(
      title: l10n.otp__title,
      message: l10n.otp__resend_success,
    );
    try {
      Future.delayed(const Duration(milliseconds: 500), () {
        startOtpTimer();
      });
    } catch (e) {
      LogUtil.e(e);
    }
    await _authService.sendOTPVerifyPhone();

    // runAction(
    //   action: () async {

    //     if ((currentUser.email ?? '').isNotEmpty) {
    //       final String? code = await _authService.requestResendOTP(
    //         email: email.value,
    //         type: 'register',
    //       );

    //       if (code != null) {
    //         ViewUtil.showToast(
    //           title: l10n.otp__title,
    //           message: l10n.otp__resend_success,
    //         );

    // },
    //     }
    //     // else {
    //     //   final String? code = await _authService.requestResendOTP(
    //     //     phone: phoneLogin.value,
    //     //     type: 'register',
    //     //   );
    //     //
    //     //   if (code != null) {
    //     //     ViewUtil.showToast(
    //     //       title: l10n.otp__title,
    //     //       message: l10n.otp__resend_success,
    //     //     );
    //     //
    //     //     try {
    //     //       Future.delayed(const Duration(milliseconds: 500), () {
    //     //         startOtpTimer();
    //     //       });
    //     //     } catch (e) {
    //     //       LogUtil.e(e);
    //     //     }
    //     //
    //     //     showBottomSheet();
    //     //   }
    //     // }
    //   },
    // onError: (exception) {
    //   if (exception is AuthException) {
    //     if (exception.kind == AuthExceptionKind.userNotFound) {
    //       // ViewUtil.showToast(
    //       //   title: l10n.otp__title,
    //       //   message: l10n.error__user_not_found,
    //       // );
    //       registerEmailOrPhone();
    //     } else if (exception.kind == AuthExceptionKind.otpNotExpired) {
    //       ViewUtil.showToast(
    //         title: l10n.otp__title,
    //         message: l10n.otp__not_expired,
    //       );
    //       showBottomSheet();
    //     } else if (exception.kind == AuthExceptionKind.custom) {
    //       ViewUtil.showToast(
    //         title: l10n.otp__title,
    //         message: l10n.error__unknown,
    //       );
    //     } else if (exception.kind == AuthExceptionKind.limitOtp) {
    //       ViewUtil.showToast(
    //         title: l10n.otp__title,
    //         message: l10n.error__limit_otp,
    //       );
    //     }
    //   } else {
    //     ViewUtil.showToast(
    //       title: l10n.otp__title,
    //       message: l10n.error__unknown,
    //     );
    //   }
    // },
    // );
  }

  Future<void> registerEmailOrPhone() async {
    if ((currentUser.email ?? '').isEmpty) {
      await runAction(
        action: () async {
          final user = await _authService.register(
            email: email.value,
            referralId: '',
          );
          // await Get.toNamed(Routes.otpReceive, arguments: {
          //   'email': emailController.text,
          //   'flowFrom': Routes.register,
          // });

          try {
            Future.delayed(const Duration(milliseconds: 500), () {
              startOtpTimer();
            });
          } catch (e) {
            LogUtil.e(e);
          }
          showBottomSheet();
        },
        onError: (exception) {
          if (exception is AuthException) {
            if (exception.kind == AuthExceptionKind.emailAlreadyInUse ||
                exception.kind == AuthExceptionKind.phoneAlreadyInUse) {
              // nextPage();
              ViewUtil.showToast(
                title: l10n.register__title,
                message: l10n.error__email_already_in_use,
              );
            } else if (exception.kind == AuthExceptionKind.custom) {
              final ServerError errors = exception.exception as ServerError;
              if (errors.fieldErrors.isNotEmpty) {
                for (var error in errors.fieldErrors) {
                  if (error.field == 'email') {
                    ViewUtil.showToast(
                      title: l10n.register__title,
                      message: error.messages.first,
                    );
                  } else if (error.field == 'ref_id') {
                    ViewUtil.showToast(
                      title: l10n.register__title,
                      message: error.messages.first,
                    );
                  }
                }
              }
            }
          } else {
            ViewUtil.showToast(
              title: l10n.register__title,
              message: l10n.error__unknown,
            );
          }
        },
      );
    } else {
      await runAction(
        action: () async {
          final user = await _authService.register(
            phone: phoneEdit.value,
            referralId: '',
          );
          // await Get.toNamed(Routes.otpReceive, arguments: {
          //   'phone': phoneRegister.value.removeAllWhitespace,
          //   'flowFrom': Routes.register,
          // });

          try {
            Future.delayed(const Duration(milliseconds: 500), () {
              startOtpTimer();
            });
          } catch (e) {
            LogUtil.e(e);
          }
          showBottomSheet();
        },
        onError: (exception) {
          if (exception is AuthException) {
            if (exception.kind == AuthExceptionKind.phoneAlreadyInUse) {
              ViewUtil.showToast(
                title: l10n.register__title,
                message: l10n.error__phone_already_in_use,
              );
            } else if (exception.kind == AuthExceptionKind.custom) {
              final ServerError errors = exception.exception as ServerError;
              if (errors.fieldErrors.isNotEmpty) {
                for (var error in errors.fieldErrors) {
                  if (error.field == 'phone') {
                    ViewUtil.showToast(
                      title: l10n.register__title,
                      message: error.messages.first,
                    );
                  }
                }
              }
            }
          } else {
            ViewUtil.showToast(
              title: l10n.register__title,
              message: l10n.error__unknown,
            );
          }
        },
      );
    }
  }

  void submitOtp() {
    if (isLoading) {
      return;
    }
    runAction(
      action: () async {
        final code = await _authService
            .validateOtpVerify(int.tryParse(otpController.text) ?? 0);
        if (code) {
          Get.back();

          isVerify.value = true;
          ViewUtil.showToast(
            title: l10n.global__success_title,
            message: Get.context!.l10n.phone_number_verify_success,
          );
          final userUpdated = await _userRepo.getUserById(currentUser.id);

          Get.find<AppController>().setLoggedUser(userUpdated);
        } else {
          ViewUtil.showToast(
              title: l10n.global__error_title,
              message: l10n.error__otp_incorrect);
        }
        // if ((currentUser.email ?? '').isNotEmpty) {
        //   final resp = await _authService.validateOtp(
        //     email: email.value,
        //     otp: otpController.text,
        //   );
        //   if (resp != null) {
        //     isVerifyPhoneOrEmail.value = true;
        //     Get.back();
        //   }
        // }
        // else {
        //   final resp = await _authService.validateOtp(
        //     phone: phoneEdit.value,
        //     otp: otpController.text,
        //   );
        //   if (resp != null) {
        //     isVerifyPhoneOrEmail.value = true;
        //     Get.back();
        //   }
        // }
      },
      // onError: (exception) {
      //   otpController.clear();
      //   if (exception is AuthException) {
      //     if (exception.kind == AuthExceptionKind.otpIncorrect) {
      //       ViewUtil.showToast(
      //         title: l10n.otp__title,
      //         message: l10n.error__otp_incorrect,
      //       );
      //     } else if (exception.kind == AuthExceptionKind.otpNotExpired) {
      //       ViewUtil.showToast(
      //         title: l10n.otp__title,
      //         message: l10n.otp__not_expired,
      //       );
      //       showBottomSheet();
      //     } else if (exception.kind == AuthExceptionKind.userNotFound) {
      //       ViewUtil.showToast(
      //         title: l10n.otp__title,
      //         message: l10n.error__user_not_found,
      //       );
      //     } else if (exception.kind == AuthExceptionKind.custom) {
      //       ViewUtil.showToast(
      //         title: l10n.otp__title,
      //         message: exception.exception.toString(),
      //       );
      //     }
      //   } else {
      //     ViewUtil.showToast(
      //       title: l10n.otp__title,
      //       message: l10n.error__unknown,
      //     );
      //   }
      // },
    );
  }

  Future<void> resendOtpRegister() async {
    if (isLoading) {
      return;
    }
    if (otpTimeLeft.value > 0) {
      return;
    }
    await runAction(
      action: () async {
        // if ((currentUser.email ?? '').isEmpty) {
        //   final String? code = await _authService.requestResendOTP(
        //     email: email.value,
        //     type: 'register',
        //   );

        //   if (code != null) {
        //     startOtpTimer();
        //     ViewUtil.showToast(
        //       title: l10n.otp__title,
        //       message: l10n.otp__resend_success,
        //     );
        //   }
        // } else {
        // final String? code = await _authService.requestResendOTP(
        //   phone: phoneEdit.value,
        //   type: 'register',
        // );

        // if (code != null) {
        await _authService.sendOTPVerifyPhone();
        startOtpTimer();
        ViewUtil.showToast(
          title: l10n.otp__title,
          message: l10n.otp__resend_success,
        );
        // }
        // }
      },
      // onError: (exception) {
      //   if (exception is AuthException) {
      //     if (exception.kind == AuthExceptionKind.userNotFound) {
      //       ViewUtil.showToast(
      //         title: l10n.otp__title,
      //         message: l10n.error__user_not_found,
      //       );
      //     } else if (exception.kind == AuthExceptionKind.otpNotExpired) {
      //       ViewUtil.showToast(
      //         title: l10n.otp__title,
      //         message: l10n.otp__not_expired,
      //       );
      //       showBottomSheet();
      //     } else if (exception.kind == AuthExceptionKind.custom) {
      //       ViewUtil.showToast(
      //         title: l10n.otp__title,
      //         message: l10n.error__unknown,
      //       );
      //     } else if (exception.kind == AuthExceptionKind.limitOtp) {
      //       ViewUtil.showToast(
      //         title: l10n.otp__title,
      //         message: l10n.error__limit_otp,
      //       );
      //     }
      //   } else {
      //     ViewUtil.showToast(
      //       title: l10n.otp__title,
      //       message: l10n.error__unknown,
      //     );
      //   }
      // },
    );
  }
}
