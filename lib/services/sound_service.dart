import 'package:audioplayers/audioplayers.dart';

import '../core/all.dart';

class SoundService {
  final AudioCache _player = AudioCache(prefix: 'assets/sounds/');
  final AudioPlayer _audioCallingPlayer = AudioPlayer(playerId: 'calling');
  final AudioPlayer _audioEndCallPlayer = AudioPlayer(playerId: 'end_call');
  static const String calling = 'calling.mp3';
  static const String endCall = 'end_call.mp3';

  SoundService() {
    _player.loadAll([calling, endCall]);
    _audioCallingPlayer.audioCache = _player;
    _audioEndCallPlayer.audioCache = _player;
    _audioCallingPlayer.setReleaseMode(ReleaseMode.loop);
    _audioEndCallPlayer.setReleaseMode(ReleaseMode.stop);
  }

  Future playSoundCalling() async {
    await _audioEndCallPlayer.stop();
    await _audioCallingPlayer.play(
      AssetSource(calling),
      mode: PlayerMode.lowLatency,
    );
  }

  Future playSoundEndCall() async {
    await _audioCallingPlayer.stop();
    await _audioEndCallPlayer.play(
      AssetSource(endCall),
      mode: PlayerMode.lowLatency,
    );
  }

  void stopSound() {
    try {
      _audioCallingPlayer.stop();
      _audioEndCallPlayer.stop();
    } catch (e) {
      LogUtil.e(e, error: e, name: runtimeType.toString());
    }
  }
}
