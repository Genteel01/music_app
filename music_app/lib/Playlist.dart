
import 'Song.dart';


class Playlist{
  List<Song> songs;
  String name;

  Playlist({required this.songs, required this.name,});

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'songs' : Song.songListToIdList(songs),
      };

  Playlist.fromJson(Map<String, dynamic> json, List<Song> allSongs)
      :
        name = json['name'],
        songs = Song.idListToSongList(json['songs'].cast<String>(), allSongs);

  //Function to turn a json file of several playlists into a list of playlists
  static List<Playlist> loadPlaylistFile(List<dynamic> data, List<Song> allSongs)
  {
    List<Playlist> newPlaylists = List<Playlist>.empty(growable: true);
    data.forEach((element) {
      Playlist newPlaylist = Playlist.fromJson(element, allSongs);
      newPlaylists.add(newPlaylist);
    });
    return newPlaylists;
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
  }
}

