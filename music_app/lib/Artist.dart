
import 'Song.dart';


class Artist{
  List<Song> songs;
  String name;

  Artist({required this.songs, required this.name});

  Map<String, dynamic> toJson() =>
      {
        'name': name,
      };

  Artist.fromJson(Map<String, dynamic> json)
      :
        name = json['name'],
        songs = [];

  //Function to turn a json file of several artists into a list of artists
  static List<Artist> loadArtistFile(List<dynamic> data)
  {
    List<Artist> newAlbums = List<Artist>.empty(growable: true);
    data.forEach((element) {
      newAlbums.add(Artist.fromJson(element));
    });
    return newAlbums;
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

