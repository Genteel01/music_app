import 'dart:convert';
import 'dart:typed_data';

import 'Song.dart';

class Album{
  List<Song> songs;

  Uint8List? albumArt;
  String name;
  String albumArtist;
  String year;
  Album({required this.songs, required this.name, required this.albumArtist, this.albumArt, required this.year});

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'albumArtist': albumArtist,
        'year': year,
        'albumArt': albumArt,
      };

  Album.fromJson(Map<String, dynamic> json)
      :
        name = json['name'],
        albumArtist = json['albumArtist'],
        year = json['year'],
        songs = [],
        albumArt = convertImage(json['albumArt']);

  static Uint8List? convertImage(List<dynamic>? source)
  {
    if(source == null)
      {
        return null;
      }
    List<int> list = source.cast();
    //List<int> list = utf8.encode(source[0].toString());
    Uint8List bytes = Uint8List.fromList(list);
    return bytes;
  }
  //Function to turn a json file of several albums into a list of albums
  static List<Album> loadAlbumFile(List<dynamic> data)
  {
      List<Album> newAlbums = List<Album>.empty(growable: true);
      data.forEach((element) {
        newAlbums.add(Album.fromJson(element));
      });
      return newAlbums;
  }
  //Function to turn a list of albums into a json file to be saved
  static List<Map<String, dynamic>> saveAlbumFile(List<Album> albumList)
  {
    List<Map<String, dynamic>> newAlbums = List<Map<String, dynamic>>.empty(growable: true);
    albumList.forEach((element) {
      newAlbums.add(element.toJson());
    });
    return newAlbums;
  }
}