
import 'package:enum_to_string/enum_to_string.dart';

import 'DataModel.dart';
import 'Song.dart';


class Settings{
  List<Song> upNext;
  List<Song> originalUpNext;
  Song? currentlyPlaying;
  bool shuffle;
  LoopType loop;
  int playingIndex;
  int startingIndex;
  List<String> songPaths;
  List<String> originalSongPaths;

  Settings({required this.upNext, this.currentlyPlaying, required this.shuffle, required this.loop, required this.playingIndex, required this.startingIndex, required this.songPaths, required this.originalUpNext, required this.originalSongPaths});

  Map<String, dynamic> toJson() =>
      {
        'shuffle': shuffle,
        'loop' : EnumToString.convertToString(loop),
        'playingIndex': playingIndex,
        'startingIndex': startingIndex,
        'songPaths': songPaths,
        'originalSongPaths': originalSongPaths,
      };

  Settings.fromJson(Map<String, dynamic> json)
      :
        shuffle = json['shuffle'],
        loop = EnumToString.fromString(LoopType.values, json['loop'])!,
        playingIndex = json['playingIndex'],
        startingIndex = json['startingIndex'],
        songPaths = json['songPaths'].cast<String>(),
        originalSongPaths = json['originalSongPaths'].cast<String>(),
        upNext = [],
        originalUpNext = [];

  loadSongs(List<Song> allSongs)
  {
    songPaths.forEach((element) {
      try {
        upNext.add(allSongs.firstWhere((song) => song.filePath == element));
      }
      catch (error) {

      }
    });
    originalSongPaths.forEach((element) {
      try
      {
        originalUpNext.add(allSongs.firstWhere((song) => song.filePath ==element));
      }
      catch(error)
      {

      }
    });
    if(upNext.length > 0)
      {
        currentlyPlaying = upNext[playingIndex];
      }
  }
  setSongPath()
  {
    songPaths.clear();
    originalSongPaths.clear();
    upNext.forEach((element) {
      songPaths.add(element.filePath);
    });
    originalUpNext.forEach((element) {
      originalSongPaths.add(element.filePath);
    });
  }
}

