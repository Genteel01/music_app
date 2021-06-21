
import 'package:enum_to_string/enum_to_string.dart';

import 'DataModel.dart';
import 'Song.dart';


class Settings{
  List<Song> upNext;
  Song? currentlyPlaying;
  bool shuffle;
  LoopType loop;
  int playingIndex;
  int startingIndex;
  List<String> songPaths;

  Settings({required this.upNext, this.currentlyPlaying, required this.shuffle, required this.loop, required this.playingIndex, required this.startingIndex, required this.songPaths});

  Map<String, dynamic> toJson() =>
      {
        'shuffle': shuffle,
        'loop' : EnumToString.convertToString(loop),
        'playingIndex': playingIndex,
        'startingIndex': startingIndex,
        'songPaths': songPaths,
      };

  Settings.fromJson(Map<String, dynamic> json)
      :
        shuffle = json['shuffle'],
        loop = EnumToString.fromString(LoopType.values, json['loop'])!,
        playingIndex = json['playingIndex'],
        startingIndex = json['startingIndex'],
        songPaths = json['songPaths'].cast<String>(),
        upNext = [];

  loadSongs(List<Song> allSongs)
  {
    songPaths.forEach((element) {
      try
      {
        upNext.add(allSongs.firstWhere((song) => song.filePath ==element));
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
    upNext.forEach((element) {
      songPaths.add(element.filePath);
    });
  }
}

