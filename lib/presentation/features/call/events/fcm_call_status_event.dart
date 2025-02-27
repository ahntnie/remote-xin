import '../enums/fcm_call_status_enum.dart';

class FCMCallStatusEvent {
  final String callId;
  final FCMCallStatusEnum status;

  FCMCallStatusEvent(this.callId, this.status);
}
