
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
      };

  Artist.fromJson(Map<String, dynamic> json)
      :
        name = json['name'],
        songs = [],
        albums = [];

  //Function to turn a json file of several artists into a list of artists
  static List<Artist> loadArtistFile(List<dynamic> data)
  {
    List<Artist> newArtists = List<Artist>.empty(growable: true);
    data.forEach((element) {
      newArtists.add(Artist.fromJson(element));
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

