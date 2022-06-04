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
  List<String> songPaths;
  List<String> originalSongPaths;
  List<String> directoryPaths;

  Settings({required this.upNext, required this.shuffle, required this.loop, required this.sort, required this.playingIndex, required this.songPaths, required this.originalUpNext, required this.originalSongPaths, required this.directoryPaths});

  Map<String, dynamic> toJson() =>
      {
        'shuffle': shuffle,
        'loop' : loopingToString(loop),
        'sort' : sortingToString(sort),
        'playingIndex': playingIndex,
        'songPaths': songPaths,
        'originalSongPaths': originalSongPaths,
        'directoryPaths' : directoryPaths
      };

  Settings.fromJson(Map<String, dynamic> json)
      :
        shuffle = json['shuffle'],
        loop = stringToLooping(json['loop']),
        sort = stringToSorting(json['sort']),
        playingIndex = json['playingIndex'],
        songPaths = json['songPaths'].cast<String>(),
        originalSongPaths = json['originalSongPaths'].cast<String>(),
        upNext = [],
        originalUpNext = [],
        directoryPaths = json['directoryPaths'].cast<String>();

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
