import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerTask extends BackgroundAudioTask {
  final audioPlayer = AudioPlayer();
  int startingIndex = 0;
  List<MediaItem> futureMediaItems = [];

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
      AudioServiceBackground.setState(
          position: Duration(),
      );
      AudioServiceBackground.sendCustomEvent(event);
      if(event != null)
      {
        AudioServiceBackground.setMediaItem(futureMediaItems[event]);
      }
    });
    audioPlayer.playerStateStream.listen((state) {
      if(state.processingState == ProcessingState.completed)
        {
          audioPlayer.seek(null, index: 0);
          AudioService.pause();
        }
    });
    AudioServiceBackground.setState(
        controls: [MediaControl.skipToPrevious, MediaControl.play, MediaControl.skipToNext, MediaControl.stop],
        /*playing: true,*/
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
    if(audioPlayer.currentIndex == futureMediaItems.length - 1 && audioPlayer.loopMode == LoopMode.off)
      {
        await audioPlayer.seek(null, index: 0);
        AudioService.pause();
      }
    else
      {
        return audioPlayer.seekToNext();
      }
  }

  @override
  Future<void> onSkipToPrevious() async {
    if(audioPlayer.position.inSeconds > audioPlayer.duration!.inSeconds / 20)
    {
      await AudioService.seekTo(Duration());
    }
    else
    {
      if(audioPlayer.currentIndex == 0 && audioPlayer.loopMode == LoopMode.off)
        {
          await audioPlayer.seek(null, index: futureMediaItems.length - 1);
        }
      else
        {
          return audioPlayer.seekToPrevious();
        }
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
    if(name == "setPlaylist")
      {
        //Build the future playlist
        futureMediaItems.clear();
        List<AudioSource> playlist = [];
        arguments.forEach((element) {
          playlist.add(AudioSource.uri(Uri.file((element as Map)["path"])));
          futureMediaItems.add(
              MediaItem(
          id: element["path"],
          artist: element["artist"],
          title: element["name"],
          album: element["album"],
          artUri: Uri.file(element["albumart"]),
          )
          );
        });
        //futurePlaylist = ConcatenatingAudioSource(children: playlist,);
        audioPlayer.setAudioSource(ConcatenatingAudioSource(children: playlist,), initialIndex: startingIndex);
        AudioServiceBackground.setQueue(futureMediaItems);
        AudioServiceBackground.setMediaItem(futureMediaItems[startingIndex]);
        AudioServiceBackground.setState(
            processingState: AudioProcessingState.ready,
            position: Duration());
      }
    if(name == "setStartingIndex")
      {
        startingIndex = arguments;
      }
    if(name == "getCurrentIndex")
      {
        AudioServiceBackground.sendCustomEvent(audioPlayer.currentIndex);
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