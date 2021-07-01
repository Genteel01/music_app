import 'dart:isolate';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import 'DataModel.dart';
import 'Song.dart';

class AudioPlayerTask extends BackgroundAudioTask {
  final audioPlayer = AudioPlayer();
  List<Song> upNext = [];
  List<String> upNextSongPaths = [];
  DataModel? dataModel;

  //DataModel dataModel;
  /*AudioPlayerTask(DataModel newDataModel)
      : dataModel = newDataModel;*/

  //albumArt = songAlbumArt;
  //final _completer = Completer();
  @override
  Future<void> onTaskRemoved() async {
    await onStop();
  }
  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    print("onStart");
    //print("DataModel info: " + dataModel.loading.toString());
    super.onStart(params);
    ReceivePort audioServicePort = ReceivePort();
    audioServicePort.listen((message) {
      dataModel = message as DataModel;
    });
    AudioServiceBackground.setState(
        controls: [MediaControl.pause, MediaControl.stop],
        playing: true,
        processingState: AudioProcessingState.connecting);
  }

  @override
  Future<void> onStop() async {
    // Stop playing audio
    await audioPlayer.stop();
    // Shut down this background task
    await super.onStop();
  }

  @override
  Future<void> onPlay() async {
    audioPlayer.play();
    AudioServiceBackground.setState(
        controls: [MediaControl.skipToPrevious, MediaControl.pause, MediaControl.skipToNext, MediaControl.stop],
        playing: true,
        processingState: AudioProcessingState.ready,);
    // Connect to the URL
  }
  @override
  Future<void> onSkipToNext() {
    return audioPlayer.seekToNext();
  }

  @override
  Future<void> onSkipToPrevious() {
    return audioPlayer.seekToPrevious();
  }
  @override
  Future<void> onPause() async {
    AudioServiceBackground.setState(
        controls: [MediaControl.skipToPrevious, MediaControl.play, MediaControl.skipToNext, MediaControl.stop],
        playing: false,
        processingState: AudioProcessingState.ready);
    audioPlayer.pause();
  }
  @override
  Future<void> onSeekTo(Duration position) async {
    //super.onSeekTo(position);
    await audioPlayer.seek(position);
    AudioServiceBackground.setState(
        position: position);
  }
  @override
  Future onCustomAction(String name, dynamic arguments) async {
    if(name == "setFilePath")
      {
          await audioPlayer.setFilePath(arguments as String);
      }
    if(name == "setPlaylist")
      {
        List<AudioSource> playlist = [];
        arguments.forEach((element) {
          playlist.add(AudioSource.uri(Uri.parse(element as String)));
        });
        ConcatenatingAudioSource audioSource = ConcatenatingAudioSource(children: playlist);
        await audioPlayer.setAudioSource(audioSource);
      }
    if(name == "setUpNextSongs")
      {
        print(arguments.toString());
        List<String> arguementsAsString = [];
        arguments.forEach((element) {
          arguementsAsString.add(element as String);
        });
        print(arguementsAsString.toString());
        //List<String> castedArguments = arguments as List<String>;
      //List<String> castedArguments = arguments.cast<List<String>>();
        //upNextSongPaths.addAll(castedArguments);
      }
  }
}