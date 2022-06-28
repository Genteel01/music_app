
import 'Album.dart';
import 'Song.dart';


class Artist{
  List<Song> songs;
  String name;
  List<Album> albums;

  Artist({required this.songs, required this.name, required this.albums});

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'songs' : Song.songListToIdList(songs),
        'albums' : Album.albumListToIdList(albums)
      };

  Artist.fromJson(Map<String, dynamic> json, List<Song> allSongs, List<Album> allAlbums)
      :
        name = json['name'],
        songs = Song.idListToSongList(json['songs'].cast<String>(), allSongs),
        albums = Album.idListToAlbumList(json['albums'].cast<String>(), allAlbums);

  //Function to turn a json file of several artists into a list of artists
  static List<Artist> loadArtistFile(List<dynamic> data, List<Song> allSongs, List<Album> allAlbums)
  {
    List<Artist> newArtists = List<Artist>.empty(growable: true);
    data.forEach((element) {
      newArtists.add(Artist.fromJson(element, allSongs, allAlbums));
    });
    return newArtists;
  }

  //Function to turn a list of artists into a json file to be saved
  static List<Map<String, dynamic>> saveArtistFile(List<Artist> artistList)
  {
    List<Map<String, dynamic>> newArtists = List<Map<String, dynamic>>.empty(growable: true);
    artistList.forEach((element) {
      newArtists.add(element.toJson());
    });
    return newArtists;
  }
}

