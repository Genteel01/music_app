import 'dart:isolate';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import 'DataModel.dart';
import 'Song.dart';

class AudioPlayerTask extends BackgroundAudioTask {
  final audioPlayer = AudioPlayer();
  int startingIndex = 0;
  //ConcatenatingAudioSource futurePlaylist = ConcatenatingAudioSource(children: []);
  List<MediaItem> futureMediaItems = [];
  //bool setUp = false;
  bool endOfSong = true;

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
      if(/*event != startingIndex*/endOfSong)
        {
          AudioServiceBackground.setState(
              position: Duration(),
              processingState: AudioProcessingState.completed);
          /*AudioServiceBackground.setState(
              processingState: AudioProcessingState.ready);*/
        }
      AudioServiceBackground.setMediaItem(futureMediaItems[event!]);
      endOfSong = true;
    });
    audioPlayer.playerStateStream.listen((state) {
      print("_____________________Isolate processing state: " + state.processingState.toString());
      if(state.processingState == ProcessingState.completed)
      {
        AudioServiceBackground.setState(
            position: Duration(),
            processingState: AudioProcessingState.completed);
        /*if(setUp)
          {
            audioPlayer.setAudioSource(futurePlaylist, initialIndex: startingIndex + 1);
            AudioServiceBackground.setMediaItem(futureMediaItems[startingIndex + 1]);
            setUp = false;
          }*/
      }
    });
    AudioServiceBackground.setState(
        /*controls: [MediaControl.pause, MediaControl.stop],
        playing: true,*/
        processingState: AudioProcessingState.connecting);
  }

  @override
  Future<void> onStop() async {
    // Stop playing audio
    await audioPlayer.stop();
    // Shut down this background task
    await super.onStop();
    AudioServiceBackground.setState(
        processingState: AudioProcessingState.stopped);
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
  Future<void> onSkipToNext() async {
    print("If set up");
    /*if (setUp)
    {
      print("In the if");
      audioPlayer.setAudioSource(
          futurePlaylist, initialIndex: startingIndex + 1);
      print("After setAudioSource");
      setUp = false;
      print("End of if");
    }*/
    print("Before set state");
    AudioServiceBackground.setState(
        processingState: AudioProcessingState.skippingToNext,
        position: Duration());
    print("Before return");
    endOfSong = false;
    return audioPlayer.seekToNext();
  }

  @override
  Future<void> onSkipToPrevious() async {
    /*if(setUp)
    {
      audioPlayer.setAudioSource(futurePlaylist, initialIndex: startingIndex + 1);
      setUp = false;
    }*/
    endOfSong = false;
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
        /*setUp = true;
        //Set the initial song to be playing
        //AudioSource firstSong = AudioSource.uri(Uri.file((arguments[startingIndex] as Map)["path"]));
        var firstSong = MediaItem(
          id: (arguments[startingIndex] as Map)["path"],
          artist: (arguments[startingIndex] as Map)["artist"],
          title: (arguments[startingIndex] as Map)["name"],
          album: "",
          artUri: Uri.file((arguments[startingIndex] as Map)["albumart"]),
          //artUri: (arguments[startingIndex] as Map)["albumart"] == "" ? null : Uri.dataFromBytes(((arguments[startingIndex] as Map)["albumart"] as Uint8List))
        );
        AudioServiceBackground.setMediaItem(firstSong);
        await audioPlayer.setAudioSource(AudioSource.uri(Uri.file(firstSong.id)));*/
        //Build the future playlist
        futureMediaItems.clear();
        List<AudioSource> playlist = [];
        arguments.forEach((element) {
          playlist.add(AudioSource.uri(Uri.file((element as Map)["path"])));
          futureMediaItems.add(
              MediaItem(
          id: (element as Map)["path"],
          artist: (element as Map)["artist"],
          title: (element as Map)["name"],
          album: "",
          artUri: Uri.file((element as Map)["albumart"]),
          //artUri: (arguments[startingIndex] as Map)["albumart"] == "" ? null : Uri.dataFromBytes(((arguments[startingIndex] as Map)["albumart"] as Uint8List))
          )
          );
        });
        //futurePlaylist = ConcatenatingAudioSource(children: playlist,);
        audioPlayer.setAudioSource(ConcatenatingAudioSource(children: playlist,), initialIndex: startingIndex);
        AudioServiceBackground.setMediaItem(futureMediaItems[startingIndex]);
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