import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerTask extends BaseAudioHandler {
  final audioPlayer = AudioPlayer();
  int startingIndex = 0;
  List<MediaItem> futureMediaItems = [];

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }


  void onStart()
  {
    playbackState.add(
        PlaybackState(controls: [MediaControl.skipToPrevious, MediaControl.play, MediaControl.skipToNext,],
            systemActions: const {
              MediaAction.seek,
            },
            processingState: AudioProcessingState.loading)
    );
    audioPlayer.currentIndexStream.listen((event) {
      playbackState.add(
          playbackState.valueOrNull!.copyWith(updatePosition: Duration())
      );
      customEvent.add(event);
      if(event != null)
      {
        mediaItem.add(futureMediaItems[event]);
      }
    });
    audioPlayer.playerStateStream.listen((state) {
      if(state.processingState == ProcessingState.completed)
      {
        audioPlayer.seek(Duration(), index: 0);
        pause();
      }
    });
  }
  AudioPlayerTask()
  {
    onStart();
  }

  @override
  Future<void> stop() async {
    // Stop playing audio
    await audioPlayer.stop();
    // Shut down this background task
    await super.stop();
    playbackState.add(
        playbackState.valueOrNull!.copyWith(
        playing: false,
        processingState: AudioProcessingState.idle)
    );
  }

  @override
  Future<void> play() async {
    audioPlayer.play();
    playbackState.add(
        playbackState.valueOrNull!.copyWith(
        controls: [MediaControl.skipToPrevious, MediaControl.pause, MediaControl.skipToNext],
        playing: true,
        processingState: AudioProcessingState.ready,)
    );
    // Connect to the URL
  }
  @override
  Future<void> skipToNext() async {
    if(audioPlayer.currentIndex == futureMediaItems.length - 1 && audioPlayer.loopMode == LoopMode.off)
      {
        await audioPlayer.seek(Duration(), index: 0);
        pause();
      }
    else
      {
        return audioPlayer.seekToNext();
      }
  }

  @override
  Future<void> skipToPrevious() async {
    if(audioPlayer.position.inSeconds > audioPlayer.duration!.inSeconds / 20)
    {
      await seek(Duration());
    }
    else
    {
      if(audioPlayer.currentIndex == 0 && audioPlayer.loopMode == LoopMode.off)
        {
          await audioPlayer.seek(Duration(), index: futureMediaItems.length - 1);
        }
      else
        {
          return audioPlayer.seekToPrevious();
        }
    }
  }
  @override
  Future<void> pause() async {
    playbackState.add(
        playbackState.valueOrNull!.copyWith(
            controls: [MediaControl.skipToPrevious, MediaControl.play, MediaControl.skipToNext],
            playing: false,
            processingState: AudioProcessingState.ready,
            updatePosition: audioPlayer.position
        )
    );
    audioPlayer.pause();
  }
  @override
  Future<void> seek(Duration position) async {
    //super.onSeekTo(position);
    await audioPlayer.seek(position);
    playbackState.add(
        playbackState.valueOrNull!.copyWith(
          updatePosition: position)
      );
  }
  @override
  Future customAction(String name, [Map<String, dynamic>? arguments]) async {
    if(name == "setPlaylist")
      {
        //Build the future playlist
        List<AudioSource> playlist = [];
        futureMediaItems = arguments!["mediaItems"];
        playlist = arguments["audioSources"];
        //futurePlaylist = ConcatenatingAudioSource(children: playlist,);
        audioPlayer.setAudioSource(ConcatenatingAudioSource(children: playlist,), initialIndex: startingIndex);
        queue.add(futureMediaItems);
        playbackState.add(
            playbackState.valueOrNull!.copyWith(
              processingState: AudioProcessingState.ready,
            updatePosition: Duration())
        );
      }
    if(name == "updatePlaylist")
    {
      //Build the future playlist
      List<AudioSource> playlist = [];
      futureMediaItems = arguments!["mediaItems"];
      playlist = arguments["audioSources"];

      Duration currentPosition = audioPlayer.position;
      await audioPlayer.setAudioSource(ConcatenatingAudioSource(children: playlist,), initialIndex: startingIndex);
      await seek(currentPosition);
      queue.add(futureMediaItems);
      mediaItem.add(futureMediaItems[startingIndex]);
      playbackState.add(
          playbackState.valueOrNull!.copyWith(
              processingState: AudioProcessingState.ready,
              playing: audioPlayer.playing,)
      );
    }
    if(name == "setStartingIndex")
      {
        startingIndex = arguments!["index"];
      }
    if(name == "getCurrentIndex")
      {
        customEvent.add(audioPlayer.currentIndex);
      }
    if(name == "setLoopMode")
      {
        switch(arguments!["loopMode"] as String)
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