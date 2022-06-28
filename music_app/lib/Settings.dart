import 'Looping.dart';
import 'Song.dart';
import 'Sorting.dart';


class Settings{
  List<Song> upNext;
  List<Song> originalUpNext;
  bool shuffle;
  LoopType loop;
  SortType sort;
  int playingIndex;
  List<String> directoryPaths;

  Settings({required this.upNext, required this.shuffle, required this.loop, required this.sort, required this.playingIndex, required this.originalUpNext, required this.directoryPaths});

  Map<String, dynamic> toJson() =>
      {
        'shuffle': shuffle,
        'loop' : loopingToString(loop),
        'sort' : sortingToString(sort),
        'playingIndex': playingIndex,
        'upNext': Song.songListToIdList(upNext),
        'originalUpNext': Song.songListToIdList(originalUpNext),
        'directoryPaths' : directoryPaths
      };

  Settings.fromJson(Map<String, dynamic> json, List<Song> allSongs)
      :
        shuffle = json['shuffle'],
        loop = stringToLooping(json['loop']),
        sort = stringToSorting(json['sort']),
        playingIndex = json['playingIndex'],
        upNext = Song.idListToSongList(json['upNext'].cast<String>(), allSongs),
        originalUpNext = Song.idListToSongList(json['originalUpNext'].cast<String>(), allSongs),
        directoryPaths = json['directoryPaths'].cast<String>();

}
