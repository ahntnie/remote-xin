import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../api/api_service.dart';
import '../../../modal/sound/sound.dart';
import 'music_card.dart';

class DiscoverPage extends StatefulWidget {
  final Function? onMoreClick;
  final Function? onPlayClick;
  final List<SoundList> soundList;
  final Function(SoundList) soundSelect;

  const DiscoverPage(
      {required this.soundList,
      required this.soundSelect,
      super.key,
      this.onMoreClick,
      this.onPlayClick});

  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  List<SoundData> soundCategoryList = [];
  int isPlay = 100;
  AudioPlayer? _audioPlayer;

  @override
  void initState() {
    // getDiscoverSound();
    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    _apiService.client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log(widget.soundList.length.toString());
    return ListView.builder(
      itemCount: widget.soundList.length,
      padding: const EdgeInsets.only(top: 5),
      itemBuilder: (context, index) {
        return MusicCard(
            onPlay: () async {
              if (_audioPlayer != null) {
                await _audioPlayer!.pause();
              }
              if (isPlay == index) {
                setState(() {
                  isPlay = 100;
                });
              } else {
                setState(() {
                  isPlay = index;
                });
                _audioPlayer = AudioPlayer(
                    playerId:
                        widget.soundList[index].soundId.toString() ?? '1');

                await _audioPlayer?.play(
                  UrlSource(widget.soundList[index].sound ?? ''),
                  mode: PlayerMode.mediaPlayer,
                  ctx: const AudioContext(
                    android: AudioContextAndroid(isSpeakerphoneOn: true),
                    iOS: AudioContextIOS(
                      category: AVAudioSessionCategory.playAndRecord,
                      options: [
                        AVAudioSessionOptions.allowAirPlay,
                        AVAudioSessionOptions.allowBluetooth,
                        AVAudioSessionOptions.allowBluetoothA2DP,
                        AVAudioSessionOptions.defaultToSpeaker
                      ],
                    ),
                  ),
                );
              }
            },
            isPlay: isPlay == index,
            soundList: widget.soundList[index],
            onItemClick: (soundUrl) {
              widget.soundSelect(widget.soundList[index]);
              Navigator.pop(context);
            },
            type: 1);
      },
    );
  }

  final ApiService _apiService = ApiService();

  void getDiscoverSound() {
    _apiService.getSoundList().then((value) {
      soundCategoryList = value.data ?? [];
      setState(() {});
    });
  }
}
