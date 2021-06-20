import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'Song.dart';

class Album{
  List<Song> songs;

  Uint8List? albumArt;
  String name;
  String albumArtist;
  String year;
  DateTime lastModified;
  Album({required this.songs, required this.name, required this.albumArtist, this.albumArt, required this.year, required this.lastModified});

  void updateAlbum(String newYear, Uint8List? newAlbumArt, DateTime newLastModified)
  {
    year = newYear;
    albumArt = newAlbumArt;
    lastModified = newLastModified;
  }
  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'albumArtist': albumArtist,
        'year': year,
        'lastModified' : lastModified.millisecondsSinceEpoch,
        //'albumArt': albumArt,
      };

  Album.fromJson(Map<String, dynamic> json, String directoryPath)
      :
        name = json['name'],
        albumArtist = json['albumArtist'],
        year = json['year'],
        songs = [],
        albumArt = File(directoryPath + "/albumart" + json['name'].replaceAll("/", "_") + json['albumArtist'].replaceAll("/", "_") + json['year'].replaceAll("/", "_")).existsSync() ? File(directoryPath + "/albumart" + json['name'].replaceAll("/", "_") + json['albumArtist'].replaceAll("/", "_") + json['year'].replaceAll("/", "_")).readAsBytesSync() : null,
        lastModified = DateTime.fromMillisecondsSinceEpoch(json['lastModified']);

  /*static Uint8List? convertImage(List<dynamic>? source)
  {
    if(source == null)
      {
        return null;
      }
    List<int> list = source.cast();
    //List<int> list = utf8.encode(source[0].toString());
    Uint8List bytes = Uint8List.fromList(list);
    return bytes;
  }*/
  //Function to turn a json file of several albums into a list of albums
  static List<Album> loadAlbumFile(List<dynamic> data, String directoryPath)
  {
      List<Album> newAlbums = List<Album>.empty(growable: true);
      data.forEach((element) {
        newAlbums.add(Album.fromJson(element, directoryPath));
      });
      return newAlbums;
  }
  //Function to turn a list of albums into a json file to be saved
  static List<Map<String, dynamic>> saveAlbumFile(List<Album> albumList, String directoryPath)
  {
    List<Map<String, dynamic>> newAlbums = List<Map<String, dynamic>>.empty(growable: true);
    albumList.forEach((element) {
      newAlbums.add(element.toJson());
      if(element.albumArt != null)
        {
          File(directoryPath + "/albumart" + element.name.replaceAll("/", "_") + element.albumArtist.replaceAll("/", "_") + element.year.replaceAll("/", "_")).writeAsBytesSync(element.albumArt!);
        }
    });
    return newAlbums;
  }
}