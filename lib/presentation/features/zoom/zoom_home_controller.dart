import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/all.dart';
import '../../base/all.dart';
import 'zoom_home_view.dart';

class ZoomHomeController extends BaseController {
  RxList<MeetingHistoryItem> meetingHistoryListRx = <MeetingHistoryItem>[].obs;
  List<MeetingHistoryItem> get meetingHistoryList =>
      meetingHistoryListRx.toList();

  // RxList<Note> meetingNoteListRx = <Note>[].obs;
  // List<Note> get meetingNoteList => meetingNoteListRx.toList();

  RxString sharedLink = ''.obs;

  TextEditingController nameZoom = TextEditingController();
  TextEditingController meetingIdController = TextEditingController();

  RxBool disableButton = true.obs;
  RxBool isEnableCamera = true.obs;
  RxBool isEnableNoAudio = true.obs;

  RxString startTimeSchedule = ''.obs;
  String previousText = '';
  RxBool isLoadingHistory = false.obs;
  // void formatIdmetting() {
  //   String text = meetingIdController.text.replaceAll('-', '');
  //   if (text.length > 12) text = text.substring(0, 12);

  //   String formatted = '';
  //   for (int i = 0; i < text.length; i++) {
  //     if (i != 0 && i % 4 == 0) formatted += '-';
  //     formatted += text[i];
  //   }

  //   // Kiểm tra nếu người dùng xóa ký tự cuối cùng
  //   if (meetingIdController.text.length < previousText.length &&
  //       previousText.endsWith('-') &&
  //       !formatted.endsWith('-')) {
  //     formatted = formatted.substring(0, formatted.length - 1);
  //   }

  //   previousText = formatted;

  //   meetingIdController.value = TextEditingValue(
  //     text: formatted,
  //     selection: TextSelection.collapsed(offset: formatted.length),
  //   );
  // }

  @override
  void onInit() {
    super.onInit();
    nameZoom.text = currentUser.fullName;
    loadMeetingHistory();
  }

  void setDisableButton(bool value) {
    disableButton.value = value;
  }

  String validIdMeeting(String nickname) {
    if (nickname.isEmpty) {
      return l10n.field__idmeeting_error_empty;
    } else if (!ValidationUtil.isValidUsername(nickname)) {
      return l10n.profile__username_not_valid;
    }

    return '';
  }

  Future<void> loadMeetingHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('meetingHistoryList');
    if (jsonString != null && jsonString != '') {
      final List<dynamic> jsonList = jsonDecode(jsonString);

      final itemhistory = jsonList.map((jsonItem) {
        return MeetingHistoryItem.fromMap(
            Map<String, String>.from(jsonDecode(jsonItem)));
      }).toList();

      final itemCurrentHistory = itemhistory
          .where((element) => element.userId == currentUser.id.toString())
          .toList();
      meetingHistoryListRx.assignAll(itemCurrentHistory);
    }

    update();
  }

  Future<void> addMeetingHistoryItem(
      String idMeeting, String time, String type) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final item = MeetingHistoryItem(
        userId: currentUser.id.toString(),
        idMeeting: idMeeting,
        time: time,
        type: type);
    final itemCurrentHistory = meetingHistoryListRx.reversed.toList();
    itemCurrentHistory.add(item);
    meetingHistoryListRx.value = itemCurrentHistory.reversed.toList();
    final List<String> jsonList = meetingHistoryListRx.map((item) {
      return jsonEncode(item.toMap());
    }).toList();
    await prefs.setString('meetingHistoryList', jsonEncode(jsonList));
  }

  var idMeeting = ''.obs;
  setIdMeeting(String value) {
    idMeeting.value = value;
  }
}
