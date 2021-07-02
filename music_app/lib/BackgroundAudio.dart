import 'dart:isolate';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import 'DataModel.dart';
import 'Song.dart';

class AudioPlayerTask extends BackgroundAudioTask {
  final audioPlayer = AudioPlayer();
  int startingIndex = 0;
  ConcatenatingAudioSource futurePlaylist = ConcatenatingAudioSource(children: []);
  bool setUp = false;


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
    audioPlayer.currentIndexStream.listen((event) {
      if(event != startingIndex)
        {
          AudioServiceBackground.setState(
              position: Duration(),
              processingState: AudioProcessingState.completed);
          AudioServiceBackground.setState(
              processingState: AudioProcessingState.ready);
        }
    });
    audioPlayer.playerStateStream.listen((state) {
      print("_____________________Isolate processing state: " + state.processingState.toString());
      if(state.processingState == ProcessingState.completed)
      {
        AudioServiceBackground.setState(
            position: Duration(),
            processingState: AudioProcessingState.completed);
        if(setUp)
          {
            audioPlayer.setAudioSource(futurePlaylist, initialIndex: startingIndex + 1);
            setUp = false;
          }
      }
    });
    AudioServiceBackground.setState(
        /*controls: [MediaControl.pause, MediaControl.stop],
        playing: true,*/
        processingState: AudioProcessingState.connecting);
  }

  @override
  Future<void> onStop() async {
    AudioServiceBackground.setState(
        processingState: AudioProcessingState.stopped);
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
    AudioServiceBackground.setState(
        processingState: AudioProcessingState.skippingToNext,
        position: Duration());
    return audioPlayer.seekToNext();
  }

  @override
  Future<void> onSkipToPrevious() async {
    if(audioPlayer.position.inSeconds > audioPlayer.duration!.inSeconds / 20)
    {
      await AudioService.seekTo(Duration());
    }
    else
    {
      AudioServiceBackground.setState(
          processingState: AudioProcessingState.skippingToPrevious,
          position: Duration());
      return audioPlayer.seekToPrevious();
    }
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
        setUp = true;
        //Set the initial song to be playing
        AudioSource firstSong = AudioSource.uri(Uri.file(arguments[startingIndex] as String));
        await audioPlayer.setAudioSource(firstSong);
        //Build the future playlist
        List<AudioSource> playlist = [];
        arguments.forEach((element) {
          playlist.add(AudioSource.uri(Uri.file(element as String)));
        });
        futurePlaylist = ConcatenatingAudioSource(children: playlist,);
        AudioServiceBackground.setState(
            processingState: AudioProcessingState.ready,
            position: Duration());
      }
    if(name == "setStartingIndex")
      {
        startingIndex = arguments;
      }
    if(name == "setLoopMode")
      {
        switch(arguments as String)
        {
          case "none":
            audioPlayer.setLoopMode(LoopMode.off);
            break;
          case "loop":
            audioPlayer.setLoopMode(LoopMode.all);
            break;
          case "singleSong":
            audioPlayer.setLoopMode(LoopMode.one);
            break;
        }
      }
  }
}