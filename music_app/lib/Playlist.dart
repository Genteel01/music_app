
import 'Song.dart';


class Playlist{
  List<Song> songs;
  String name;
  List<String> songPaths;

  Playlist({required this.songs, required this.name, required this.songPaths,});

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'songs' : songPaths
      };

  Playlist.fromJson(Map<String, dynamic> json)
      :
        name = json['name'],
        songPaths = json['songs'].cast<String>(),
        songs = [];

  //Function to turn a json file of several playlists into a list of playlists
  static List<Playlist> loadPlaylistFile(List<dynamic> data, List<Song> allSongs)
  {
    List<Playlist> newPlaylists = List<Playlist>.empty(growable: true);
    data.forEach((element) {
      Playlist newPlaylist = Playlist.fromJson(element);
      newPlaylist.loadSongs(allSongs);
      newPlaylists.add(newPlaylist);
    });
    return newPlaylists;
  }
  loadSongs(List<Song> allSongs)
  {
    songPaths.forEach((element) {
      try
      {
        songs.add(allSongs.firstWhere((song) => song.filePath ==element));
      }
      catch(error)
      {

      }
    });
  }
  //Function to turn a list of playlists into a json file to be saved
  static List<Map<String, dynamic>> savePlaylistFile(List<Playlist> playlistList)
  {
    List<Map<String, dynamic>> newPlaylists = List<Map<String, dynamic>>.empty(growable: true);
    playlistList.forEach((element) {
      newPlaylists.add(element.toJson());
    });
    return newPlaylists;
  }

  addToPlaylist(List<Song> newSongs)
  {
    songs.addAll(newSongs);
    newSongs.forEach((element) {
      songPaths.add(element.filePath);
    });
  }
}

