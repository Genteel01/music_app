import 'dart:io';
import 'dart:typed_data';

import 'Song.dart';

class Album{
  List<Song> songs;

  String name;
  String albumArtist;
  String year;
  DateTime lastModified;
  String albumArt;
  Album({required this.songs, required this.name, required this.albumArtist, required this.year, required this.lastModified, required this.albumArt});

  void updateAlbum(String newYear, Uint8List? newAlbumArt, DateTime newLastModified, String directoryPath)
  {
    try
      {
        File(directoryPath + "/albumart/" + name.replaceAll("/", "_") + albumArtist.replaceAll("/", "_") + year.replaceAll("/", "_")).delete();
        if(newAlbumArt != null)
          {
            File(directoryPath + "/albumart/" + name.replaceAll("/", "_") + albumArtist.replaceAll("/", "_") + year.replaceAll("/", "_")).writeAsBytes(newAlbumArt);
            albumArt = directoryPath + "/albumart/" + name.replaceAll("/", "_") + albumArtist.replaceAll("/", "_") + year.replaceAll("/", "_");
          }
      }
    catch(error){}
    year = newYear;
    lastModified = newLastModified;
  }
  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'albumArtist': albumArtist,
        'year': year,
        'lastModified' : lastModified.millisecondsSinceEpoch,
        'albumArt' : albumArt
        //'albumArt': albumArt,
      };

  Album.fromJson(Map<String, dynamic> json, String directoryPath)
      :
        name = json['name'],
        albumArtist = json['albumArtist'],
        year = json['year'],
        albumArt = json['albumArt'],
        songs = [],
        lastModified = DateTime.fromMillisecondsSinceEpoch(json['lastModified']);

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
    });
    return newAlbums;
  }
}