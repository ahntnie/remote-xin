import 'sound_event.dart';

class SoundPlayEvent extends SoundEvent {
  SoundType soundType;

  SoundPlayEvent(this.soundType);
}

enum SoundType { calling, endCall }
